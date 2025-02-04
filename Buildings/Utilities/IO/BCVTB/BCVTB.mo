within Buildings.Utilities.IO.BCVTB;
model BCVTB
  "Block that exchanges data with the Building Controls Virtual Test Bed"
  extends Modelica.Blocks.Interfaces.DiscreteBlock(final startTime=0,
  final samplePeriod = if activateInterface then timeStep else Modelica.Constants.inf);
  parameter Boolean activateInterface = true
    "Set to false to deactivate interface and use instead yFixed as output"
    annotation(Evaluate = true);
  parameter Modelica.SIunits.Time timeStep
    "Time step used for the synchronization"
    annotation(Dialog(enable = activateInterface));
  parameter String xmlFileName = "socket.cfg"
    "Name of the file that is generated by the BCVTB and that contains the socket information";
  parameter Integer nDblWri(min=0)
    "Number of double values to write to the BCVTB";
  parameter Integer nDblRea(min=0)
    "Number of double values to be read from the BCVTB";
  parameter Integer flaDblWri[nDblWri] = zeros(nDblWri)
    "Flag for double values (0: use current value, 1: use average over interval, 2: use integral over interval)";
  parameter Real uStart[nDblWri]
    "Initial input signal, used during first data transfer with BCVTB";
  parameter Real yRFixed[nDblRea] = zeros(nDblRea)
    "Fixed output, used if activateInterface=false"
    annotation(Evaluate = true,
                Dialog(enable = not activateInterface));

  Modelica.Blocks.Interfaces.RealInput uR[nDblWri]
    "Real inputs to be sent to the BCVTB"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Interfaces.RealOutput yR[nDblRea]
    "Real outputs received from the BCVTB"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));

 Integer flaRea "Flag received from BCVTB";
 Modelica.SIunits.Time simTimRea
    "Current simulation time received from the BCVTB";
 Integer retVal "Return value from the BSD socket data exchange";
protected
  parameter Integer socketFD(fixed=false)
    "Socket file descripter, or a negative value if an error occured";
  parameter Real _uStart[nDblWri](fixed=false)
    "Initial input signal, used during first data transfer with BCVTB";
  constant Integer flaWri=0;
  Real uRInt[nDblWri] "Value of integral";
  Real uRIntPre[nDblWri] "Value of integral at previous sampling instance";
public
  Real uRWri[nDblWri] "Value to be sent to the interface";
initial algorithm
  socketFD :=if activateInterface then
      Buildings.Utilities.IO.BCVTB.BaseClasses.establishClientSocket(xmlFileName=xmlFileName) else
      0;
    // check for valid socketFD
     assert(socketFD >= 0, "Socket file descripter for BCVTB must be positive.\n" +
                         "   A negative value indicates that no connection\n" +
                         "   could be established. Check file 'utilSocket.log'.\n" +
                         "   Received: socketFD = " + String(socketFD));
   flaRea   := 0;
   uRInt    := zeros(nDblWri);
   uRIntPre := zeros(nDblWri);
   for i in 1:nDblWri loop
     assert(flaDblWri[i]>=0 and flaDblWri[i]<=2,
        "Parameter flaDblWri out of range for " + String(i) + "-th component.");
     if (flaDblWri[i] == 0) then
        _uStart[i] := uStart[i];               // Current value.
     elseif (flaDblWri[i] == 1) then
        _uStart[i] := uStart[i];                // Average over interval
     else
        _uStart[i] := uStart[i]*samplePeriod;  // Integral over the sampling interval
                                               // This is multiplied with samplePeriod because if
                                               // u is power, then uRWri needs to be energy.

     end if;
   end for;
   // Exchange initial values
    if activateInterface then
      (flaRea, simTimRea, yR, retVal) :=
        Buildings.Utilities.IO.BCVTB.BaseClasses.exchangeReals(
        socketFD=socketFD,
        flaWri=flaWri,
        simTimWri=time,
        dblValWri=_uStart,
        nDblWri=size(uRWri, 1),
        nDblRea=size(yR, 1));
    else
      flaRea := 0;
      simTimRea := time;
      yR := yRFixed;
      retVal := 0;
      end if;

equation
   for i in 1:nDblWri loop
      der(uRInt[i]) = if (flaDblWri[i] > 0) then uR[i] else 0;
   end for;
