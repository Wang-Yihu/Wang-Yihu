#pragma once

#include "ADKernel.h"

/**
 * Schrage interface mass-transfer relation:
 *
 * gamma_m / (pi * D_v)
 *   - 2*phi/(2-phi) * sqrt(M/(2*pi*R_u))
 *     * (p_i/sqrt(T_i) - p_v/sqrt(T_v)) = 0
 *
 * The primary variable is gamma_m = d(m_dot)/dx,
 * with units kg/(m s).
 */
class ADSchrageMassTransferConstraint : public ADKernel
{
public:
  static InputParameters validParams();

  ADSchrageMassTransferConstraint(
      const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// Vapor pressure p_v, Pa
  const ADVariableValue & _vapor_pressure;

  /// Vapor temperature T_v, K
  const ADVariableValue & _vapor_temperature;

  /// Interface temperature T_i, K
  const ADVariableValue & _interface_temperature;

  /// Interface saturation pressure p_i = p_sat(T_i), Pa
  const ADMaterialProperty<Real> & _interface_pressure;

  /// Vapor/interface diameter, m
  const Real _diameter;

  /// Numerical value of pi
  const Real _pi;

  /**
   * Schrage coefficient:
   *
   * 2*phi/(2-phi) * sqrt(M/(2*pi*R_u))
   */
  const Real _schrage_coefficient;
};
