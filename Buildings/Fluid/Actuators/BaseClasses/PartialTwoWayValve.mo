within Buildings.Fluid.Actuators.BaseClasses;
partial model PartialTwoWayValve "Partial model for a two way valve"

  extends Buildings.Fluid.BaseClasses.PartialResistance(
       final dp_nominal=dpValve_nominal + dpFixed_nominal,
       dp(nominal=6000),
       final m_flow_turbulent = deltaM * abs(m_flow_nominal));

  extends Buildings.Fluid.Actuators.BaseClasses.ValveParameters(
      rhoStd=Medium.density_pTX(101325, 273.15+4, Medium.X_default));

  extends Buildings.Fluid.Actuators.BaseClasses.ActuatorSignal;
  parameter Modelica.SIunits.Pressure dpFixed_nominal(displayUnit="Pa", min=0) = 0
    "Pressure drop of pipe and other resistances that are in series"
     annotation(Dialog(group = "Nominal condition"));

  parameter Real l(min=1e-10, max=1) = 0.0001
    "Valve leakage, l=Kv(y=0)/Kv(y=1)";
  input Real phi
    "Ratio actual to nominal mass flow rate of valve, phi=Kv(y)/Kv(y=1)";
protected
 parameter Real kFixed(unit="", min=0) = if dpFixed_nominal > Modelica.Constants.eps
    then m_flow_nominal / sqrt(dpFixed_nominal) else 0
    "Flow coefficient of fixed resistance that may be in series with valve, k=m_flow/sqrt(dp), with unit=(kg.m)^(1/2).";
 Real kVal(unit="", min=Modelica.Constants.small)
    "Flow coefficient of valve, k=m_flow/sqrt(dp), with unit=(kg.m)^(1/2).";
 Real k(unit="", min=Modelica.Constants.small)
    "Flow coefficient of valve and pipe in series, k=m_flow/sqrt(dp), with unit=(kg.m)^(1/2).";
initial equation
  assert(dpFixed_nominal > -Modelica.Constants.small, "Require dpFixed_nominal >= 0. Received dpFixed_nominal = "
        + String(dpFixed_nominal) + " Pa.");
equation
 kVal = phi*Kv_SI;
 if (dpFixed_nominal > Modelica.Constants.eps) then
   k = sqrt(1/(1/kFixed^2 + 1/kVal^2));
 else
   k = kVal;
 end if;

 if linearized then
   // This implementation yields m_flow_nominal = phi*kv_SI * sqrt(dp_nominal)
   // if m_flow = m_flow_nominal and dp = dp_nominal
   m_flow*m_flow_nominal_pos = k^2 * dp;
 else
   if homotopyInitialization then
     if from_dp then
         m_flow=homotopy(actual=Buildings.Fluid.BaseClasses.FlowModels.basicFlowFunction_dp(dp=dp, k=k,
                                m_flow_turbulent=m_flow_turbulent),
                                simplified=m_flow_nominal_pos*dp/dp_nominal_pos);
      else
         dp=homotopy(actual=Buildings.Fluid.BaseClasses.FlowModels.basicFlowFunction_m_flow(m_flow=m_flow, k=k,
                                m_flow_turbulent=m_flow_turbulent),
                                simplified=dp_nominal_pos*m_flow/m_flow_nominal_pos);
     end if;
   else // do not use homotopy
     if from_dp then
       m_flow=Buildings.Fluid.BaseClasses.FlowModels.basicFlowFunction_dp(dp=dp, k=k,
                                m_flow_turbulent=m_flow_turbulent);
      else
        dp=Buildings.Fluid.BaseClasses.FlowModels.basicFlowFunction_m_flow(m_flow=m_flow, k=k,
                                m_flow_turbulent=m_flow_turbulent);
      end if;
    end if; // homotopyInitialization
 end if; // linearized
  annotation (Icon(coordinateSystem(preserveAspectRatio=true,  extent={{-100,-100},
            {100,100}}),       graphics={
        Polygon(
          points={{2,-2},{-76,60},{-76,-60},{2,-2}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-50,40},{0,-2},{54,40},{54,40},{-50,40}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-52,-42},{0,-4},{60,40},{60,-42},{-52,-42}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{0,-2},{82,60},{82,-60},{0,-2}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{0,40},{0,-4}},
          color={0,0,0},
          smooth=Smooth.None),
        Line(
          visible=not filteredOpening,
          points={{0,100},{0,40}},
          color={0,0,0},
          smooth=Smooth.None)}),
