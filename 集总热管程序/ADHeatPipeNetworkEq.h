// https://mooseframework.inl.gov/bison/source/materials/SS316Thermal.html
//IAEA–TECDOC–XXXX Sodium Coolant Handbook: Physical and Chemical Properties 
// IAEA PROJECT ON SODIUM PROPERTIES AND SAFE OPERATION OF EXPERIMENTAL FACILITIES IN SUPPORT OF THE DEVELOPMENT AND DEPLOYMENT OF SODIUM–COOLED FAST REACTORS (NAPRO)
#pragma once

#include "ADScalarKernel.h"

class ADHeatPipeNetworkEq : public ADScalarKernel

{
public:
  /**
   * Constructor
   */
  ADHeatPipeNetworkEq(const InputParameters & parameters);

  /**
   * validParams returns the parameters that this Kernel accepts / needs
   * The actual body of the function MUST be in the .C file.
   */
  static InputParameters validParams();

protected:
  /**
   * Responsible for computing the residual
   */
  virtual ADReal computeQpResidual() override;

  ADReal _k_w(ADReal T);

  /**
   * Coupled scalar variable values
   */
  const ADVariableValue & _T_p_e;
  const ADVariableValue & _T_p_i;
  const ADVariableValue & _T_p_c;
  const ADVariableValue & _T_w_e;
  const ADVariableValue & _T_w_i;
  const ADVariableValue & _T_w_c;
  const ADVariableValue & _T_v_e;
  const ADVariableValue & _T_v_i;
  const ADVariableValue & _T_v_c;
  const ADVariableValue & _T_wallc;

  const Function * const _k_p;
  const Function * const _k_l;
  const Function * const _hfg;
  const Function * const _p_v;
  const Function * const _miu_v;
  const Function * const _rho_v;

private:
  Real _Q_in;
  Real _L_e;
  Real _L_i;
  Real _L_c;
  Real _d_p;
  Real _d_w;
  Real _d_v;
  Real _T_f;
  Real _M;
  Real _h_c;
  Real _epsilon;
  int _equation;
};
