#include "ADFlowTemperatureAverageScalarKernel.h"

registerMooseObject("asnerdihp_fullApp",
                    ADFlowTemperatureAverageScalarKernel);

InputParameters
ADFlowTemperatureAverageScalarKernel::validParams()
{
  InputParameters params = ADScalarKernel::validParams();

  params.addRequiredParam<UserObjectName>(
      "temperature_average_userobject",
      "Name of the ADFlowTemperatureAverageUserObject that computes the "
      "globally averaged flow-channel temperature.");

  params.addClassDescription(
      "Constrains a scalar variable to equal the AD flow-temperature average "
      "computed by ADFlowTemperatureAverageUserObject.");

  return params;
}

ADFlowTemperatureAverageScalarKernel::
    ADFlowTemperatureAverageScalarKernel(
        const InputParameters & parameters)
  : ADScalarKernel(parameters),
    _temperature_average_uo(
        getUserObject<ADFlowTemperatureAverageUserObject>(
            "temperature_average_userobject"))
{
}

ADReal
ADFlowTemperatureAverageScalarKernel::computeQpResidual()
{
  return _u[_i] -
         _temperature_average_uo.averageTemperature();
}
