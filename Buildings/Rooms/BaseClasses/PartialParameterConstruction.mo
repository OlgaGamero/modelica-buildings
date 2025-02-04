within Buildings.Rooms.BaseClasses;
record PartialParameterConstruction "Partial record for constructions"
  extends Modelica.Icons.Record;
  parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic
    layers "Material properties of opaque construction"
    annotation(Dialog(group="Opaque construction"),
               choicesAllMatching=true, Placement(transformation(extent={{146,258},
            {166,278}})));
  parameter Modelica.SIunits.Angle til "Surface tilt";
  parameter Modelica.SIunits.Angle azi "Surface azimuth";
  final parameter Boolean isFloor=til > 2.74889125 and til < 3.53428875
    "Flag, true if construction is a floor" annotation (Evaluate=true);
  final parameter Boolean isCeiling=til > -0.392699 and til < 0.392699
    "Flag, true if construction is a floor" annotation (Evaluate=true);
  final parameter Integer nLay(min=1, fixed=true) = layers.nLay
    "Number of layers";
  final parameter Integer nSta[nLay](each min=1)={layers.material[i].nSta for i in 1:nLay}
    "Number of states"  annotation(Evaluate=true);
  parameter Boolean steadyStateInitial=false
    "=true initializes dT(0)/dt=0, false initializes T(0) at fixed temperature using T_a_start and T_b_start"
        annotation (Dialog(group="Initialization"), Evaluate=true);
  parameter Modelica.SIunits.Temperature T_a_start=293.15
    "Initial temperature at port_a, used if steadyStateInitial = false"
    annotation (Dialog(group="Initialization", enable=not steadyStateInitial));
  parameter Modelica.SIunits.Temperature T_b_start=293.15
    "Initial temperature at port_b, used if steadyStateInitial = false"
    annotation (Dialog(group="Initialization", enable=not steadyStateInitial));

  annotation (
Documentation(info="<html>
<p>
This data record is used to set the parameters of constructions that do not have a window.
</p>
<p>
The surface azimuth is defined in
<a href=\"modelica://Buildings.HeatTransfer.Types.Azimuth\">
Buildings.HeatTransfer.Types.Azimuth</a>
and the surface tilt is defined in <a href=\"modelica://Buildings.HeatTransfer.Types.Tilt\">
Buildings.HeatTransfer.Types.Tilt</a>
</p>
</html>", revisions="<html>
<ul>
<li>
October 11, 2013, by Michael Wetter:<br/>
Added missing <code>each</code> keyword.
</li>
<li>
December 14, 2010, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));

end PartialParameterConstruction;
