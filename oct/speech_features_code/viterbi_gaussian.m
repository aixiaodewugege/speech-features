function states = viterbi_gaussian(features, trans_probs, mus, sigmas)
%

num_features = size(features, 1);
num_frames = size(features, 2);
num_states = size(trans_probs, 1);

% First: estimate the probability of seeing the three features under each state.
feature_probs = ones(num_states, num_frames);

total_log_coeffs = - sum(real(log(sigmas.*sqrt(2*pi))),1);

if (num_features ~= 3)
    % General case
    for t = 1:num_frames
        for state = 1:num_states
            total = 0;
            for feat = 1:num_features
                total = total + ...
                    - ((features(feat, t) - mus(feat, state))/sigmas(feat, state))^2 / 2;
            end
            feature_probs(state, t) = exp(total + total_log_coeffs(state));
        end
    end
else
    for t = 1:num_frames
        % Special case for speed: num_features = 3.
        for state = 1:num_states
            total = ...
                - ((features(1, t) - mus(1, state))/sigmas(1, state))^2 / 2 + ...
                - ((features(2, t) - mus(2, state))/sigmas(2, state))^2 / 2 + ...
                - ((features(3, t) - mus(3, state))/sigmas(3, state))^2 / 2;
            feature_probs(state, t) = exp(total + total_log_coeffs(state));
        end
    end
end

states = viterbi(ones(num_states, 1)/num_states, feature_probs, trans_probs);
