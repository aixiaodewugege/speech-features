function features = fast_voicing_features(sig, framesize, framestep, std_dev);

% features(1, t) = maximum autocorrelation peak
% features(2, t) = number of autocorrelation peaks
% features(3, t) = spectral entropy

num_frames = floor( (length(sig) - (framesize-framestep))/framestep);
features = zeros(3, num_frames);

h = hamming(framesize);
inv_length = 1/framesize;
nfft = framesize;

% In autocorrelation computation:
nacorr = framesize/2;
% compensate for frame effects: scale by 1/( 1/framesize -- framesize/framesize -- 1/framesize)
% compensating multiplier
comp = [framesize:-1:framesize-nacorr+1]/framesize;
comp = 1./comp';
    

for f = 1:num_frames
    % Grab frame and remove DC component
    avg = sum(sig((f-1)*framestep+1:(f-1)*framestep+framesize)) / framesize;
    frame = sig((f-1)*framestep+1:(f-1)*framestep+framesize) - avg(1);
    
    % Compute spectrogram
    tmp = fft(frame .* h,nfft); 
    spec = abs(tmp(1:(nfft/2)));
    
    % Compute spectral entropy
    normspec = spec / (sum(spec) + 1e-5);
    normspec(normspec < 1e-5) = 1e-5;
    features(3, f) = -sum(normspec .* log(normspec));
    
    % Compute autocorrelation
    X = fft(frame,2*framesize);
    c = ifft(X.*conj(X));
    % Multiply by comp to compensate for frame effects
    acorr = real(c(1:nacorr)).*comp/(sum(frame.^2)+std_dev^2*framesize);
    
    % Compute the values of the autocorrelation peaks
    peakvals = fast_find_acorr_peaks(acorr);
    features(1, f) = max(peakvals);
    features(2, f) = length(peakvals);
end
