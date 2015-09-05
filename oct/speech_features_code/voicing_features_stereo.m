function [featuresL, featuresR, energyL, energyR] = voicing_features_stereo(fname)

rms = wavrms(fname);

% Compute voicing features and energy from audio
[featuresL, energyL, featuresR, energyR] = wav_voicing_features(fname, 256, 128, rms(1) / 5, rms(2)/5);

% Make sure they're both the same length
if size(featuresL, 2) ~= size(featuresR, 2)
    error('Different number of frames in each channel.  How is that possible?!?!?!?!');
end
