function features = scale_speech_features(features)
% Scale the 21 speech features to be in the range 0..1 or -1..1.

features(1, :) = features(1, :) / 500; % 500 is the maximum frequency
features(2, :) = features(2, :) / 2;
features(3, :) = features(3, :) / 5;

% 4 is already fine.
features(5, :) = features(5, :) / 15;
features(6, :) = features(6, :) / 25;

% 7 is more or less fine.
features(8, :) = features(8, :) * 10;

% These scaling factors are all eyeballed from looking at histograms.  I
% don't know much about MFCC.
features(9, :) = features(9, :) / 20;
features(10, :) = features(10, :) / 4;
features(11:14, :) = features(11:14, :) / 2;
% 15 and up are fine the way they are.
