# Extract Speech Features using Octave on OSX Yosemite

## Step 1 - Install Octave in a Vagrant VM
Adapted from these [instructions](http://deepneural.blogspot.fr/p/instructions-1_10.html),
* First, use the X11 installer in /Applications/Utilities or go [here](http://xquartz.macosforge.org). Test by typing "xclock" in a shell. If a little clock appears in a new window, close it and proceed.
* Now install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](http://vagrantup.com)
* Open a terminal, `cd` to the main project folder `speech-features` and:
```
vagrant up && vagrant ssh -c "octave --force-gui" && vagrant suspend
```
* Inside of Octave, install the optimization package:
```
pkg install -forge struct
pkg install -forge optim
```



## Step 2 - Run the demo in Octave
* Inside of Octave:
* To prevent a bunch of warnings, you may want to type:
```
warning('off', 'Octave:possible-matlab-short-circuit-operator');
```
* First `cd` to `~/work/bnt` folder and run
```
addpath(genpathKPM(pwd))
```
* Next `cd` to `~/work/speech_features` and run the following to compute the raw features:
```
features = speech_features_stereo('demo.wav')
```
* Next, compute voiced and speaking states with:
```
[states_voiced, states_speaking] = voicing_speaking(features, 'mixgauss')
```
* And the final features, in 2 minute chunks:
```
[means, stds, others] = chunk_features(features, states_voiced, states_speaking, 2)
```
* Apparently, influence features can be computed as follows but the required function is not implemented in Octave :(
```
alphas = chunk_influence(states_speaking, 2)
```






d
d
d
