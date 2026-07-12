#include "ConvectiveHeatTransferSideIntegralScalarTf.h"

#include "metaphysicl/raw_type.h"

registerMooseObject("asnerdihp_fullApp", ConvectiveHeatTransferSideIntegralScalarTf);
registerMooseObject("asnerdihp_fullApp", ADConvectiveHeatTransferSideIntegralScalarTf);

template <bool is_ad>
InputParameters
ConvectiveHeatTransferSideIntegralScalarTfTempl<is_ad>::validParams()
{
  InputParameters params = SideIntegralPostprocessor::validParams();

  params.addClassDescription(
      "Computes the total convective heat transfer across a boundary, "
      "with T_fluid_var treated as a scalar variable.");

  params.addRequiredCoupledVar("T_solid", "The solid temperature field variable.");
  params.addRequiredCoupledVar("T_fluid_var", "The fluid temperature scalar variable.");

  params.addCoupledVar("htc_var", "Heat transfer coefficient field variable.");
  params.addParam<MaterialPropertyName>("htc", "Heat transfer coefficient material property.");
  
  params.addParam<Real>("scale",1.0,"Scale factor");

  return params;
}

template <bool is_ad>
ConvectiveHeatTransferSideIntegralScalarTfTempl<is_ad>::
    ConvectiveHeatTransferSideIntegralScalarTfTempl(const InputParameters & parameters)
  : SideIntegralPostprocessor(parameters),
    _T_wall(coupledValue("T_solid")),
    _T_fluid_scalar(coupledScalarValue("T_fluid_var")),
    _hw(isCoupled("htc_var") ? &coupledValue("htc_var") : nullptr),
    _hw_mat(isParamValid("htc") ? &getGenericMaterialProperty<Real, is_ad>("htc") : nullptr),
    _scale(getParam<Real>("scale"))
{
  if (isCoupled("htc_var") == isParamValid("htc"))
    paramError("htc", "Either htc_var OR htc must be provided, exactly one, not both.");
}

template <bool is_ad>
Real
ConvectiveHeatTransferSideIntegralScalarTfTempl<is_ad>::computeQpIntegral()
{
  Real hw;

  if (_hw)
    hw = (*_hw)[_qp];
  else
    hw = MetaPhysicL::raw_value((*_hw_mat)[_qp]);

  const Real Tf = _T_fluid_scalar[0];

  return _scale * hw * (_T_wall[_qp] - Tf);
}

template class ConvectiveHeatTransferSideIntegralScalarTfTempl<false>;
template class ConvectiveHeatTransferSideIntegralScalarTfTempl<true>;
