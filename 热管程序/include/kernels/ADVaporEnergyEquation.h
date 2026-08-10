#pragma once

#include "ADKernel.h"

/**
 * Vapor energy equation:
 *
 * d/dx [rho_v * u_v * A_v *
 *       (h_v + beta * u_v^2 / 2)]
 *
 *   = Gamma_m * h_upwind
 *
 * where
 *
 * h_upwind = h_v_i, Gamma_m >= 0 (evaporation)
 * h_upwind = h_v,   Gamma_m <  0 (condensation)
 *
 * The radial kinetic energy carried by the interfacial mass source
 * is neglected in this simplified model.
 */
class ADVaporEnergyEquation : public ADKernel
{
public:
  static InputParameters validParams();

  ADVaporEnergyEquation(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// Axial vapor velocity u_v
  const ADVariableValue & _velocity;

  /// Vapor density rho_v
  const ADMaterialProperty<Real> & _density;

  /// Vapor specific enthalpy h_v
  const ADMaterialProperty<Real> & _vapor_enthalpy;

  /// Vapor-side interface specific enthalpy h_v_i
  const ADMaterialProperty<Real> & _interface_enthalpy;

  /**
   * Gamma_m may be supplied by either:
   *
   * 1. a coupled Variable;
   * 2. an AD MaterialProperty.
   *
   * Exactly one of the following pointers is non-null.
   */
  const ADVariableValue * const _mass_source_variable;
  const ADMaterialProperty<Real> * const _mass_source_material;

  /// Vapor-core diameter D_v
  const Real _diameter;

  /// Vapor-core cross-sectional area A_v
  const Real _area;

  /// Kinetic-energy correction factor beta
  const Real _energy_correction;
};
