function [proportions, mus, sigmas] = M_mixture_gaussians(data, soft_assignments)

% The M step: Compute the parameters that maximize the expected complete
% log likelihood.
%
% soft_assignment is size  num_classes x num_data
% data is a vector of size num_data
%
% For now, data must be one dimentional.

% First, estimate the parameters of the Gaussians.
num_classes = size(soft_assignments, 1);

mus = zeros(num_classes, 1);
scales = zeros(num_classes, 1);

data = data(:)';

for c = 1:num_classes
    mus(c) = sum(soft_assignments(c, :) .* data) / sum(soft_assignments(c, :));
    sigmas(c) = sqrt(sum(soft_assignments(c, :) .* (data - mus(c)).^2) / sum(soft_assignments(c, :)));
end

% Now, estimate the mixing proportions
proportions = sum(soft_assignments, 2) ./ length(data);
