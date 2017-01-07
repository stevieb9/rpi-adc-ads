use warnings;
use strict;

use RPi::ADS1x15 qw(fetch);

my $addr = 0x48;
my $i2c  = '/dev/i2c-1');

while (1){
    my $volts = fetch($addr, $i2c);
    print "analog level: $volts\n";
    sleep 2;
}
