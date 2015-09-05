function [featuresL, energyL, featuresR, energyR] = wav_voicing_features(fname, framesize, framestep, std_devL, std_devR, filter)

% features(1, t) = maximum autocorrelation peak
% features(2, t) = number of autocorrelation peaks
% features(3, t) = spectral entropy
% energy(t) = average signal^2

if (~isempty(filter))
    b = filter(1,:);
    a = filter(2,:);
end

sz = wavread(fname, 'size');

if sz(2) == 1
    if nargout ~= 2
        error('File is mono, only 2 output args expected.');
    end
elseif sz(2) == 2
    if nargout ~= 4
        error('File is stereo, 4 output args expected.');
    end
else
    error('Can only work with mono and stereo files.');
end

[tmp, fs] = wavread(fname, 1);

if (fs ~= 8000)
    error ('Wav file must be 8000 Hz.');
end

% Read not more than 5 minutes at a time.
samples_per_read = 8000*60*5;

num_reads = ceil(sz(1) / samples_per_read);
total_num_frames = floor((sz(1) - framesize) / framestep) + 1;
frames_per_read = ceil(total_num_frames / num_reads);

featuresL = zeros(3, total_num_frames);
energyL = zeros(1, total_num_frames);
if sz(2) > 1
    featuresR = zeros(3, total_num_frames);
    energyR = zeros(1, total_num_frames);
end

for r = 1:num_reads
    start_frame = (r - 1) * frames_per_read + 1;
    end_frame = min(r * frames_per_read, total_num_frames);
    start_sample = (start_frame - 1) * framestep + 1;
    end_sample = (end_frame - 1) * framestep + framesize;
    
    fprintf(1, 'reading %f min to %f min\n', (start_sample - 1) / 8000 / 60, ...
        (end_sample - 1) / 8000 / 60);
    
    sig = wavread(fname, [start_sample end_sample]);
    if (~isempty(filter))
        sig = filter(b,a,sig);
    end
    featuresL(:, start_frame:end_frame) = fast_voicing_features(sig(:, 1), 256, 128, std_devL);
    if sz(2) > 1
        featuresR(:, start_frame:end_frame) = fast_voicing_features(sig(:, 2), 256, 128, std_devR);
    end

    % compute the energy of each frame
    for f = start_frame:end_frame
        energyL(f) = sum(sig((f-start_frame)*framestep + 1:(f-start_frame)*framestep+framesize, 1).^2) / framesize;
        if sz(2) > 1
            energyR(f) = sum(sig((f-start_frame)*framestep + 1:(f-start_frame)*framestep+framesize, 2).^2) / framesize;
        end
    end
end
