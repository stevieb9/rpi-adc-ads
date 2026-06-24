use strict;
use warnings;

use RPi::ADC::ADS;
use Test::More;

my $mod = 'RPi::ADC::ADS';

# HW-free coverage of _samples(): the per-call averaging validator that
# volts()/raw()/percent() use for their optional $samples argument. Pure Perl,
# no I2C.

my $o = $mod->new;

for my $bad (0, -1, 'x', '2.5') {
    eval { $o->_samples($bad) };
    like $@, qr/samples must be a positive integer/, "_samples('$bad') dies";
}

is $o->_samples(5), 5, "_samples(5) returns 5";
is $o->_samples(1), 1, "_samples(1) returns 1";

# undef falls back to the object default (samples() defaults to 1)
is $o->_samples(undef), $o->samples, "_samples(undef) falls back to the object default";
is $o->_samples(undef), 1, "...which is 1 by default";

done_testing();
