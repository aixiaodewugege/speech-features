function [trans_probs, means, stds] = initial_voicing_params(features)
% [trans_probs, means, stds] = initial_voicing_params(features)

trans_probs = [0.95 0.05; 0.05 0.95];

num_frames = size(features, 2);
sorted = sort(features, 2);

half = floor(num_frames/2);

means = [mean(sorted(1, 1:half)) mean(sorted(1, half+1:end));
         mean(sorted(2, half+1:end)) mean(sorted(2, 1:half));
         mean(sorted(3, half+1:end)) mean(sorted(3, 1:half))];
stds = [std(sorted(1, 1:half)) std(sorted(1, half+1:end));
        std(sorted(2, half+1:end)) std(sorted(2, 1:half));
        std(sorted(3, half+1:end)) std(sorted(3, 1:half))];
    
% If there's a hum in the signal, we can get a large number of frames where
% the autocorrelation vectors are almost all identical.  In particular,
% they'll all have the same number of peaks.  This leads to standard
% deviations that are too small.  So here, we make sure they have some
% minimum.  With the experience Ron has had, you probably don't want to
% train on these negotiations anyway.

stds(2, stds(2, :) < 2) = 2;
