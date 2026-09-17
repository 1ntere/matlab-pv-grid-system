function nextVref_V = po_mppt_step(currentVpv_V, currentIpv_A, ...
    previousVpv_V, previousPpv_W, previousVref_V, perturbStep_V, ...
    powerTolerance_W, voltageTolerance_V, vrefMin_V, vrefMax_V)
%PO_MPPT_STEP Apply one voltage-reference P&O update.
%   Positive delta-P keeps the previous voltage perturbation direction;
%   negative delta-P reverses it. Small changes hold the reference.

arguments
    currentVpv_V (1,1) double {mustBeNonnegative}
    currentIpv_A (1,1) double {mustBeNonnegative}
    previousVpv_V (1,1) double {mustBeNonnegative}
    previousPpv_W (1,1) double {mustBeNonnegative}
    previousVref_V (1,1) double {mustBeNonnegative}
    perturbStep_V (1,1) double {mustBePositive}
    powerTolerance_W (1,1) double {mustBeNonnegative}
    voltageTolerance_V (1,1) double {mustBeNonnegative}
    vrefMin_V (1,1) double {mustBeNonnegative}
    vrefMax_V (1,1) double {mustBeGreaterThan(vrefMax_V, vrefMin_V)}
end

currentPpv_W = currentVpv_V * currentIpv_A;
powerChange_W = currentPpv_W - previousPpv_W;
voltageChange_V = currentVpv_V - previousVpv_V;
nextVref_V = previousVref_V;

if abs(powerChange_W) > powerTolerance_W && ...
        abs(voltageChange_V) > voltageTolerance_V
    if powerChange_W * voltageChange_V > 0
        nextVref_V = previousVref_V + perturbStep_V;
    else
        nextVref_V = previousVref_V - perturbStep_V;
    end
end

nextVref_V = min(max(nextVref_V, vrefMin_V), vrefMax_V);
end
