#pragma once

#include "SideIntegralPostprocessor.h"

/**
 * Computes the total convective heat transfer across a boundary.
 *
 * Difference from ConvectiveHeatTransferSideIntegral:
 *   T_fluid_var is treated as a scalar variable.
 *
 * Integral:
 *   integral_Gamma h * (T_solid - T_fluid_scalar) dGamma
 */
template <bool is_ad>
class ConvectiveHeatTransferSideIntegralScalarTfTempl : public SideIntegralPostprocessor
{
public:
  static InputParameters validParams();

  ConvectiveHeatTransferSideIntegralScalarTfTempl(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral() override;

  /// Solid wall temperature field variable
  const VariableValue & _T_wall;

  /// Fluid temperature scalar variable
  const VariableValue & _T_fluid_scalar;

  /// Heat transfer coefficient field variable
  const VariableValue * const _hw;

  /// Heat transfer coefficient material property
  const GenericMaterialProperty<Real, is_ad> * const _hw_mat;
  
  const Real _scale;
};

typedef ConvectiveHeatTransferSideIntegralScalarTfTempl<false>
    ConvectiveHeatTransferSideIntegralScalarTf;

typedef ConvectiveHeatTransferSideIntegralScalarTfTempl<true>
    ADConvectiveHeatTransferSideIntegralScalarTf;
