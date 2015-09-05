function features = speech_features_separate_files(fnames,filter)
% features = speech_features_separate_files(fnames)
%
% fnames{f} is the name of file f.
%
% features(i, t, f) is feature i at time t (measured in frames at 62.5 Hz)
% from file f.  See "help speech_features" for more details.

if (nargin<2)
    filter_val = [];
end 


num_files = length(fnames);
feat = cell(1, num_files);
for i = 1:num_files
    level = wavrms(fnames{i},filter_val);
    feat{i} = wav_speech_features(fnames{i}, 256, 128, level / 5,filter_val);
    if i == 1
        min_frames = size(feat{i}, 2);
    else
        min_frames = min(min_frames, size(feat{i}, 2));
    end
end

% Make sure they're all the same length.
features = zeros(size(feat{1}, 1), min_frames, num_files);
for i = 1:num_files
    features(:, :, i) = feat{i}(:, 1:min_frames);
end
