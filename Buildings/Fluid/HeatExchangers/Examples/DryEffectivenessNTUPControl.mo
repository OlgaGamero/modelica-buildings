within Buildings.Fluid.HeatExchangers.Examples;
model DryEffectivenessNTUPControl
  "Model that demonstrates use of a heat exchanger without condensation that uses the epsilon-NTU relation with feedback control"
  extends Modelica.Icons.Example;

 package Medium1 = Buildings.Media.ConstantPropertyLiquidWater;
 //package Medium2 = Buildings.Media.PerfectGases.MoistAir;
 //package Medium2 = Buildings.Media.GasesPTDecoupled.MoistAir;
 // package Medium2 = Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated;
 package Medium2 = Buildings.Media.GasesPTDecoupled.SimpleAir;
  parameter Modelica.SIunits.Temperature T_a1_nominal = 60+273.15
    "Temperature at nominal conditions as port a1";
  parameter Modelica.SIunits.Temperature T_b1_nominal = 50+273.15
    "Temperature at nominal conditions as port b1";
  parameter Modelica.SIunits.Temperature T_a2_nominal = 20+273.15
    "Temperature at nominal conditions as port a2";
  parameter Modelica.SIunits.Temperature T_b2_nominal = 40+273.15
    "Temperature at nominal conditions as port b2";
  parameter Modelica.SIunits.MassFlowRate m1_flow_nominal = 5
    "Nominal mass flow rate medium 1";
  parameter Modelica.SIunits.MassFlowRate m2_flow_nominal = m1_flow_nominal*4200/1000*(T_a1_nominal-T_b1_nominal)/(T_b2_nominal-T_a2_nominal)
    "Nominal mass flow rate medium 2";

  Buildings.Fluid.Sources.Boundary_pT sin_2(                       redeclare
      package Medium = Medium2,
    use_p_in=false,
    p(displayUnit="Pa") = 101325,
    T=303.15,
    nPorts=1)             annotation (Placement(transformation(extent={{-52,10},
            {-32,30}})));
  Buildings.Fluid.Sources.Boundary_pT sou_2(                       redeclare
      package Medium = Medium2,
    nPorts=1,
    use_p_in=false,
    use_T_in=false,
    p(displayUnit="Pa") = 101625,
    T=T_a2_nominal)              annotation (Placement(transformation(extent={{140,10},
            {120,30}})));
  Buildings.Fluid.Sources.Boundary_pT sin_1(                       redeclare
      package Medium = Medium1,
    use_p_in=false,
    p=300000,
    T=293.15,
    nPorts=1)             annotation (Placement(transformation(extent={{140,50},
            {120,70}})));
  Buildings.Fluid.Sources.Boundary_pT sou_1(
    redeclare package Medium = Medium1,
    p=300000 + 9000,
    nPorts=1,
    use_T_in=false,
    T=T_a1_nominal)              annotation (Placement(transformation(extent={{-50,50},
            {-30,70}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort temSen(redeclare package Medium =
        Medium2, m_flow_nominal=m2_flow_nominal)
                 annotation (Placement(transformation(extent={{40,10},{20,30}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage val(
    redeclare package Medium = Medium1,
    l=0.005,
    m_flow_nominal=m1_flow_nominal,
    dpFixed_nominal=2000 + 3000,
    dpValve_nominal=6000) "Valve model"
             annotation (Placement(transformation(extent={{30,50},{50,70}})));
  Buildings.Controls.Continuous.LimPID P(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    Ti=30,
    k=0.1,
    Td=1)                             annotation (Placement(transformation(
          extent={{-24,80},{-4,100}})));
  Modelica.Blocks.Sources.Pulse     TSet(
    amplitude=5,
    period=3600,
    offset=273.15 + 22) "Setpoint temperature"
    annotation (Placement(transformation(extent={{-70,80},{-50,100}})));
  Buildings.Fluid.HeatExchangers.DryEffectivenessNTU hex(
    redeclare package Medium1 = Medium1,
    redeclare package Medium2 = Medium2,
    show_T=true,
    m1_flow_nominal=m1_flow_nominal,
    m2_flow_nominal=m2_flow_nominal,
    Q_flow_nominal=m1_flow_nominal*4200*(T_a1_nominal-T_b1_nominal),
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
    T_a1_nominal=T_a1_nominal,
    T_a2_nominal=T_a2_nominal,
    dp1_nominal(displayUnit="Pa") = 0,
    dp2_nominal(displayUnit="Pa") = 200 + 100)
                         annotation (Placement(transformation(extent={{60,16},{
            80,36}})));

  inner Modelica.Fluid.System system
    annotation (Placement(transformation(extent={{-80,-80},{-60,-60}})));
equation
  connect(val.port_b, hex.port_a1)                   annotation (Line(points={{50,60},
          {52,60},{52,32},{60,32}},        color={0,127,255}));
  connect(sou_1.ports[1], val.port_a) annotation (Line(
      points={{-30,60},{30,60}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(sou_2.ports[1], hex.port_a2) annotation (Line(
      points={{120,20},{80,20}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(hex.port_b2, temSen.port_a) annotation (Line(
      points={{60,20},{40,20}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(TSet.y, P.u_s) annotation (Line(
      points={{-49,90},{-26,90}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(temSen.T, P.u_m) annotation (Line(
      points={{30,31},{30,40},{-14,40},{-14,78}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(P.y, val.y) annotation (Line(
      points={{-3,90},{40,90},{40,72}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(hex.port_b1, sin_1.ports[1]) annotation (Line(
      points={{80,32},{100,32},{100,60},{120,60}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(temSen.port_b, sin_2.ports[1]) annotation (Line(
      points={{20,20},{-32,20}},
      color={0,127,255},
      smooth=Smooth.None));
  annotation(Diagram(coordinateSystem(preserveAspectRatio=true,  extent={{-100,
            -100},{200,200}})),
experiment(StopTime=3600),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/HeatExchangers/Examples/DryEffectivenessNTUPControl.mos"
        "Simulate and plot"),
Documentation(info="<html>
<p>
This model demonstrates the use of
<a href=\"modelica://Buildings.Fluid.HeatExchangers.DryEffectivenessNTU\">
Buildings.Fluid.HeatExchangers.DryEffectivenessNTU</a>.
The valve on the water-side is regulated to track a setpoint temperature
for the air outlet.
</p>
</html>",
revisions="<html>
<ul>
<li>
July 3, 2014, by Michael Wetter:<br/>
Changed pressure sink to mass flow rate sink to avoid an overdetermined
by consistent set of initial conditions.
</li>
<li>
March 1, 2013, by Michael Wetter:<br/>
Added nominal pressure drop for valve as
this parameter no longer has a default value.
</li>
</ul>
</html>"));
end DryEffectivenessNTUPControl;
