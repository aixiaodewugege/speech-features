function energy_pv = energy_per_voiced(energy, regions)

num_voiced = size(regions, 2);
energy_pv = zeros(num_voiced, 1);
% for each voiced region
for r = 1:num_voiced
    energy_pv(r) = sum(energy(regions(1, r):regions(2, r)-1)) / (regions(2, r) - regions(1,r));
end
