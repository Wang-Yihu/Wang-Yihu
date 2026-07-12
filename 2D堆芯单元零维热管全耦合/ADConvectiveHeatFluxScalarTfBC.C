//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADConvectiveHeatFluxScalarTfBC.h"

registerMooseObject("HeatConductionApp", ADConvectiveHeatFluxScalarTfBC);

InputParameters
ADConvectiveHeatFluxScalarTfBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addClassDescription(
      "Convective heat transfer boundary condition with temperature and heat "
      "transfer coefficent given by material properties.");
  params.addCoupledVar("T_infinity", 900, "far-field temperature");
  params.addRequiredParam<MaterialPropertyName>("heat_transfer_coefficient",
                                                "Material property for heat transfer coefficient");
  return params;
}

ADConvectiveHeatFluxScalarTfBC::ADConvectiveHeatFluxScalarTfBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters),
    _T_infinity(adCoupledScalarValue("T_infinity")),
    _htc(getADMaterialProperty<Real>("heat_transfer_coefficient"))
{
}

ADReal
ADConvectiveHeatFluxScalarTfBC::computeQpResidual()
{
  /*return -_test[_i][_qp] * _htc[_qp] * (_T_infinity[_i] - _u[_qp]);*/
  return -_test[_i][_qp] * _htc[_qp] * (_T_infinity[0] - _u[_qp]);
}
