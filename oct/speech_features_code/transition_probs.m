function trans_probs = transition_probs(states, num_states)

% The HMM probabilities.
trans_probs = zeros(num_states, num_states);

for prev_state = 1:num_states
    indexes = find(states(1:end-1) == prev_state);
    if (length(indexes) == 0)
        error('length(indexes) == 0');
    end
    next_states = states(indexes+1);
    trans_probs(prev_state, :) = histc(next_states, 1:num_states)' / length(next_states);
end
