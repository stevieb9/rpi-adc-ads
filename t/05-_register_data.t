use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

my %mux = (
    # bit 14-12 (most significant bit shown)
    '000' => 0x0,    # 00000000, 0
    '001' => 0x1000, # 00100000, 4096
    '010' => 0x2000, # 00100000, 8192
    '011' => 0x3000, # 00110000, 12288
    '100' => 0x4000, # 01000000, 16384
    '101' => 0x5000, # 01010000, 20480
    '110' => 0x6000, # 01100000, 24576
    '111' => 0x7000, # 01110000, 28672

    0     => 0x4000, # 01000000, 16384, 100
    1     => 0x5000, # 01010000, 20480, 101
    2     => 0x6000, # 01100000, 24576, 110
    3     => 0x7000, # 01110000, 28672, 111
);

my %queue = (
    # bit 1-0 (least significant bit shown)
    '00' => 0x00, # 00000000, 0
    '01' => 0x01, # 00000001, 1
    '10' => 0x02, # 00000010, 2
    '11' => 0x03, # 00000011, 3
);

my %polarity = (
    # bit 3
    '0'  => 0x00, # 00000000, 0
    '1'  => 0x08, # 00000001, 8
);

my %rate = (
    # bit 7-5
    '000'  => 0x00, # 00000000, 0
    '001'  => 0x20, # 00100000, 32
    '010'  => 0x40, # 01000000, 64
    '011'  => 0x60, # 01100000, 96
    '100'  => 0x80, # 10000000, 128
    '101'  => 0xA0, # 10100000, 160
    '110'  => 0xC0, # 00000001, 192
    '111'  => 0xE0, # 00000001, 224
);


my %mode = (
    # bit 8
    '0'  => 0x00,  # 0|00000000, 0
    '1'  => 0x100, # 1|00000000, 256
);

my %gain = (
    # bit 11-9 (most significant bit shown)
    '000'  => 0x00,  # 00000000, 0
    '001'  => 0x200, # 00000010, 512
    '010'  => 0x400, # 00000100, 1024
    '011'  => 0x600, # 00000110, 1536
    '100'  => 0x800, # 00001000, 2048
    '101'  => 0xA00, # 00001010, 2560
    '110'  => 0xC00, # 00001100, 3072
    '111'  => 0xE00, # 00001110, 3584
);

{ # mux

    my $o = $mod->new;
    my $d = $o->_register_data->{mux};

    print "mux...\n";

    for (keys %$d){
        is $d->{$_}, $mux{$_}, "value for $_ ok";
    }
}

{ # queue

    my $o = $mod->new;
    my $d = $o->_register_data->{queue};

    print "\nqueue...\n";

    for (keys %$d){
        is $d->{$_}, $queue{$_}, "value for $_ ok";
    }
}

{ # polarity

    my $o = $mod->new;
    my $d = $o->_register_data->{polarity};

    print "\npolarity...\n";

    for (keys %$d){
        is $d->{$_}, $polarity{$_}, "value for $_ ok";
    }
}

{ # rate

    my $o = $mod->new;
    my $d = $o->_register_data->{rate};

    print "\nrate...\n";

    for (keys %$d){
        is $d->{$_}, $rate{$_}, "value for $_ ok";
    }
}

{ # mode

    my $o = $mod->new;
    my $d = $o->_register_data->{mode};

    print "\nmode...\n";

    for (keys %$d){
        is $d->{$_}, $mode{$_}, "value for $_ ok";
    }
}

{# polarity

    my $o = $mod->new;
    my $d = $o->_register_data->{polarity};

    print "\npolarity...\n";

    for (keys %$d){
        is $d->{$_}, $polarity{$_}, "value for $_ ok";
    }
}

done_testing();
