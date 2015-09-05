function voicing_frac = voicing_fraction(states, holdingsize, holdingstep)

voicing_frac = conv(states - 1, ones(holdingsize, 1)/holdingsize);
voicing_frac = voicing_frac(holdingsize:holdingstep:end-holdingsize);
