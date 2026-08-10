#include "ADSchrageMassTransferConstraint.h"

#include "metaphysicl/raw_type.h"

#include <cmath>

registerMooseObject("asnerdihp_tianApp",
                    ADSchrageMassTransferConstraint);

InputParameters
ADSchrageMassTransferConstraint::validParams()
{
  InputParameters params = ADKernel::validParams();

  params.addClassDescription(
      "Solves the Schrage interface mass-transfer equation "
      "for the line mass source gamma_m.");

  params.addRequiredCoupledVar(
      "vapor_pressure",
      "Vapor-core pressure p_v in Pa");

  params.addRequiredCoupledVar(
      "vapor_temperature",
      "Vapor-core temperature T_v in K");

  params.addRequiredCoupledVar(
      "interface_temperature",
      "Liquid-vapor interface temperature T_i in K");

  params.addRequiredParam<MaterialPropertyName>(
      "interface_pressure",
      "Interface saturation pressure p_i = p_sat(T_i) in Pa");

  params.addRequiredRangeCheckedParam<Real>(
      "diameter",
      "diameter > 0",
      "Vapor/interface diameter D_v in m");

  params.addRequiredRangeCheckedParam<Real>(
      "phi",
      "phi > 0 & phi <= 1",
      "Evaporation/condensation accommodation coefficient");

  params.addRangeCheckedParam<Real>(
      "molar_mass",
      0.02298976928,
      "molar_mass > 0",
      "Sodium molar mass in kg/mol");

  params.addRangeCheckedParam<Real>(
      "universal_gas_constant",
      8.314462618,
      "universal_gas_constant > 0",
      "Universal gas constant in J/(mol K)");

  return params;
}

ADSchrageMassTransferConstraint::
ADSchrageMassTransferConstraint(
    const InputParameters & parameters)
  : ADKernel(parameters),

    _vapor_pressure(
        adCoupledValue("vapor_pressure")),

    _vapor_temperature(
        adCoupledValue("vapor_temperature")),

    _interface_temperature(
        adCoupledValue("interface_temperature")),

    _interface_pressure(
        getADMaterialProperty<Real>(
            getParam<MaterialPropertyName>(
                "interface_pressure"))),

    _diameter(getParam<Real>("diameter")),

    _pi(std::acos(-1.0)),

    _schrage_coefficient(
        (2.0 * getParam<Real>("phi") /
         (2.0 - getParam<Real>("phi"))) *
        std::sqrt(
            getParam<Real>("molar_mass") /
            (2.0 * _pi *
             getParam<Real>("universal_gas_constant"))))
{
}

ADReal
ADSchrageMassTransferConstraint::computeQpResidual()
{
  if (MetaPhysicL::raw_value(
          _interface_temperature[_qp]) <= 0.0)
    mooseError(
        "The interface temperature T_i must be positive.");

  if (MetaPhysicL::raw_value(
          _vapor_temperature[_qp]) <= 0.0)
    mooseError(
        "The vapor temperature T_v must be positive.");

  using std::sqrt;

  // Interfacial mass flux obtained from gamma_m
  const ADReal mass_flux_from_gamma =
      _u[_qp] / (_pi * _diameter);

  // Schrage kinetic-theory mass flux
  const ADReal schrage_mass_flux =
      _schrage_coefficient *
      (_interface_pressure[_qp] /
           sqrt(_interface_temperature[_qp])
       -
       _vapor_pressure[_qp] /
           sqrt(_vapor_temperature[_qp]));

  // Algebraic equation:
  //
  // gamma_m/(pi*D_v) - j_Schrage = 0
  return _test[_i][_qp] *
         (mass_flux_from_gamma - schrage_mass_flux);
}
