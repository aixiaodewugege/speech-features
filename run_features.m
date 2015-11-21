files = [
    {'./wav/031a.wav','./wav/031b.wav'},
    {'./wav/032a.wav','./wav/032b.wav'},
    {'./wav/033a.wav','./wav/033b.wav'},
    {'./wav/034a.wav','./wav/034b.wav'},
    {'./wav/035a.wav','./wav/035b.wav'},
    {'./wav/036a.wav','./wav/036b.wav'},
    {'./wav/037a.wav','./wav/037b.wav'},
    {'./wav/038a.wav','./wav/038b.wav'},
    {'./wav/039a.wav','./wav/039b.wav'},
    {'./wav/040a.wav','./wav/040b.wav'},
    {'./wav/041a.wav','./wav/041b.wav'},
    {'./wav/042a.wav','./wav/042b.wav'}
];

addpath('oct/bnt');
addpath(genpathKPM('oct/bnt'));
addpath('oct/speech_features_code');
addpath('oct/matlab-json');
minutes_per_chunk = 0;

for i = 1:length(files)
    result = {};
    ids = regexp(sprintf('%s%s\n',files{i,:}),'\d+[ab]','match');
    result.name = sprintf('%s%s',ids{1});
    fprintf('%s\n---------------------\n',result.name);
    try
        features = speech_features_separate_files(files(i,:));
    catch
        fprintf('features failed\n');
        continue;
    end

    try
        [states_voiced, states_speaking] = voicing_speaking(features, 'mixgauss');
    catch
        fprintf('voicing_speaking failed\n');
        continue;
    end

    if minutes_per_chunk == 0
        mpc = floor(size(features,2)/3780);
    else
        mpc = minutes_per_chunk;
    end

    try
        [result.means, result.stds, result.others] = ...
            chunk_features(features, states_voiced, states_speaking, mpc);
    catch
        fprintf('chunk_features failed\n');
        continue;
    end

    try
        result.alphas = chunk_influence(states_speaking, mpc);
    catch
        fprintf('alphas failed\n');
        continue;
    end
    result

    if exist('results')
        results(end+1) = result;
    else
        results = result;
    end

end

filename = sprintf('speech_features_output_%02dmpc.json',minutes_per_chunk);
json.startup;
json.write(results, filename);
