within Buildings.Fluid.Sensors.Examples;
model MassFraction
  extends Modelica.Icons.Example;
  import Buildings;

  package Medium = Buildings.Media.PerfectGases.MoistAirUnsaturated
    "Medium model";

  Buildings.Fluid.Sources.Boundary_pT sin(             redeclare package Medium
      = Medium,
    T=293.15,
    nPorts=1)                                       annotation (Placement(
        transformation(extent={{90,0},{70,20}},  rotation=0)));
  Buildings.Fluid.Sources.MassFlowSource_T masFloRat(
    redeclare package Medium = Medium,
    use_m_flow_in=false,
    use_T_in=false,
    X={0.02,0.98},
    m_flow=10,
    nPorts=1)                            annotation (Placement(transformation(
          extent={{-80,0},{-60,20}},  rotation=0)));
  inner Modelica.Fluid.System system
    annotation (Placement(transformation(extent={{80,-100},{100,-80}})));
  Buildings.Fluid.Sensors.MassFraction senMasFra2(redeclare package Medium =
        Medium) "Mass fraction"
    annotation (Placement(transformation(extent={{20,36},{40,56}})));
  Buildings.Fluid.MixingVolumes.MixingVolume vol(
    redeclare package Medium = Medium,
    V=1,
    nPorts=3) "Volume"
    annotation (Placement(transformation(extent={{0,10},{20,30}})));
  Buildings.Fluid.FixedResistances.FixedResistanceDpM dp(
    redeclare package Medium = Medium,
    m_flow_nominal=10,
    dp_nominal=200)
    annotation (Placement(transformation(extent={{40,0},{60,20}})));
  Buildings.Fluid.Sensors.MassFractionTwoPort senMasFra1(redeclare package
      Medium = Medium, m_flow_nominal=10)
    annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
equation
  connect(dp.port_b, sin.ports[1]) annotation (Line(
      points={{60,10},{70,10}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(masFloRat.ports[1], senMasFra1.port_a) annotation (Line(
      points={{-60,10},{-40,10}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(senMasFra1.port_b, vol.ports[1]) annotation (Line(
      points={{-20,10},{7.33333,10}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(vol.ports[2], dp.port_a) annotation (Line(
      points={{10,10},{40,10}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(vol.ports[3], senMasFra2.port) annotation (Line(
      points={{12.6667,10},{30,10},{30,36}},
      color={0,127,255},
      smooth=Smooth.None));
    annotation (Diagram(coordinateSystem(preserveAspectRatio=true,  extent={{-100,
            -100},{100,100}}),
                        graphics),
             __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/Sensors/Examples/MassFraction.mos" "Simulate and plot"),
    Documentation(info="<html>
This examples is a unit test for the mass fraction sensor.
</html>", revisions="<html>
<ul>
<li>
April 7, 2009 by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"));
end MassFraction;
