function secondsSpeaking = change_speaking_segmentsize(statesAspeaking,stepSize)

% Perform run length encoding, so that we match the format that
% label_speech_features returns.
%
% NOTE: regions(1, r) is the first voiced frame of the region,
%       regions(2, r) is the first unvoiced frame after the region.

i=1;
for frame = 1:stepSize:length(statesAspeaking)-stepSize
    secondsSpeaking(i,1) = (sum(statesAspeaking(frame:frame+stepSize)) > (stepSize*1.5) +1) +1 ;
    i=i+1;
end
