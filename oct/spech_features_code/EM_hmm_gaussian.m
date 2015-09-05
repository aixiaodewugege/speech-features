function [trans_probs, mus, sigmas] = EM_hmm_gaussian(data, trans_probs, mus, sigmas, num_states, max_iterations)


num_observations = size(data, 1);

% Convert standard deviations to a bunch of diagonal covariance matricies
cov_bnt = zeros(num_observations, num_observations, num_states, 1);
for s = 1:num_states
    cov_bnt(:,:,s) = diag(sigmas(:, s).^2);
end

initial_state_probs = ones(num_states, 1)/num_states;

[LL, initial_state_probs, trans_probs, mus, cov_bnt] = ...
    mhmm_em(data, ones(num_states, 1)/num_states, trans_probs, ...
    mus, cov_bnt, ones(num_states, 1), ...
    'cov_type', 'diag', 'adj_prior', 0, 'max_iter', max_iterations);

if any(~isfinite(LL))
    error('Loglik messed up.');
end

% Extract the diagonal entries from cov_bnt
for s = 1:num_states
    sigmas(:, s) = sqrt(diag(cov_bnt(:, :, s)));
end
