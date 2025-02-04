within Buildings.Media.GasesPTDecoupled;
package SimpleAir
  "Package with dry air model that decouples pressure and temperature"
  extends Buildings.Media.Interfaces.PartialSimpleIdealGasMedium(
     final singleState = false,
     mediumName="GasesPTDecoupled.SimpleAir",
     cp_const=1005.45,
     MM_const=0.0289651159,
     R_gas=Constants.R/0.0289651159,
     eta_const=1.82e-5,
     lambda_const=0.026,
     T_min=Cv.from_degC(-50),
     T_max=Cv.from_degC(100));

  import SI = Modelica.SIunits;
  import Cv = Modelica.SIunits.Conversions;
  import Modelica.Constants;

  constant FluidConstants[nS] fluidConstants=
    FluidConstants(iupacName={"simple air"},
                   casRegistryNumber={"not a real substance"},
                   chemicalFormula={"N2, O2"},
                   structureFormula={"N2, O2"},
                   molarMass=Modelica.Media.IdealGases.Common.SingleGasesData.N2.MM)
    "constant data for the fluid";

// the statements above have the same effects as the commented "extends" below,
// except that the Interfaces of the Buildings.Media library is used instead of the Interfaces
// of Modelica.Media. This is required since Modelica.Media does not allow to redeclare
// certain property functions that we need to redeclare here.
//  extends Modelica.Media.Air.SimpleAir(
//      mediumName="GasesPTDecoupled.SimpleAir",
//      T_min=Cv.from_degC(-50));

// redeclare model BaseProperties "Basic medium properties"
//    extends BasePropertiesRecord;

   constant AbsolutePressure pStp = 101325 "Pressure for which dStp is defined";
   constant Density dStp = 1.2 "Fluid density at pressure pStp";

 redeclare replaceable model BaseProperties "Basic medium properties"
    // declarations from Modelica.Media.Interfaces.PartialMedium
    InputAbsolutePressure p "Absolute pressure of medium";
    InputMassFraction[nXi] Xi(start=reference_X[1:nXi])
      "Structurally independent mass fractions";
    InputSpecificEnthalpy h "Specific enthalpy of medium";
    Density d "Density of medium";
    Temperature T "Temperature of medium";
    MassFraction[nX] X(start=reference_X)
      "Mass fractions (= (component mass)/total mass  m_i/m)";
    SpecificInternalEnergy u "Specific internal energy of medium";
    SpecificHeatCapacity R "Gas constant (of mixture if applicable)";
    MolarMass MM "Molar mass (of mixture or single fluid)";
    ThermodynamicState state
      "thermodynamic state record for optional functions";
    parameter Boolean preferredMediumStates=false
      "= true if StateSelect.prefer shall be used for the independent property variables of the medium"
      annotation (Evaluate=true, Dialog(tab="Advanced"));
    final parameter Boolean standardOrderComponents = true
      "if true, and reducedX = true, the last element of X will be computed from the other ones";
    SI.Conversions.NonSIunits.Temperature_degC T_degC=
        Modelica.SIunits.Conversions.to_degC(T)
      "Temperature of medium in [degC]";
    SI.Conversions.NonSIunits.Pressure_bar p_bar=
     Modelica.SIunits.Conversions.to_bar(p)
      "Absolute pressure of medium in [bar]";

    // Local connector definition, used for equation balancing check
    connector InputAbsolutePressure = input SI.AbsolutePressure
      "Pressure as input signal connector";
    connector InputSpecificEnthalpy = input SI.SpecificEnthalpy
      "Specific enthalpy as input signal connector";
    connector InputMassFraction = input SI.MassFraction
      "Mass fraction as input signal connector";

    // own declarations

 equation
    if standardOrderComponents then
      Xi = X[1:nXi];

        if fixedX then
          X = reference_X;
        end if;
        if reducedX and not fixedX then
          X[nX] = 1 - sum(Xi);
        end if;
        for i in 1:nX loop
          assert(X[i] >= -1.e-5 and X[i] <= 1 + 1.e-5, "Mass fraction X[" +
                 String(i) + "] = " + String(X[i]) + "of substance "
                 + substanceNames[i] + "\nof medium " + mediumName + " is not in the range 0..1");
        end for;

    end if;

    assert(p >= 0.0, "Pressure (= " + String(p) + " Pa) of medium \"" +
      mediumName + "\" is negative\n(Temperature = " + String(T) + " K)");

    // new medium equations
    h = specificEnthalpy_pTX(p,T,X);
    // Equation for ideal gas, from h=u+p*v and R*T=p*v, from which follows that  u = h-R*T.
    // u = h-R*T;

    // However, in this medium, the gas law is d/dStp=p/pStp, from which follows using h=u+pv that
    // u= h-p*v = h-p/d = h-pStp/dStp
    u = h-pStp/dStp;
    R = R_gas;
    //    d = p/(R*T);
    d/dStp = p/pStp;

    MM = MM_const;
    state.T = T;
    state.p = p;
    annotation (Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,
              -100},{100,100}}), graphics={Rectangle(
            extent={{-100,100},{100,-100}},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid,
            lineColor={0,0,255}), Text(
            extent={{-152,164},{152,102}},
            textString="%name",
            lineColor={0,0,255})}));
 end BaseProperties;

 redeclare function setState_dTX
    "Return thermodynamic state from d, T, and X or Xi"
    extends Modelica.Icons.Function;
    input Density d "Density";
    input Temperature T "Temperature";
    input MassFraction X[:] = fill(0,0) "Mass fractions";
    output ThermodynamicState state;
 algorithm
    state := ThermodynamicState(p=d/dStp*pStp,T=T);
 end setState_dTX;

 redeclare function density "return density of ideal gas"
    extends Modelica.Icons.Function;
    input ThermodynamicState state "Thermodynamic state record";
    output Density d "Density";
 algorithm
    d := dStp*state.p/pStp;
 end density;

 redeclare function specificInternalEnergy "Return specific internal energy"
   extends Modelica.Icons.Function;
   input ThermodynamicState state "thermodynamic state record";
   output SpecificEnergy u "Specific internal energy";
 algorithm
   u := specificEnthalpy(state) - pStp/dStp;
 end specificInternalEnergy;

 redeclare replaceable function specificEntropy "Return specific entropy"
    extends Modelica.Icons.Function;
    input ThermodynamicState state "Thermodynamic state record";
    output SpecificEntropy s "Specific entropy";
 algorithm
    s := cp_const*Modelica.Math.log(state.T/T0);// - R_gas*Modelica.Math.log(state.p/reference_p);
 end specificEntropy;

