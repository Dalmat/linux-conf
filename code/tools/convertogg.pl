#!/usr/bin/perl -w
use strict;

my @inputfiles = @ARGV;

@inputfiles = glob('*.wav') if(!exists $inputfiles[0]);

foreach my $filename (@inputfiles) {
	if(-f $filename && $filename=~ /^(.+)(\.\w+)/) {
		my $basefilename = $1;
		$filename=~ s/ /\\ /g;
		$basefilename=~ s/ /\\ /g;
#print "$filename et $basefilename.ogg\n";
		`/usr/bin/oggenc -q 5 $filename -o $basefilename.ogg`
	}
}
