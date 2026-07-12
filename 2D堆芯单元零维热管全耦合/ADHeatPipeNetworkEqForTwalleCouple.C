// https://mooseframework.inl.gov/bison/source/materials/SS316Thermal.html
//IAEA–TECDOC–XXXX Sodium Coolant Handbook: Physical and Chemical Properties 
// IAEA PROJECT ON SODIUM PROPERTIES AND SAFE OPERATION OF EXPERIMENTAL FACILITIES IN SUPPORT OF THE DEVELOPMENT AND DEPLOYMENT OF SODIUM–COOLED FAST REACTORS (NAPRO)
#include "ADHeatPipeNetworkEqForTwalleCouple.h"
#include "Function.h"

// e - evaporation section; i - heat insulation section; c - condensation section
// p - heat pipe clad; w - wick; v - vapor region
// r - radial; a - axial
registerMooseObject("asnerdihp_fullApp", ADHeatPipeNetworkEqForTwalleCouple);

InputParameters
ADHeatPipeNetworkEqForTwalleCouple::validParams()
{
  /*InputParameters params = ODEKernel::validParams();*/
  InputParameters params = ADScalarKernel::validParams();

  /*params.addParam<Real>("Q_in", 1000000/570, "heat absorption from evaporation sector");*/
  params.addParam<Real>("d_p", 0.019, "heat pipe clad diameter");
  params.addParam<Real>("d_w", 0.017, "heat pipe wick diameter");
  params.addParam<Real>("L_e", 1.55, "evaporation sector length");

  params.addCoupledVar("T_p_e", 900, "temperature in (p, e)");
  params.addCoupledVar("Q_in", 1000000/570, "heat absorption from evaporation sector");

  params.addParam<FunctionName>("k_p", 24.83819,"function of heat conductivity coefficient of heat pipe clad with temperature");

  return params;
}

ADHeatPipeNetworkEqForTwalleCouple::ADHeatPipeNetworkEqForTwalleCouple(const InputParameters & parameters)
  : ADScalarKernel(parameters),

    /*_Q_in(getParam<Real>("Q_in")),*/
    _d_p(getParam<Real>("d_p")),
    _d_w(getParam<Real>("d_w")),
    _L_e(getParam<Real>("L_e")),

    _Q_in(adCoupledScalarValue("Q_in")),
    _T_p_e(adCoupledScalarValue("T_p_e")),

    _k_p(&getFunction("k_p"))
{
}

ADReal
ADHeatPipeNetworkEqForTwalleCouple::computeQpResidual()
{ 
  Real pi = 3.1415926535897932384626433; 
  
  const auto & _T_walle = _u; 

  return _Q_in[_i] - 2*pi*_k_p->value(_T_p_e[_i])*_L_e*(_T_walle[_i] - _T_p_e[_i])/std::log(_d_p/((_d_p+_d_w)/2));

}
