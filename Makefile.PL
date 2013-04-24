#!/usr/bin/perl
use ExtUtils::MakeMaker;
use strict;

WriteMakefile(
	'NAME'		=> 'rdnsd',
	'VERSION_FROM'	=> 'rdnsd',
	'ABSTRACT_FROM'	=> 'rdnsd',
	'AUTHOR'	=> [ 'Gavin Brown <gavin.brown@centralnic.com>' ],
	'LICENSE'	=> 'perl',
	'EXE_FILES'	=> [ 'rdnsd' ],
	'PREREQ_PM'	=> {
		'Getopt::Long'		=> 0,
		'POSIX'			=> 0,
		'Pod::Usage'		=> 0,
		'Net::DNS'		=> 0,
		'Time::HiRes'		=> 0,
		'Config::Simple'	=> 0,
	},
);
