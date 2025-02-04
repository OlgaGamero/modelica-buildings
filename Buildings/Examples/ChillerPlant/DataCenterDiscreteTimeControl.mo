within Buildings.Examples.ChillerPlant;
model DataCenterDiscreteTimeControl
  "Primary only chiller plant system with water-side economizer"
  extends Modelica.Icons.Example;
  package MediumAir = Buildings.Media.GasesPTDecoupled.SimpleAir "Medium model";
  package MediumCHW = Buildings.Media.ConstantPropertyLiquidWater
    "Medium model";
  package MediumCW = Buildings.Media.ConstantPropertyLiquidWater "Medium model";
  parameter Modelica.SIunits.MassFlowRate mAir_flow_nominal=roo.QRoo_flow/(1005
      *15) "Nominal mass flow rate at fan";
  parameter Modelica.SIunits.Power P_nominal=80E3
    "Nominal compressor power (at y=1)";
  parameter Modelica.SIunits.TemperatureDifference dTEva_nominal=10
    "Temperature difference evaporator inlet-outlet";
  parameter Modelica.SIunits.TemperatureDifference dTCon_nominal=10
    "Temperature difference condenser outlet-inlet";
  parameter Real COPc_nominal=3 "Chiller COP";
  parameter Modelica.SIunits.MassFlowRate mCHW_flow_nominal=2*roo.QRoo_flow/(
      4200*20) "Nominal mass flow rate at chilled water";

  parameter Modelica.SIunits.MassFlowRate mCW_flow_nominal=2*roo.QRoo_flow/(
      4200*6) "Nominal mass flow rate at condenser water";

  parameter Modelica.SIunits.Pressure dp_nominal=500
    "Nominal pressure difference";
  Buildings.Fluid.Movers.FlowMachine_m_flow fan(
    redeclare package Medium = MediumAir,
    m_flow_nominal=mAir_flow_nominal,
    dp(start=249),
    m_flow(start=mAir_flow_nominal),
    filteredSpeed=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    T_start=293.15) "Fan for air flow through the data center"
    annotation (Placement(transformation(extent={{348,-235},{328,-215}})));
  Buildings.Fluid.HeatExchangers.DryCoilCounterFlow cooCoi(
    redeclare package Medium1 = MediumCHW,
    redeclare package Medium2 = MediumAir,
    m2_flow_nominal=mAir_flow_nominal,
    m1_flow_nominal=mCHW_flow_nominal,
    m1_flow(start=mCHW_flow_nominal),
    m2_flow(start=mAir_flow_nominal),
    dp1_nominal(displayUnit="Pa") = 1000,
    dp2_nominal=249*3,
    UA_nominal=mAir_flow_nominal*1006*5,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    "Cooling coil"
    annotation (Placement(transformation(extent={{298,-185},{278,-165}})));
  Modelica.Blocks.Sources.Constant mFanFlo(k=mAir_flow_nominal)
    "Mass flow rate of fan" annotation (Placement(transformation(extent={{298,
            -210},{318,-190}})));
  BaseClasses.SimplifiedRoom roo(
    redeclare package Medium = MediumAir,
    nPorts=2,
    rooLen=50,
    rooWid=30,
    rooHei=3,
    m_flow_nominal=mAir_flow_nominal,
    QRoo_flow=500000) "Room model" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={248,-238})));
  inner Modelica.Fluid.System system(T_ambient=283.15)
    annotation (Placement(transformation(extent={{-322,-151},{-302,-131}})));
  Fluid.Movers.FlowMachine_dp pumCHW(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=mCHW_flow_nominal,
    m_flow(start=mCHW_flow_nominal),
    dp(start=325474),
    filteredSpeed=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Chilled water pump"                      annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=270,
        origin={218,-120})));
  Buildings.Fluid.Storage.ExpansionVessel expVesCHW(redeclare package Medium =
        MediumCHW, V_start=1) "Expansion vessel"
    annotation (Placement(transformation(extent={{248,-147},{268,-127}})));
  Buildings.Fluid.HeatExchangers.CoolingTowers.YorkCalc cooTow(
    redeclare package Medium = MediumCW,
    m_flow_nominal=mCW_flow_nominal,
    PFan_nominal=6000,
    TAirInWB_nominal(displayUnit="degC") = 283.15,
    TApp_nominal=6,
    dp_nominal=14930 + 14930 + 74650,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    "Cooling tower"                                   annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        origin={269,239})));
  Buildings.Fluid.Movers.FlowMachine_m_flow pumCW(
    redeclare package Medium = MediumCW,
    m_flow_nominal=mCW_flow_nominal,
    dp(start=214992),
    filteredSpeed=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Condenser water pump"                      annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=270,
        origin={358,200})));
  Buildings.Fluid.HeatExchangers.ConstantEffectiveness wse(
    redeclare package Medium1 = MediumCW,
    redeclare package Medium2 = MediumCHW,
    m1_flow_nominal=mCW_flow_nominal,
    m2_flow_nominal=mCHW_flow_nominal,
    eps=0.8,
    dp2_nominal=0,
    dp1_nominal=0) "Water side economizer (Heat exchanger)"
    annotation (Placement(transformation(extent={{126,83},{106,103}})));
  Fluid.Actuators.Valves.TwoWayLinear val5(
    redeclare package Medium = MediumCW,
    m_flow_nominal=mCW_flow_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=89580,
    y_start=1,
    filteredOpening=false) "Control valve for condenser water loop of chiller"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={218,180})));
  Fluid.Actuators.Valves.TwoWayLinear val1(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=mCHW_flow_nominal,
    dpValve_nominal=20902,
    filteredOpening=false)
    "Bypass control valve for economizer. 1: disable economizer, 0: enable economoizer"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={218,-40})));
  Buildings.Fluid.Storage.ExpansionVessel expVesChi(redeclare package Medium =
        MediumCW, V_start=1)
    annotation (Placement(transformation(extent={{236,143},{256,163}})));
  Buildings.Examples.ChillerPlant.BaseClasses.Controls.WSEControl wseCon
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={-150,-29})));
  Modelica.Blocks.Sources.RealExpression expTowTApp(y=cooTow.TApp_nominal)
    "Cooling tower approach" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={-212,-20})));
  Fluid.Chillers.ElectricEIR chi(
    redeclare package Medium1 = MediumCW,
    redeclare package Medium2 = MediumCHW,
    m1_flow_nominal=mCW_flow_nominal,
    m2_flow_nominal=mCHW_flow_nominal,
    dp2_nominal=0,
    dp1_nominal=0,
    per=Buildings.Fluid.Chillers.Data.ElectricEIR.ElectricEIRChiller_Carrier_19XR_742kW_5_42COP_VSD(),
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    annotation (Placement(transformation(extent={{274,83},{254,103}})));
  Fluid.Actuators.Valves.TwoWayLinear val6(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=mCHW_flow_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=14930 + 89580,
    y_start=1,
    filteredOpening=false)
    "Control valve for chilled water leaving from chiller" annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=270,
        origin={358,40})));
  Buildings.Examples.ChillerPlant.BaseClasses.Controls.ChillerSwitch chiSwi(
      deaBan(displayUnit="K") = 2.2)
    "Control unit switching chiller on or off "
    annotation (Placement(transformation(extent={{-226,83},{-206,103}})));
  replaceable
    Buildings.Examples.ChillerPlant.BaseClasses.Controls.TrimAndRespond triAndRes(
    yEqu0=0,
    samplePeriod=120,
    uTri=0,
    yDec=-0.03,
    yInc=0.03) constrainedby Modelica.Blocks.Icons.Block
    "Trim and respond logic"
    annotation (Placement(transformation(extent={{-160,190},{-140,210}})));
  Buildings.Examples.ChillerPlant.BaseClasses.Controls.LinearPiecewiseTwo
    linPieTwo(
    x0=0,
    x2=1,
    x1=0.5,
    y11=1,
    y21=273.15 + 5.56,
    y10=0.2,
    y20=273.15 + 22) "Translate the control signal for chiller setpoint reset"
    annotation (Placement(transformation(extent={{-120,190},{-100,210}})));
  Modelica.Blocks.Sources.Constant TAirSet(k=273.15 + 27)
    "Set temperature for air supply to the room" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={-230,170})));
  Modelica.Blocks.Math.BooleanToReal chiCon "Contorl signal for chiller"
    annotation (Placement(transformation(extent={{-160,40},{-140,60}})));
  Fluid.Actuators.Valves.TwoWayLinear val4(
    redeclare package Medium = MediumCW,
    m_flow_nominal=mCW_flow_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=59720,
    y_start=0,
    filteredOpening=false)
    "Control valve for condenser water loop of economizer" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={98,180})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TAirSup(redeclare package Medium
      = MediumAir, m_flow_nominal=mAir_flow_nominal)
    "Supply air temperature to data center" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        origin={288,-225})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TCHWEntChi(redeclare package
      Medium = MediumCHW, m_flow_nominal=mCHW_flow_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=270,
        origin={218,0})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TCWLeaTow(redeclare package Medium
      = MediumCW, m_flow_nominal=mCW_flow_nominal)
    "Temperature of condenser water leaving the cooling tower"      annotation (
     Placement(transformation(
        extent={{10,-10},{-10,10}},
        origin={330,119})));
  Modelica.Blocks.Sources.Constant cooTowFanCon(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={230,271})));
  Fluid.Actuators.Valves.TwoWayEqualPercentage valByp(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=mCHW_flow_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=14930,
    y_start=0,
    filteredOpening=false) "Bypass valve for chiller."
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={288,20})));
  Buildings.Examples.ChillerPlant.BaseClasses.Controls.KMinusU KMinusU(k=1)
    annotation (Placement(transformation(extent={{-60,28},{-40,48}})));
  Fluid.Actuators.Valves.TwoWayLinear val3(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=mCHW_flow_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=59720 + 1000,
    filteredOpening=false)
    "Control valve for economizer. 0: disable economizer, 1: enable economoizer"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        origin={118,-60})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TCHWLeaCoi(redeclare package
      Medium = MediumCHW, m_flow_nominal=mCHW_flow_nominal)
    "Temperature of chilled water leaving the cooling coil"
                                                     annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=270,
        origin={218,-80})));
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaData(filNam=
        "modelica://Buildings/Resources/weatherdata/USA_CA_San.Francisco.Intl.AP.724940_TMY3.mos")
    annotation (Placement(transformation(extent={{-360,-100},{-340,-80}})));
  BoundaryConditions.WeatherData.Bus weaBus
    annotation (Placement(transformation(extent={{-332,-98},{-312,-78}})));
  Fluid.FixedResistances.FixedResistanceDpM res(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=mCHW_flow_nominal,
    dp_nominal=89580)
    annotation (Placement(transformation(extent={{328,-170},{348,-150}})));
  Modelica.Blocks.Math.Gain gain(k=20*6485)
    annotation (Placement(transformation(extent={{-60,90},{-40,110}})));
  Modelica.Blocks.Math.Feedback feedback
    annotation (Placement(transformation(extent={{-210,190},{-190,210}})));
  Modelica.Blocks.Logical.GreaterThreshold greaterThreshold
    annotation (Placement(transformation(extent={{-10,190},{10,210}})));
  Modelica.Blocks.Logical.Or or1
    annotation (Placement(transformation(extent={{20,190},{40,210}})));
  Modelica.Blocks.Math.BooleanToReal mCWFlo(realTrue=mCW_flow_nominal)
    "Mass flow rate of condensor loop"
    annotation (Placement(transformation(extent={{60,190},{80,210}})));
  Modelica.Blocks.Sources.RealExpression PHVAC(y=fan.P + pumCHW.P + pumCW.P +
        cooTow.PFan + chi.P) "Power consumed by HVAC system"
                             annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={-290,-250})));
  Modelica.Blocks.Sources.RealExpression PIT(y=roo.QSou.Q_flow)
    "Power consumed by IT"   annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={-290,-280})));
  Modelica.Blocks.Continuous.Integrator EHVAC(initType=Modelica.Blocks.Types.Init.InitialState,
      y_start=0) "Energy consumed by HVAC"
    annotation (Placement(transformation(extent={{-240,-260},{-220,-240}})));
  Modelica.Blocks.Continuous.Integrator EIT(initType=Modelica.Blocks.Types.Init.InitialState,
      y_start=0) "Energy consumed by IT"
    annotation (Placement(transformation(extent={{-240,-290},{-220,-270}})));
