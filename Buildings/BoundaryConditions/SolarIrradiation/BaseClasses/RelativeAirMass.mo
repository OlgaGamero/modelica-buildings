within Buildings.BoundaryConditions.SolarIrradiation.BaseClasses;
block RelativeAirMass "Relative air mass"
  extends Modelica.Blocks.Icons.Block;
public
  Modelica.Blocks.Interfaces.RealInput zen(
    quantity="Angle",
    unit="rad",
    displayUnit="degree") "Zenith angle of the sun beam"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Interfaces.RealOutput relAirMas "Relative air mass"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
protected
  Real zenLim;
  Real zenDeg;
equation
  zenLim = Buildings.Utilities.Math.Functions.smoothMin(
    zen,
    Modelica.Constants.pi/2,
    0.01);
  zenDeg = zenLim*180/Modelica.Constants.pi;
  relAirMas = 1/(Modelica.Math.cos(zenLim) + 0.15*(93.9 - zenDeg)^(-1.253));
  annotation (
    defaultComponentName="relAirMas",
    Documentation(info="<html>
<p>
This component computes the relative air mass for sky brightness.
</p>
<h4>References</h4>
R. Perez (1999).
<i>Fortran Function irrpz.f</i>,
Emailed by R. Perez to F.C. Winkelmann on May 21, 1999.<br/>
</html>", revisions="<html>
<ul>
<li>
July 07, 2010, by Wangda Zuo:<br/>
First implementation.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{100,
            100}}), graphics={Text(
          extent={{-150,110},{150,150}},
          textString="%name",
          lineColor={0,0,255})}));
end RelativeAirMass;
