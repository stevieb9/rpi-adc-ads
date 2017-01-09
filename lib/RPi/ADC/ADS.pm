package RPi::ADC::ADS;

use strict;
use warnings;

our $VERSION = '0.05';

require XSLoader;
XSLoader::load('RPi::ADC::ADS', $VERSION);

# channel multiplexer binary representations

my %mux = (
    0 => '100',
    1 => '101',
    2 => '110',
    3 => '111',
);

# object methods (public)

sub new {
    my ($class, %args) = @_;
    # model (done)
    # addr (done)
    # dev (done)
    # channel (done)
    # mode
    # rate 
    # polarity

    my $self = bless {}, $class;

    $self->_register_default;

    $self->model($args{model});
    $self->addr($args{addr});
    $self->device($args{device});
    $self->channel($args{channel});

    return $self;
}
sub addr {
    my ($self, $addr) = @_;

    if (defined $addr){
        if (! grep {$addr eq $_} qw(72 73 74 75)){
            die "invalid address. " .
                "Use 0x48 (72), 0x49 (73), 0x4A (74) or 0x4B (75)\n";
        }
        $self->{addr} = $addr;
    }

    $self->{addr} = 0x48 if ! defined $self->{addr};

    return $self->{addr};
}
sub channel {
    my ($self, $chan) = @_;

    if (defined $chan){
        if ($chan !~ /\d/ || ! grep {$chan == $_} qw(0 1 2 3)){
            die "invalid channel specification: $chan. " .
                "use 0, 1, 2 or 3\n";
        }

        $self->{channel} = $chan;

        my $bin = $mux{$chan};
        my $reg = $self->register;

        substr $reg, 1, 3, $bin;
        $self->register($reg);
    }

    $self->{channel} = 0 if ! defined $self->{channel};

    return $self->{channel};
}
sub device {
    my ($self, $dev) = @_;

    if (defined $dev){
        if ($dev !~ m|/dev/i2c-\d|){
            die "invalid device name: $dev. " .
                "Must be /dev/i2c-N, where N is 0-9\n";
        }
        $self->{device} = $dev;
    }

    $self->{device} = '/dev/i2c-1' if ! defined $self->{device};

    return $self->{device};
}
sub model {
    my ($self, $model) = @_;

    if (defined $model){
        if ($model !~ /^ADS1[01]1[3458]/){
            die "invalid model name: $model. " .
                "Must be 'ADS1x1y' where x is 1 or 0, and y is 3, 4, 5 or 8\n";
        }
        $self->{model} = $model
    }

    $self->{model} = 'ADS1015' if ! defined $self->{model};

    my ($model_num) = $self->{model} =~ /(\d+)/;

    $self->_resolution($model_num);

    return $self->{model};
}
sub register {
    my ($self, $bin) = @_;
    if (defined $bin){
        $self->{register_data} = $bin;
    }
    return $self->{register_data};
}

# object methods (private)

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
sub _mux {
    # for testing purposes
    return %mux;
}
sub _register_default {
    my $self = shift;
    my $bit_8_15 = '11000011'; # 0xC3
    my $bit_7_0  = '00000011'; # 0x03
    $self->register($bit_8_15 . $bit_7_0);
}
sub _resolution {
    my ($self, $model) = @_;

    if (defined $model){
        if ($model =~ /11\d{2}/){
            $self->{resolution} = 16;
        }
        else {
            $self->{resolution} = 12;
        }
    }
    return $self->{resolution};
}

# device methods

