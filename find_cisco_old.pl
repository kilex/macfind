#!/usr/bin/perl

use strict;
my $ip=$ARGV[0];
my $community=$ARGV[1];

my @ifname=`snmpwalk -v 2c -c $community $ip ifName`;
my %names;
foreach my $name (@ifname) {
    #IF-MIB::ifName.52 = STRING: Slot0/52
    $name=~/IF-MIB::ifName.(\d+) = STRING: (.*)/;
    #print "$1 $2\n";
    $names{$1}=$2;
}

my %ifindex;
my @indexes=`snmpwalk -v 2c -c $community $ip SNMPv2-SMI::mib-2.17.1.4.1.2`;
foreach my $index (@indexes) {
    $index=~/SNMPv2-SMI::mib-2.17.1.4.1.2.(\d+) = INTEGER: (\d+)/;
    #print "$1 $2\n";
    $ifindex{$1}=$2;
}

#my %miniifindex;
#my @miniindexes=`snmpwalk -v 2c -c $community $ip SNMPv2-SMI::mib-2.47.1.1.1.1.14`;
#foreach my $miniindex (@miniindexes) {
#    #IF-MIB::ifName.52 = STRING: Slot0/52
#    $miniindex=~/SNMPv2-SMI::mib-2.47.1.1.1.1.14.(\d+) = STRING: "(\d+)"/;
#    #print "$1 $2\n";
#    $miniifindex{$1}=$2;
#}

#SNMPv2-SMI::mib-2.47.1.1.1.1.14.1020 = STRING: "10016"

my $getcommunites="snmpwalk -v 2c -c $community $ip SNMPv2-SMI::enterprises.9.9.46.1.3.1.1.2.1";
my @rawcoms=`$getcommunites`;
my @vlans;
foreach my $string (@rawcoms) {
		$string=~/SNMPv2-SMI::enterprises.9.9.46.1.3.1.1.2.1.(\d+) = INTEGER: \d/;
		#print $1."\n";
		push @vlans,$community.'@'.$1;
}

foreach my $vlan (@vlans){
	my $cmd="snmpwalk -v 2c -c $vlan $ip SNMPv2-SMI::mib-2.17.4.3.1.2";
	my @raw=`$cmd`;
	if (@raw) {
	foreach my $row (@raw) {
		$row=~/SNMPv2-SMI::mib-2.17.4.3.1.2.([\d\.]*) = INTEGER: (\d+)/;
		my $port=$2;
		my $macdec=$1;
		my @octets=split(/\./,$macdec);
		my $mac='';
		foreach my $oct (@octets) {
			my $hex = sprintf("%02x",$oct);
			$mac="$mac$hex";
		}
		$vlan=~/@(\d+)/;
		my $vlanid=$1;
		my $portname=$names{$ifindex{$port}};
		#print $port."\n";
		if ($mac && $mac != 'ffffffffffff' && !($mac=~/0007ebc89b/) && $portname) {print "$mac;$portname;$vlanid\n";}
	}
	}
}
exit
