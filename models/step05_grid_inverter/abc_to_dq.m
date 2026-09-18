function [d, q, zero] = abc_to_dq(a, b, c, theta_rad)
%ABC_TO_DQ Amplitude-invariant abc-to-dq0 Park transformation.
%   Positive phase sequence is a=cos(theta), b=cos(theta-2*pi/3),
%   c=cos(theta+2*pi/3). The q row uses negative sine, so a balanced
%   in-phase signal produces constant positive d and approximately zero q.

if ~isequal(size(a), size(b), size(c), size(theta_rad))
    error("STEP5:TransformSizeMismatch", ...
        "a, b, c, and theta_rad must have identical sizes.");
end

cosA = cos(theta_rad);
cosB = cos(theta_rad - 2*pi/3);
cosC = cos(theta_rad + 2*pi/3);
sinA = sin(theta_rad);
sinB = sin(theta_rad - 2*pi/3);
sinC = sin(theta_rad + 2*pi/3);

d = (2/3) .* (a .* cosA + b .* cosB + c .* cosC);
q = -(2/3) .* (a .* sinA + b .* sinB + c .* sinC);
zero = (a + b + c) ./ 3;
end
