within Buildings.BoundaryConditions.SolarGeometry.BaseClasses;
block IncidenceAngle "The solar incidence angle on a tilted surface"
  extends Modelica.Blocks.Icons.Block;
public
  parameter Modelica.SIunits.Angle lat "Latitude";
  parameter Modelica.SIunits.Angle azi(displayUnit="degree")
    "Surface azimuth. azi=-90 degree if surface outward unit normal points toward east; azi=0 if it points toward south";
  parameter Modelica.SIunits.Angle til(displayUnit="degree")
    "Surface tilt. til=90 degree for walls; til=0 for ceilings; til=180 for roof";
  Modelica.Blocks.Interfaces.RealInput solHouAng(quantity="Angle", unit="rad")
    "Solar hour angle"
    annotation (Placement(transformation(extent={{-140,-68},{-100,-28}})));
  Modelica.Blocks.Interfaces.RealInput decAng(quantity="Angle", unit="rad")
    "Declination"
    annotation (Placement(transformation(extent={{-142,34},{-102,74}})));
  Modelica.Blocks.Interfaces.RealOutput incAng(
    final quantity="Angle",
    final unit="rad",
    displayUnit="deg") "Incidence angle on a tilted surfce"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
protected
  Real dec_c=Modelica.Math.cos(decAng);
  Real dec_s=Modelica.Math.sin(decAng);
  Real sol_c=Modelica.Math.cos(solHouAng);
  Real sol_s=Modelica.Math.sin(solHouAng);
  Real lat_c=Modelica.Math.cos(lat);
  Real lat_s=Modelica.Math.sin(lat);
equation
  incAng = Modelica.Math.acos(Modelica.Math.cos(til)*(dec_c*sol_c*lat_c + dec_s
    *lat_s) + Modelica.Math.sin(til)*(Modelica.Math.sin(azi)*dec_c*sol_s +
    Modelica.Math.cos(azi)*(dec_c*sol_c*lat_s - dec_s*lat_c))) "(A.4.13)";
  annotation (
    defaultComponentName="incAng",
    Documentation(info="<html>
<p>
This component computes the solar incidence angle on a tilted surface using the solar hour angle and the declination angle as input.
</p>
</html>", revisions="<html>
<ul>
<li>
Dec 7, 2010, by Michael Wetter:<br/>
Rewrote equation in explicit form to avoid nonlinear equations in room model.
</li>
<li>
May 19, 2010, by Wangda Zuo:<br/>
First implementation.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{100,
            100}}), graphics={
        Text(
          extent={{-150,110},{150,150}},
          textString="%name",
          lineColor={0,0,255}),
        Text(
          extent={{-98,60},{-56,50}},
          lineColor={0,0,127},
          textString="decAng"),
        Text(
          extent={{-98,-42},{-42,-54}},
          lineColor={0,0,127},
          textString="solHouAng"),
        Bitmap(extent={{-90,92},{90,-94}}, fileName=
              "modelica://Buildings/Resources/Images/BoundaryConditions/SolarGeometry/BaseClasses/IncidenceAngle.png")}));
end IncidenceAngle;
