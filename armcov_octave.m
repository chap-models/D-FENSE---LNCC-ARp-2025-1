function a = armcov_octave(x, p)
% ARMCOV_OCTAVE  AR model estimation via the modified covariance method.
%
% Replaces MATLAB's armcov (System Identification / Signal Processing Toolbox).
% Returns a = [1, -a1, -a2, ..., -ap] matching MATLAB's convention so that
%   filter(a, 1, x) produces the prediction error.
%
% Algorithm: builds forward and backward prediction matrices and solves for
% the AR coefficients via least squares (modified covariance method).

  x = x(:);  % ensure column vector
  N = length(x);

  % Build forward prediction matrix
  % Forward: x(p+1:N) predicted from x(p:-1:1), x(p+1:-1:2), ...
  Xf = zeros(N - p, p);
  for k = 1:p
    Xf(:, k) = x(p + 1 - k : N - k);
  end
  yf = x(p + 1 : N);

  % Build backward prediction matrix
  % Backward: x(1:N-p) predicted from x(2:N-p+1), x(3:N-p+2), ...
  Xb = zeros(N - p, p);
  for k = 1:p
    Xb(:, k) = x(k + 1 : N - p + k);
  end
  yb = x(1 : N - p);

  % Stack forward and backward equations
  X = [Xf; Xb];
  y = [yf; yb];

  % Solve via least squares
  ar_coeffs = X \ y;   % p x 1 vector of AR coefficients

  % Return in MATLAB armcov convention: [1, -a1, -a2, ..., -ap]
  a = [1; -ar_coeffs];
  a = a(:)';  % row vector
end
