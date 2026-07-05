#pragma once

#include "AuxScalarKernel.h"

class CalTwalle : public AuxScalarKernel
{
public:
  static InputParameters validParams();

CalTwalle(const InputParameters & parameters);

protected:
  //const ADVariableValue & _Q_in;
  const VariableValue & _Q_in;
  //const ADVariableValue & _T_p_e;
  const VariableValue & _T_p_e;
  const Function * const _k_p;
  virtual Real computeValue() override;

private:
  Real _d_p;
  Real _d_w;
  Real _L_e;


};
