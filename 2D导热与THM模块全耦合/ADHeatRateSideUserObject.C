#include "ADHeatRateSideUserObject.h"
#include "metaphysicl/parallel_numberarray.h"
#include "metaphysicl/parallel_dualnumber.h"
#include "metaphysicl/parallel_semidynamicsparsenumberarray.h"
#include "libmesh/parallel_algebra.h"

registerMooseObject("asnerdihp_fullApp", ADHeatRateSideUserObject);

InputParameters
ADHeatRateSideUserObject::validParams()
{
  InputParameters params = SideUserObject::validParams();

  params.addRequiredCoupledVar("temperature", "Solid temperature variable on the boundary");
  params.addRequiredCoupledVar("T_wall", "Scalar heat pipe wall temperature");
  params.addRequiredParam<MaterialPropertyName>(
      "heat_transfer_coefficient",
      "Heat transfer coefficient material property");

  params.addParam<Real>("scale", 1.0, "Extra multiplier, e.g. axial length in 2D");

  return params;
}

ADHeatRateSideUserObject::ADHeatRateSideUserObject(const InputParameters & parameters)
  : SideUserObject(parameters),
    _T(adCoupledValue("temperature")),
    _T_wall(adCoupledScalarValue("T_wall")),
    _htc(getADMaterialProperty<Real>("heat_transfer_coefficient")),
    _scale(getParam<Real>("scale")),
    _heat_rate(0.0)
{
}

void
ADHeatRateSideUserObject::initialize()
{
  _heat_rate = 0.0;
}

void
ADHeatRateSideUserObject::execute()
{
  for (unsigned int qp = 0; qp < _qrule->n_points(); ++qp)
    _heat_rate += _scale * _JxW[qp] * _coord[qp] *
                  _htc[qp] * (_T[qp] - _T_wall[0]);
}

void
ADHeatRateSideUserObject::threadJoin(const UserObject & y)
{
  const auto & uo = static_cast<const ADHeatRateSideUserObject &>(y);
  _heat_rate += uo._heat_rate;
}

void
ADHeatRateSideUserObject::finalize()
{
  comm().sum(_heat_rate);
}
