#pragma once

#include "ADKernel.h"
#include "ADHeatRateSideUserObject.h"

/**
 * Adds a boundary-integrated heat rate to a 1-D THM energy equation.
 *
 * The heat rate supplied by ADHeatRateSideUserObject is distributed uniformly
 * over the specified channel length:
 *
 *   q_line = Q_boundary / L_channel  [W/m]
 *
 * The weak residual contribution is
 *
 *   R_i = - integral(test_i * q_line dx)
 *
 * A positive Q_boundary therefore adds energy to the THM flow channel.
 */
class ADOneDEnergyFromHeatRateUO : public ADKernel
{
public:
  static InputParameters validParams();

  ADOneDEnergyFromHeatRateUO(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// Boundary-integrated heat rate, including AD derivative information
  const ADHeatRateSideUserObject & _heat_rate_uo;

  /// Length over which the total heat rate is distributed
  const Real & _channel_length;
};
