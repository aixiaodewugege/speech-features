function [trans_probs, mus, sigmas] = initial_holding_params(voicing_frac)
% [trans_probs, mus, sigmas] = initial_holding_params(voicing_frac)

trans_probs = [0.9 0.05 0.05; 0.05 0.9 0.05; 0.05 0.05 0.9];

num_frames = length(voicing_frac);
sorted = sort(voicing_frac);

third = floor(num_frames/3);

mus = [mean(sorted(1:third)) mean(sorted(third+1:2*third)) mean(sorted(2*third+1:end))];
sigmas = [std(sorted(1:third)) std(sorted(third+1:2*third)) std(sorted(2*third+1:end))];
