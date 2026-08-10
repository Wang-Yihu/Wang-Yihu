#include "ADVaporEnergyEquation.h"

#include "metaphysicl/raw_type.h"

#include <cmath>

registerMooseObject("asnerdihp_tianApp", ADVaporEnergyEquation);

InputParameters
ADVaporEnergyEquation::validParams()
{
  InputParameters params = ADKernel::validParams();

  params.addClassDescription(
      "Solves the steady one-dimensional vapor energy equation "
      "with an interfacial mass-transfer energy source.");

  params.addRequiredCoupledVar(
      "velocity",
      "Axial vapor velocity u_v.");

  params.addRequiredParam<MaterialPropertyName>(
      "density",
      "AD material property for vapor density rho_v.");

  params.addRequiredParam<MaterialPropertyName>(
      "vapor_enthalpy",
      "AD material property for vapor specific enthalpy h_v.");

  params.addRequiredParam<MaterialPropertyName>(
      "interface_enthalpy",
      "AD material property for the vapor-side interface "
      "specific enthalpy h_v_i.");

  /*
   * Gamma_m can be supplied by either a coupled variable
   * or an AD material property.
   */
  params.addCoupledVar(
      "mass_source_variable",
      "Interfacial mass source Gamma_m supplied by a coupled "
      "variable, with units kg/(m s).");

  params.addParam<MaterialPropertyName>(
      "mass_source_material",
      "Interfacial mass source Gamma_m supplied by an AD "
      "material property, with units kg/(m s).");

  params.addRequiredParam<Real>(
      "diameter",
      "Vapor-core diameter D_v.");

  params.addParam<Real>(
      "energy_correction",
      1.0,
      "Kinetic-energy correction factor beta.");

  return params;
}

ADVaporEnergyEquation::ADVaporEnergyEquation(
    const InputParameters & parameters)
  : ADKernel(parameters),

    _velocity(adCoupledValue("velocity")),

    _density(
        getADMaterialProperty<Real>("density")),

    _vapor_enthalpy(
        getADMaterialProperty<Real>("vapor_enthalpy")),

    _interface_enthalpy(
        getADMaterialProperty<Real>("interface_enthalpy")),

    _mass_source_variable(
        isCoupled("mass_source_variable")
            ? &adCoupledValue("mass_source_variable")
            : nullptr),

    _mass_source_material(
        isParamValid("mass_source_material")
            ? &getADMaterialProperty<Real>(
                  "mass_source_material")
            : nullptr),

    _diameter(getParam<Real>("diameter")),

    _area(
        0.25 *
        std::acos(-1.0) *
        _diameter *
        _diameter),

    _energy_correction(
        getParam<Real>("energy_correction"))
{
  if (_diameter <= 0.0)
    paramError(
        "diameter",
        "The vapor-core diameter must be greater than zero.");

  const bool variable_given =
      (_mass_source_variable != nullptr);

  const bool material_given =
      (_mass_source_material != nullptr);

  if (!variable_given && !material_given)
    mooseError(
        "ADVaporEnergyEquation requires either "
        "'mass_source_variable' or 'mass_source_material'.");

  if (variable_given && material_given)
    mooseError(
        "ADVaporEnergyEquation cannot use both "
        "'mass_source_variable' and "
        "'mass_source_material' simultaneously.");
}

ADReal
ADVaporEnergyEquation::computeQpResidual()
{
  /*
   * Obtain Gamma_m from either the coupled variable
   * or the AD material property.
   */
  const ADReal gamma_m =
      _mass_source_variable
          ? (*_mass_source_variable)[_qp]
          : (*_mass_source_material)[_qp];

  /*
   * Upwind enthalpy:
   *
   * Gamma_m >= 0: evaporation, mass enters the vapor region
   *                from the interface.
   *
   * Gamma_m < 0:  condensation, mass leaves the vapor region,
   *                carrying the local vapor enthalpy.
   *
   * raw_value() is used only to determine the active branch.
   * The selected enthalpy and gamma_m remain ADReal quantities.
   */
  const ADReal h_upwind =
      MetaPhysicL::raw_value(gamma_m) >= 0.0
          ? _interface_enthalpy[_qp]
          : _vapor_enthalpy[_qp];

  const ADReal velocity = _velocity[_qp];

  /*
   * Axial vapor energy flux:
   *
   * F_E = rho_v * u_v * A_v *
   *       (h_v + beta * u_v^2 / 2)
   */
  const ADReal energy_flux =
      _density[_qp] *
      velocity *
      _area *
      (_vapor_enthalpy[_qp] +
       0.5 *
           _energy_correction *
           velocity *
           velocity);

  /*
   * Interfacial energy source:
   *
   * S_E = Gamma_m * h_upwind
   *
   * The radial kinetic-energy contribution is neglected.
   */
  const ADReal energy_source =
      gamma_m * h_upwind;

  /*
   * Strong form:
   *
   * d(F_E)/dx - S_E = 0
   *
   * After integration by parts:
   *
   * - integral grad(test) * F_E dx
   * - integral test * S_E dx
   * + boundary energy flux = 0
   *
   * This Kernel contains the domain terms.
   */
  return
      -_grad_test[_i][_qp](0) * energy_flux
      -_test[_i][_qp] * energy_source;
}
