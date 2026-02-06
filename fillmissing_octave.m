function x = fillmissing_octave(x)
% FILLMISSING_OCTAVE  Fill NaN values using forward fill, backward fill, then zero.
%
% 1. Forward fill: propagate last known value forward
% 2. Backward fill: propagate next known value backward (for leading NaNs)
% 3. Any remaining NaNs (entire series was NaN) become 0

  x = x(:);

  % Forward fill
  for i = 2:length(x)
    if isnan(x(i)) && ~isnan(x(i-1))
      x(i) = x(i-1);
    end
  end

  % Backward fill (for leading NaNs)
  for i = length(x)-1:-1:1
    if isnan(x(i)) && ~isnan(x(i+1))
      x(i) = x(i+1);
    end
  end

  % Fill any remaining NaNs with 0
  x(isnan(x)) = 0;
end
