within Buildings.BoundaryConditions.WeatherData.BaseClasses.Examples;
model CheckSkyCover "Test model for checking sky cover"
  extends Modelica.Icons.Example;
public
  Buildings.BoundaryConditions.WeatherData.BaseClasses.CheckSkyCover
    cheTotSkyCov "Check total sky cover"
    annotation (Placement(transformation(extent={{60,20},{80,40}})));
  Buildings.BoundaryConditions.WeatherData.BaseClasses.CheckSkyCover
    cheOpaSkyCov "Check opaque sky cover"
    annotation (Placement(transformation(extent={{60,-20},{80,0}})));
protected
  Buildings.Utilities.SimulationTime simTim "Generate simulation time"
    annotation (Placement(transformation(extent={{-100,0},{-80,20}})));

  Modelica.Blocks.Tables.CombiTable1Ds datRea(
    tableOnFile=true,
    tableName="tab1",
    fileName=ModelicaServices.ExternalReferences.loadResource(
       "modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"),
    columns=2:30,
    smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative)
    "Data reader"
    annotation (Placement(transformation(extent={{-20,0},{0,20}})));

  Buildings.BoundaryConditions.WeatherData.BaseClasses.ConvertTime conTim
    annotation (Placement(transformation(extent={{-60,0},{-40,20}})));

  Modelica.Blocks.Math.Gain conTotSkyCov(final k=0.1)
    "Convert sky cover from [0...10] to [0...1]"
    annotation (Placement(transformation(extent={{20,20},{40,40}})));
  Modelica.Blocks.Math.Gain conOpaSkyCov1(final k=0.1)
    "Convert sky cover from [0...10] to [0...1]"
    annotation (Placement(transformation(extent={{20,-20},{40,0}})));
equation
  connect(simTim.y, conTim.simTim) annotation (Line(
      points={{-79,10},{-62,10}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(conTim.calTim, datRea.u) annotation (Line(
      points={{-39,10},{-22,10}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(datRea.y[17], conTotSkyCov.u) annotation (Line(
      points={{1,10.1379},{1,10},{10,10},{10,30},{18,30},{18,30}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(datRea.y[18], conOpaSkyCov1.u) annotation (Line(
      points={{1,10.2069},{10,10.2069},{10,-10},{18,-10}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(conTotSkyCov.y, cheTotSkyCov.nIn) annotation (Line(
      points={{41,30},{58,30}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(conOpaSkyCov1.y, cheOpaSkyCov.nIn) annotation (Line(
      points={{41,-10},{58,-10}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (experiment(StopTime=8640000),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/BoundaryConditions/WeatherData/BaseClasses/Examples/CheckSkyCover.mos"
        "Simulate and plot"));
end CheckSkyCover;
