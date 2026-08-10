#include "asnerdihp_tianApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
asnerdihp_tianApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  return params;
}

asnerdihp_tianApp::asnerdihp_tianApp(InputParameters parameters) : MooseApp(parameters)
{
  asnerdihp_tianApp::registerAll(_factory, _action_factory, _syntax);
}

asnerdihp_tianApp::~asnerdihp_tianApp() {}

void 
asnerdihp_tianApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAllObjects<asnerdihp_tianApp>(f, af, s);
  Registry::registerObjectsTo(f, {"asnerdihp_tianApp"});
  Registry::registerActionsTo(af, {"asnerdihp_tianApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
asnerdihp_tianApp::registerApps()
{
  registerApp(asnerdihp_tianApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
asnerdihp_tianApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  asnerdihp_tianApp::registerAll(f, af, s);
}
extern "C" void
asnerdihp_tianApp__registerApps()
{
  asnerdihp_tianApp::registerApps();
}
