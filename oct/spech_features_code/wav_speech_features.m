function [featuresL, featuresR] = wav_speech_features(fname, framesize, framestep, std_devL, std_devR, filter_val)

if (nargin<6)
    filter_val = [];
end

if (~isempty(filter_val))
    b = filter_val(1,:);
    a = filter_val(2,:);
end

sz = wavread(fname, 'size');

if sz(2) == 1
    if nargout ~= 1
        error('File is mono, only 1 output arg expected.');
    end
elseif sz(2) == 2
    if nargout ~= 2
        error('File is stereo, 2 output args expected.');
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

featuresL = zeros(21, total_num_frames);
if sz(2) > 1
    featuresR = zeros(21, total_num_frames);
end

for r = 1:num_reads
    start_frame = (r - 1) * frames_per_read + 1;
    end_frame = min(r * frames_per_read, total_num_frames);
    start_sample = (start_frame - 1) * framestep + 1;
    end_sample = (end_frame - 1) * framestep + framesize;
    
    fprintf(1, 'reading %f min to %f min\n', (start_sample - 1) / 8000 / 60, ...
        (end_sample - 1) / 8000 / 60);
    
    sig = wavread(fname, [start_sample end_sample]);
    if (~isempty(filter_val))
        sig = filter(b,a,sig);
    end
    featuresL(:, start_frame:end_frame) = speech_features(sig(:, 1), 256, 128, std_devL);
    if sz(2) > 1
        featuresR(:, start_frame:end_frame) = speech_features(sig(:, 2), 256, 128, std_devR);
    end
end
