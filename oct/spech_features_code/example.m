% Guide to Matlab Code:
%
% This code relies heavily on the fact that there is one person per microphone.
%
% First compute the 21 speech features each frame (i.e. 62.5 times a
% second):


features = speech_features_stereo('demo.wav');
% or with low frequency noise:
[b,a] = butter(7,500/8000,'high');
filter_val = [b;a]; 
features = speech_features_stereo('demo.wav',filter_val);
% or for one or multiple mono files
%features = speech_features_separate_files({'demo.wav'});


% You can then compute the voiced/not-voiced and speaking/not-speaking
% states every frame.  If you have close talking microphones, where other
% speakers are very quite or inaudible, use the 'threshold' method.  If you
% have lapell mics, where the speaker is loudest in their own microphone
% but understandable in other microphones, use the 'mixgauss' method.  The
% lapell mics/'mixgauss' method only works for two speakers.
[states_voiced, states_speaking] = voicing_speaking(features, 'threshold', 0.1);
% [states_voiced, states_speaking] = voicing_speaking(features, 'mixgauss');


% If you want information at longer timescales, you can call
% chunk_influence and chunk_features:

[means, stds, others] = chunk_features(features, states_voiced, states_speaking, 5);
alphas = chunk_influence(states_speaking, 5);

% The last argument to both functions is the number of minutes per chunk.
% These functions assume that every speaker speaks at least once during each
% chunk, and hopefully more than that.  If not, they will trigger an error.
% Instead, they should probably just return NaN or something similar.  That
% would be a good project for someone...