function [activePower_W, reactivePower_var] = calculate_three_phase_power( ...
    voltageD_V, voltageQ_V, currentD_A, currentQ_A)
%CALCULATE_THREE_PHASE_POWER Calculate P/Q for amplitude-invariant dq data.
%   Q = 1.5*(vq*id-vd*iq); therefore positive iq is capacitive/negative Q
%   when the grid-voltage frame has vq=0 under this convention.

activePower_W = 1.5 .* (voltageD_V .* currentD_A + ...
    voltageQ_V .* currentQ_A);
reactivePower_var = 1.5 .* (voltageQ_V .* currentD_A - ...
    voltageD_V .* currentQ_A);
end
