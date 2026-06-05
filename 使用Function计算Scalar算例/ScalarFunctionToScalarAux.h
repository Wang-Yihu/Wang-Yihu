#pragma once

#include "AuxScalarKernel.h"

class ScalarFunctionToScalarAux : public AuxScalarKernel
{
public:
  static InputParameters validParams();

 ScalarFunctionToScalarAux(const InputParameters & parameters);

protected:
  const Function * const _input_function;
  const VariableValue & _input_scalar;
  virtual Real computeValue() override;

};
