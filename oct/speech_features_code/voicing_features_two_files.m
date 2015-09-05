function [featuresA, featuresB, energyA, energyB] = voicing_features_two_files(fnameA, fnameB)

levelA = wavrms(fnameA);
levelB = wavrms(fnameB);

% Compute voicing features and energy from audio

[featuresA, energyA] = wav_voicing_features(fnameA, 256, 128, levelA / 5);
[featuresB, energyB] = wav_voicing_features(fnameB, 256, 128, levelB / 5);

% Make sure they're both the same length.
num_frames = min(size(featuresA,2), size(featuresB,2));
featuresA = featuresA(:, 1:num_frames);
featuresB = featuresB(:, 1:num_frames);
energyA = energyA(:, 1:num_frames);
energyB = energyB(:, 1:num_frames);