sub volts {
    my ($self, $channel) = @_;

    if (defined $channel){
        $self->channel($channel);
    }

    my $addr = $self->addr;
    my $dev = $self->device;
    my @write_buf = $self->_bytes;

    return voltage_c(
        $addr, $dev, $write_buf[0], $write_buf[1], $self->_resolution
    );
}
sub raw {
    my ($self, $channel) = @_;

    if (defined $channel){
        $self->channel($channel);
    }

    my $addr = $self->addr;
    my $dev = $self->device;
    my @write_buf = $self->_bytes;

    return raw_c($addr, $dev, $write_buf[0], $write_buf[1], $self->_resolution);
}
sub percent {
    my ($self, $channel) = @_;

    if (defined $channel){
        $self->channel($channel);
    }

    my $addr = $self->addr;
    my $dev = $self->device;
    my @write_buf = $self->_bytes;

    my $percent = percent_c(
        $addr, $dev, $write_buf[0], $write_buf[1], $self->_resolution
    );

    return sprintf("%.2f", $percent);
}

sub _vim {}

1;

__END__

=head1 NAME

RPi::ADC::ADS - Interface to ADS 1xxx series analog to digital converters (ADC)
on Raspberry Pi

=head1 SYNOPSIS

    use RPi::ADC::ADS;

    # instantiation of the object, shown with optional parameters
    # with their defaults if you don't specify them

    my $adc = RPi::ADC::ADS->new(
        model   => 'ADS1015',
        addr    => 0x48,
        device  => '/dev/i2c-1',
        channel => 0,
    );

    my $volts   = $apc->volts;

    my $percent = $apc->percent;

    my $int     = $apc->raw;

=head1 DESCRIPTION

Perl interface to the Texas Instruments/Adafruit ADS 1xxx series Analog to
Digital Converters (ADC) on the Raspberry Pi.

Provides access via the i2c bus to all four input channels on each ADC, while
performing correct bit-shifting between the 12-bit and 16-bit resolution on
the differing models.

=head1 PHYSICAL SETUP

List of pinout connections between the ADC and the Raspberry Pi.

    ADC     Pi
    -----------
    VDD     Vcc
    GND     Gnd
    SCL     SCL
    SDA     SDA
    ADDR    Gnd (see below for more info)
    ALRT    NC  (no connect)

Pinouts C<A0> through C<A3> on the ADC are the analog pins used to connect to
external peripherals (specified in this software as C<0> through C<3>).

The C<ADDR> pin specifies the memory address of the ADC unit. Four ADCs can be
connected to the i2c bus at any one time. By default, this software uses
address C<0x48>, which is the address when the C<ADDR> pin is connected to
C<Gnd> on the Raspberry Pi. Here are the addresses for the four Pi pins:

    Pin     Address
    ---------------
    Gnd     0x48
    VDD     0x49
    SDA     0x4A
    SCL     0x4B

=head1 OBJECT METHODS

=head2 new

Instantiates a new L<RPi::ADC::ADS> object. All parameters are optional, and are
all sent in as a single hash.

Parameters:

    model => $string

Optional. The model number of the ADC. If not specified, we use C<ADS1015>.
Models that start with C<ADS11> have 16-bit accuracy resolution, and models
that start with C<ADS10> have 12-bit resolution.

    addr => $hex

Optional. The hex location of the ADC. If the pinout in L</PHYSICAL SETUP> is
used, this will be C<0x48> (which is the default if not supplied).

    device => $string

Optional. The filesystem path to the i2c device file. Defaults to C</dev/i2c-1>

    channel => $int

Optional. One of C<0> through C<A3> which specifies which channel to read. If
not sent in, we default to C<0> throughout the object's lifecycle.

=head2 addr($hex)

