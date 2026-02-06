function data = read_chap_csv(csv_path)
% READ_CHAP_CSV  Read a CHAP-format CSV file with mixed text and numeric columns.
%
% Returns a struct with fields:
%   header      - cell array of column names
%   time_period - cell array of strings (e.g. '2023-W01')
%   location    - cell array of strings
%   numeric     - matrix of all numeric columns (one row per record, NaN for missing)
%   numeric_names - cell array of numeric column names

  fid = fopen(csv_path, 'r');
  if fid == -1
    error('read_chap_csv: cannot open file %s', csv_path);
  end

  % Read header line — preserve empty fields for unnamed index column
  header_line = fgetl(fid);
  header = strsplit(header_line, ',', 'CollapseDelimiters', false);
  n_cols = length(header);

  % Identify string columns by name
  tp_col = find(strcmp(header, 'time_period'));
  loc_col = find(strcmp(header, 'location'));

  % Columns to skip: empty header (unnamed index), 'parent', and other known strings
  skip_cols = [tp_col, loc_col];
  for k = 1:n_cols
    if isempty(header{k}) || strcmp(header{k}, 'parent')
      skip_cols = [skip_cols, k];
    end
  end
  skip_cols = unique(skip_cols);

  % Remaining columns are numeric
  numeric_cols = setdiff(1:n_cols, skip_cols);
  numeric_names = header(numeric_cols);

  % Read all data lines
  time_period = {};
  location = {};
  numeric_data = [];
  row = 0;

  while ~feof(fid)
    line = fgetl(fid);
    if ~ischar(line) || isempty(strtrim(line))
      continue;
    end
    row = row + 1;
    fields = strsplit(line, ',', 'CollapseDelimiters', false);

    % Handle lines with fewer fields than header (pad with empty)
    if length(fields) < n_cols
      fields(end+1:n_cols) = {''};
    end

    time_period{row, 1} = fields{tp_col};
    location{row, 1} = fields{loc_col};

    for j = 1:length(numeric_cols)
      val = strtrim(fields{numeric_cols(j)});
      if isempty(val)
        numeric_data(row, j) = NaN;
      else
        numeric_data(row, j) = str2double(val);
      end
    end
  end

  fclose(fid);

  data.header = header;
  data.time_period = time_period;
  data.location = location;
  data.numeric = numeric_data;
  data.numeric_names = numeric_names;
end
