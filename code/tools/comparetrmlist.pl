#!/usr/bin/perl
#
use strict;

# The hashtable indexing the files by their hash
my %trmhash;
my $strdelimiter = "######################################################\n";

die "Syntax: $0 file_with_trm" if(!defined($ARGV[0]) || !-r $ARGV[0]);

my $trmfile =$ARGV[0];

open(TRM_FILE, $trmfile) or die "Unable to open : $trmfile !:$!\n";

while(my $line=<TRM_FILE>) {

	if($line =~ /^([\da-f\-]+) (.+)$/) {

		if(!exists($trmhash{$1})) {
			my @t=($2);
			$trmhash{$1}=\@t;
		}
		else {
			my $ref = $trmhash{$1};
#		push($trmhash{$1},$2);
			push(@$ref,$2);
#		$trmhash{$1}=\@t;
		}
#	print "Ajout: $1 -> $2\n";

	}
	else {
		warn "Unable to parse the following line:\n$line";
	}

}

close(TRM_FILE) or die "Unable to close $trmfile: $!\n";
#display();

my $keyssize = scalar(keys(%trmhash));
my $currentindex=0;

foreach my $ref (values(%trmhash)) {

	$currentindex++;
	next if(@$ref==1);

#	print "$ref\n";
	removedup($currentindex,$keyssize,@$ref);

}



sub display {
	foreach my $k (keys(%trmhash)) {

		print "$k -> ";
		my $ref = $trmhash{$k};
		foreach my $i (@$ref) {
			print "$i ";
		}
		print "\n";
	}
}

sub removedup {
	my ($currentindex,$keyssize,@ref)=@_;
	my @keptfiles;
	my $outputstring="";

	for(my $i=0; $i<=$#ref; $i++) {
		while(!-f $ref[$i]) {

#		warn "The file $ref[$i] does not exist anymore !";
			if($#ref==1) {
				#	print "No more duplicates, switching to the next file\n";
#			print $strdelimiter;
				return;
			}

			last if($i==$#ref);

			for(my $j=$i; $j<$#ref; $j++) {
				$ref[$j]=$ref[$j+1];
			}
			pop(@ref);
		}
		my $size = -s $ref[$i];
		if($size>1000) {
			$size= int($size/ 1000);
			$size = "$size K";
		}
		my $k=$i+1;
		#print "[$k] $size : $ref[$i]\n";
		$outputstring.="[$k] $size : $ref[$i]\n";
	}

	#print the info only if required (a real choice is needed
	print $strdelimiter;
	print "$currentindex/$keyssize\n";
	print $outputstring;

	my $validsyntax;
	do {
		$validsyntax=1;
		my $userinput = <STDIN>;
		chop($userinput);

		if($userinput eq "*" || $userinput eq "all" || $userinput eq "") {
			@keptfiles=(0..$#ref);

		}
		else {
			@keptfiles=split(/ /,$userinput);
			foreach my $number (@keptfiles) {
				if($number!~ /\d+/ || $number>$#ref+1 || $number==0) {
					$validsyntax=0;	
					last;
				}
				$number--;
			}
		}

	} while($validsyntax!=1);

	print "Keeping the following file(s): \n";
	for (my $i=0; $i<=$#ref; $i++) {

		my $keep=0;

		foreach my $kept (@keptfiles) {
			if($kept == $i) {
				$keep=1;
				last;
			}
		}

		if($keep==1) {
			print "[+]";
		}
		else {
			print "[-]";
			unlink($ref[$i]);

		}

		print " $ref[$i]\n";

	}

	print $strdelimiter;

}