Sets/gets the ADC memory address. After object instantiation, this method
should only be used to get (ie. don't send in any parameters.

Parameters:

    $hex

Optional: A memory address in the form C<0xNN>. See L</PHYSICAL SETUP> for full
details.

=head2 channel($channel)

Sets/gets the currently registered ADC input channel within the object.

Parameters:

    $channel

Optional: String, C<0> through C<3>, representing the ADC's multiplexer
input channel to read from. Setting through this method overrides the value that
was set in C<new()> (C<0> by default if never specified), until it is changed
again. If you are using more than one channel, it's more useful to set the
channel in your read calls (C<volts()>, C<raw()> and C<percent()>).

=head2 device($dev)

Sets/gets the file path information for the i2c device. This shouldn't be used
as a setter after object instantiation. It defaults to C</dev/i2c-1> if not set
in the C<new()> call (or with this method thereafter).

Parameters:

    $dev

Optional: String, the full path of the i2c device in use. Defaults to
C</dev/i2c-1>.

=head2 model($model)

Sets/gets the model of the ADC chip that we're connected to. This shouldn't be
set after object instantiation. Defaults to C<ADS1015> if not set in the
C<new()> call, or later with this method.

Parameters:

    $model

Optional: String, the model name of the ADC unit. Defaults to C<ADS1015>. Valid
values are C</ADS1[01]1[3458]/>.

=head2 register($binary)

Sets/gets the ADC's registers. This has been left public for convenience for
those who understand the hardware very well. It really shouldn't be used
otherwise.

Parameters:

    $binary

Optional: A binary string (literal 1s and 0s), 32 bits long that represents the
data we'll write to the ADC device.

=head1 DATA RETRIEVAL METHODS

=head2 volts($channel)

Retrieves the voltage level of the channel.

Parameters:

    $channel

Optional: String, C<0> through C<3>, representing the ADC input channel to
read from. Setting this parameter allows you to read all four channels without
changing the default set in the object.

Return: A floating point number between C<0> and the maximum voltage output by
the Pi's GPIO pins.

=head2 percent($channel)

Retrieves the ADC channel's input value by percentage of maximum input.

Parameters: See C<$channel> in L</volts>.

=head2 raw($channel)

Retrieves the raw value of the ADC channel's input value.

Parameters: See C<$channel> in L</volts>.

=head1 C FUNCTIONS

The following C functions aren't meant to be called directly. Rather, use the
corresponding Perl object methods instead.

=head2 fetch

Fetches the raw data from the channel specified.

Implemented as:

    int
    fetch (ads_address, dev_name, wbuf1, wbuf2, resolution)
        int	ads_address
        const char * dev_name
        char * wbuf1
        char * wbuf2
        int resolution

C<wbuf1> is the most significant byte (bits 15-8)for the configuration register,
C<wbuf2> being the least significant byte (bits 7-0).

=head2 voltage_c

Fetches the ADC input and returns it as the actual voltage.

Implemented as:

    float
    voltage_c (ads_address, dev_name, wbuf1, wbuf2, resolution)
        int	ads_address
        const char * dev_name
        char * wbuf1
        char * wbuf2
        int resolution

See L</fetch> for details on the C<wbuf> arguments.

=head2 raw_c

Fetches the ADC input and returns it in its raw form.

Implemented as:

    int
    raw_c (ads_address, dev_name, wbuf1, wbuf2, resolution)
        int	ads_address
        const char * dev_name
        char * wbuf1
        char * wbuf2
        int resolution

See L</fetch> for details on the C<wbuf> arguments.

=head2 percent_c

Fetches the ADC input value as a floating point percentage between minimum and
maximum input values.

Implemented as:

    float
    percent_c (ads_address, dev_name, wbuf1, wbuf2, resolution)
        int	ads_address
        const char * dev_name
        char * wbuf1
        char * wbuf2
        int resolution

See L</fetch> for details on the C<wbuf> arguments.

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
+/-4.096V to cover the Pi's 3.3V output.

    000: FS = +/-6.144V              100: FS = +/-0.512V
    001: FS = +/-4.096V              101: FS = +/-0.256V
    010: FS = +/-2.048V (hw default) 110: FS = +/-0.256V
    011: FS = +/-2.024V              111: FS = +/-0.256V

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

=head1 READING DATA

Each channel has a conversion register (that contains the actual analog input).
This register is 16 bits wide. With that said, the most significant bit is used
to identify whether the number is positive or negative, so technically, for the
ADC1xxx series ADCs, the width is actually 15 bits, and the ADC10xx units are
11 bits wide (as the resolution on these models are only 12-bit as opposed to
16-bit).

See the L<ADC's datasheet|https://cdn-shop.adafruit.com/datasheets/ads1016.pdf>
for further information.

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
