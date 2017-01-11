use warnings;
use strict;
use feature 'say';

use RPi::ADC::ADS;

my $o = RPi::ADC::ADS->new;

say $o->volts(0);
say $o->volts(3);

say $o->percent(0);
say $o->percent(5);
