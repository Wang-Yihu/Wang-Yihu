#include "ADNaVaporDensity.h"

registerMooseObject("asnerdihp_tian", ADNaVaporDensity);

InputParameters
ADNaVaporDensity::validParams()
{
  InputParameters params = ADMaterial::validParams();

  params.addClassDescription(
      "Calculates sodium-vapor density from pressure and temperature "
      "using rho = rho_sat(T) * p / p_sat(T).");

  params.addRequiredCoupledVar(
      "temperature", "Vapor temperature variable, K");

  params.addRequiredCoupledVar(
      "pressure", "Vapor pressure variable, Pa");

  params.addRequiredParam<FunctionName>(
      "saturation_pressure_function",
      "Function defining sodium saturation pressure in Pa");

  params.addRequiredParam<FunctionName>(
      "saturated_density_function",
      "Function defining saturated sodium-vapor density in kg/m^3");

  params.addParam<MaterialPropertyName>(
      "density_name",
      "rho_v",
      "Name of the calculated vapor-density material property");

  return params;
}

ADNaVaporDensity::ADNaVaporDensity(
    const InputParameters & parameters)
  : ADMaterial(parameters),
    _temperature(adCoupledValue("temperature")),
    _pressure(adCoupledValue("pressure")),
    _p_sat_function(
        getFunction("saturation_pressure_function")),
    _rho_sat_function(
        getFunction("saturated_density_function")),
    _density(
        declareADProperty<Real>(
            getParam<MaterialPropertyName>("density_name")))
{
}

void
ADNaVaporDensity::computeQpProperties()
{
  const ADReal & T_ad = _temperature[_qp];
  const Real T = MetaPhysicL::raw_value(T_ad);

  /*
   * PiecewiseLinear functions use their first argument as the
   * interpolation coordinate when axis is not specified.
   * Here, temperature is deliberately passed as that argument.
   */
  const Real p_sat_value =
      _p_sat_function.value(T, _q_point[_qp]);

  const Real rho_sat_value =
      _rho_sat_function.value(T, _q_point[_qp]);

  /*
   * Slopes of the two piecewise-linear functions.
   * They are needed to retain the AD derivatives with respect to T.
   */
  const Real dp_sat_dT =
      _p_sat_function.timeDerivative(T, _q_point[_qp]);

  const Real drho_sat_dT =
      _rho_sat_function.timeDerivative(T, _q_point[_qp]);

  /*
   * Lift the Real interpolation results back to ADReal.
   * Their numerical values remain unchanged, while the derivatives
   * with respect to the nonlinear temperature variable are retained.
   */
   
  /*When calculate derivative, product rule for the derivative:
    0 * (Real_2-Real_3) + Real_1 * (dT/dU-0) = Real_1*dT/dU
    We want ADReal p_sat_ad:
    value part: p_sat for the (T, _q_point[_qp])
    derivative part: d(p_sat)/dT * dT/dU, U is various nonlinear variables.
  */  
  ///                     #(Real,0)     (Real_1,0)  (Real_2,dT/dU) (Real_3,0)
  const ADReal p_sat_ad = p_sat_value + dp_sat_dT * (T_ad         - T);

  /*
   We want ADReal rho_sat_ad:
   value part: rho_sat for the (T, _q_point[_qp])
   derivative part: d(rho_sat)/dT * dT/dU, U is various nonlinear variables.
  */
  const ADReal rho_sat_ad = rho_sat_value + drho_sat_dT * (T_ad - T);

  if (p_sat_value <= 0.0)
    mooseError("The evaluated saturation pressure must be positive.");

  if (rho_sat_value <= 0.0)
    mooseError("The evaluated saturated vapor density must be positive.");
  /*
  We want to get rho_v varying with T and p  
  So we assume the correction factor of ideal gas from saturation to overheat keeping constant.
  Z_sat(T) = p_sat(T)*M/rho_sat(T)/R_u/T
  rho(T,p) = p*M/Z_sat(T)/R_u/T
  So: rho(T,p) = rho_sat(T) * p / p_sat(T)
  */
  _density[_qp] =
      rho_sat_ad * _pressure[_qp] / p_sat_ad;
}
