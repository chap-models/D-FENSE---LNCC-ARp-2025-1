function predict(model_path, historic_data_path, future_data_path, out_path)
% PREDICT  CHAP prediction entry point for the LNCC AR(p) model.
%
% Loads the trained AR(p) model, recomputes initial conditions from
% historic data, runs Monte Carlo simulation over the forecast horizon
% defined by future_data, and writes CHAP-format output CSV.
%
% Core algorithm preserved from forecast26_UF_ARp_forecast_batch.m
% (lines 97-127 of the original).

  % --- Read user options ---
  opts = read_model_config();
  if isfield(opts, 'n_samples')
    MC = opts.n_samples;
  else
    MC = 100;  % default number of MC samples
  end

  % --- Load trained model ---
  S = load(model_path);
  models = S.models;

  % --- Read future data (defines forecast horizon and locations) ---
  future = read_chap_csv(future_data_path);

  % --- Read historic data (used to recompute initial conditions) ---
  historic = read_chap_csv(historic_data_path);

  % Find disease_cases column in historic data
  dc_idx = find(strcmp(historic.numeric_names, 'disease_cases'));
  if isempty(dc_idx)
    error('predict_chap: historic_data CSV must contain a disease_cases column');
  end

  % Collect output across all locations
  all_tp = {};
  all_loc = {};
  all_samples = [];

  unique_locs = unique(future.location);

  for loc_i = 1:length(unique_locs)
    loc_name = unique_locs{loc_i};
    field_name = ['loc_', regexprep(loc_name, '[^a-zA-Z0-9]', '_')];

    if ~isfield(models, field_name)
      warning('predict_chap: no trained model for location %s, skipping', loc_name);
      continue;
    end

    m = models.(field_name);
    a = m.a;
    mcc = m.mcc;
    med_stdE = m.med_stdE;

    % --- Recompute initial conditions from historic data ---
    hist_mask = strcmp(historic.location, loc_name);
    cc_hist = historic.numeric(hist_mask, dc_idx);
    cc_hist = fillmissing_octave(cc_hist);  % forward/backward fill, then zero
    cc_hist(cc_hist == 0) = 0.1;
    cclog_hist = log2(cc_hist);
    sig_hist = cclog_hist - mcc;

    % Get filter initial conditions by running the inverse filter on historic data
    e1_hist = filter(a, 1, sig_hist);
    [~, zf] = filter(1, a, e1_hist);

    % --- Forecast horizon from future data ---
    fut_mask = strcmp(future.location, loc_name);
    fut_tp = future.time_period(fut_mask);
    lwea = sum(fut_mask);  % number of time periods to forecast

    fprintf('Predicting location: %s (%d periods, %d MC samples)\n', loc_name, lwea, MC);

    % --- Monte Carlo simulation (preserved from original lines 106-127) ---
    RE = randn(MC, lwea) * med_stdE;

    CP_v = zeros(MC, lwea);
    for kk = 1:MC
      ee = RE(kk, :);
      cases_prediction = filter(1, a, ee, zf);
      cases_prediction = 2.^(cases_prediction + mcc);
      CP_v(kk, :) = cases_prediction;
    end

    % Transpose: each row is a time period, each column is a sample
    samples_loc = CP_v';  % lwea x MC

    % Collect results
    all_tp = [all_tp; fut_tp];
    all_loc = [all_loc; repmat({loc_name}, lwea, 1)];
    all_samples = [all_samples; samples_loc];
  end

  % --- Write output CSV ---
  write_chap_csv(out_path, all_tp, all_loc, all_samples);
  fprintf('Predictions written to %s\n', out_path);
end
