function [proportions, mus, sigmas] = fit_mixture_of_gaussians(data, num_gaussians, num_iterations)
% [proportions, mus, sigmas] = fit_mixture_of_gaussians(data, num_gaussians, num_iterations)
%
% For now, data must be 1 dimensional.

num_data = length(data);

% Initial assignment: lowest 1/num_gaussians of data points to the first
% class, 2nd lowest 1/num_gaussians of data points to the second, etc.
data_sorted = sort(data);
soft_assignments = zeros(num_gaussians, num_data);

d = 0;
for c = 1:num_gaussians
    last_d = round(num_data / num_gaussians * c);
    soft_assignments(c, d+1:last_d) = ones(1, last_d - d);
    d = last_d;
end

% Now time for a little EM
[proportions, mus, sigmas] = M_mixture_gaussians(data_sorted, soft_assignments);

for i = 1:num_iterations
    soft_assignments = E_mixture_gaussians(data, proportions, mus, sigmas);
    [proportions, mus, sigmas] = M_mixture_gaussians(data, soft_assignments);
end    