Documentation(info="<html>
<p>
Partial model for a two way valve. This is the base model for valves
with different opening characteristics, such as linear, equal percentage
or quick opening.
</p>
<p>
To prevent the derivative <code>d/dP (m_flow)</code> to be infinite near
the origin, this model linearizes the pressure drop versus flow relation
ship. The region in which it is linearized is parameterized by
</p>
<pre>
  m_turbulent_flow = deltaM * m_flow_nominal
</pre>
<p>
Because the parameterization contains <code>Kv_SI</code>, the values for
<code>deltaM</code> and <code>dp_nominal</code> need not be changed if the valve size
changes.
</p>
<p>
In contrast to the model in <a href=\"modelica://Modelica.Fluid\">
Modelica.Fluid</a>, this model uses the parameter <code>Kv_SI</code>,
which is the flow coefficient in SI units, i.e.,
it is the ratio between mass flow rate in <code>kg/s</code> and square root
of pressure drop in <code>Pa</code>.
</p>
<h4>Modelling options</h4>
<p>
This model allows different parameterization of the flow resistance.
The different parameterizations are described in
<a href=\"modelica://Buildings.Fluid.Actuators.BaseClasses.ValveParameters\">
Buildings.Fluid.Actuators.BaseClasses.ValveParameters</a>.
</p>
<h4>Implementation</h4>
<p>
The two way valve models are implemented using this partial model, as opposed to using
different functions for the valve opening characteristics, because
each valve opening characteristics has different parameters.
</p>
<h4>Implementation</h4>
<p>
Models that extend this model need to provide a binding equation
for the flow function <code>phi</code>.
An example of such a code can be found in
<a href=\"modelica://Buildings.Fluid.Actuators.Valves.TwoWayLinear\">
Buildings.Fluid.Actuators.Valves.TwoWayLinear</a>.
</p>
</html>",
revisions="<html>
<ul>
<li>
August 8, 2014, by Michael Wetter:<br/>
Reformulated the computation of <code>k</code> to make the model
work in OpenModelica.
</li>
<li>
April 4, 2014, by Michael Wetter:<br/>
Added keyword <code>input</code> to variable <code>phi</code>
to require models that extend this model to provide a binding equation.
This is done to use the same modeling concept as is used for example in
<a href=\"modelica://Buildings.Fluid.Interfaces.StaticTwoPortHeatMassExchanger\">
Buildings.Fluid.Interfaces.StaticTwoPortHeatMassExchanger</a>.
</li>
<li>
March 27, 2014 by Michael Wetter:<br/>
Revised model for implementation of new valve model that computes the flow function
based on a table.
</li>
<li>
March 20, 2013, by Michael Wetter:<br/>
Set <code>dp(nominal=6000)</code> as the previous formulation gives an error during model check
in Dymola 2014. The reason is that the previous formulation used <code>dpValve_nominal</code>, which
is not known at translation time.
</li>
<li>
February 28, 2013, by Michael Wetter:<br/>
Reformulated assignment of parameters.
Removed default value for <code>dpValve_nominal</code>, as this
parameter has the attribute <code>fixed=false</code> for some values
of <code>CvData</code>. In this case, assigning a value is not allowed.
Changed assignment of nominal attribute of <code>dp</code> to avoid assigning
a non-literal value.
</li>
<li>
February 20, 2012 by Michael Wetter:<br/>
Renamed parameter <code>dp_nominal</code> to <code>dpValve_nominal</code>,
and added new parameter <code>dpFixed_nominal</code>.
See
<a href=\"modelica://Buildings.Fluid.Actuators.UsersGuide\">
Buildings.Fluid.Actuators.UsersGuide</a>.
</li>
<li>
January 16, 2012 by Michael Wetter:<br/>
To simplify object inheritance tree, revised base classes
<code>Buildings.Fluid.BaseClasses.PartialResistance</code>,
<code>Buildings.Fluid.Actuators.BaseClasses.PartialTwoWayValve</code>,
<code>Buildings.Fluid.Actuators.BaseClasses.PartialDamperExponential</code>,
<code>Buildings.Fluid.Actuators.BaseClasses.PartialActuator</code>
and model
<code>Buildings.Fluid.FixedResistances.FixedResistanceDpM</code>.
</li>
<li>
August 12, 2011 by Michael Wetter:<br/>
Added <code>assert</code> statement to prevent <code>l=0</code> due to the
implementation of
<a href=\"modelica://Buildings.Fluid.BaseClasses.FlowModels.basicFlowFunction_m_flow\">
Buildings.Fluid.BaseClasses.FlowModels.basicFlowFunction_m_flow</a>.
</li>
<li>
April 4, 2011 by Michael Wetter:<br/>
Revised implementation to use new base class for actuators.
</li>
<li>
February 18, 2009 by Michael Wetter:<br/>
Implemented parameterization of flow coefficient as in
<code>Modelica.Fluid</code>.
</li>
<li>
August 15, 2008 by Michael Wetter:<br/>
Set valve leakage to nonzero value.
</li>
<li>
June 3, 2008 by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end PartialTwoWayValve;
