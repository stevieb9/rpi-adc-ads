use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

my %map = (
    '000' => [
            49411,
            193,
            3,
        ],
    '001' => [
            49923,
            195,
            3,
        ],
    '010' => [
            50435,
            197,
            3,
        ],
    '011' => [
            50947,
            199,
            3,
        ],
    '100' => [
            51459,
            201,
            3,
        ],
    '101' => [
            51971,
            203,
            3,
        ],
    '110' => [
            52483,
            205,
            3,
        ],
    '111' => [
            52995,
            207,
            3,
        ],
);

{ # gain (bits 2-0)

    my $o = $mod->new;

    is $o->bits, 49923, "default bits ok";

    # printf("xxx: %b\n", $o->bits);

    my ($m, $l) = $o->register;
    is $m, 195, "default msb ok";
    is $l, 3, "default lsb ok";

    for (qw(000 001 010 011 100 101 110 111)){
        $o->gain($_);
        is $o->bits, $map{$_}->[0], "$_ bits ok";

        # printf("$_: %b\n", $o->bits);

        my ($m, $l) = $o->register;
        is $m, $map{$_}->[1], "$_ msb ok";
        is $l, $map{$_}->[2], "$_ lsb ok";

    }

    $o->gain('000');
    # printf("000: %b\n", $o->bits);
    is $o->bits, 49411, "000 goes back to unset bits ok";
}

done_testing();
exit;
{ # bad

    my $o = $mod->new;

    my $ok = eval { $o->gain('11'); 1; };

    is $ok, undef, "dies on bad param";
    like $@, qr/gain param requires/, "...error msg ok";
}

done_testing();
