#pragma once

#include "ADKernel.h"

/**
 * Steady one-dimensional vapor momentum equation for constant area:
 *
 *   d(rho alpha v^2 A)/dx + A dp/dx
 *     + f rho v^2 A/(2D) = 0,
 *
 * with f = 64/Re.  The friction term is evaluated in the nonsingular,
 * algebraically equivalent form 32 mu v A/D^2.
 *
 * This Kernel acts on pressure. The dynamic-momentum-flux derivative is
 * integrated by parts. Its consistent boundary contribution is supplied by
 * the companion ADVaporMomentumFluxBC object.
 */
class ADVaporMomentumEquation : public ADKernel
{
public:
  static InputParameters validParams();

  ADVaporMomentumEquation(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// Axial vapor velocity, m/s
  const ADVariableValue & _velocity;

  /// Vapor density, kg/m^3
  const ADMaterialProperty<Real> & _density;

  /// Vapor dynamic viscosity, Pa s
  const ADMaterialProperty<Real> & _dynamic_viscosity;

  /// Momentum correction factor
  const ADMaterialProperty<Real> & _alpha;

  /// Vapor-core diameter, m
  const Real _diameter;

  /// Vapor-core cross-sectional area, m^2
  const Real _area;
};
