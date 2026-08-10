#pragma once

#include "ADKernel.h"

/**
 * Enforces the integrated steady continuity relation
 *
 *   u - m_dot / (rho A) = 0,
 *
 * where A = pi D^2 / 4.
 *
 * The mass-flow-rate field may be either an AuxVariable (prescribed stage)
 * or a nonlinear Variable (future fully coupled stage).
 */
class ADMassFlowVelocityConstraint : public ADKernel
{
public:
  static InputParameters validParams();

  ADMassFlowVelocityConstraint(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// Axial vapor mass flow rate, kg/s
  const ADVariableValue & _mass_flow_rate;

  /// Vapor density as a function of pressure and temperature, kg/m^3
  const ADMaterialProperty<Real> & _density;

  /// Vapor-core cross-sectional area, m^2
  const Real _area;
};
