#include "ADHeatRateSideUserObjectPostprocessor.h"
#include "ADHeatRateSideUserObject.h"

#include "metaphysicl/raw_type.h"

registerMooseObject("asnerdihp_fullApp", ADHeatRateSideUserObjectPostprocessor);

InputParameters
ADHeatRateSideUserObjectPostprocessor::validParams()
{
  InputParameters params = GeneralPostprocessor::validParams();

  params.addRequiredParam<UserObjectName>(
      "heat_rate_userobject",
      "The ADHeatRateSideUserObject whose heat rate will be returned as a Real postprocessor value");

  params.addClassDescription(
      "Reads the raw value of an ADHeatRateSideUserObject heat rate and outputs it as a Real postprocessor.");

  return params;
}

ADHeatRateSideUserObjectPostprocessor::ADHeatRateSideUserObjectPostprocessor(
    const InputParameters & parameters)
  : GeneralPostprocessor(parameters),
    _heat_rate_uo(getUserObject<ADHeatRateSideUserObject>("heat_rate_userobject"))
{
}

Real
ADHeatRateSideUserObjectPostprocessor::getValue() const
{
  return MetaPhysicL::raw_value(_heat_rate_uo.heatRate());
}
