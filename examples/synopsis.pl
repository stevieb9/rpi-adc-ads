use warnings;
use strict;

use RPi::ADS1x15 qw(fetch);

my $volts = fetch(0x48, '/dev/i2c-1');

print "analog level: $volts\n";