equation
  connect(expVesCHW.port_a, cooCoi.port_b1) annotation (Line(
      points={{258,-147},{258,-169},{278,-169}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(expTowTApp.y, wseCon.towTApp) annotation (Line(
      points={{-201,-20},{-178,-20},{-178,-32.75},{-162,-32.75}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(chiSwi.y, chiCon.u) annotation (Line(
      points={{-205,92.4},{-182,92.4},{-182,50},{-162,50}},
      color={255,0,255},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(cooTow.port_b, pumCW.port_a) annotation (Line(
      points={{279,239},{358,239},{358,210}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(val5.port_a, chi.port_b1) annotation (Line(
      points={{218,170},{218,99},{254,99}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(expVesChi.port_a, chi.port_b1) annotation (Line(
      points={{246,143},{246,99},{254,99}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(val4.port_a, wse.port_b1) annotation (Line(
      points={{98,170},{98,99},{106,99}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(chiSwi.y, chi.on) annotation (Line(
      points={{-205,92.4},{-182,92.4},{-182,129},{276,129},{276,96}},
      color={255,0,255},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(linPieTwo.y[2], chi.TSet) annotation (Line(
      points={{-99,200.3},{-82,200},{-64,200},{-64,125},{284,125},{284,90},{276,
          90}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(chiCon.y, val5.y) annotation (Line(
      points={{-139,50},{-80,50},{-80,60},{196,60},{196,180},{206,180}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(linPieTwo.y[2], chiSwi.TSet) annotation (Line(
      points={{-99,200.3},{-64,200.3},{-64,249},{-274,249},{-274,88},{-227,88}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));

  connect(cooTowFanCon.y, cooTow.y) annotation (Line(
      points={{241,271},{250,271},{250,247},{257,247}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(cooCoi.port_b2, fan.port_a) annotation (Line(
      points={{298,-181},{359,-181},{359,-225},{348,-225}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(mFanFlo.y, fan.m_flow_in) annotation (Line(
      points={{319,-200},{338.2,-200},{338.2,-213}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));

  connect(wse.port_a2, val3.port_b) annotation (Line(
      points={{106,87},{98,87},{98,-60},{108,-60}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(wseCon.y2, val1.y) annotation (Line(
      points={{-139,-34},{134,-34},{134,-40},{206,-40}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(wseCon.y1, val3.y) annotation (Line(
      points={{-139,-24},{58,-24},{58,-40},{118,-40},{118,-48}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(wseCon.y1, val4.y) annotation (Line(
      points={{-139,-24},{-20,-24},{-20,180},{86,180}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(TAirSup.port_a, fan.port_b) annotation (Line(
      points={{298,-225},{328,-225}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(roo.airPorts[1],TAirSup. port_b) annotation (Line(
      points={{249.85,-228},{249.85,-225},{278,-225}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(roo.airPorts[2], cooCoi.port_a2) annotation (Line(
      points={{246.15,-228},{246.15,-225},{218,-225},{218,-181},{278,-181}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(TCHWLeaCoi.port_a, pumCHW.port_b)
                                           annotation (Line(
      points={{218,-90},{218,-110}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(TCHWEntChi.port_b, valByp.port_a)
                                         annotation (Line(
      points={{218,10},{218,20},{278,20}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(TCHWEntChi.port_a, val1.port_b)
                                         annotation (Line(
      points={{218,-10},{218,-30}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(val1.port_a, TCHWLeaCoi.port_b)
                                         annotation (Line(
      points={{218,-50},{218,-70}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(val3.port_a, TCHWLeaCoi.port_b)
                                         annotation (Line(
      points={{128,-60},{218,-60},{218,-70}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(TCWLeaTow.port_b, chi.port_a1)
                                        annotation (Line(
      points={{320,119},{300,119},{300,99},{274,99}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(TCWLeaTow.port_b, wse.port_a1)
                                        annotation (Line(
      points={{320,119},{138,119},{138,99},{126,99}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(TCHWEntChi.T, chiSwi.chiCHWST)
                                        annotation (Line(
      points={{207,1.40998e-15},{-18,0},{-18,0},{-242,-2},{-242,100},{-227,100}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(wseCon.wseCWST, TCWLeaTow.T)
                                      annotation (Line(
      points={{-162,-37.625},{-300,-37.625},{-300,290},{380,290},{380,137},{330,
          137},{330,130}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(wseCon.wseCHWST, TCHWLeaCoi.T)
                                        annotation (Line(
      points={{-162,-22.75},{-176,-22.75},{-176,-80},{207,-80}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(weaData.weaBus, weaBus) annotation (Line(
      points={{-340,-90},{-331,-90},{-331,-88},{-322,-88}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(wseCon.TWetBul, weaBus.TWetBul) annotation (Line(
      points={{-162,-29},{-322,-29},{-322,-88}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(cooTow.TAir, weaBus.TWetBul) annotation (Line(
      points={{257,243},{82,243},{82,268},{-322,268},{-322,-88}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(TCHWEntChi.port_a, wse.port_b2)
                                         annotation (Line(
      points={{218,-10},{218,-20},{138,-20},{138,87},{126,87}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(valByp.port_b, val6.port_b)
                                    annotation (Line(
      points={{298,20},{358,20},{358,30}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(TCHWEntChi.port_b, chi.port_a2)
                                         annotation (Line(
      points={{218,10},{218,88},{254,88},{254,87}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(val5.port_b, cooTow.port_a) annotation (Line(
      points={{218,190},{218,239},{259,239}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(val4.port_b, cooTow.port_a) annotation (Line(
      points={{98,190},{98,239},{259,239}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(pumCW.port_b, TCWLeaTow.port_a)
                                         annotation (Line(
      points={{358,190},{358,119},{340,119}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));

  connect(cooCoi.port_a1, res.port_a) annotation (Line(
      points={{298,-169},{318,-169},{318,-160},{328,-160}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(chiCon.y, KMinusU.u) annotation (Line(
      points={{-139,50},{-80,50},{-80,38},{-61.8,38}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(KMinusU.y, valByp.y)
                             annotation (Line(
      points={{-39,38},{288,38},{288,32}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(chiCon.y, val6.y) annotation (Line(
      points={{-139,50},{-80,50},{-80,60},{338,60},{338,40},{346,40}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(linPieTwo.y[1], gain.u) annotation (Line(
      points={{-99,199.3},{-80,199.3},{-80,100},{-62,100}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(gain.y, pumCHW.dp_in) annotation (Line(
      points={{-39,100},{20,100},{20,-120.2},{206,-120.2}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));

  connect(triAndRes.y, linPieTwo.u) annotation (Line(
      points={{-139,200},{-122,200}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(TAirSet.y, feedback.u2) annotation (Line(
      points={{-219,170},{-200,170},{-200,192}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(TAirSup.T, feedback.u1) annotation (Line(
      points={{288,-214},{288,-202},{-264,-202},{-264,200},{-208,200}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(chi.port_b2, val6.port_a) annotation (Line(
      points={{274,87},{358,87},{358,50}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(res.port_b, val6.port_b) annotation (Line(
      points={{348,-160},{358,-160},{358,30}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(pumCHW.port_a, cooCoi.port_b1) annotation (Line(
      points={{218,-130},{218,-160},{258,-160},{258,-169},{278,-169}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(feedback.y, triAndRes.u) annotation (Line(
      points={{-191,200},{-162,200}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(greaterThreshold.u, wseCon.y1) annotation (Line(
      points={{-12,200},{-20,200},{-20,-24},{-139,-24}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(or1.u1, greaterThreshold.y) annotation (Line(
      points={{18,200},{11,200}},
      color={255,0,255},
      pattern=LinePattern.Dash,
      smooth=Smooth.None));
  connect(or1.u2, chiSwi.y) annotation (Line(
      points={{18,192},{18,192},{16,192},{16,192},{12,192},{12,128},{-182,128},
          {-182,92},{-205,92},{-205,92.4}},
      color={255,0,255},
      pattern=LinePattern.Dash,
      smooth=Smooth.None));
  connect(or1.y, mCWFlo.u) annotation (Line(
      points={{41,200},{58,200}},
      color={255,0,255},
      pattern=LinePattern.Dash,
      smooth=Smooth.None));
  connect(mCWFlo.y, pumCW.m_flow_in) annotation (Line(
      points={{81,200},{218,200},{218,200.2},{346,200.2}},
      color={0,0,127},
      pattern=LinePattern.Dash,
      smooth=Smooth.None));
  connect(PHVAC.y, EHVAC.u) annotation (Line(
      points={{-279,-250},{-242,-250}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(PIT.y, EIT.u) annotation (Line(
      points={{-279,-280},{-242,-280}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=false,extent={{-400,-300},{400,
            300}}), graphics),
    __Dymola_Commands(file=
          "modelica://Buildings/Resources/Scripts/Dymola/Examples/ChillerPlant/DataCenterDiscreteTimeControl.mos"
        "Simulate and plot"),
Documentation(info="<HTML>
<p>
This model is the chilled water plant with discrete time control and
trim and response logic for a data center. The model is described at
<a href=\"Buildings.Examples.ChillerPlant\">
Buildings.Examples.ChillerPlant</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
March 25, 2014, by Michael Wetter:<br/>
Updated model with new expansion vessel.
</li>
<li>
December 5, 2012, by Michael Wetter:<br/>
Removed the filtered speed calculation for the valves to reduce computing time by 25%.
</li>
<li>
October 16, 2012, by Wangda Zuo:<br/>
Reimplemented the controls.
</li>
<li>
July 20, 2011, by Wangda Zuo:<br/>
Added comments and merge to library.
</li>
<li>
January 18, 2011, by Wangda Zuo:<br/>
First implementation.
</li>
</ul>
</html>"),
    experiment(
      StartTime=1.30464e+07,
      StopTime=1.36512e+07,
      Tolerance=1e-06));
end DataCenterDiscreteTimeControl;
