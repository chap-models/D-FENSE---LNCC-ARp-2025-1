function train(train_data_path, model_path)
% TRAIN  CHAP training entry point for the LNCC AR(p) dengue forecast model.
%
% Reads a CHAP-format training CSV, fits an AR(p) model per location
% (modified covariance method), analyzes the prediction error, and saves
% the trained parameters to a .mat file.
%
% Core algorithm preserved from forecast26_UF_ARp_forecast_batch.m
% (lines 25-86 of the original).

  % --- Read user options (p, n_samples) from CHAP config if available ---
  opts = read_model_config();
  if isfield(opts, 'p')
    p = opts.p;
  else
    p = 92;  % default AR model order
  end

  % --- Read training data ---
  data = read_chap_csv(train_data_path);

  % Find disease_cases column index in the numeric columns
  dc_idx = find(strcmp(data.numeric_names, 'disease_cases'));
  if isempty(dc_idx)
    error('train: training CSV must contain a disease_cases column');
  end

  % Get unique locations
  unique_locs = unique(data.location);
  n_locs = length(unique_locs);

  models = struct();

  for loc_i = 1:n_locs
    loc_name = unique_locs{loc_i};
    mask = strcmp(data.location, loc_name);
    cc = data.numeric(mask, dc_idx);
    tp = data.time_period(mask);

    % Fill missing values: forward fill, backward fill, then zero
    cc = fillmissing_octave(cc);

    fprintf('Training location: %s (%d observations)\n', loc_name, length(cc));

    % --- Original model logic (preserved) ---

    % Replace zeros with 0.1 (log2 requires positive values)
    cc(cc == 0) = 0.1;

    % Log2 transform
    cclog = log2(cc);
    mcc = mean(cclog);
    sig = cclog - mcc;  % zero-mean log2 signal

    % Handle edge case: if signal is too short for the requested AR order,
    % reduce p for this location
    p_loc = min(p, length(sig) - 1);
    if p_loc < 1
      warning('train: location %s has too few observations (%d), skipping', loc_name, length(sig));
      continue;
    end

    % AR(p) model estimation via modified covariance method
    a = armcov_octave(sig, p_loc);
    a = a(:);  % column vector

    % Inverse filtering to get prediction error
    e1 = filter(a, 1, sig);

    % Centered inverse filtering (replaces MATLAB's filter2(a, sig, 'same'))
    e = conv(sig(:)', a(:)', 'same')(:);

    % Estimate excitation noise standard deviation from centered prediction error
    % (Original used 104-week blocks + median of per-position stds, which
    % reduces to approximately std(e) when variance is assumed constant.)
    med_stdE = std(e);

    % Store trained parameters for this location
    % Use a safe field name (replace non-alphanumeric chars with _)
    field_name = ['loc_', regexprep(loc_name, '[^a-zA-Z0-9]', '_')];
    models.(field_name).location = loc_name;
    models.(field_name).a = a;
    models.(field_name).mcc = mcc;
    models.(field_name).med_stdE = med_stdE;
    models.(field_name).p = p_loc;
    models.(field_name).sig = sig;       % needed to recompute initial conditions
    models.(field_name).e1 = e1;         % needed to get filter initial conditions
  end

  % Save all location models
  save(model_path, 'models');
  fprintf('Model saved to %s\n', model_path);
end
