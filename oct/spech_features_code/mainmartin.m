% Basic commands:

cd('C:\Develop\BorglabCVS\matlab\speech');

%fnameA = 'C:/Develop/Matlab/Negotiation/8k2/8K_dmerdith.9.29.sync.wav';
%fnameB = 'C:/Develop/Matlab/Negotiation/8k2/8K_dmiller.9.29.sync.wav';

% Read in the features for voicing/non-voicing, as well as the energy of
% each frame.
%[featuresA, featuresB, energyA, energyB] = voicing_features_two_files(fnameA, fnameB);


%fname = 'C:/Develop/Matlab/8k/52_jporras_sinde.wav';
fname = 'C:/Develop/Matlab/8k/47_kmcheng_jpark.wav';
[featuresA, featuresB, energyA, energyB] = voicing_features_stereo(fname);

% Estimate the voicing state for each frame.
% State 1 is not-voiced, state 2 is voiced.
[trans_probsA, musA, sigmasA] = initial_voicing_params(featuresA);
[trans_probsA, musA, sigmasA] = EM_hmm_gaussian(featuresA, trans_probsA, musA, sigmasA, 2, 5);
statesAvoicedBoth = viterbi_gaussian(featuresA, trans_probsA, musA, sigmasA);

[trans_probsB, musB, sigmasB] = initial_voicing_params(featuresB);
[trans_probsB, musB, sigmasB] = EM_hmm_gaussian(featuresB, trans_probsB, musB, sigmasB, 2, 5);
statesBvoicedBoth = viterbi_gaussian(featuresB, trans_probsB, musB, sigmasB);


% Decide when each participant is voicing
statesAvoiced = eliminate_other_speaker(statesAvoicedBoth, energyA, energyB);

statesBvoiced = eliminate_other_speaker(statesBvoicedBoth, energyB, energyA);

% Go from voicing to speaking.  We should really combine voicing vs.
% non-voicing, who is voicing, and speaking vs. non-speaking into a
% single graphical model.  But it's not clear that inference is tractible.
%
% State 1 is not speaking, 2 is speaking.
trans_probs_speakingA = [0.9999 0.0001; 0.0001 0.9999];
prob_voicedA = [0.99 0.01; 0.5 0.5];
trans_probs_speakingB = trans_probs_speakingA;
prob_voicedB = prob_voicedA;