algorithm
  when {sampleTrigger} then
    assert(flaRea == 0, "BCVTB interface attempts to exchange data after Ptolemy reached its final time.\n" +
                        "   Aborting simulation. Check final time in Modelica and in Ptolemy.\n" +
                        "   Received: flaRea = " + String(flaRea));
     // Compute value that will be sent to the BCVTB interface
     for i in 1:nDblWri loop
       if (flaDblWri[i] == 0) then
         uRWri[i] :=pre(uR[i]);  // Send the current value.
                                 // Without the pre(), Dymola 7.2 crashes during translation of Examples.MoistAir
       else
         uRWri[i] :=uRInt[i] - uRIntPre[i]; // Integral over the sampling interval
         if (flaDblWri[i] == 1) then
            uRWri[i] := uRWri[i]/samplePeriod;   // Average value over the sampling interval
         end if;
       end if;
      end for;

    // Exchange data
    if activateInterface then
      (flaRea, simTimRea, yR, retVal) :=
        Buildings.Utilities.IO.BCVTB.BaseClasses.exchangeReals(
        socketFD=socketFD,
        flaWri=flaWri,
        simTimWri=time,
        dblValWri=uRWri,
        nDblWri=size(uRWri, 1),
        nDblRea=size(yR, 1));
    else
      flaRea := 0;
      simTimRea := time;
      yR := yRFixed;
      retVal := 0;
      end if;
    // Check for valid return flags
    assert(flaRea >= 0, "BCVTB sent a negative flag to Modelica during data transfer.\n" +
                        "   Aborting simulation. Check file 'utilSocket.log'.\n" +
                        "   Received: flaRea = " + String(flaRea));
    assert(retVal >= 0, "Obtained negative return value during data transfer with BCVTB.\n" +
                        "   Aborting simulation. Check file 'utilSocket.log'.\n" +
                        "   Received: retVal = " + String(retVal));

    // Store current value of integral
  uRIntPre:=uRInt;
  end when;
   // Close socket connnection
   when terminal() then
     if activateInterface then
        Buildings.Utilities.IO.BCVTB.BaseClasses.closeClientSocket(
                                                          socketFD);
     end if;
   end when;

  annotation (defaultComponentName="cliBCVTB",
 Icon(coordinateSystem(
          preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
        Rectangle(
          visible=not activateInterface,
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          visible=activateInterface,
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={223,223,159},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{0,28},{80,-100}},
          lineColor={0,0,0},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{10,14},{26,4}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{32,14},{48,4}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{54,14},{70,4}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{54,-2},{70,-12}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{32,-2},{48,-12}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{10,-2},{26,-12}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{54,-18},{70,-28}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{32,-18},{48,-28}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{10,-18},{26,-28}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{54,-34},{70,-44}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{32,-34},{48,-44}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{10,-34},{26,-44}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{54,-50},{70,-60}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{32,-50},{48,-60}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{10,-50},{26,-60}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{54,-66},{70,-76}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{32,-66},{48,-76}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{10,-66},{26,-76}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{54,-82},{70,-92}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{32,-82},{48,-92}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{10,-82},{26,-92}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{38,46},{-16,28},{92,28},{38,46}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-82,108},{30,40}},
          lineColor={0,0,0},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          textString="tS=%samplePeriod%")}),
    Documentation(info="<html>
Block that exchanges data with the
<a href=\"http://simulationresearch.lbl.gov/bcvtb\">Building Controls Virtual Test Bed</a> (BCVTB).
<p>
At the start of the simulation, this block establishes a socket connection
using the Berkeley Software Distribution socket (BSD socket).
At each sampling interval, data are exchanged between Modelica
and the BCVTB.
When Dymola terminates, a signal is sent to the BCVTB
so that it can terminate gracefully.
</p>
<p>
For each element in the input vector <code>uR[nDblWri]</code>,
the value of the flag <code>flaDblWri[nDblWri]</code> determines whether
the current value, the average over the sampling interval or the integral
over the sampling interval is sent to the BCVTB. The following three options are allowed:
<table summary=\"summary\" border=\"1\">
<tr>
<td>
flaDblWri[i]
</td>
<td>
Value sent to the BCVTB
</td>
</tr>
<tr>
<td>
0
</td>
<td>
Current value of uR[i]
</td>
</tr>
<tr>
<td>
1
</td>
<td>
Average value of uR[i] over the sampling interval
</td>
</tr>
<tr>
<td>
2
</td>
<td>
Integral of uR[i] over the sampling interval
</td>
</tr>
</table>
<br/>
<p>
For the first call to the BCVTB interface, the value of the parameter <code>uStart[nDblWri]</code>
will be used instead of <code>uR[nDblWri]</code>. This avoids an algebraic loop when determining
the initial conditions. If <code>uR[nDblWri]</code> were to be used, then computing the initial conditions
may require an iterative solution in which the function <code>exchangeWithSocket</code> may be called
multiple times.
Unfortunately, it does not seem possible to use a parameter that would give a user the option to either
select <code>uR[i]</code> or <code>uStart[i]</code> in the first data exchange. The reason is that the symbolic solver does not evaluate
the test that picks <code>uR[i]</code> or <code>uStart[i]</code>, and hence there would be an algebraic loop.
</p>
<p>
If the parameter <code>activateInterface</code> is set to false, then no data is exchanged with the BCVTB.
The output of this block is then equal to the value of the parameter <code>yRFixed[nDblRea]</code>.
This option can be helpful during debugging. Since during model translation, the functions are
still linked to the C library, the header files and libraries need to be present in the current working
directory even if <code>activateInterface=false</code>.
</p>
</html>", revisions="<html>
<ul>
<li>
July 19, 2012, by Michael Wetter:<br/>
Added a call to <code>Buildings.Utilities.IO.BCVTB.BaseClasses.exchangeReals</code>
in the <code>initial algorithm</code> section.
This is needed to propagate the initial condition to the server.
It also leads to one more data exchange, which is correct and avoids the
warning message in Ptolemy that says that the simulation reached its stop time
one time step prior to the final time.
</li>
<li>
January 19, 2010, by Michael Wetter:<br/>
Introduced parameter to set initial value to be sent to the BCVTB.
In the prior implementation, if a variable was in an algebraic loop, then zero was
sent for this variable.
</li>
<li>
May 14, 2009, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end BCVTB;
