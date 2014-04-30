#!/usr/bin/perl

use strict;
my $ip=$ARGV[0];
my $community=$ARGV[1];


my @ifname=`snmpwalk -v 2c -c $community $ip ifName`;
my %names;
foreach my $name (@ifname) {
	$name=~/IF-MIB::ifName.(\d+) = STRING: (.*)/;
	$names{$1}=$2;
}


my @raw=`snmpwalk -v 2c -c $community $ip mib-2.17.7.1.2.2.1.2`;

foreach my $row (@raw) {
	$row=~/SNMPv2-SMI::mib-2.17.7.1.2.2.1.2.(\d+).([\d\.]*) = INTEGER: (\d+)/;
	my $port=$3;
	my $macdec=$2;
	my $vlan=$1;
	my @octets=split(/\./,$macdec);
	my $mac='';
	foreach my $oct (@octets) {
		my $hex = sprintf("%02x",$oct);
		$mac="$mac$hex";
	}
	my $portname=$names{$port};
	print "$mac;$portname;$vlan\n";
}

exit
