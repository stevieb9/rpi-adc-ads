use warnings;
use strict;
use feature 'say';

use Data::Dumper;
use RPi::ADS1x15;

my $adc = RPi::ADS1x15->new;

say $adc->read;
say $adc->read('a0');
say $adc->read('a3');
