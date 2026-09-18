function [a, b, c] = dq_to_abc(d, q, zero, theta_rad)
%DQ_TO_ABC Inverse of the amplitude-invariant Park transformation.
%   Uses the same positive-sequence and negative-q convention as abc_to_dq.

if ~isequal(size(d), size(q), size(zero), size(theta_rad))
    error("STEP5:InverseTransformSizeMismatch", ...
        "d, q, zero, and theta_rad must have identical sizes.");
end

angleA = theta_rad;
angleB = theta_rad - 2*pi/3;
angleC = theta_rad + 2*pi/3;
a = d .* cos(angleA) - q .* sin(angleA) + zero;
b = d .* cos(angleB) - q .* sin(angleB) + zero;
c = d .* cos(angleC) - q .* sin(angleC) + zero;
end
