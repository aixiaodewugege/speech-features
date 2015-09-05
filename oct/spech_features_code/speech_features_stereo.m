function features = speech_features_stereo(fname, filter_val)

if (nargin<2)
    filter_val = [];
end 

rms = wavrms(fname, filter_val);

% Compute voicing features and energy from audio
[featuresL, featuresR] = wav_speech_features(fname, 256, 128, rms(1) / 5, rms(2)/5, filter_val);

% Make sure they're both the same length (not needed because file is stereo?)
if size(featuresL, 2) ~= size(featuresR, 2)
    error('Different number of features in each channel.  How is that possible?!?!?!?!');
end

features = cat(3, featuresL, featuresR);
