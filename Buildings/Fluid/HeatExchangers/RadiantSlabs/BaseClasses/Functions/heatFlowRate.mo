within Buildings.Fluid.HeatExchangers.RadiantSlabs.BaseClasses.Functions;
function heatFlowRate "Heat flow rate for epsilon-NTU model"
  extends Modelica.Icons.Function;
  input Modelica.SIunits.Temperature T_a "Temperature at port_a";
  input Modelica.SIunits.Temperature T_b "Temperature at port_b";
  input Modelica.SIunits.Temperature T_s "Temperature of solid";
  input Modelica.SIunits.Temperature T_f "Temperature of fluid control volume";

  input Modelica.SIunits.SpecificHeatCapacity c_p "Specific heat capacity";
  input Modelica.SIunits.ThermalConductance UA "UA value";
  input Modelica.SIunits.MassFlowRate m_flow
    "Mass flow rate from port_a to port_b";
  input Modelica.SIunits.MassFlowRate m_flow_nominal
    "Nominal mass flow rate from port_a to port_b";

  output Modelica.SIunits.HeatFlowRate Q_flow "Heat flow rate";
protected
  Modelica.SIunits.MassFlowRate m_abs_flow "Absolute value of mass flow rate";
  Modelica.SIunits.Temperature T_in "Inlet fluid temperature";
  Real eps "Heat transfer effectiveness";

algorithm
  m_abs_flow :=noEvent(abs(m_flow));
  T_in :=smooth(1, noEvent(if m_flow >= 0 then T_a else T_b));
  if m_abs_flow > 0.15*m_flow_nominal then
    // High flow rate. Use epsilon-NTU formula.
    eps := 1-Modelica.Math.exp(-UA/m_abs_flow/c_p);
    Q_flow :=eps*(T_s-T_in)*m_abs_flow*c_p;
  elseif (m_abs_flow < 0.05*m_flow_nominal) then
    // Low flow rate. Use heat conduction to temperature of the control volume.
    Q_flow :=UA*(T_s-T_f);
  else
    // Transition. Use a once continuously differentiable transition between the
    // above regimes.
    eps := 1-Modelica.Math.exp(-UA/m_abs_flow/c_p);
    Q_flow := Buildings.Utilities.Math.Functions.spliceFunction(
      pos=eps*(T_s-T_in)*m_abs_flow*c_p,
      neg=UA*(T_s-T_f),
      x=m_abs_flow/m_flow_nominal-0.1,
      deltax=0.05);
  end if;

annotation (
smoothOrder=1,
Documentation(info="<html>
<p>
fixme
</p>
</html>",
revisions="<html>
<ul>
<li>
October 7, 2014, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end heatFlowRate;
