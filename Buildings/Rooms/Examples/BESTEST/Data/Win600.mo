within Buildings.Rooms.Examples.BESTEST.Data;
record Win600 =
    Buildings.HeatTransfer.Data.GlazingSystems.Generic (
    final glass={Buildings.Rooms.Examples.BESTEST.Data.Glass600(),
                            Buildings.Rooms.Examples.BESTEST.Data.Glass600()},
    final gas={Buildings.HeatTransfer.Data.Gases.Air(x=0.013)},
    UFra=1.4,
    final nLay=2)
  "Double pane, clear glass 3.175mm, air 13mm, clear glass 3.175mm" annotation (
   Documentation(info="<html>
<p>
This record declares the parameters for the window system
for the BESTEST.
</p>
</html>", revisions="<html>
<ul>
<li>
October 6, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
