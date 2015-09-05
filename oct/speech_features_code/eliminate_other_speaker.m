function states_same = eliminate_other_speaker(states, energy_same, energy_other)
% states_same = eliminate_other_speaker(states, energy_same, energy_other)
%

% For each voiced region, compute the ratio of energies.  We model these as
% a mixture of three Gaussians.  Lowest energy -> other person talking,
% middle energy -> both people talking, highest energy -> me talking.

regions = states_to_regions(states);

energy_same_for_warning = energy_same;
energy_same = energy_per_voiced(energy_same, regions);
energy_other = energy_per_voiced(energy_other, regions);
energy_same(energy_same < 1e-6) = 1e-6;
energy_other(energy_other < 1e-6) = 1e-6;

ratio = log(energy_same ./ energy_other);

% Fit a mixture of gaussians to the ratio.
[proportions, mus, sigmas] = fit_mixture_of_gaussians(ratio, 3, 5);
posterior = E_mixture_gaussians(ratio, proportions, mus, sigmas);
if (mus(1) > mus(2) | mus(2) > mus(3))
    %     error('ERROR: Mixture components switched order.  Problem with data?');
    warning('WARNING: Mixture components switched order.  Problem with data?');
    states_same = eliminate_other(states, energy_same_for_warning, 0.2);
else
    states_same = regions_to_states(regions(:, posterior(2, :) > posterior(1, :) | ...
        posterior(3, :) > posterior(1, :)), length(states));
end

% in cases where there is no middle gaussion (both speaking) e.g. loud backgroundnoise:
% states_same = regions_to_states(regions(:, posterior(3, :) > posterior(1, :)), length(states));
