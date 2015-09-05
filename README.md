# Extract Speech Features in Octave on OSX Yosemite

## Step 1 - Install Octave in a Vagrant VM
Following these [instructions](http://deepneural.blogspot.fr/p/instructions-1_10.html),
* First, use the X11 installer in /Applications/Utilities or go [here](http://xquartz.macosforge.org). Test by typing "xclock" in a shell. If aa little clock appears in a new window, close it and proceed.
* Now install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](http://vagrantup.com)
* Open a terminal, `cd` to the `oct` folder and launch the VM with Octave showing the GUI:
		vagrant up && vagrant ssh -c "cd /vagrant && octave --force-gui" && vagrant suspend
* Inside of Octave, install the optimization package:
		pkg install -forge optim


## Step 2 - Run the demo in Octave
* Inside of Octave, `cd` to the `speech_features` folder
* To prevent a bunch of warnings, you may want to type:
		warning('off', 'Octave:possible-matlab-short-circuit-operator');
* Run:
		features = speech_features_stereo('demo.wav')
* Followed by:
		[states_voiced, states_speaking] = voicing_speaking(features, 'mixgauss')

[means, stds, others] = chunk_features(features, states_voiced, states_speaking, 2)







d
d
d
