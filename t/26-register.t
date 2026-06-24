use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

# HW-free coverage of the config-register bit machinery (register/_bit_set/bits)
# - pure Perl, no I2C. new() only sets defaults + the config register; the
# device isn't opened until a read (volts/raw/percent), so this needs no Pi.

my $o = $mod->new;

# --- register(): argument validation ---

eval { $o->register(0) };
like $@, qr/requires \$msb and \$lsb/, "register() with only msb dies";

eval { $o->register(300, 0) };
like $@, qr/msb param requires an int 0\.\.255/, "register() msb > 255 dies";

eval { $o->register(-1, 0) };
like $@, qr/msb param requires an int 0\.\.255/, "register() msb < 0 dies";

eval { $o->register(0, 300) };
like $@, qr/lsb param requires an int 0\.\.255/, "register() lsb > 255 dies";

eval { $o->register(0, -1) };
like $@, qr/lsb param requires an int 0\.\.255/, "register() lsb < 0 dies";

# --- register() set -> bits round-trip ---

{
    my @r = $o->register(0xFF, 0xFF);
    is_deeply \@r, [0xFF, 0xFF], "register() returns the [msb, lsb] pair it set";
    is $o->bits, 0xFFFF, "bits() merges to 0xFFFF";
}

$o->register(0x12, 0x34);
is $o->bits, 0x1234, "bits() = (msb << 8) | lsb";

$o->register(0x80, 0x00);
is $o->bits, 0x8000, "bits() high-byte-only merge ok";

# --- _bit_set(): clear the field's max bits, set the value, preserve the rest ---

$o->register(0xFF, 0xFF);          # bits = 0xFFFF
$o->_bit_set(0x0200, 0x0E00);      # gain field (max 0xE00): set 0x200
is $o->bits, 0xF3FF,
    "_bit_set clears the 0xE00 field then sets 0x200, preserving other bits";

$o->register(0xFF, 0xFF);
$o->_bit_set(0x0000, 0x0E00);      # clear the whole field, set nothing
is $o->bits, 0xF1FF, "_bit_set with value 0 clears the field entirely";

done_testing();
