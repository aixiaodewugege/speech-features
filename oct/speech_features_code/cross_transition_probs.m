function trans_probs = cross_transition_probs(from_states, num_from_states, to_states, num_to_states)

% trans_probs(si, sj, i, j) = P(HMM j is in to_state sj at time t+1 | HMM i
% is in from_state si at time t)
%
% from_states(i, t) is the state of the "cause" HMM i at timestep t.
%
% to_states(i, t) is the state of the "effect" HMM i at timestep t.

num_HMMs = size(from_states, 1);
assert(size(to_states, 1) == num_HMMs);

% Make sure number of timesteps are the same.
assert(size(from_states, 2) == size(to_states, 2));

trans_probs = zeros(num_from_states, num_to_states, num_HMMs, num_HMMs);

for i = 1:num_HMMs
    for si = 1:num_from_states
        times_in_from_state = find(from_states(i, 1:end-1) == si);
        if length(times_in_from_state) < 10
            warning(sprintf('Chain %d was in state %d only %d times', i, si, length(times_in_from_state)));
        end
        if isempty(times_in_from_state)
            trans_probs(si, :, i, :) = 1/num_to_states;
        else
            for j = 1:num_HMMs
                trans_probs(si, :, i, j) = (histc(to_states(j, times_in_from_state + 1), 1:num_to_states) + 1) / (length(times_in_from_state) + num_to_states);
            end
        end
    end
end
