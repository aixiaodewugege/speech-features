function [value, gradient] = influence_likelihood(alphas, from_states, to_states, trans_probs, dest_hmm)
%
% Returns the NEGATIVE of the likelihood, so that we can minimize it.
%
% This could be sped up a bit more if need be.

num_timesteps = size(from_states, 2);
assert(size(to_states, 2) == num_timesteps);

num_HMMs = size(from_states, 1);
assert(size(to_states, 1) == num_HMMs);

value = 0;
gradient = zeros(1, num_HMMs);
probs_helper = trans_probs(:, :, :, dest_hmm);
probs = zeros(1, num_HMMs);
for t = 2:num_timesteps
    total = 0;
    for j = 1:num_HMMs
        probs(j) = probs_helper(from_states(j, t-1), to_states(dest_hmm, t), j);
        total = total + alphas(j) * probs(j);
    end
    value = value + log(total);
    gradient = gradient + probs / total;
end

value = -value;
gradient = -gradient;
