#include "ADOneDEnergyFromHeatRateUO.h"

registerMooseObject("asnerdihp_fullApp", ADOneDEnergyFromHeatRateUO);

InputParameters
ADOneDEnergyFromHeatRateUO::validParams()
{
  InputParameters params = ADKernel::validParams();

  params.addRequiredParam<UserObjectName>(
      "heat_rate_userobject",
      "ADHeatRateSideUserObject that supplies the boundary-integrated heat rate.");

  params.addRequiredParam<Real>(
      "channel_length",
      "Length of the 1-D flow channel over which the total heat rate is distributed.");

  params.addClassDescription(
      "Adds a boundary-integrated AD heat rate uniformly to a 1-D THM energy equation.");

  return params;
}

ADOneDEnergyFromHeatRateUO::ADOneDEnergyFromHeatRateUO(
    const InputParameters & parameters)
  : ADKernel(parameters),
    _heat_rate_uo(
        getUserObject<ADHeatRateSideUserObject>("heat_rate_userobject")),
    _channel_length(getParam<Real>("channel_length"))
{
  if (_channel_length <= 0.0)
    paramError("channel_length", "The channel length must be greater than zero.");
}

ADReal
ADOneDEnergyFromHeatRateUO::computeQpResidual()
{
  const ADReal q_line = _heat_rate_uo.heatRate() / _channel_length;

  // Positive boundary heat rate means heat entering the THM fluid.
  return -q_line * _test[_i][_qp];
}
