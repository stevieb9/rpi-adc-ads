package RPi::ADC::ADS;

use strict;
use warnings;

our $VERSION = '0.03';

require XSLoader;
XSLoader::load('RPi::ADC::ADS', $VERSION);

my %mux = (
    # channels
    A0 => '100',
    A1 => '101',
    A2 => '110',
    A3 => '111',
    a0 => '100',
    a1 => '101',
    a2 => '110',
    a3 => '111',
);

sub new {
    my ($class, %args) = @_;
    # addr (done)
    # dev (done)
    # channel (done)
    # mode
    # rate 
    # polarity

    my $self = bless {}, $class;

    $self->_register_default;

    $self->addr($args{addr});
    $self->device($args{device});
    $self->channel($args{channel});

    return $self;
}
sub addr {
    my ($self, $addr) = @_;
    $self->{adc_addr} = $addr if defined $addr;
    return defined $self->{adc_addr} ? $self->{adc_addr} : 0x48;
}
sub channel {
    my ($self, $chan) = @_;

    $chan = defined $chan ? $chan : 'A0';

    if (defined $chan){
        my $bin = uc $mux{$chan};
        my $reg = $self->register;
        
        substr $reg, 1, 3, $bin;
        $self->register($reg);
    }

}
sub device {
    my ($self, $dev) = @_;
    $self->{device} = $dev if defined $dev;
    return defined $self->{device} ? $self->{device} : '/dev/i2c-1'; 
}
sub register {
    my ($self, $bin) = @_;
    if (defined $bin){
        $self->{register_data} = $bin;
    }
    return $self->{register_data};
}
sub _bytes {
    my ($self, $binstr) = @_;

    my @bytes;

    if (defined $binstr){
        @bytes = ($binstr =~ m/.{8}/g);
    }
    else {
        my $reg = $self->register;
        @bytes = ($reg =~ m/.{8}/g);
    }

    my @hex;
    
    for (@bytes){
        push @hex, sprintf("%#x", oct("0b$_"));
    }

    return @hex;
}
sub _register_default {
    my $self = shift;
    my $bit_9_15 = '11000011'; # 0xC3
    my $bit_7_0  = '00000011'; # 0x03
    $self->register($bit_9_15 . $bit_7_0);
}

# device methods

sub read {
    my ($self, $channel) = @_;

    if (defined $channel){
        $self->channel($channel);
    }

    my $addr = $self->addr;
    my $dev = $self->device;
    my @write_buf = $self->_bytes;

    return fetch($addr, $dev, $write_buf[1], $write_buf[0]);
}
sub _vim {}

1;

__END__

=head1 NAME

RPi::ADC::ADS - Interface to ADS 1xxx series analog to digital converters (ADC)
on Raspberry Pi

=head1 SYNOPSIS

    use RPi::ADC::ADS;

    my $adc = RPi::ADC::ADS->new;

    my $level = $apc->read;

=head1 DESCRIPTION

Perl interface to the Adafruit ADS 1xxx series Analog to Digital Converters
(ADC) on the Raspberry Pi.

Provides access via the i2c bus to all four input channels on each ADC.

=head1 PHYSICAL SETUP

List of pinouts between the ADC and the Raspberry Pi.

    ADC     Pi
    -----------
    VDD     Vcc
    GND     Gnd
    SCL     SCL (NOT SCLK)
    SDA     SDA
    ADDR    Gnd
    ALRT    NC  (no connect)

Pinouts C<A0> through C<A3> on the ADC are the analog pins used to connect to
external peripherals.

=head1 METHODS

=head2 new

Parameters:

=head3 addr

Optional. The hex location of the ADC. If the pinout in L</PHYSICAL SETUP> is
used, this will be C<0x48> (which is the default if not supplied).

=head3 device

Optional. The filesystem path to the i2c device file. Defaults to C</dev/i2c-1>

=head3 channel

Optional. One of C<A0> through C<A3> which specifies which channel to read. If
not sent in, we default to C<A0> throughout the object's lifecycle.

=head2 read($channel)

Fetches the data from the ADC as the specified input channel.

Parameters:

=head3 $channel

Optional: String, C<A0> through C<A3>, representing the ADC input channel to
read from. Setting this parameter allows you to read all four channels without
changing the default set in the object.

Return: A floating point number between C<0> and the maximum voltage output by
the Pi's GPIO pins.

=head2 addr($hex)

Sets/gets the ADC memory address. After object instantiation, this method
should only be used to get (ie. don't send in any parameters.

Parameters:

=head3 $hex 

Optional: A memory address in the form C<0xNN>.

=head2 channel($mux)

Sets/gets the currently registered ADC input channel within the object.

Parameters:

=head3 $mux

Optional: String, C<A0> through C<A3>, representing the ADC's multiplexer
input channel to read from.

=head2 register($binary)

Sets/gets the ADC's registers. This has been left public for convenience for
those who understand the hardware very well. It really shouldn't be used
otherwise.

Parameters:

=head3 $binary

Optional: A binary string (literal 1s and 0s), 32 bits long.

=head1 TECHNICAL DATA

=head2 REGISTERS

The write buffer consists of an array with three elements. Element C<0>
selects the register to use. C<0> for the conversion register and C<1> for the
configuration register.

Element C<1> is a byte long, and represents bits 15-8 of a register, while
element C<2> represents bits 7-0.

=head2 CONFIG REGISTER

Bit 15 should always be set to C<1> when writing. This initiates a conversation
ADC. When reading, this bit will read C<1> if a conversion is currently
occuring, and C<0> if the current conversion is complete.

Bits 14-12 represent the ADC input channel, as well as either a single-ended
(difference between HIGH and GRD) or differential mode (difference between
two input channels). Only single-ended is currently supported.

Below is the binary representation for the input channels (bits 14-12):

    Input   Binary

    A0      100
    A1      101
    A2      110
    A3      111

Bits 11-9 are for the programmable gain amplifier. This software uses C<001> or
4.096V to cover the Pi's 3.3V output.

    000: FS = ±6.144V(1)           100: FS = ±0.512V
    001: FS = ±4.096V(1)           101: FS = ±0.256V
    010: FS = ±2.048V (hw default) 110: FS = ±0.256V
    011: FS = ±2.024V              111: FS = ±0.256V

Bit 8 is for the conversion operation mode. We use single conversion hardware
default.

    0: continuous conversion
    1: single conversion (hw default)

Bits 9-5 represent the data rate. We use 128SPS:

    000 : 128SPS 100 : 1600SPS (hw default)
    001 : 250SPS 101 : 2400SPS
    010 : 490SPS 110 : 3300SPS
    011 : 920SPS 111 : 3300SPS

Bit 4 is unused.

Bit 3 is the comparator polarity. We use Active Low by default:

    0 - Active Low (hw default)
    1 - Active High

Bit 2 is unused.

Bits 1-0 represent the comparator queue. This software has disabled it:

    00 : Assert after one conversion
    01 : Assert after two conversions
    10 : Assert after four conversions
    11 : Disable comparator (default)

See the L<https://cdn-shop.adafruit.com/datasheets/ads1015.pdf|datasheet> for
further information.

=head1 SEE ALSO

L<WiringPi::API>, L<RPi::WiringPi>, L<RPi::DHT11>

=head1 AUTHOR

Steve Bertrand, E<lt>steveb@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Steve Bertrand

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.22.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
