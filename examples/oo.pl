use warnings;
use strict;
use feature 'say';

use Data::Dumper;
use RPi::ADC::ADS;

my $adc = RPi::ADC::ADS->new;

say $adc->read('a0');
say $adc->read('a3');
