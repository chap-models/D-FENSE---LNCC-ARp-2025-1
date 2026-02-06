% ISOLATED_RUN  Local testing helper for the LNCC AR(p) CHAP model.
% Runs train followed by predict_chap using sample input data.

train('input/trainData.csv', 'output/model.mat');
predict('output/model.mat', 'input/trainData.csv', 'input/futureClimateData.csv', 'output/predictions.csv');

fprintf('\n--- Output preview ---\n');
fid = fopen('output/predictions.csv', 'r');
for i = 1:10
  line = fgetl(fid);
  if ~ischar(line); break; end
  fprintf('%s\n', line);
end
fclose(fid);
