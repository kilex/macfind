#!/usr/bin/perl

use strict;
my $ip=$ARGV[0];
my $community=$ARGV[1];

# Получаем имена интерфейсов
my @ifname=`snmpwalk -v 2c -c $community $ip ifName`;
my %names;
foreach my $name (@ifname) {
    $name=~/IF-MIB::ifName.(\d+) = STRING: (.*)/;
    $names{$1}=$2;
}

# Получаем все комьюнити (виланы)
my $getcommunites="snmpwalk -v 2c -c $community $ip SNMPv2-SMI::mib-2.47.1.2.1.1.4";
my @rawcoms=`$getcommunites`;
my @vlans;
foreach my $string (@rawcoms) {
		$string=~/SNMPv2-SMI::mib-2.47.1.2.1.1.4.\d+ = STRING: "(.*)"/;
		push @vlans,$1;
}

foreach my $vlan (@vlans){
	# Получаем ифиндексы портов задействованных в этом вилане
	my $cmdif="snmpwalk -v 2c -c $vlan $ip SNMPv2-SMI::mib-2.17.1.4.1.2";
	my @rawif=`$cmdif`;
	my %ifindex;
	foreach my $row (@rawif) {
		$row=~/SNMPv2-SMI::mib-2.17.1.4.1.2.(\d+) = INTEGER: (\d+)/;
		$ifindex{$1}=$2;
	}
	# Запрашиваем мак таблицы
	my $cmd="snmpwalk -v 2c -c $vlan $ip mib-2.17.4.3.1.2";
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
		if ($mac && $portname) {print "$mac;$portname;$vlanid\n";}
	}
	}
}
exit
