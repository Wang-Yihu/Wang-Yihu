#include "ADVaporMomentumEquation.h"

#include <cmath>

// Replace HeatPipeApp with the registered name of your own MOOSE application.
registerMooseObject("asnerdihp_tianApp", ADVaporMomentumEquation);

InputParameters
ADVaporMomentumEquation::validParams()
{
  InputParameters params = ADKernel::validParams();

  params.addClassDescription(
      "Steady 1-D vapor momentum equation with Tian et al.'s alpha correction and f=64/Re.");

  params.addRequiredCoupledVar("velocity", "Axial vapor velocity in m/s");
  params.addRequiredParam<MaterialPropertyName>("density", "Vapor density property");
  params.addRequiredParam<MaterialPropertyName>(
      "dynamic_viscosity", "Vapor dynamic viscosity property");
  params.addRequiredParam<MaterialPropertyName>(
      "momentum_correction", "Momentum correction factor alpha property");
  params.addRequiredRangeCheckedParam<Real>(
      "diameter", "diameter > 0", "Vapor-core diameter in m");

  return params;
}

ADVaporMomentumEquation::ADVaporMomentumEquation(const InputParameters & parameters)
  : ADKernel(parameters),
    _velocity(adCoupledValue("velocity")),
    _density(getADMaterialProperty<Real>(getParam<MaterialPropertyName>("density"))),
    _dynamic_viscosity(
        getADMaterialProperty<Real>(getParam<MaterialPropertyName>("dynamic_viscosity"))),
    _alpha(getADMaterialProperty<Real>(getParam<MaterialPropertyName>("momentum_correction"))),
    _diameter(getParam<Real>("diameter")),
    _area(0.25 * std::acos(-1.0) * _diameter * _diameter)
{
}

ADReal
ADVaporMomentumEquation::computeQpResidual()
{
  // Here the Kernel's primary variable (_u) is pressure p.
  const ADReal dynamic_momentum_flux =
      _density[_qp] * _alpha[_qp] * _velocity[_qp] * _velocity[_qp] * _area;

  // f=64/Re removes the apparent 0/0 singularity at velocity=0:
  // f*rho*v^2*A/(2D) = 32*mu*v*A/D^2.
  const ADReal wall_friction_per_length =
      32.0 * _dynamic_viscosity[_qp] * _velocity[_qp] * _area /
      (_diameter * _diameter);

  return -_grad_test[_i][_qp](0) * dynamic_momentum_flux +
         _test[_i][_qp] * _area * _grad_u[_qp](0) +
         _test[_i][_qp] * wall_friction_per_length;
}
