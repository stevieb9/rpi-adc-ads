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

    my %mux = $obj->_mux;

    my %r = (
        0 => [
                195,
                198,
            ],
        1 => [
                211,
                214,
            ],
        2 => [
                227,
                230,
            ],
        3 => [
                243,
                246,
            ],
    );

    for (qw(0 1 2 3)){
        $obj->channel($_);
        is $obj->channel, $_, "channel $_ set ok";

        # register

        my ($msb, $lsb) = $obj->register;

        is $msb, $r{$_}->[0], "msb ok for channel $_";
        is $msb + $lsb, $r{$_}->[1], "total bits ok for channel $_";        

        is $r{$_}->[0] & $mux{$_}, $mux{$_}, "channel $_ has ok bit value total after bitwise AND";
    }
}
done_testing();
exit;

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
