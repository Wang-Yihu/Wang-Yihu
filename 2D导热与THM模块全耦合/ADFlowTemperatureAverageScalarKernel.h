#pragma once

#include "ADScalarKernel.h"
#include "ADFlowTemperatureAverageUserObject.h"

/**
 * Enforces a scalar variable to equal the globally averaged flow-channel
 * temperature computed by ADFlowTemperatureAverageUserObject.
 *
 * Residual:
 *
 *   R_i = T_scalar,i - T_flow_average
 *
 * For a FIRST-order scalar variable, there is one scalar degree of freedom:
 *
 *   T_scalar = T_flow_average
 */
class ADFlowTemperatureAverageScalarKernel : public ADScalarKernel
{
public:
  static InputParameters validParams();

  ADFlowTemperatureAverageScalarKernel(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// UserObject that computes the AD flow-temperature average
  const ADFlowTemperatureAverageUserObject & _temperature_average_uo;
};
