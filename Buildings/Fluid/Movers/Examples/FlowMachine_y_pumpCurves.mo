within Buildings.Fluid.Movers.Examples;
model FlowMachine_y_pumpCurves
  "Pumps that illustrates the use of the pump curves"
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.ConstantPropertyLiquidWater "Medium model";

  parameter Modelica.SIunits.MassFlowRate m_flow_nominal = 0.5
    "Nominal mass flow rate";
  parameter Modelica.SIunits.Pressure dp_nominal = 10000 "Nominal pressure";

   model pumpModel = Buildings.Fluid.Movers.FlowMachine_y (
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    dynamicBalance=false,
    pressure(V_flow=2/1000*m_flow_nominal*{0.2, 0.4, 0.6, 0.8},
                  dp=dp_nominal*{0.9, 0.85, 0.6, 0.2}))
    "Declaration of pump model";

  pumpModel pum(filteredSpeed=false) "Pump"
    annotation (Placement(transformation(extent={{40,80},{60,100}})));
  pumpModel pum1(filteredSpeed=false) "Pump"
    annotation (Placement(transformation(extent={{40,38},{60,58}})));
  pumpModel pum2(filteredSpeed=false) "Pump"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  pumpModel pum3(filteredSpeed=false) "Pump"
    annotation (Placement(transformation(extent={{40,-60},{60,-40}})));

  Modelica.Blocks.Sources.Ramp y(
    offset=1,
    duration=0.5,
    startTime=0.25,
    height=-1) "Input signal"
                 annotation (Placement(transformation(extent={{-80,120},{-60,140}})));
  Buildings.Fluid.Sources.Boundary_pT sou(
    redeclare package Medium = Medium,
    use_p_in=false,
    p=300000,
    T=293.15,
    nPorts=4) annotation (Placement(transformation(extent={{-70,78},{-50,98}})));


  Buildings.Fluid.Sources.Boundary_pT sou1(
    redeclare package Medium = Medium,
    use_p_in=false,
    nPorts=4,
    p(displayUnit="Pa") = 300000,
    T=293.15) annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=180,
        origin={128,88})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear dp1(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=0.01*dp_nominal,
    filteredOpening=false) "Pressure drop"
    annotation (Placement(transformation(extent={{-20,80},{0,100}})));
  Modelica.Blocks.Sources.Constant
                               y1(k=1) "Input signal"
                 annotation (Placement(transformation(extent={{20,120},{40,140}})));

  Buildings.Fluid.Actuators.Valves.TwoWayLinear dp2(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=0.01*dp_nominal,
    filteredOpening=false) "Pressure drop"
    annotation (Placement(transformation(extent={{-20,38},{0,58}})));
  Modelica.Blocks.Sources.Constant
                               y2(k=0.5) "Input signal"
                 annotation (Placement(transformation(extent={{8,60},{28,80}})));

  Buildings.Fluid.Actuators.Valves.TwoWayLinear dp3(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=0.01*dp_nominal,
    filteredOpening=false) "Pressure drop"
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Modelica.Blocks.Sources.Constant
                               y3(k=0.05) "Input signal"
                 annotation (Placement(transformation(extent={{8,12},{28,32}})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear dp4(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=0.01*dp_nominal,
    filteredOpening=false) "Pressure drop"
    annotation (Placement(transformation(extent={{-20,-60},{0,-40}})));
  Modelica.Blocks.Sources.Constant
                               y4(k=0.01) "Input signal"
                 annotation (Placement(transformation(extent={{8,-38},{28,-18}})));
equation
  connect(dp1.port_b, pum.port_a)      annotation (Line(
      points={{5.55112e-16,90},{40,90}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(dp1.port_a, sou.ports[1]) annotation (Line(
      points={{-20,90},{-31,90},{-31,91},{-50,91}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(y1.y, pum.y)      annotation (Line(
      points={{41,130},{50,130},{50,102}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(y.y, dp1.y) annotation (Line(
      points={{-59,130},{-10,130},{-10,102}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(dp2.port_b, pum1.port_a)     annotation (Line(
      points={{5.55112e-16,48},{40,48}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(y.y,dp2. y) annotation (Line(
      points={{-59,130},{-26,130},{-26,68},{-10,68},{-10,60}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(sou.ports[2], dp2.port_a) annotation (Line(
      points={{-50,89},{-32,89},{-32,48},{-20,48}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(y2.y, pum1.y) annotation (Line(
      points={{29,70},{50,70},{50,60}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(dp3.port_b, pum2.port_a)     annotation (Line(
      points={{5.55112e-16,6.10623e-16},{10,6.10623e-16},{10,0},{20,0},{20,
          6.10623e-16},{40,6.10623e-16}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(y.y,dp3. y) annotation (Line(
      points={{-59,130},{-26,130},{-26,20},{-10,20},{-10,12}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(y3.y, pum2.y) annotation (Line(
      points={{29,22},{50,22},{50,12}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(dp3.port_a, sou.ports[3]) annotation (Line(
      points={{-20,6.10623e-16},{-28,0},{-36,0},{-36,86},{-50,86},{-50,87}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(dp4.port_b, pum3.port_a)     annotation (Line(
      points={{5.55112e-16,-50},{40,-50}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(y.y,dp4. y) annotation (Line(
      points={{-59,130},{-26,130},{-26,-30},{-10,-30},{-10,-38}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(y4.y, pum3.y) annotation (Line(
      points={{29,-28},{50,-28},{50,-38}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(dp4.port_a, sou.ports[4]) annotation (Line(
      points={{-20,-50},{-38,-50},{-38,85},{-50,85}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(pum3.port_b, sou1.ports[1]) annotation (Line(
      points={{60,-50},{110,-50},{110,85},{118,85}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(pum2.port_b, sou1.ports[2]) annotation (Line(
      points={{60,6.10623e-16},{80,6.10623e-16},{80,0},{106,0},{106,87},{118,87}},
      color={0,127,255},
      smooth=Smooth.None));

  connect(pum1.port_b, sou1.ports[3]) annotation (Line(
      points={{60,48},{104,48},{104,89},{118,89}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(pum.port_b, sou1.ports[4]) annotation (Line(
      points={{60,90},{89,90},{89,91},{118,91}},
      color={0,127,255},
      smooth=Smooth.None));
  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{160,
            160}})),
experiment(StopTime=1.0),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/Movers/Examples/FlowMachine_y_pumpCurves.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
This example demonstrates how the pump curves changes for different (constant) input
signal <code>y</code>.
If <code>y &ge; delta = 0.05</code>, the pump curves are polynomials.
For <code>y &lt; delta = 0.05</code>, the pump curves convert to linear functions to
avoid a singularity at the origin.
</p>
</html>", revisions="<html>
<ul>
<li>March 24 2010, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end FlowMachine_y_pumpCurves;
