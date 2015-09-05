function states = viterbi(init_state_distro, obser_probs, trans_probs)
% 
% trans_probs(i, j): Probability that, if at time t you're in state i, then
% at time t+1 you'll be in state j.
%
% init_state_distro(i): Probability of starting in state i.
%
% obser_probs(i, t): Probability of seeing the observation at time t if we're in state
% i.

num_obser = size(obser_probs, 2);
num_states = length(init_state_distro);
xi = zeros(num_obser, num_states);

% Initialize
delta = init_state_distro .* obser_probs(:, 1);
xi(1, :) = 0;

% Recurse
% General case:
if (num_states ~= 2)
    for t = 2:num_obser
        mat = (delta * ones(1, num_states)) .* trans_probs;
        for j = 1:num_states
            index = 1;
            for i = 2:size(mat,1)
                if (mat(i,j) > mat(index,j))
                    index = i;
                end
            end
            xi(t,j) = index;
            if mat(index, j) == 0
                error('Hey!  Max was zero!');
            end
            delta(j) = mat(index, j) * obser_probs(j, t);
        end
        % Divide delta by its biggest element, to avoid underflows.
        delta = delta / max(delta);
    end
else
    % Special case for two states.
    for t = 2:num_obser
        mat(1,1) = delta(1) * trans_probs(1,1);
        mat(1,2) = delta(1) * trans_probs(1,2);
        mat(2,1) = delta(2) * trans_probs(2,1);
        mat(2,2) = delta(2) * trans_probs(2,2);
                
        if (mat(1,1) > mat(2,1))
            xi(t,1) = 1;
        else
            xi(t,1) = 2;
        end
        delta(1) = mat(xi(t,1), 1) * obser_probs(1, t);
        
        if (mat(1,2) > mat(2,2))
            xi(t,2) = 1;
        else
            xi(t,2) = 2;
        end
        delta(2) = mat(xi(t,2), 2) * obser_probs(2, t);
        
        m = max(delta(1), delta(2));
        delta(1) = delta(1) / m;
        delta(2) = delta(2) / m;
        
    end
end
        

% Pick out the best states.
states = zeros(num_obser, 1);
states(num_obser) = argmax(delta);

for t = num_obser-1:-1:1
    states(t) = xi(t+1, states(t+1));
end

% xi
