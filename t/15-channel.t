use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

my %map = (
    '000' => [
        33539,
        131,
        3,
    ],
    '001' => [
        37635,
        147,
        3,
    ],
    '010' => [
        41731,
        163,
        3,
    ],
    '011' => [
        45827,
        179,
        3,
    ],
    '100' => [ # default
        49923,
        195,
        3,
    ],
    '101' => [
        54019,
        211,
        3,
    ],
    '110' => [
        58115,
        227,
        3,
    ],
    '111' => [
        62211,
        243,
        3,
    ],
);

{ # channel (bits 2-0)

    my $o = $mod->new;

    is $o->bits, 49923, "default bits ok";

    # printf("xxx: %b\n", $o->bits);

    my ($m, $l) = $o->register;
    is $m, 195, "default msb ok";
    is $l, 3, "default lsb ok";

    for (qw(000 001 010 011 100 101 110 111)){
        $o->channel($_);
        is $o->bits, $map{$_}->[0], "$_ bits ok";

        # printf("$_: %b\n", $o->bits);

        my ($m, $l) = $o->register;
        is $m, $map{$_}->[1], "$_ msb ok";
        is $l, $map{$_}->[2], "$_ lsb ok";
    }

    $o->channel('000');
    # printf("000: %b\n", $o->bits);
    is $o->bits, 33539, "000 goes back to default bits ok";
}


{ # bad

    my $o = $mod->new;

    my $ok = eval { $o->channel('11'); 1; };

    is $ok, undef, "dies on bad param";
    like $@, qr/channel param requires/, "...error msg ok";
}

done_testing();