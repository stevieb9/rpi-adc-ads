use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

my %map = (
    '00' => [
            49920,
            195,
            0,
        ],
    '01' => [
            49921,
            195,
            1,
        ],
    '10' => [
            49922,
            195,
            2,
        ],
    '11' => [
            49923,
            195,
            3,
        ],
);

{ # queue (bits 2-0)

    my $o = $mod->new;

    is $o->bits, 49923, "default bits ok";

    my ($m, $l) = $o->register;
    is $m, 195, "default msb ok";
    is $l, 3, "default lsb ok";

    for (qw(00 01 10 11)){
        $o->queue($_);
        is $o->bits, $map{$_}->[0], "$_ bits ok";

        my ($m, $l) = $o->register;
        is $m, $map{$_}->[1], "$_ msb ok";
        is $l, $map{$_}->[2], "$_ lsb ok";
    }
}

{ # bad

    my $o = $mod->new;

    my $ok = eval { $o->queue('111'); 1; };

    is $ok, undef, "dies on bad param";
    like $@, qr/queue param requires/, "...error msg ok";
}

done_testing();