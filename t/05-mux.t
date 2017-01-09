use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

{ # multiplexer (channel) conversion to binary

    my $obj = $mod->new;
    my %mux = $obj->_mux;

    is $mux{0}, 64,  "chan 0 has ok binary";
    is $mux{1}, 80,  "chan 1 has ok binary";
    is $mux{2}, 96,  "chan 2 has ok binary";
    is $mux{3}, 112, "chan 3 has ok binary";
}

done_testing();
