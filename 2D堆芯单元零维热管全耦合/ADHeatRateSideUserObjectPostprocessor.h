#pragma once

#include "GeneralPostprocessor.h"

class ADHeatRateSideUserObject;

class ADHeatRateSideUserObjectPostprocessor : public GeneralPostprocessor
{
public:
  static InputParameters validParams();

  ADHeatRateSideUserObjectPostprocessor(const InputParameters & parameters);

  virtual void initialize() override {}
  virtual void execute() override {}
  virtual Real getValue() const override;

protected:
  const ADHeatRateSideUserObject & _heat_rate_uo;
};
