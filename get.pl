#!/usr/bin/perl

use strict;
use DBI;

my $basedir='/opt/macfind/';

my $dbh = DBI->connect("DBI:mysql:mactable:127.0.0.1:3306",'root','colorbar');

my $sth = $dbh->prepare("SELECT ip,name,community,type FROM switches;");
$sth->execute();
my %masscount;

while (my @row = $sth->fetchrow_array) {
	my $ip=$row[0];
	my $name=$row[1];
	my $community=$row[2];
	my $type='unknown'; #$row[3];
	my $run;
	my $snmptype=`snmpwalk -v 2c -c $community $ip sysDescr`;
	#print $snmptype."\n";

	if ( $snmptype =~ /C2960/ ) {
		$type="CISCO 2960";
		$run='./find_cisco.pl';
	}
	elsif ( $snmptype =~ /C2950/ ) {
		$type="CISCO 2950";
		$run='./find_cisco.pl';
	}
	elsif ( $snmptype =~ /C2970/ ) {
		$type="CISCO 2970";
		$run='./find_cisco.pl';
	}
	elsif ( $snmptype =~ /2900/ ) {
		$type="CISCO 2900";
		$run="./find_cisco_old.pl";
	}
	elsif ( $snmptype =~ /C3750/ ) {
		$type="CISCO 3750";
		$run="./find_cisco.pl";
	}
	elsif ($snmptype=~/DES-1210|DGS-1210/) {
		$type="DLINK 1210";
		$run="./find_dlink.pl";
	}
	elsif ($snmptype=~/DES-2108/) {
		$type="DLINK DES2108";
		$run="./find_dlink_2108.pl";
	}
	else {
		print "not supported type - $type ($ip)\n";
		print $snmptype."\n";
	}
	if ($run) {
		print "$ip ($name) - $type ...\n";
		my @result=`$basedir$run $ip $community`;
		my %count;
		foreach my $resrow (@result) {
			$resrow=~s/\n//g;
			my ($mac,$port,$vlan)=split(";",$resrow);
			$count{$vlan}++;
			$masscount{$vlan}++;
			&mactobase($mac,$ip,$port,$vlan);
		}
		print "vlan\tmacs_count\n";
		foreach my $countvl(sort { $count{$b} <=> $count{$a} } keys %count){
			print $countvl."\t".$count{$countvl}."\n";
		}
	}
}
	
	print "\n\nRESULT:\n";
	print "vlan\tmacs_count\n";
	foreach my $masscountvl(sort { $masscount{$b} <=> $masscount{$a} } keys %masscount){
		print $masscountvl."\t".$masscount{$masscountvl}."\n";
	}

sub mactobase () {
	my $mac			= shift;
	my $ipswitch	= shift;
	my $port		= shift;
	my $vlan		= shift;
	#print "$mac - $ipswitch / $port $vlan\n";
	if ($mac && $ipswitch && $port && $vlan) {
		my $query="INSERT INTO mactable SET 
						mac='$mac',
						dt=now(),
						switchip='$ipswitch',
						switchport='$port',
						vlan=$vlan
						ON DUPLICATE KEY UPDATE dt=now();
						;";
		#print $query;
		$dbh->do($query);
	}
	else {
		print "ERROR!\n";
	}


}
