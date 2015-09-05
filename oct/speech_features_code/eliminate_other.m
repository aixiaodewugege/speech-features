function states_same = eliminate_other(states, energy, rel_threshold)
% states_same = eliminate_other(states, energy, rel_threshold)
%

regions = states_to_regions(states);

energy = energy_per_voiced(energy, regions);
energy(energy < 1e-6) = 1e-6;

power = mean(energy)* rel_threshold;


states_same = regions_to_states(regions(:, energy > power), length(states));

