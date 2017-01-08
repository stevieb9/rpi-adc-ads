use warnings;
use strict;

use RPi::ADS1x15 qw(fetch);

my $adc = RPi::ADS1x15->new;

while (1){
    print "a0: ". $adc->read('a0') ."\n";
    print "a3: ". $adc->read('a3') ."\n";
    sleep 1;
}
