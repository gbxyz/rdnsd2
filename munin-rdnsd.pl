#!/usr/bin/perl
# $Id: munin-rdnsd.pl,v 1.16 2013/04/17 20:12:39 gavin Exp $
use Net::DNS;
use strict;

my (undef, $mode, $domain, $proto) = split(/_/, $0, 4);

my $pidfile;
my $statsfile;

if ($proto eq 'tcp') {
	$pidfile   = '/var/run/rdnsd_tcp.pid';
	$statsfile = '/var/run/rdnsd_tcp.log';

} else {
	$pidfile   = '/var/run/rdnsd.pid';
	$statsfile = '/var/run/rdnsd.log';

}

my @servers;

my $resolver = Net::DNS::Resolver->new;

my $answer = $resolver->query('_dns._udp.'.$domain, 'SRV');
if (!$answer) {
	die("No answer for '$domain'");

} else {
	foreach my $rr (grep {$_->type eq 'SRV'} $answer->answer) {
		push(@servers, $rr->target);
	}

}

die("unhandled mode '$mode'") if ($mode ne 'rate' && $mode ne 'time');

if ($ARGV[0] eq 'config') {
	print "graph_category DNS\n";

	if ($mode eq 'time') {
		printf("graph_title %s query response time %s\ngraph_vlabel Milliseconds\n", uc($domain), ($proto eq 'tcp' ? '(TCP)' : ''));

	} elsif ($mode eq 'rate') {
		printf("graph_title %s query response rate %s\ngraph_vlabel Response rate\ngraph_args --upper-limit 1 -l 0\n", uc($domain), ($proto eq 'tcp' ? '(TCP)' : ''));

	}

	foreach my $server (@servers) {
		my $name = $server;
		$name =~ s/\./_/g;
		$name =~ s/\-/_/g;
		printf("%s.label %s\n", $name, $server);
	}

	exit;
}

# don't signal the daemon if the stats file is less than 60s old:
# otherwise the quality of the statistics will be poor
if (time() - (stat($statsfile))[9] > 60) {
	die("Error opening '$pidfile': $!") if (!open(PIDFILE, $pidfile));
	chomp(my $pid = <PIDFILE>);
	close(PIDFILE);

	die("No processes signalled") if (kill('USR1', $pid) < 1);

	sleep(1);
}

die("Error opening '$statsfile': $!") if (!open(FILE, $statsfile));

while (<FILE>) {
	chomp;
	my ($server, $rate, $time) = split(/ /, $_);
	next if (scalar(grep { $server eq $_ } @servers) < 1);

	my $name = $server;
	$name =~ s/\./_/g;
	$name =~ s/\-/_/g;
	printf("%s.value %s\n", $name, ($mode eq 'time' ? $time : $rate));
}

close(FILE);

exit;
