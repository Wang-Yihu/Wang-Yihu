//* This file is part of the MOOSE framework
#include "CalTwalle.h"
#include "Function.h"

registerMooseObject("asnerdihp_extest2App", CalTwalle);

InputParameters
CalTwalle::validParams()
{
  InputParameters params = AuxScalarKernel::validParams();
 
  params.addParam<Real>("d_p", 0.019, "heat pipe clad diameter");
  params.addParam<Real>("d_w", 0.017, "heat pipe wick diameter");
  params.addParam<Real>("L_e", 1.55, "evaporation sector length");

  params.addCoupledVar("Q_in", 1000000/570, "heat absorption from evaporation sector");
  params.addCoupledVar("T_p_e", 900, "temperature in (p, e)");

  params.addParam<FunctionName>("k_p", 24.83819,"function of heat conductivity coefficient of heat pipe clad with temperature");

  return params;
}

CalTwalle::CalTwalle(const InputParameters & parameters)
  : AuxScalarKernel(parameters),
   _d_p(getParam<Real>("d_p")),
   _d_w(getParam<Real>("d_w")),
   _L_e(getParam<Real>("L_e")),

   _Q_in(coupledScalarValue("Q_in")),
   _T_p_e(coupledScalarValue("T_p_e")),

   _k_p(&getFunction("k_p"))
{
}

Real
CalTwalle::computeValue()
{
  Real pi = 3.1415926535897932384626433; 

  return _T_p_e[_i] + _Q_in[_i] * (std::log(_d_p/((_d_p+_d_w)/2))/(2*pi*_k_p->value(_T_p_e[_i])*_L_e));
}
