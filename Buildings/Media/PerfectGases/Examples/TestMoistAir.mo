within Buildings.Media.PerfectGases.Examples;
model TestMoistAir
  extends Modelica.Icons.Example;
  extends Modelica.Media.Examples.Tests.Components.PartialTestModel(
     redeclare package Medium =
          Buildings.Media.PerfectGases.MoistAir);

      annotation (experiment(StopTime=1.0),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Media/PerfectGases/Examples/TestMoistAir.mos"
        "Simulate and plot"),
    Documentation(info="<html>
This is a simple test for the medium model. It uses the test model described in
<a href=\"modelica://Modelica.Media.UsersGuide.MediumDefinition.TestOfMedium\">
Modelica.Media.UsersGuide.MediumDefinition.TestOfMedium</a>.
</html>", revisions="<html>
<ul>
<li>
May 12, 2008, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end TestMoistAir;
