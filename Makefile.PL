use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'dudl-www',
    'VERSION'		=> '0.0.1',
    'PREREQ_PM'		=> {
	# update debian/control, too!
    	'Dudl::DB'		=> 0,
	}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => 'CGI frontend for dudl database',
       AUTHOR     => 'Rainer Clasen <bj@zuto.de>') : ()),
);
