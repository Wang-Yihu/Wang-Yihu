#pragma once

#include "ADScalarKernel.h"
#include "ADHeatRateSideUserObject.h"


class ADHeatPipeNetworkEqForCoupleFromHeatRateUO : public ADScalarKernel
{
public:
  ADHeatPipeNetworkEqForCoupleFromHeatRateUO(const InputParameters & parameters);

  static InputParameters validParams();

protected:
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

  /**
   * AD SideUserObject that provides Q_in = boundary heat rate
   */
  const ADHeatRateSideUserObject & _heat_rate_uo;

  const Function * const _k_p;
  const Function * const _k_l;
  const Function * const _hfg;
  const Function * const _p_v;
  const Function * const _miu_v;
  const Function * const _rho_v;

private:
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
