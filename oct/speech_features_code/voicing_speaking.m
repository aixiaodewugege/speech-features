function [states_voiced, states_speaking] = voicing_speaking(features, method, thresh)
% [states_voiced, states_speaking] = voicing_speaking(features)
%
% Method is either 'mixgauss' (for two speaker, not-close-talking
% microphones) or 'threshold'.  If 'threshold', then thresh is the relative
% threshold, 0 < thresh < 1.  Defaults to 0.1

num_frames = size(features, 2);
num_speakers = size(features, 3);
sumit_features = zeros(3, size(features, 2));
states_voicedAll = zeros(num_frames, num_speakers);
states_voiced = zeros(num_frames, num_speakers);
energy = zeros(num_frames, num_speakers);

for s = 1:num_speakers
    sumit_features(1, :) = features(4, :, s);
    sumit_features(2, :) = features(6, :, s);
    sumit_features(3, :) = features(3, :, s);
    sumit_features(3, ~isfinite(sumit_features(3, :))) = 0;
    energy(:, s) = features(7, :, s)';
    
    % Decide voicing/non-voicing
    % State 1 is "not voiced," state 2 is "voiced."
    [trans_probs, mus, sigmas] = initial_voicing_params(sumit_features);
    [trans_probs, mus, sigmas] = EM_hmm_gaussian(sumit_features, trans_probs, mus, sigmas, 2, 5);
    states_voicedAll(:, s) = viterbi_gaussian(sumit_features, trans_probs, mus, sigmas);
    
    %if mean(energy(states_voicedAll(:,s)==1,s))>mean(energy(states_voicedAll(:,s)==2,s)) 
    %    states_voicedAll(:,s)=3-states_voicedAll(:,s);
    %end
end


if strcmp(method, 'mixgauss')
    if num_speakers ~= 2
        error('mixgauss only appropriate for two speakers.');
    end
    
    states_voiced(:, 1) = eliminate_other_speaker(states_voicedAll(:, 1), energy(:, 1), energy(:, 2));
    states_voiced(:, 2) = eliminate_other_speaker(states_voicedAll(:, 2), energy(:, 2), energy(:, 1));
elseif strcmp(method, 'threshold')
    if nargin < 3
        thresh = 0.1;
    end
    for s = 1:num_speakers
        states_voiced(:, s) = eliminate_other(states_voicedAll(:, s), energy(:, s), thresh);
    end
else
    error('Unknown method.');
end
    
% Compute speaking/not-speaking
% State 1 is "not speaking," 2 is "speaking."
trans_probs_speaking = [0.9999 0.0001; 0.0001 0.9999];
prob_voiced = [0.99 0.01; 0.5 0.5];
for s = 1:num_speakers
    states_speaking(:, s) = viterbi([0.5 0.5]', prob_voiced(:, states_voiced(:, s)), trans_probs_speaking);
end
