use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

my %map = (
    '000' => [
            49923,
            195,
            3,
        ],
    '001' => [
            49955,
            195,
            35,
        ],
    '010' => [
            49987,
            195,
            67,
        ],
    '011' => [
            50019,
            195,
            99,
        ],
    '100' => [
            50051,
            195,
            131,
        ],
    '101' => [
            50083,
            195,
            163,
        ],
    '110' => [
            50115,
            195,
            195,
        ],
    '111' => [
            50147,
            195,
            227,
        ],
);

{ # rate (bits 2-0)

    my $o = $mod->new;

    is $o->bits, 49923, "default bits ok";

    # printf("xxx: %b\n", $o->bits);

    my ($m, $l) = $o->register;
    is $m, 195, "default msb ok";
    is $l, 3, "default lsb ok";

    for (qw(000 001 010 011 100 101 110 111)){
        $o->rate($_);
        is $o->bits, $map{$_}->[0], "$_ bits ok";

        # printf("$_: %b\n", $o->bits);

        my ($m, $l) = $o->register;
        is $m, $map{$_}->[1], "$_ msb ok";
        is $l, $map{$_}->[2], "$_ lsb ok";
    }

    $o->rate('000');
    # printf("000: %b\n", $o->bits);
    is $o->bits, 49923, "000 goes back to default bits ok";
}


{ # bad

    my $o = $mod->new;

    my $ok = eval { $o->rate('11'); 1; };

    is $ok, undef, "dies on bad param";
    like $@, qr/rate param requires/, "...error msg ok";
}

done_testing();