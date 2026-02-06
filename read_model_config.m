function opts = read_model_config()
% READ_MODEL_CONFIG  Parse user_option_values from CHAP's model config YAML.
%
% CHAP writes a file called 'model_configuration_for_run.yaml' in the
% working directory.  This is a simple key-value YAML with structure:
%   user_option_values:
%     p: 92
%     n_samples: 100
%
% Returns a struct with fields for each option found, or empty struct
% if the file does not exist.

  opts = struct();
  config_path = 'model_configuration_for_run.yaml';

  if ~exist(config_path, 'file')
    return;
  end

  fid = fopen(config_path, 'r');
  in_user_options = false;

  while ~feof(fid)
    line = fgetl(fid);
    if ~ischar(line)
      break;
    end

    % Detect the user_option_values section
    if ~isempty(strfind(line, 'user_option_values'))
      in_user_options = true;
      continue;
    end

    % If we are inside user_option_values, parse indented key: value lines
    if in_user_options
      % End of section if line is not indented (and not empty)
      stripped = strtrim(line);
      if isempty(stripped)
        continue;
      end
      if line(1) ~= ' ' && line(1) ~= char(9)
        % New top-level key — stop parsing
        break;
      end

      tokens = strsplit(stripped, ':');
      if length(tokens) >= 2
        key = strtrim(tokens{1});
        val_str = strtrim(strjoin(tokens(2:end), ':'));
        val_num = str2double(val_str);
        if ~isnan(val_num)
          opts.(key) = val_num;
        else
          opts.(key) = val_str;
        end
      end
    end
  end

  fclose(fid);
end
