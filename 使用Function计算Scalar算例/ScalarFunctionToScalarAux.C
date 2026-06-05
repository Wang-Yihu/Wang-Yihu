//* This file is part of the MOOSE framework
#include "ScalarFunctionToScalarAux.h"
#include "Function.h"

registerMooseObject("asnerdihp_extestApp", ScalarFunctionToScalarAux);

InputParameters
ScalarFunctionToScalarAux::validParams()
{
  InputParameters params = AuxScalarKernel::validParams();
  params.addClassDescription("Input a scalar variable and a function then get an output aux scalar.");
  params.addCoupledVar("input_scalar", "input scalar");
  params.addParam<FunctionName>("input_function","" ,"input function");
  return params;
}

ScalarFunctionToScalarAux::ScalarFunctionToScalarAux(const InputParameters & parameters)
  : AuxScalarKernel(parameters), _input_scalar(coupledScalarValue("input_scalar")), _input_function(&getFunction("input_function"))
{
}

Real
ScalarFunctionToScalarAux::computeValue()
{
  return _input_function->value(_input_scalar[_i]);
}
