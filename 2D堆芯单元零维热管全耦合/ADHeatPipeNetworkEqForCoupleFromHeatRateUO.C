#include "ADHeatPipeNetworkEqForCoupleFromHeatRateUO.h"

#include "Function.h"

registerMooseObject("asnerdihp_fullApp", ADHeatPipeNetworkEqForCoupleFromHeatRateUO);

InputParameters
ADHeatPipeNetworkEqForCoupleFromHeatRateUO::validParams()
{
  InputParameters params = ADScalarKernel::validParams();

  params.addParam<Real>("d_p", 0.019, "heat pipe clad diameter");
  params.addParam<Real>("d_w", 0.017, "heat pipe wick diameter");
  params.addParam<Real>("d_v", 0.015, "heat pipe vapor diameter");
  params.addParam<Real>("T_f", 563 + 273.15, "cooling temperature of condenser sector");
  params.addParam<Real>("M", 0.023, "molar mass");
  params.addParam<Real>("h_c", 254, "convective heat transfer coefficient of condenser sector");
  params.addParam<Real>("epsilon", 0.84, "porosity of wick structure");
  params.addParam<Real>("L_e", 1.55, "evaporation sector length");
  params.addParam<Real>("L_i", 0.45, "heat insulation sector length");
  params.addParam<Real>("L_c", 2.0, "condensation sector length");

  params.addParam<int>("equation", "number of the equation");

  params.addCoupledVar("T_p_e", 900, "temperature in (p, e)");
  params.addCoupledVar("T_p_i", 900, "temperature in (p, i)");
  params.addCoupledVar("T_p_c", 900, "temperature in (p, c)");
  params.addCoupledVar("T_w_e", 900, "temperature in (w, e)");
  params.addCoupledVar("T_w_i", 900, "temperature in (w, i)");
  params.addCoupledVar("T_w_c", 900, "temperature in (w, c)");
  params.addCoupledVar("T_v_e", 900, "temperature in (v, e)");
  params.addCoupledVar("T_v_i", 900, "temperature in (v, i)");
  params.addCoupledVar("T_v_c", 900, "temperature in (v, c)");
  params.addCoupledVar("T_wallc", 900, "temperature of condenser sector wall");

  params.addRequiredParam<UserObjectName>(
      "heat_rate_userobject",
      "ADHeatRateSideUserObject that provides Q_in as the integrated boundary heat rate");

  params.addParam<FunctionName>("k_p",
                                24.83819,
                                "function of heat conductivity coefficient of heat pipe clad");
  params.addParam<FunctionName>("k_l",
                                58.341242,
                                "function of heat conductivity coefficient of liquid coolant");
  params.addParam<FunctionName>("hfg",
                                4112000,
                                "function of latent heat of vaporization");
  params.addParam<FunctionName>("p_v",
                                4740.0,
                                "function of saturation pressure");
  params.addParam<FunctionName>("miu_v",
                                1.6884e-05,
                                "function of viscosity gas coolant");
  params.addParam<FunctionName>("rho_v",
                                0.017,
                                "function of density gas coolant");

  return params;
}

ADHeatPipeNetworkEqForCoupleFromHeatRateUO::ADHeatPipeNetworkEqForCoupleFromHeatRateUO(
    const InputParameters & parameters)
  : ADScalarKernel(parameters),

    _d_p(getParam<Real>("d_p")),
    _d_w(getParam<Real>("d_w")),
    _d_v(getParam<Real>("d_v")),
    _T_f(getParam<Real>("T_f")),
    _M(getParam<Real>("M")),
    _h_c(getParam<Real>("h_c")),
    _epsilon(getParam<Real>("epsilon")),
    _L_e(getParam<Real>("L_e")),
    _L_i(getParam<Real>("L_i")),
    _L_c(getParam<Real>("L_c")),

    _equation(getParam<int>("equation")),

    _T_p_e(adCoupledScalarValue("T_p_e")),
    _T_p_i(adCoupledScalarValue("T_p_i")),
    _T_p_c(adCoupledScalarValue("T_p_c")),
    _T_w_e(adCoupledScalarValue("T_w_e")),
    _T_w_i(adCoupledScalarValue("T_w_i")),
    _T_w_c(adCoupledScalarValue("T_w_c")),
    _T_v_e(adCoupledScalarValue("T_v_e")),
    _T_v_i(adCoupledScalarValue("T_v_i")),
    _T_v_c(adCoupledScalarValue("T_v_c")),
    _T_wallc(adCoupledScalarValue("T_wallc")),

    _heat_rate_uo(getUserObject<ADHeatRateSideUserObject>("heat_rate_userobject")),

    _k_p(&getFunction("k_p")),
    _k_l(&getFunction("k_l")),
    _hfg(&getFunction("hfg")),
    _p_v(&getFunction("p_v")),
    _miu_v(&getFunction("miu_v")),
    _rho_v(&getFunction("rho_v"))
{
}

