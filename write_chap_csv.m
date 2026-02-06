function write_chap_csv(out_path, time_periods, locations, samples)
% WRITE_CHAP_CSV  Write CHAP prediction output CSV.
%
% Arguments:
%   out_path     - output file path
%   time_periods - cell array of time_period strings (n_rows x 1)
%   locations    - cell array of location strings (n_rows x 1)
%   samples      - numeric matrix (n_rows x n_samples)

  [n_rows, n_samples] = size(samples);

  fid = fopen(out_path, 'w');
  if fid == -1
    error('write_chap_csv: cannot open file %s for writing', out_path);
  end

  % Write header
  fprintf(fid, 'time_period,location');
  for j = 0:(n_samples - 1)
    fprintf(fid, ',sample_%d', j);
  end
  fprintf(fid, '\n');

  % Write data rows
  fmt = repmat(',%.6g', 1, n_samples);
  for i = 1:n_rows
    fprintf(fid, '%s,%s', time_periods{i}, locations{i});
    fprintf(fid, fmt, samples(i, :));
    fprintf(fid, '\n');
  end

  fclose(fid);
end
