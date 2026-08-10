#include "ADMassFlowRateBalance.h"

registerMooseObject("asnerdihp_tianApp", ADMassFlowRateBalance);

InputParameters
ADMassFlowRateBalance::validParams()
{
  InputParameters params = ADKernel::validParams();

  params.addClassDescription(
      "Solves d(m_dot)/dx = mass_source, where the source may be "
      "a coupled variable or an AD material property.");

  params.addCoupledVar(
      "mass_source_variable",
      "Mass source variable gamma_m, with units kg/(m s).");

  params.addParam<MaterialPropertyName>(
      "mass_source_material",
      "AD material property used as the mass source gamma_m.");

  return params;
}

ADMassFlowRateBalance::ADMassFlowRateBalance(
    const InputParameters & parameters)
  : ADKernel(parameters),

    _mass_source_variable(
        isCoupled("mass_source_variable")
            ? &adCoupledValue("mass_source_variable")
            : nullptr),

    _mass_source_material(
        isParamValid("mass_source_material")
            ? &getADMaterialProperty<Real>("mass_source_material")
            : nullptr)
{
  const bool variable_given = (_mass_source_variable != nullptr);
  const bool material_given = (_mass_source_material != nullptr);

  if (variable_given == material_given)
    mooseError(
        "ADMassFlowRateBalance requires exactly one of "
        "'mass_source_variable' and 'mass_source_material'.");
}

ADReal
ADMassFlowRateBalance::computeQpResidual()
{
  const ADReal & gamma_m =
      _mass_source_variable
          ? (*_mass_source_variable)[_qp]
          : (*_mass_source_material)[_qp];

  return _test[_i][_qp] *
         (_grad_u[_qp](0) - gamma_m);
}
