function regions = states_to_regions(states)

% Perform run length encoding, so that we match the format that
% label_speech_features returns.
%
% NOTE: regions(1, r) is the first voiced frame of the region,
%       regions(2, r) is the first unvoiced frame after the region.
num_frames = size(states, 1);

next_region = 1;
voiced = 0;
regions = [];

for frame = 1:num_frames
    if voiced == 0 & states(frame) == 2
        if (frame == num_frames)
            return;
        end
        regions(1, next_region) = frame;
        voiced = 1;
    elseif voiced == 1 & states(frame) == 1
        regions(2, next_region) = frame;
        voiced = 0;
        next_region = next_region + 1;
    end
end

if (voiced)
    regions(2, next_region) = num_frames;
end
