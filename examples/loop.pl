use warnings;
use strict;

use RPi::ADC::ADS qw(fetch);

my $adc = RPi::ADC::ADS->new;

while (1){
    print "a0: ". $adc->read('a0') ."\n";
    print "a3: ". $adc->read('a3') ."\n";
    sleep 1;
}
