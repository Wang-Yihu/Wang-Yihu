#pragma once

#include "ADKernel.h"

class ADMassFlowRateBalance : public ADKernel
{
public:
  static InputParameters validParams();

  ADMassFlowRateBalance(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// 二者只能指定一个
  const ADVariableValue * const _mass_source_variable;
  const ADMaterialProperty<Real> * const _mass_source_material;
};
