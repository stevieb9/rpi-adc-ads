use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

{ # default

    my $obj = $mod->new;

    is $obj->channel, 0, "channel() default is ok";
}

{ # legit channels

    my $obj = $mod->new;

    my %register = (
        0 => [
                '1100001100000011',
                '100',
            ],
        1 => [
                '1101001100000011',
                '101',
            ],
        2 => [
                '1110001100000011',
                '110',
            ],
        3 => [
                '1111001100000011',
                '111',
            ],
    );

    for (qw(0 1 2 3)){
        $obj->channel($_);
        is $obj->channel, $_, "channel $_ set ok";

        # register

        is $obj->register, $register{$_}->[0], "$_ binary register ok";

        # bits 14-12

        my $bits = substr $obj->register, 1, 3;
        is $bits, $register{$_}->[1], "$_ sets register bits 14-12 ok";
    }
}

{ # faulty channels

    my $obj = $mod->new;

    my $ok = eval { $obj->channel('A'); 1; };

    is $ok, undef, "alpha chars in channel() die";
    like $@, qr/invalid channel spec/, "...with proper error msg";

    for (qw(-1 4)){
        my $ok = eval { $obj->channel($_); 1; };
        is $ok, undef, "dies with channel $_, which is out of bounds";
    }
}
done_testing();