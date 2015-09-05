function [means, stds, others, alphas] = chunk_features_separate_files(file_names, minutes_per_chunk)

% features = chunk_features(file_name)
%
% Returns various features over minutes_per_chunk minutes, default 5.
%
% Assumes close talking microphones.
%
% means(f, t, s) is the mean of feature f over chunk t for speaker s.
% stds(f, t, s) is the standard deviation of feature f over chunk t for speaker s.
% others(f, t, s) is the value of feature f over chunk t for speaker s.
% alphas(i, j, t) is the influence of speaker i on speaker j over chunk t.
%
%  Eight Features (for means/stds):
%
%  1 - formant frequency (Hz)
%  2 - confidence in formant frequency
%  3 - spectral entropy
% 
%  4 - value of largest autocorrelation peak
%  5 - location of largest autocorrelation peak
%  6 - number of autocorelation peaks
% 
%  7 - energy in frame
%  8 - time derivative of energy in frame
%
% Other Features:
%  1 - Average length of voiced segment (seconds)
%  2 - Average length of speaking segment (seconds)
%  3 - Fraction of time speaking
%  4 - Voicing rate: number of voiced regions per second speaking
%  5 - Fraction speaking over: fraction of time that you & any other
%        speaker are speaking.
%  6 - Average number of short speaking segments (< 1 sec) per minute.
%        Only segments within 1 sec of similarly short segments of any
%        other speaker are included.


if nargin < 2
    minutes_per_chunk = 5;
end

features = speech_features_separate_files(file_names);
[states_voiced, states_speaking] = voicing_speaking(features, 'threshold', 0.1);
[means, stds, others] = chunk_features(features, states_voiced, states_speaking, minutes_per_chunk);
alphas = chunk_influence(states_speaking, minutes_per_chunk);
