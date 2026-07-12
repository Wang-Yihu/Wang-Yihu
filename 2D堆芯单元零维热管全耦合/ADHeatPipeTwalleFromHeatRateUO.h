#pragma once

#include "ADScalarKernel.h"
#include "ADHeatRateSideUserObject.h"
#include "Function.h"

/**
 * Scalar equation for T_walle, with Q_in obtained directly from
 * ADHeatRateSideUserObject.
 *
 * Residual:
 *
 *   Q_in - 2*pi*k_p(T_p_e)*L_e*(T_walle - T_p_e)
 *          / log(d_p / ((d_p + d_w)/2)) = 0
 *
 * where
 *
 *   Q_in = ADHeatRateSideUserObject::heatRate()
 */
class ADHeatPipeTwalleFromHeatRateUO : public ADScalarKernel
{
public:
  static InputParameters validParams();

  ADHeatPipeTwalleFromHeatRateUO(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// Heat pipe clad temperature in evaporation section
  const ADVariableValue & _T_p_e;

  /// UserObject that provides Q_in as an ADReal boundary heat rate
  const ADHeatRateSideUserObject & _heat_rate_uo;

  /// Thermal conductivity function of heat pipe clad
  const Function * const _k_p;

private:
  Real _L_e;
  Real _d_p;
  Real _d_w;
};
