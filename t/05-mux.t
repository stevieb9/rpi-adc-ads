use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

{ # multiplexer (channel) conversion to binary

    my $obj = $mod->new;
    my %mux = $obj->_mux;

    is $mux{0}, '100', "chan 0 has ok binary";
    is $mux{1}, '101', "chan 1 has ok binary";
    is $mux{2}, '110', "chan 2 has ok binary";
    is $mux{3}, '111', "chan 3 has ok binary";
}

done_testing();