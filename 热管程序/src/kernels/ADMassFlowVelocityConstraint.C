#include "ADMassFlowVelocityConstraint.h"
#include <cmath>
// Replace HeatPipeApp with the registered name of your own MOOSE application.
registerMooseObject("asnerdihp_tianApp", ADMassFlowVelocityConstraint);
InputParameters
ADMassFlowVelocityConstraint::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription(
      "Enforces u = m_dot/(rho*A) for a one-dimensional heat-pipe vapor core.");
  params.addRequiredCoupledVar("mass_flow_rate", "Axial vapor mass flow rate in kg/s");
  params.addRequiredParam<MaterialPropertyName>(
      "density", "Name of the AD saturated-vapor density property in kg/m^3");
  params.addRequiredRangeCheckedParam<Real>(
      "diameter", "diameter > 0", "Vapor-core diameter in m");
  return params;
}
ADMassFlowVelocityConstraint::ADMassFlowVelocityConstraint(const InputParameters & parameters)
  : ADKernel(parameters),
    _mass_flow_rate(adCoupledValue("mass_flow_rate")),
    _density(getADMaterialProperty<Real>(getParam<MaterialPropertyName>("density"))),
    _area(0.25 * std::acos(-1.0) * getParam<Real>("diameter") * getParam<Real>("diameter"))
{
}
ADReal
ADMassFlowVelocityConstraint::computeQpResidual()
{
  return _test[_i][_qp] *
         (_u[_qp] - _mass_flow_rate[_qp] / (_density[_qp] * _area));
}
