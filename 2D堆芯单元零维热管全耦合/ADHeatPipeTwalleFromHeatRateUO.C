#include "ADHeatPipeTwalleFromHeatRateUO.h"

registerMooseObject("asnerdihp_fullApp", ADHeatPipeTwalleFromHeatRateUO);

InputParameters
ADHeatPipeTwalleFromHeatRateUO::validParams()
{
  InputParameters params = ADScalarKernel::validParams();

  params.addParam<Real>("d_p", 0.019, "heat pipe clad diameter");
  params.addParam<Real>("d_w", 0.017, "heat pipe wick diameter");
  params.addParam<Real>("L_e", 1.55, "evaporation sector length");

  params.addCoupledVar("T_p_e", 900, "temperature in heat pipe clad, evaporation section");

  params.addRequiredParam<UserObjectName>(
      "heat_rate_userobject",
      "ADHeatRateSideUserObject that provides Q_in as the integrated boundary heat rate");

  params.addParam<FunctionName>(
      "k_p",
      24.83819,
      "function of heat conductivity coefficient of heat pipe clad with temperature");

  return params;
}

ADHeatPipeTwalleFromHeatRateUO::ADHeatPipeTwalleFromHeatRateUO(
    const InputParameters & parameters)
  : ADScalarKernel(parameters),

    _T_p_e(adCoupledScalarValue("T_p_e")),
    _heat_rate_uo(getUserObject<ADHeatRateSideUserObject>("heat_rate_userobject")),
    _k_p(&getFunction("k_p")),

    _L_e(getParam<Real>("L_e")),
    _d_p(getParam<Real>("d_p")),
    _d_w(getParam<Real>("d_w"))
{
}

ADReal
ADHeatPipeTwalleFromHeatRateUO::computeQpResidual()
{
  const Real pi = 3.1415926535897932384626433;

  const auto & T_walle = _u;

  /*
   * Q_in is not a coupled scalar variable here.
   * It is directly provided by ADHeatRateSideUserObject and remains ADReal.
   */
  const ADReal & Q_in = _heat_rate_uo.heatRate();

  return Q_in -
         2.0 * pi * _k_p->value(_T_p_e[_i]) * _L_e *
             (T_walle[_i] - _T_p_e[_i]) /
             std::log(_d_p / ((_d_p + _d_w) / 2.0));
}
