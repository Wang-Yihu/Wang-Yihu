// https://mooseframework.inl.gov/bison/source/materials/SS316Thermal.html
//IAEA–TECDOC–XXXX Sodium Coolant Handbook: Physical and Chemical Properties 
// IAEA PROJECT ON SODIUM PROPERTIES AND SAFE OPERATION OF EXPERIMENTAL FACILITIES IN SUPPORT OF THE DEVELOPMENT AND DEPLOYMENT OF SODIUM–COOLED FAST REACTORS (NAPRO)
#pragma once

#include "ADScalarKernel.h"

class ADHeatPipeNetworkEqForTwalleCouple : public ADScalarKernel

{
public:
  /**
   * Constructor
   */
  ADHeatPipeNetworkEqForTwalleCouple(const InputParameters & parameters);

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

  /**
   * Coupled scalar variable values
   */
  const ADVariableValue & _T_p_e;
  const ADVariableValue & _Q_in;

  const Function * const _k_p;

private:
  Real _L_e;
  Real _d_p;
  Real _d_w;
};
