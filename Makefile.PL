use ExtUtils::MakeMaker;

if ($^O =~ 'freebsd'){
    print "Can't run on $^O\n";
    exit;
}

# The I2C development-header presence check is the family-canonical check in
# RPi::Const::BuildCheck (pulled in via CONFIGURE_REQUIRES below). It honours
# RPI_DIST_RELEASE and exits 0 with a message before WriteMakefile when the
# headers are missing, so CPAN testers report NA, not FAIL.
eval {
    require RPi::Const::BuildCheck;
    RPi::Const::BuildCheck::i2c_build_check();
    1;
} or do {
    # No RPi::Const::BuildCheck (a bare `perl Makefile.PL` with no CPAN client
    # to honour CONFIGURE_REQUIRES). Stay NA-safe: exit 0 unless releasing.
    print "RPi::Const (the build-check dependency) is not installed; install " .
          "it first, or set RPI_DIST_RELEASE to skip the i2c check.\n";
    exit 0 if ! $ENV{RPI_DIST_RELEASE};
};

WriteMakefile(
    NAME              => 'RPi::ADC::ADS',
    VERSION_FROM      => 'lib/RPi/ADC/ADS.pm',
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/RPi/ADC/ADS.pm',
       AUTHOR         => 'Steve Bertrand <steveb@cpan.org>') : ()),
    LIBS              => [],
    DEFINE            => '',
    INC               => '-I.',
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            bugtracker => {
                web => 'https://github.com/stevieb9/rpi-adc-ads/issues',
            },
            repository => {
                type => 'git',
                url => 'https://github.com/stevieb9/rpi-adc-ads.git',
                web => 'https://github.com/stevieb9/rpi-adc-ads',
            },
        },
    },
    LICENSE => 'perl_5',
    CONFIGURE_REQUIRES => {
        'RPi::Const' => '1.07',
    },
    PREREQ_PM         => {
    },
#    CCFLAGS => => '-Wno-unused-result',
);
