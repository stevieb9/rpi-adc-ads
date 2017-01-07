use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'RPi::ADS1x15',
    VERSION_FROM      => 'lib/RPi/ADS1x15.pm',
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/RPi/ADS1x15.pm',
       AUTHOR         => 'Steve Bertrand <steveb@cpan.org>') : ()),
    LIBS              => [],
    DEFINE            => '',
    INC               => '-I.',
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            bugtracker => {
                web => 'https://github.com/stevieb9/rpi-ads1x15/issues',
            },
            repository => {
                type => 'git',
                url => 'https://github.com/stevieb9/rpi-ads1x15.git',
                web => 'https://github.com/stevieb9/rpi-ads1x15',
            },
        },
    },
    PREREQ_PM         => {
    },
);
