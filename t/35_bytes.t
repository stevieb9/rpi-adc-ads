use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

my %byte = (
    0 => '0xc3',
    1 => '0xd3',
    2 => '0xe3',
    3 => '0xf3',
);

{ # default

    my $obj = $mod->new;
    my @b = $obj->_bytes;

    is @b, 2, "bytes has proper elem count";

    is $b[0], '0xc3', "byte 0 default ok";
    is $b[1], '0x3',  "byte 1 default ok";
}
{ # channels

    my $obj = $mod->new;

    for (qw(0 1 2 3)){
        $obj->channel($_);
        my @b = $obj->_bytes;
        is $b[0], $byte{$_}, "channel $_, byte 0 ok: $byte{$_}";
        is $b[1], '0x3', "channel $_, byte 1 ok";
    }
}

done_testing();