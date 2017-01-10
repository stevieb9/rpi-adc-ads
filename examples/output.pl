use warnings;
use strict;
use feature 'say';

use RPi::ADC::ADS;

my $o = RPi::ADC::ADS->new;


print "channel 0\n";

say "v: " . $o->volts;
say "%: " .$o->percent;
say "r: " . $o->raw;

print "\n";

print "channel 3\n";

say "v: " . $o->volts(3);
say "%: " . $o->percent(3);
say "r: " . $o->raw(3);
