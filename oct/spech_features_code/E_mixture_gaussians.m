function [soft_assignments] = E_mixture_gaussians(data, proportions, mus, sigmas)

% data is a vector of size num_data x 1.
% proportions, mus and sigmas are each vectors of size 1 x num_classes.

% The E step: Compute the parameters of the expected complete log
% likelihood.  For a mixure model, this is just the soft assignments.

% soft_assignment is size  num_classes x num_data

data = data(:)';
num_classes = length(proportions);
num_data = length(data);

% I really wish Matlab had asserts...
if min(size(data)) ~= 1
    error('data must be a vector of size num_data x 1.');
end

if min(size(proportions)) ~= 1
    error('proportions must be a vector of size 1 x num_classes.');
end

if length(mus) ~= num_classes
    error('length(mus) ~= num_classes');
end

if length(sigmas) ~= num_classes
    error('length(sigmas) ~= num_classes');
end

soft_assignments = zeros(num_classes, num_data);

weights = zeros(1, num_data);
for c = 1:num_classes
    soft_assignments(c, :) = proportions(c) / (sigmas(c) * sqrt(2*pi)) * exp(-(data - mus(c)).^2 / (2*sigmas(c)^2));
    weights = weights + soft_assignments(c, :);
end

% Now normalize by the weights.  Hope none of them are zero.  :)
for c = 1:num_classes
    soft_assignments(c, :) = soft_assignments(c, :) ./ weights;
end

% The log likelihood is the log of the product of the weights.
fprintf(1, 'Log likliehood: %g\n', sum(log(weights)));
