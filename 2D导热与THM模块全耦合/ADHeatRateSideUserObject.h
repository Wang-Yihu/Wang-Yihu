#pragma once

#include "SideUserObject.h"

class ADHeatRateSideUserObject : public SideUserObject
{
public:
  static InputParameters validParams();

  ADHeatRateSideUserObject(const InputParameters & parameters);

  virtual void initialize() override;
  virtual void execute() override;
  virtual void threadJoin(const UserObject & y) override;
  virtual void finalize() override;

  ADReal heatRate() const { return _heat_rate; }

protected:
  const ADVariableValue & _T;
  const ADVariableValue & _T_wall;
  const ADMaterialProperty<Real> & _htc;

  const Real & _scale;

  ADReal _heat_rate;
};