replaceable function enthalpyOfCondensingGas
    "Enthalpy of steam per unit mass of steam"
  extends Modelica.Icons.Function;
  input Temperature T "Temperature";
  output SpecificEnthalpy h "Steam enthalpy";
algorithm
  h := 0;
  annotation (Documentation(info="<html>
Dummy function that returns <code>0</code>.
</html>", revisions="<html>
<ul>
<li>
April 27, 2011, by Michael Wetter:<br/>
First implementation to allow using the room model with a medium that does not contain water vapor.
</li>
</ul>
</html>"));
end enthalpyOfCondensingGas;

replaceable function saturationPressure
    "Return saturation pressure of condensing fluid"
  extends Modelica.Icons.Function;
  input Temperature Tsat "Saturation temperature";
  output AbsolutePressure psat "Saturation pressure";
algorithm
  psat := 0;
  annotation (Documentation(info="<html>
Dummy function that returns <code>0</code>.
</html>", revisions="<html>
<ul>
<li>
April 27, 2011, by Michael Wetter:<br/>
First implementation to allow using the room model with a medium that does not contain water vapor.
</li>
</ul>
</html>"));
end saturationPressure;

  annotation (preferredView="info", Documentation(info="<html>
<p>
This medium model is identical to
<a href=\"modelica://Modelica.Media.Air.SimpleAir\">
Modelica.Media.Air.SimpleAir</a>, except the
equation <code>d = p/(R*T)</code> has been replaced with
<code>d/dStp = p/pStp</code> where
<code>pStd</code> and <code>dStp</code> are constants for a reference
temperature and density.
</p>
<p>
This new formulation often leads to smaller systems of nonlinear equations
because pressure and temperature are decoupled, at the expense of accuracy.
</p>
<p>
As in
<a href=\"modelica://Modelica.Media.Air.SimpleAir\">
Modelica.Media.Air.SimpleAir</a>, the
specific enthalpy h and specific internal energy u are only
a function of temperature T and all other provided medium
quantities are constant.
</p>
</html>", revisions="<html>
<ul>
<li>
March 29, 2013, by Michael Wetter:<br/>
Added qualifier <code>final</code> to <code>standardOrderComponents=true</code> in the
<code>BaseProperties</code> declaration. This avoids an error
when models are checked in Dymola 2014 in the pedenatic mode.
</li>
<li>
August 3, 2011, by Michael Wetter:<br/>
Fixed bug in <code>u=h-R*T</code>, which is only valid for ideal gases.
For this medium, the function is <code>u=h-pStd/dStp</code>.
</li>
<li>
April 27, 2011, by Michael Wetter:<br/>
Added function <code>enthalpyOfCondensingGas</code>, which returns <code>0</code>,
to allow using the room model with a medium that does not contain water vapor.
</li><li>
August 21, 2008, by Michael Wetter:<br/>
Replaced <code>d*pStp = p*dStp</code> by
<code>d/dStp = p/pStp</code> to indicate that division by
<code>dStp</code> and <code>pStp</code> is allowed.
</li>
<li>
March 19, 2008, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end SimpleAir;
