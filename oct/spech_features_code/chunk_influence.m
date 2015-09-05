function alphas = chunk_influence(states_speaking, minutes_per_chunk)
%
% alphas(i, j, t) is the influence of speaker i on speaker j over chunk t.


num_frames = size(states_speaking, 1);
num_speakers = size(states_speaking, 2);

% For the influence model, we want states to be 200 milliseconds long.
frames_per_influence_state = floor(8000/128/5);
num_influence = floor(num_frames / frames_per_influence_state);

temp = reshape(states_speaking(1:frames_per_influence_state*num_influence, :), frames_per_influence_state, num_influence, num_speakers);
states_speaking_influence = double(sum(temp) > frames_per_influence_state * 1.5) + 1;
states_speaking_influence = reshape(states_speaking_influence, num_influence, num_speakers);

if (minutes_per_chunk == inf)
    frames_per_chunk = num_frames -frames_per_influence_state;
else
    frames_per_chunk = round(8000/128*60*minutes_per_chunk);
end

num_chunks = floor(num_frames / frames_per_chunk);

alphas = zeros(num_speakers, num_speakers, num_chunks);

for t = 1:num_chunks
    % Estimate the influcence parameters
    frames_influence = round(frames_per_chunk*(t-1) / frames_per_influence_state)+1:round(frames_per_chunk*t / frames_per_influence_state);
        
    alphas(:, :, t) = estimate_influence_parameters(states_speaking_influence(frames_influence, :)', 2,states_speaking_influence(frames_influence, :)', 2);
end

