function states = regions_to_states(regions, num_frames)
% Turns "regions" (a list of when frames switch from voiced to unvoiced)
% into "states" states(frame) = 1 for non-voiced and 2 for voiced.

states = zeros(num_frames, 1);
frame = 0;
for i = 1:size(regions, 2)
    %%%%% First: non-voiced
    for f = frame+1:regions(1, i)-1
        frame = frame + 1;
        states(f) = 1;
    end

    %%%%% Next: voiced
    for f = frame+1:regions(2, i)-1
        frame = frame + 1;
        states(f) = 2;
    end
end

% The non-voiced region that follows everything else
for f = frame+1:num_frames
    states(f) = 1;
end
