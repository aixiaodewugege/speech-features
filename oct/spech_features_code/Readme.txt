Short introduction to speech feature extraction code:


Step 1:
Create speech features:

If you have a one stereo file with each speaker in one channel use:
	features = speech_features_stereo('demo.wav')

If you are using several mono audio files use (the audio files have to be synchronized):
	speech_features_separate_files({'file1.wav', 'file2.wav', 'file3.wav'})

	
Both functions are wrappers to process the individual audio streams. The main purpose is to calculate the overall rms (wavrms.m) as input for the actual features extraction.


wav_speech_features.m: is a wrapper that process the audio signal in chunks of less 5min. (to minimize memory usage)

speech_features.m: calculates the actual features for each chunk. (details in code)


Step 2:
Determines voiced/unvoiced and speaking/non-speaking states

voicing_speaking.m: 
	I cluster voiced/unvoiced
	II remove other speakers 
	III cluster speaking/non-speaking

I) voiced/unvoiced:
this scripts is using Sumit Basu's algorithm to detect the voiced/unvoiced segments (for details see: http://vismod.media.mit.edu//tech-reports/TR-557.pdf).

for this part the following m-files are use:
initial_voicing_params.m
EM_hmm_gaussian.m
viterbi_gaussian.m

II) remove other speakers:
Basu's algorithm is mostly energy independent and detects any kind of voiced/unvoiced. Therefore it is necessary to remove other speakers voices. This can be done with a gaussian mixture model or energy threshold. These function use:

Gaussian: (works only for two speakers)
eliminate_other_speaker.m
fit_mixture_of_gaussiansm
M_mixture_gaussians.m
E_mixture_gaussians.m
viterbi.m

Gaussian + Threshold:
energy_per_voiced.m
states_to_regions.m
regions_to_states.m

III) speaking/non-speaking:
For this a simple HMM is applied. 


Step 3:
Generate overall statistics for longer timeframe: (from 1 min to all)

chunk_features.m: see comment in code
chunk_influence.m: implementation of influence model