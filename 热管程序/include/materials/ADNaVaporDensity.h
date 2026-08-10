#pragma once

#include "ADMaterial.h"
#include "Function.h"

class ADNaVaporDensity : public ADMaterial
{
public:
  static InputParameters validParams();

  ADNaVaporDensity(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Nonlinear temperature variable, K
  const ADVariableValue & _temperature;

  /// Nonlinear vapor-pressure variable, Pa
  const ADVariableValue & _pressure;

  /// Saturation pressure p_sat(T), Pa
  const Function & _p_sat_function;

  /// Saturated vapor density rho_sat(T), kg/m^3
  const Function & _rho_sat_function;

  /// Calculated vapor density, kg/m^3
  ADMaterialProperty<Real> & _density;
};
