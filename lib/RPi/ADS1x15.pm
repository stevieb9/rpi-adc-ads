package RPi::ADS1x15;

use strict;
use warnings;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('RPi::ADS1x15', $VERSION);

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(fetch);

1;

__END__

=head1 NAME

RPi::ADS1x15 - Interface to ADS1x15 series analog to digital converters (ADC) on
Raspberry Pi

=head1 SYNOPSIS

  use RPi::ADS1x15 qw(fetch);

  my $adc_addr = 0x48;
  my $i2c_dev  = "/dev/i2c-1";

  my $volts = fetch($adc_addr, $i2c_dev)

=head1 DESCRIPTION

Perl interface to the Adafruit ADS 1x15 series Analog to Digital Converters
(ADC) on the Raspberry Pi.

=head2 EXPORT

None by default.

=head2 EXPORT_OK

Exports C<fetch()> on demand.

=head1 FUNCTIONS

=head2 fetch

Returns a float that represents the analog voltage level.

Parameters:

=head3 $adc_addr

Mandatory. The hex location of the ADC. By default, C<0x48>.

=head3 $i2c_dev

Mandatory. The filesystem path to the i2c device file. Typically C</dev/i2c-1>.

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
