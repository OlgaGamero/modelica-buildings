within Buildings.Media.GasesPTDecoupled;
package MoistAirUnsaturated
  "Package with moist air model that decouples pressure and temperature and that has no liquid water"
  extends Modelica.Media.Interfaces.PartialCondensingGases(
     final singleState = false,
     mediumName="MoistAirPTDecoupledUnsaturated",
     substanceNames={"water", "air"},
     final reducedX=true,
     reference_X={0.01,0.99},
     fluidConstants = {Modelica.Media.IdealGases.Common.FluidData.H2O,
                       Modelica.Media.IdealGases.Common.FluidData.N2});

  constant Integer Water=1
    "Index of water (in substanceNames, massFractions X, etc.)";
  constant Integer Air=2
    "Index of air (in substanceNames, massFractions X, etc.)";
  constant Real k_mair =  steam.MM/dryair.MM "ratio of molar weights";
  constant Buildings.Media.PerfectGases.Common.DataRecord dryair=
        Buildings.Media.PerfectGases.Common.SingleGasData.Air;
  constant Buildings.Media.PerfectGases.Common.DataRecord steam=
        Buildings.Media.PerfectGases.Common.SingleGasData.H2O;
  import SI = Modelica.SIunits;

  constant AbsolutePressure pStp = 101325 "Pressure for which dStp is defined";
  constant Density dStp = 1.2 "Fluid density at pressure pStp";

  // Redeclare ThermodynamicState to avoid the warning
  // "Base class ThermodynamicState is replaceable"
  // during model check
  redeclare record extends ThermodynamicState(
    p(start=p_default),
    T(start=T_default),
    X(start=X_default)) "ThermodynamicState record for moist air"
  end ThermodynamicState;

  redeclare replaceable model extends BaseProperties(
    T(stateSelect=if preferredMediumStates then StateSelect.prefer else StateSelect.default),
    p(stateSelect=if preferredMediumStates then StateSelect.prefer else StateSelect.default),
    Xi(each stateSelect=if preferredMediumStates then StateSelect.prefer else StateSelect.default),
    final standardOrderComponents=true)

    /* p, T, X = X[Water] are used as preferred states, since only then all
     other quantities can be computed in a recursive sequence.
     If other variables are selected as states, static state selection
     is no longer possible and non-linear algebraic equations occur.
      */
  protected
    constant SI.MolarMass[2] MMX = {steam.MM,dryair.MM}
      "Molar masses of components";

    //    MassFraction X_liquid "Mass fraction of liquid water";
    MassFraction X_steam "Mass fraction of steam water";
    MassFraction X_air "Mass fraction of air";
  equation
    assert(T >= 200.0 and T <= 423.15, "
Temperature T is not in the allowed range
200.0 K <= (T ="
               + String(T) + " K) <= 423.15 K
required from medium model \""     + mediumName + "\".");

  /*
    assert(Xi[Water] <= X_sat, "The medium model '" + mediumName + "' must not be saturated.\n"
     + "To model a saturated medium, use 'Buildings.Media.GasesPTDecoupled.MoistAir' instead of this medium.\n"
     + " T         = " + String(T) + "\n"
     + " X_sat     = " + String(X_sat) + "\n"
     + " Xi[Water] = " + String(Xi[Water]) + "\n"
     + " phi       = " + String(phi) + "\n"
     + " p         = " + String(p));
  */

    MM = 1/(Xi[Water]/MMX[Water]+(1.0-Xi[Water])/MMX[Air]);

    X_steam  = Xi[Water]; // There is no liquid in this medium model
    X_air    = 1-Xi[Water];

    h = specificEnthalpy_pTX(p,T,Xi);
    R = dryair.R*(1 - Xi[Water]) + steam.R*Xi[Water];

    // Equation for ideal gas, from h=u+p*v and R*T=p*v, from which follows that  u = h-R*T.
    // u = h-R*T;

    // However, in this medium, the gas law is d/dStp=p/pStp, from which follows using h=u+pv that
    // u= h-p*v = h-p/d = h-pStp/dStp
    u = h-pStp/dStp;

    //    d = p/(R*T);
    d/dStp = p/pStp;

    /* Note, u and d are computed under the assumption that the volume of the liquid
         water is neglible with respect to the volume of air and of steam
      */
    state.p = p;
    state.T = T;
    state.X = X;
  end BaseProperties;

  function Xsaturation = Buildings.Media.PerfectGases.MoistAir.Xsaturation
    "Steam water mass fraction of saturation boundary in kg_water/kg_moistair";

  redeclare function setState_pTX
    "Thermodynamic state as function of p, T and composition X"
      extends Buildings.Media.PerfectGases.MoistAir.setState_pTX;
  end setState_pTX;

  redeclare function setState_phX
    "Thermodynamic state as function of p, h and composition X"
  extends Modelica.Icons.Function;
  input AbsolutePressure p "Pressure";
  input SpecificEnthalpy h "Specific enthalpy";
  input MassFraction X[:] "Mass fractions";
  output ThermodynamicState state;
  algorithm
  state := if size(X,1) == nX then
         ThermodynamicState(p=p,T=T_phX(p,h,X),X=X) else
        ThermodynamicState(p=p,T=T_phX(p,h,cat(1,X,{1-sum(X)})), X=cat(1,X,{1-sum(X)}));
    //    ThermodynamicState(p=p,T=T_phX(p,h,X), X=cat(1,X,{1-sum(X)}));
    annotation (Documentation(info="<html>
Function to set the state for given pressure, enthalpy and species concentration.
This function needed to be reimplemented in order for the medium model to use
the implementation of <code>T_phX</code> provided by this package as opposed to the
implementation provided by its parent package.
</html>"));
  end setState_phX;

  redeclare function setState_dTX
    "Thermodynamic state as function of d, T and composition X"
     extends Buildings.Media.PerfectGases.MoistAir.setState_dTX;
  end setState_dTX;

  redeclare function gasConstant
    "Gas constant (computation neglects liquid fraction)"
     extends Buildings.Media.PerfectGases.MoistAir.gasConstant;
  end gasConstant;

function saturationPressureLiquid
    "Return saturation pressure of water as a function of temperature T in the range of 273.16 to 373.16 K"

  extends Modelica.Icons.Function;
  input SI.Temperature Tsat "saturation temperature";
  output SI.AbsolutePressure psat "saturation pressure";
algorithm
  psat := 611.657*Modelica.Math.exp(17.2799 - 4102.99/(Tsat - 35.719));
  annotation(Inline=false,smoothOrder=5,derivative=Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated.saturationPressureLiquid_der,
    Documentation(info="<html>
Saturation pressure of water above the triple point temperature is computed from temperature. It's range of validity is between
273.16 and 373.16 K. Outside these limits a less accurate result is returned.
</html>"));
end saturationPressureLiquid;

function saturationPressureLiquid_der
    "Time derivative of saturationPressureLiquid"

  extends Modelica.Icons.Function;
  input SI.Temperature Tsat "Saturation temperature";
  input Real dTsat(unit="K/s") "Saturation temperature derivative";
  output Real psat_der(unit="Pa/s") "Saturation pressure";
algorithm
  psat_der:=611.657*Modelica.Math.exp(17.2799 - 4102.99/(Tsat - 35.719))*4102.99*dTsat/(Tsat - 35.719)/(Tsat - 35.719);

  annotation(Inline=false,smoothOrder=5,
    Documentation(info="<html>
Derivative function of <a href=modelica://Modelica.Media.Air.MoistAir.saturationPressureLiquid>saturationPressureLiquid</a>
</html>"));
end saturationPressureLiquid_der;

  function sublimationPressureIce =
      Buildings.Media.PerfectGases.MoistAir.sublimationPressureIce
    "Saturation curve valid for 223.16 <= T <= 273.16. Outside of these limits a (less accurate) result is returned";

redeclare function extends saturationPressure
    "Saturation curve valid for 223.16 <= T <= 373.16 (and slightly outside with less accuracy)"

algorithm
  psat := Buildings.Utilities.Math.Functions.spliceFunction(
                                                  saturationPressureLiquid(Tsat),sublimationPressureIce(Tsat),Tsat-273.16,1.0);
  annotation(Inline=false,smoothOrder=5);
end saturationPressure;

 redeclare function pressure "Gas pressure"
    extends Buildings.Media.PerfectGases.MoistAir.pressure;
 end pressure;

 redeclare function temperature "Gas temperature"
    extends Buildings.Media.PerfectGases.MoistAir.temperature;
 end temperature;

 redeclare function density "Gas density"
   extends Modelica.Icons.Function;
   input ThermodynamicState state;
   output Density d "Density";
 algorithm
  d :=state.p*dStp/pStp;
 end density;

 redeclare function specificEntropy
    "Specific entropy (liquid part neglected, mixing entropy included)"
    extends Buildings.Media.PerfectGases.MoistAir.specificEntropy;
 end specificEntropy;

 redeclare function extends enthalpyOfVaporization
    "Enthalpy of vaporization of water"
 algorithm
  r0 := 2501014.5;
 end enthalpyOfVaporization;

  function HeatCapacityOfWater
    "Specific heat capacity of water (liquid only) which is constant"
    extends Modelica.Icons.Function;
    input Temperature T;
    output SpecificHeatCapacity cp_fl;
  algorithm
    cp_fl := 4186;
  end HeatCapacityOfWater;

redeclare replaceable function extends enthalpyOfLiquid
    "Enthalpy of liquid (per unit mass of liquid) which is linear in the temperature"

algorithm
  h := (T - 273.15)*4186;
  annotation(smoothOrder=5, derivative=der_enthalpyOfLiquid);
end enthalpyOfLiquid;

replaceable function der_enthalpyOfLiquid
    "Temperature derivative of enthalpy of liquid per unit mass of liquid"
  extends Modelica.Icons.Function;
  input Temperature T "temperature";
  input Real der_T "temperature derivative";
  output Real der_h "derivative of liquid enthalpy";
algorithm
  der_h := 4186*der_T;
end der_enthalpyOfLiquid;

redeclare function enthalpyOfCondensingGas
    "Enthalpy of steam per unit mass of steam"
  extends Modelica.Icons.Function;

  input Temperature T "temperature";
  output SpecificEnthalpy h "steam enthalpy";
algorithm
  h := (T-273.15) * steam.cp + Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated.enthalpyOfVaporization(T);
  annotation(smoothOrder=5, derivative=der_enthalpyOfCondensingGas);
end enthalpyOfCondensingGas;

replaceable function der_enthalpyOfCondensingGas
    "Derivative of enthalpy of steam per unit mass of steam"
  extends Modelica.Icons.Function;
  input Temperature T "temperature";
  input Real der_T(unit="K/s") "temperature derivative";
  output Real der_h(unit="J/(kg.s)") "derivative of steam enthalpy";
algorithm
  der_h := steam.cp*der_T;
end der_enthalpyOfCondensingGas;

redeclare replaceable function extends enthalpyOfGas
    "Enthalpy of gas mixture per unit mass of gas mixture"
algorithm
  h := Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated.enthalpyOfCondensingGas(T)*X[Water]
       + Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated.enthalpyOfDryAir(T)*(1.0-X[Water]);
end enthalpyOfGas;

replaceable function enthalpyOfDryAir
    "Enthalpy of dry air per unit mass of dry air"
  extends Modelica.Icons.Function;

  input Temperature T "temperature";
  output SpecificEnthalpy h "dry air enthalpy";
algorithm
  h := (T - 273.15)*dryair.cp;
  annotation(smoothOrder=5, derivative=der_enthalpyOfDryAir);
end enthalpyOfDryAir;

replaceable function der_enthalpyOfDryAir
    "Derivative of enthalpy of dry air per unit mass of dry air"
  extends Modelica.Icons.Function;
  input Temperature T "temperature";
  input Real der_T(unit="K/s") "temperature derivative";
  output Real der_h(unit="J/(kg.s)") "derivative of dry air enthalpy";
algorithm
  der_h := dryair.cp*der_T;
end der_enthalpyOfDryAir;

redeclare replaceable function extends specificHeatCapacityCp
    "Specific heat capacity of gas mixture at constant pressure"
algorithm
  cp := dryair.cp*(1-state.X[Water]) +steam.cp*state.X[Water];
    annotation(derivative=der_specificHeatCapacityCp);
end specificHeatCapacityCp;

replaceable function der_specificHeatCapacityCp
    "Derivative of specific heat capacity of gas mixture at constant pressure"
    input ThermodynamicState state;
    input ThermodynamicState der_state;
    output Real der_cp(unit="J/(kg.K.s)");
algorithm
  der_cp := (steam.cp-dryair.cp)*der_state.X[Water];
end der_specificHeatCapacityCp;

redeclare replaceable function extends specificHeatCapacityCv
    "Specific heat capacity of gas mixture at constant volume"
algorithm
  cv:= dryair.cv*(1-state.X[Water]) +steam.cv*state.X[Water];
    annotation(derivative=der_specificHeatCapacityCv);
end specificHeatCapacityCv;

replaceable function der_specificHeatCapacityCv
    "Derivative of specific heat capacity of gas mixture at constant volume"
    input ThermodynamicState state;
    input ThermodynamicState der_state;
    output Real der_cv(unit="J/(kg.K.s)");
algorithm
  der_cv := (steam.cv-dryair.cv)*der_state.X[Water];
end der_specificHeatCapacityCv;

redeclare function extends dynamicViscosity "dynamic viscosity of dry air"
algorithm
  eta := 1.85E-5;
end dynamicViscosity;

redeclare function extends thermalConductivity
    "Thermal conductivity of dry air as a polynomial in the temperature"
  import Modelica.Media.Incompressible.TableBased.Polynomials_Temp;
algorithm
  lambda := Polynomials_Temp.evaluate({(-4.8737307422969E-008), 7.67803133753502E-005, 0.0241814385504202},
   Modelica.SIunits.Conversions.to_degC(state.T));
end thermalConductivity;

redeclare function extends specificEnthalpy "Specific enthalpy"
algorithm
  h := Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated.h_pTX(state.p, state.T, state.X);
end specificEnthalpy;

redeclare function extends specificInternalEnergy "Specific internal energy"
  extends Modelica.Icons.Function;
algorithm
  u := Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated.h_pTX(state.p,state.T,state.X) - pStp/dStp;
end specificInternalEnergy;

redeclare function extends specificGibbsEnergy "Specific Gibbs energy"
  extends Modelica.Icons.Function;
algorithm
  g := Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated.h_pTX(state.p,state.T,state.X) - state.T*specificEntropy(state);
end specificGibbsEnergy;

redeclare function extends specificHelmholtzEnergy "Specific Helmholtz energy"
  extends Modelica.Icons.Function;
algorithm
  f := Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated.h_pTX(state.p,state.T,state.X)
         - gasConstant(state)*state.T
         - state.T*Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated.specificEntropy(state);
end specificHelmholtzEnergy;

////////////////////////////////////////////////////////////////////////////
function h_pTX
    "Compute specific enthalpy from pressure, temperature and mass fraction"
  extends Modelica.Icons.Function;

  input SI.Pressure p "Pressure";
  input SI.Temperature T "Temperature";
  input SI.MassFraction X[nX] "Mass fractions of moist air";
  output SI.SpecificEnthalpy h "Specific enthalpy at p, T, X";
algorithm
  h := (T - 273.15)*dryair.cp * (1 - X[Water]) + ((T-273.15) * steam.cp + 2501014.5) * X[Water];
  annotation(smoothOrder=5);
end h_pTX;

function T_phX "Compute temperature from specific enthalpy and mass fraction"
  extends Modelica.Icons.Function;

  input AbsolutePressure p "Pressure";
  input SpecificEnthalpy h "specific enthalpy";
  input MassFraction[:] X "mass fractions of composition";
  output Temperature T "temperature";
algorithm
  T := 273.15 + (h-2501014.5 * X[Water])/(dryair.cp * (1 - X[Water])+steam.cp*X[Water]);
  annotation(smoothOrder=5);
end T_phX;

redeclare function enthalpyOfNonCondensingGas
    "Enthalpy of non-condensing gas per unit mass"
  extends Modelica.Icons.Function;

  input Temperature T "temperature";
  output SpecificEnthalpy h "enthalpy";
algorithm
  h := enthalpyOfDryAir(T);
  annotation(smoothOrder=5, derivative=der_enthalpyOfNonCondensingGas);
end enthalpyOfNonCondensingGas;

replaceable function der_enthalpyOfNonCondensingGas
    "Derivative of enthalpy of non-condensing gas per unit mass"
  extends Modelica.Icons.Function;
  input Temperature T "temperature";
  input Real der_T "temperature derivative";
  output Real der_h "derivative of steam enthalpy";
algorithm
  der_h := der_enthalpyOfDryAir(T, der_T);
end der_enthalpyOfNonCondensingGas;
  annotation (preferredView="info", Documentation(info="<html>
<p>
This is a medium model that is identical to
<a href=\"modelica://Buildings.Media.GasesPTDecoupled.MoistAir\">
Buildings.Media.GasesPTDecoupled.MoistAir</a>,  but
in this model, the air must not be saturated. If the air is saturated,
use the medium model
<a href=\"modelica://Buildings.Media.GasesPTDecoupled.MoistAir\">
Buildings.Media.GasesPTDecoupled.MoistAir</a> instead of this one.
</p>
<p>
This medium model has been added to allow an explicit computation of
the function
<code>T_phX</code> so that it is once differentiable in <code>h</code>
with a continuous derivative. This allows obtaining an analytic
expression for the Jacobian, and therefore simplifies the computation
of initial conditions that can be numerically challenging for
thermo-fluid systems.
</p>
<p>
This new formulation often leads to smaller systems of nonlinear equations
because it allows to invert the function <code>T_phX</code> analytically.
</p>
</html>", revisions="<html>
<ul>
<li>
November 13, 2014, by Michael Wetter:<br/>
Removed <code>phi</code> and removed non-required computations.
</li>
<li>
September 29, 2014, by Michael Wetter:<br/>
Set consistent nominal values to avoid the warning
alias set with different nominal values
in OpenModelica.
</li>
<li>
March 29, 2013, by Michael Wetter:<br/>
Added <code>final standardOrderComponents=true</code> in the
<code>BaseProperties</code> declaration. This avoids an error
when models are checked in Dymola 2014 in the pedenatic mode.
</li>
<li>
April 12, 2012, by Michael Wetter:<br/>
Added keyword <code>each</code> to <code>Xi(stateSelect=...</code>.
</li>
<li>
April 4, 2012, by Michael Wetter:<br/>
Added redeclaration of <code>ThermodynamicState</code> to avoid a warning
during model check and translation.
</li>
<li>
August 3, 2011, by Michael Wetter:<br/>
Fixed bug in <code>u=h-R*T</code>, which is only valid for ideal gases.
For this medium, the function is <code>u=h-pStd/dStp</code>.
</li>
<li>
January 27, 2010, by Michael Wetter:<br/>
Fixed bug in <code>else</code> branch of function <code>setState_phX</code>
that lead to a run-time error when the constructor of this function was called.
</li>
<li>
January 22, 2010, by Michael Wetter:<br/>
Added implementation of function
<a href=\"modelica://Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated.enthalpyOfNonCondensingGas\">
enthalpyOfNonCondensingGas</a> and its derivative.
<li>
January 13, 2010, by Michael Wetter:<br/>
Fixed implementation of derivative functions.
</li>
<li>
August 28, 2008, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end MoistAirUnsaturated;