ADReal
ADHeatPipeNetworkEqForCoupleFromHeatRateUO::_k_w(ADReal T)
{
  return ((_k_l->value(T) + _k_p->value(T)) -
          (1 - _epsilon) * (_k_l->value(T) - _k_p->value(T))) /
         ((_k_l->value(T) + _k_p->value(T)) +
          (1 - _epsilon) * (_k_l->value(T) - _k_p->value(T))) *
         _k_l->value(T);
}

ADReal
ADHeatPipeNetworkEqForCoupleFromHeatRateUO::computeQpResidual()
{
  Real pi = 3.1415926535897932384626433;
  Real R = 8.31446261815324;
  Real _r_p = _d_p / 2;
  Real _r_w = _d_w / 2;
  Real _r_v = _d_v / 2;

  /*
   * This is the key change:
   * Q_in is no longer a coupled scalar variable.
   * It is directly read from ADHeatRateSideUserObject.
   */
  const ADReal & Q_in = _heat_rate_uo.heatRate();

  ADReal R_p_to_w_e_r =
      std::log((_d_w + _d_p) / 2 / _d_w) / (2 * pi * _k_p->value(_T_p_e[_i]) * _L_e) +
      std::log(_d_w / ((_d_v + _d_w) / 2)) / (2 * pi * _k_w(_T_w_e[_i]) * _L_e);

  ADReal R_p_e_to_i_a =
      (_L_e / 2) / (pi * _k_p->value(_T_p_e[_i]) * (_r_p * _r_p - _r_w * _r_w)) +
      (_L_i / 2) / (pi * _k_p->value(_T_p_i[_i]) * (_r_p * _r_p - _r_w * _r_w));

  ADReal R_p_i_to_c_a =
      (_L_i / 2) / (pi * _k_p->value(_T_p_i[_i]) * (_r_p * _r_p - _r_w * _r_w)) +
      (_L_c / 2) / (pi * _k_p->value(_T_p_c[_i]) * (_r_p * _r_p - _r_w * _r_w));

  ADReal R_w_to_p_c_r =
      std::log((_d_w + _d_p) / 2 / _d_w) / (2 * pi * _k_p->value(_T_p_c[_i]) * _L_c) +
      std::log(_d_w / ((_d_v + _d_w) / 2)) / (2 * pi * _k_w(_T_w_c[_i]) * _L_c);

  ADReal R_w_e_to_i_a =
      (_L_e / 2) / (pi * _k_w(_T_w_e[_i]) * (_r_w * _r_w - _r_v * _r_v)) +
      (_L_i / 2) / (pi * _k_w(_T_w_i[_i]) * (_r_w * _r_w - _r_v * _r_v));

  ADReal R_w_to_v_e_r =
      std::log(((_d_v + _d_w) / 2) / _d_v) / (2 * pi * _k_w(_T_w_e[_i]) * _L_e) +
      std::sqrt(2 * pi * R * _T_v_e[_i]) * R * std::pow(_T_v_e[_i], 2) /
          (std::pow(_hfg->value(_T_v_e[_i]), 2) * _p_v->value(_T_v_e[_i]) * _M *
           std::sqrt(_M) * pi * _d_v * _L_e);

  ADReal R_w_i_to_c_a =
      (_L_i / 2) / (pi * _k_w(_T_w_i[_i]) * (_r_w * _r_w - _r_v * _r_v)) +
      (_L_c / 2) / (pi * _k_w(_T_w_c[_i]) * (_r_w * _r_w - _r_v * _r_v));

  ADReal R_v_to_w_c_r =
      std::sqrt(2 * pi * R * _T_v_c[_i]) * R * std::pow(_T_v_c[_i], 2) /
          (std::pow(_hfg->value(_T_v_c[_i]), 2) * _p_v->value(_T_v_c[_i]) * _M *
           std::sqrt(_M) * pi * _d_v * _L_c) +
      std::log(((_d_w + _d_v) / 2) / _d_v) / (2 * pi * _k_w(_T_w_c[_i]) * _L_c);

  ADReal R_v_e_to_i_a =
      8 * R * std::pow(_T_v_e[_i], 2) * _miu_v->value(_T_v_e[_i]) * (_L_e) / 2 /
          (pi * _rho_v->value(_T_v_e[_i]) * std::pow(_r_v, 4) *
           std::pow(_hfg->value(_T_v_e[_i]), 2) * _p_v->value(_T_v_e[_i]) * _M) +
      8 * R * std::pow(_T_v_i[_i], 2) * _miu_v->value(_T_v_i[_i]) * (_L_i) / 2 /
          (pi * _rho_v->value(_T_v_i[_i]) * std::pow(_r_v, 4) *
           std::pow(_hfg->value(_T_v_i[_i]), 2) * _p_v->value(_T_v_i[_i]) * _M);

  ADReal R_v_i_to_c_a =
      8 * R * std::pow(_T_v_i[_i], 2) * _miu_v->value(_T_v_i[_i]) * (_L_i) / 2 /
          (pi * _rho_v->value(_T_v_i[_i]) * std::pow(_r_v, 4) *
           std::pow(_hfg->value(_T_v_i[_i]), 2) * _p_v->value(_T_v_i[_i]) * _M) +
      8 * R * std::pow(_T_v_c[_i], 2) * _miu_v->value(_T_v_c[_i]) * (_L_c) / 2 /
          (pi * _rho_v->value(_T_v_c[_i]) * std::pow(_r_v, 4) *
           std::pow(_hfg->value(_T_v_c[_i]), 2) * _p_v->value(_T_v_c[_i]) * _M);

  Real A_c = pi * _d_p * _L_c;

  mooseAssert(_equation >= 1 && _equation <= 10, "equation>=1 and <=10 !");

  switch (_equation)
  {
    case 1:
    {
      const auto & _T_p_e = _u;

      return -(Q_in + _T_w_e[_i] / R_p_to_w_e_r - _T_p_e[_i] / R_p_to_w_e_r +
               _T_p_i[_i] / R_p_e_to_i_a - _T_p_e[_i] / R_p_e_to_i_a);
    }

    case 2:
    {
      const auto & _T_p_i = _u;

      return -(_T_p_e[_i] / R_p_e_to_i_a - _T_p_i[_i] / R_p_e_to_i_a +
               _T_p_c[_i] / R_p_i_to_c_a - _T_p_i[_i] / R_p_i_to_c_a);
    }

    case 3:
    {
      const auto & _T_p_c = _u;

      return -(_T_p_i[_i] / R_p_i_to_c_a - _T_p_c[_i] / R_p_i_to_c_a +
               _T_w_c[_i] / R_w_to_p_c_r - _T_p_c[_i] / R_w_to_p_c_r -
               _h_c * A_c * (_T_wallc[_i] - _T_f));
    }

    case 4:
    {
      const auto & _T_wallc = _u;

      return -((_T_p_c[_i] - _T_wallc[_i]) /
                   (std::log(_r_p / ((_r_p + _r_w) / 2)) /
                    (2 * pi * _k_p->value(_T_p_c[_i]) * _L_c)) -
               _h_c * A_c * _T_wallc[_i] + _h_c * A_c * _T_f);
    }

    case 5:
    {
      const auto & _T_w_e = _u;

      return -(_T_p_e[_i] / R_p_to_w_e_r - _T_w_e[_i] / R_p_to_w_e_r +
               _T_w_i[_i] / R_w_e_to_i_a - _T_w_e[_i] / R_w_e_to_i_a +
               _T_v_e[_i] / R_w_to_v_e_r - _T_w_e[_i] / R_w_to_v_e_r);
    }

    case 6:
    {
      const auto & _T_w_i = _u;

      return -(_T_w_e[_i] / R_w_e_to_i_a - _T_w_i[_i] / R_w_e_to_i_a +
               _T_w_c[_i] / R_w_i_to_c_a - _T_w_i[_i] / R_w_i_to_c_a);
    }

    case 7:
    {
      const auto & _T_w_c = _u;

      return -(_T_w_i[_i] / R_w_i_to_c_a - _T_w_c[_i] / R_w_i_to_c_a +
               _T_p_c[_i] / R_w_to_p_c_r - _T_w_c[_i] / R_w_to_p_c_r +
               _T_v_c[_i] / R_v_to_w_c_r - _T_w_c[_i] / R_v_to_w_c_r);
    }

    case 8:
    {
      const auto & _T_v_e = _u;

      return -(_T_w_e[_i] / R_w_to_v_e_r - _T_v_e[_i] / R_w_to_v_e_r +
               _T_v_i[_i] / R_v_e_to_i_a - _T_v_e[_i] / R_v_e_to_i_a);
    }

    case 9:
    {
      const auto & _T_v_i = _u;

      return -(_T_v_e[_i] / R_v_e_to_i_a - _T_v_i[_i] / R_v_e_to_i_a +
               _T_v_c[_i] / R_v_i_to_c_a - _T_v_i[_i] / R_v_i_to_c_a);
    }

    case 10:
    {
      const auto & _T_v_c = _u;

      return -(_T_v_i[_i] / R_v_i_to_c_a - _T_v_c[_i] / R_v_i_to_c_a +
               _T_w_c[_i] / R_v_to_w_c_r - _T_v_c[_i] / R_v_to_w_c_r);
    }

    default:
      mooseError("Invalid equation number: ", _equation);
  }
}
