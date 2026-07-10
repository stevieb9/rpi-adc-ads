use warnings;
use strict;

use RPi::ADC::ADS;
use Test::More;

# Hardware-free verification of the ADS scaling math (ADS.xs). These exercise
# the pure _pga_fsr / _scale_volts / _scale_percent helpers that voltage_c and
# percent_c now route through, feeding a KNOWN raw conversion value instead of
# reading the chip - so the PGA full-scale table and the FSR/resolution scaling
# are covered without any hardware. The live path is t/40-volts.t etc.

# --- _pga_fsr: the full PGA full-scale table (config MSB; gain bits are
# (byte >> 1) & 0x07, so a byte of (pga << 1) isolates the gain field) ---

my %fsr = (
    0 => 6.144,
    1 => 4.096,
    2 => 2.048,
    3 => 1.024,
    4 => 0.512,
    5 => 0.256,
    6 => 0.256,
    7 => 0.256,
);

for my $pga (sort keys %fsr) {
    my $wbuf1 = sprintf '0x%02X', $pga << 1;
    near(RPi::ADC::ADS::_pga_fsr($wbuf1), $fsr{$pga}, "_pga_fsr pga=$pga ($wbuf1)");
}

# --- _scale_volts: conversion * FSR / full-scale (2048 at 12-bit, 32767 at
# 16-bit). gain 1 (byte 0x02) -> FSR 4.096 ---

my $g1 = '0x02';

near(RPi::ADC::ADS::_scale_volts(825, $g1, 12),    1.65,  'volts 825 @ g1/12-bit (POD worked example)');
near(RPi::ADC::ADS::_scale_volts(2048, $g1, 12),   4.096, 'volts full-scale 12-bit');
near(RPi::ADC::ADS::_scale_volts(1024, $g1, 12),   2.048, 'volts half-scale 12-bit');
near(RPi::ADC::ADS::_scale_volts(0, $g1, 12),      0,     'volts zero');
near(RPi::ADC::ADS::_scale_volts(-100, $g1, 12),   -0.2,  'volts negative preserved');
near(RPi::ADC::ADS::_scale_volts(32767, $g1, 16),  4.096, 'volts full-scale 16-bit');
near(RPi::ADC::ADS::_scale_volts(2048, '0x00', 12), 6.144, 'volts scales by FSR (gain 0)');

# --- _scale_percent: volts / 3.3V GPIO reference * 100 (raw math, uncapped;
# the Perl percent() method is what clamps at 100) ---

near(RPi::ADC::ADS::_scale_percent(825, $g1, 12),  50.0,    'percent 825 @ g1/12-bit = 50%');
near(RPi::ADC::ADS::_scale_percent(0, $g1, 12),    0,       'percent zero');
near(RPi::ADC::ADS::_scale_percent(2048, $g1, 12), 124.121, 'percent full-scale (uncapped)');

done_testing;

# Float compare within a small tolerance (the XS returns a 32-bit float)
sub near {
    my ($got, $want, $name) = @_;
    ok(abs($got - $want) < 1e-3, "$name (got $got, want $want)");
}
