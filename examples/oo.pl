use warnings;
use strict;
use feature 'say';

use Data::Dumper;
use RPi::ADC::ADS;

my $adc = RPi::ADC::ADS->new();

say "$_\n" for $adc->_bytes;
say $adc->volts(0);

say $adc->raw(0);

say $adc->percent(0);