% State 1 is not speaking, 2 is speaking.
statesAspeaking = viterbi([0.5 0.5]', prob_voicedA(:, statesAvoiced), trans_probs_speakingA);
statesBspeaking = viterbi([0.5 0.5]', prob_voicedB(:, statesBvoiced), trans_probs_speakingB);

% For the influence model, we want states to be 200 milliseconds long.
frames_per_influence_state = ceil(8000/128/5);
num_influence = floor(length(statesAspeaking) / frames_per_influence_state);

temp = reshape(statesAspeaking(1:frames_per_influence_state*num_influence), frames_per_influence_state, num_influence);
statesAspeaking_influence = double(sum(temp) > frames_per_influence_state * 1.5) + 1;
temp = reshape(statesBspeaking(1:frames_per_influence_state*num_influence), frames_per_influence_state, num_influence);
statesBspeaking_influence = double(sum(temp) > frames_per_influence_state * 1.5) + 1;

% Estimate the influcence parameters
states_speaking = [statesAspeaking_influence; statesBspeaking_influence];
alphas = estimate_influence_parameters(states_speaking, 2);


% Quick hack: estimate influence parameters over each chunk (5 min), and plot
% them chunk by chunk.
frames_per_minute = round(8000*60/128/frames_per_influence_state);
frames_per_chunk = 5 * frames_per_minute;
frames_per_chunkstep = floor(2.5 * frames_per_minute);
num_chunks = floor((size(states_speaking, 2) - frames_per_chunk) / frames_per_chunkstep) + 1;
v = zeros(num_chunks, 2);
for s=1:num_chunks
    start_frame = (s-1)*frames_per_chunkstep+1;

    this_statesAspeaking_influence = statesAspeaking_influence(start_frame:start_frame + frames_per_chunk - 1);
    this_statesBspeaking_influence = statesBspeaking_influence(start_frame:start_frame + frames_per_chunk - 1);
    
    % Influence parameters
    x = [this_statesAspeaking_influence; this_statesBspeaking_influence];
    fprintf('length(x): %d, length(uniq(x)): %d\n', length(x), length(uniq(x)));
%    alphas = estimate_influence_parameters(uniq([this_statesAspeaking_influence; this_statesBspeaking_influence]), 2);
    alphas = estimate_influence_parameters([this_statesAspeaking_influence; this_statesBspeaking_influence], 2);
    v(s, 1) = alphas(1, 2);
    v(s, 2) = alphas(2, 1);
end

figure

plot(v(:, 1))
hold on
plot(v(:, 2), 'r')
hold off
title('Influence parameters');


% Quick hack: estimate other parameters over each chunk (5 min), and plot
% them chunk by chunk.
frames_per_minute = round(8000*60/128);
frames_per_chunk = 5 * frames_per_minute;
frames_per_chunkstep = floor(2.5 * frames_per_minute);
num_chunks = floor((size(states_speaking, 2) - frames_per_chunk) / frames_per_chunkstep) + 1;
v = zeros(num_chunks, 26);
for s=1:num_chunks
    start_frame = (s-1)*frames_per_chunkstep+1;

    this_statesAspeaking = statesAspeaking(start_frame:start_frame + frames_per_chunk - 1);
    this_statesBspeaking = statesBspeaking(start_frame:start_frame + frames_per_chunk - 1);
    this_statesAvoiced = statesAvoiced(start_frame:start_frame + frames_per_chunk - 1);
    this_statesBvoiced = statesBvoiced(start_frame:start_frame + frames_per_chunk - 1);
    this_featuresA = featuresA(:, start_frame:start_frame + frames_per_chunk - 1);
    this_featuresB = featuresB(:, start_frame:start_frame + frames_per_chunk - 1);
    this_energyA = energyA(start_frame:start_frame + frames_per_chunk - 1);
    this_energyB = energyB(start_frame:start_frame + frames_per_chunk - 1);
    
    % Transition probabilities for speaker A
    trans_probs = transition_probs(this_statesAspeaking, 2);
    v(s, 3) = trans_probs(1, 2);
    v(s, 4) = trans_probs(2, 1);
    
    % Transition probabilities for speaker B
    trans_probs = transition_probs(this_statesBspeaking, 2);
    v(s, 5) = trans_probs(1, 2);
    v(s, 6) = trans_probs(2, 1);
    
    % A's energy while speaking
    e = this_energyA(find(this_statesAspeaking == 2));
    v(s, 7) = mean(e);
    v(s, 8) = std(e);
    
    % B's energy while speaking
    e = this_energyB(find(this_statesBspeaking == 2));
    v(s, 9) = mean(e);
    v(s, 10) = std(e);
    
    % A's accor peaks while voiced.
    e = this_featuresA(2, find(this_statesAvoiced == 2));
    v(s, 11) = mean(e);
    v(s, 12) = std(e);
    
    % B's accor peaks while voiced.
    e = this_featuresB(2, find(this_statesBvoiced == 2));
    v(s, 13) = mean(e);
    v(s, 14) = std(e);
    
    % A's number & avg length of voiced segments
    regions = states_to_regions(this_statesAvoiced);
    v(s, 15) = size(regions, 2);
    v(s, 16) = mean(regions(2, :) - regions(1, :));
    v(s, 17) = std(regions(2, :) - regions(1, :));
    
    % B's number & avg length of voiced segments
    regions = states_to_regions(this_statesBvoiced);
    v(s, 18) = size(regions, 2);
    v(s, 19) = mean(regions(2, :) - regions(1, :));
    v(s, 20) = std(regions(2, :) - regions(1, :));
    
    % Compute the pauses
    this_statesApause = ones(size(this_statesAspeaking));
    this_statesApause(this_statesAspeaking == 1) = 2;
    this_statesBpause = ones(size(this_statesBspeaking));
    this_statesBpause(this_statesBspeaking == 1) = 2;
    
    % A's number & length of pauses
    regions = states_to_regions(this_statesApause);
    v(s, 21) = size(regions, 2);
    v(s, 22) = mean(regions(2, :) - regions(1, :));
    v(s, 23) = std(regions(2, :) - regions(1, :));
    
    % B's number & length of pauses
    regions = states_to_regions(this_statesBpause);
    v(s, 24) = size(regions, 2);
    v(s, 25) = mean(regions(2, :) - regions(1, :));
    v(s, 26) = std(regions(2, :) - regions(1, :));
end

figure
subplot(2, 1, 1)
plot(v(:, 3))
hold on
plot(v(:, 4), ':')
hold off
title('Transition probabilities for speaker A');

subplot(2, 1, 2)
plot(v(:, 5), 'r')
hold on
plot(v(:, 6), 'r:')
title('Transition probabilities for speaker B');


figure
plot(v(:, 7));
hold on
plot(v(:, 8), ':');
plot(v(:, 9), 'r');
plot(v(:, 10), ':r');
title('A (blue) & B (red)''s energy while speaking');


figure
plot(v(:, 11));
hold on
plot(v(:, 12), ':');
plot(v(:, 13), 'r');
plot(v(:, 14), ':r');
title('A (blue) and B (red)''s autocorrelation peaks while voiced');


figure
subplot(3, 1, 1);
plot(v(:, 15));
hold on
plot(v(:, 18), 'r');
title('Number of voiced segments');

subplot(3, 1, 2);
plot(v(:, 16));
hold on
plot(v(:, 19), 'r');
title('Mean length of voiced segments (frames)');

subplot(3, 1, 3);
plot(v(:, 17));
hold on
plot(v(:, 20), 'r');
title ('Standard Deviation of length of voiced segments');


figure
subplot(3, 1, 1);
plot(v(:, 21));
hold on
plot(v(:, 24), 'r');
title('Number of pauses');

subplot(3, 1, 2);
plot(v(:, 22));
hold on
plot(v(:, 25), 'r');
title('Mean length of pauses (frames)');

subplot(3, 1, 3);
plot(v(:, 23));
hold on
plot(v(:, 26), 'r');
title ('Standard Deviation of length of pauses');


%%% Compute the fraction of the time each speaker is holding the floor.
% Compute the feature, the difference in voicing fractions.
voicing_fracA = voicing_fraction(statesAvoiced, 500, 500);
voicing_fracB = voicing_fraction(statesBvoiced, 500, 500);
voicing_frac = voicing_fracA - voicing_fracB;

% Estimate parameters for the "holding the floor" model, a three state HMM
% with Gaussian features.
[holding_probs, holding_mus, holding_sigmas] = initial_holding_params(voicing_frac);
[holding_probs, holding_mus, holding_sigmas] = EM_hmm_gaussian(voicing_frac', holding_probs, holding_mus, holding_sigmas, 3, 5);
states_holding = viterbi_gaussian(voicing_frac', holding_probs, holding_mus, holding_sigmas);


% Compute some statistics
num_frames = length(energyA);
% stats(1): fraction of time speaker A is speaking
stats(1) = length(find(statesAspeaking == 2)) / num_frames;
% stats(2): fraction of time speaker B is speaking
stats(2) = length(find(statesBspeaking == 2)) / num_frames;
% stats(3): fraction of time both speakers are speaking simultaneously
stats(3) = length(find(statesAspeaking == 2 & statesBspeaking == 2)) / num_frames;

% stats(4): std dev of A's energy / mean of A's energy, when A is speaking
e = energyA(find(statesAspeaking == 2));
stats(4) = std(e) / mean(e);
% stats(5): std dev of B's energy / mean of B's energy, when B is speaking
e = energyB(find(statesBspeaking == 2));
stats(5) = std(e) / mean(e);

% stats(6): fraction of time that A was holding floor
stats(6) = length(find(states_holding == 3)) / length(states_holding);
% stats(7): fraction of time that B was holding floor
stats(7) = length(find(states_holding == 1)) / length(states_holding);

% stats(8): average length of A's speaking time
regionsAspeaking = states_to_regions(statesAspeaking);
stats(8) = mean(regionsAspeaking(2, :) - regionsAspeaking(1, :));

% stats(9): average length of B's speaking time
regionsBspeaking = states_to_regions(statesBspeaking);
stats(9) = mean(regionsBspeaking(2, :) - regionsBspeaking(1, :));

% stats(10): A's speaking rate, i.e. frequency of voiced-nonvoiced-voiced
% transitions while speaking.
statesAvoicedSpeaking = statesAvoiced(find(statesAspeaking == 2));
regionsAvoicedSpeaking = states_to_regions(statesAvoicedSpeaking);
stats(10) = size(regionsAvoicedSpeaking, 1) / length(statesAvoicedSpeaking);

% stats(11): B's speaking rate, i.e. frequency of voiced-nonvoiced-voiced
% transitions while speaking.
statesBvoicedSpeaking = statesBvoiced(find(statesBspeaking == 2));
regionsBvoicedSpeaking = states_to_regions(statesBvoicedSpeaking);
stats(11) = size(regionsBvoicedSpeaking, 1) / length(statesBvoicedSpeaking);
