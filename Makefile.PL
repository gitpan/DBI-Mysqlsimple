use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'DBI::Mysqlsimple',
    AUTHOR              => 'Jeff Pang <pangj@earthlink.net>',
    VERSION_FROM        => 'lib/DBI/Mysqlsimple.pm',
    ABSTRACT_FROM       => 'lib/DBI/Mysqlsimple.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'DBI-Mysqlsimple-*' },
);
