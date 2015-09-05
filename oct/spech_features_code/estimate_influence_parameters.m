function alphas = estimate_influence_parameters(from_states, num_from_states, to_states, num_to_states)
% alphas = estimate_influence_parameters(from_states, num_from_states, to_states, num_to_states)
%
% from_states(i, t) is the state of "cause" HMM i at timestep t.  The
% states at the last timestep aren't used.
%
% to_state(i, t) is the state of "effect" HMM j at timestep t.  The states
% at the first timestep aren't used.
%
% alpha(i, j) is the influence of "cause" HMM i on "effect" HMM j.

trans_probs = cross_transition_probs(from_states, num_from_states, to_states, num_to_states);


% Now to fit the influence parameters.
num_HMMs = size(from_states, 1);
assert(size(to_states, 1) == num_HMMs);

options = optimset('GradObj', 'on', 'Display', 'none');
% To get detailed info during gradient descent:
% options = optimset('GradObj', 'on', 'Display', 'iter');

for i = 1:num_HMMs
    % After all this, fmincon seems to use a pretty conservative algorithm,
    % such as simplex.  Since our likelihood is convex, we could probably
    % write a simple search algorithm ourselves that would be faster.
    alphas(i, :) = fmincon(@influence_likelihood, ones(1, num_HMMs)/num_HMMs, ...
        [], [], ...
        ones(1, num_HMMs), [1], ...
        zeros(1, num_HMMs), ones(1, num_HMMs)*Inf, ...
        [], options, ...
        from_states, to_states, trans_probs, i);
end
