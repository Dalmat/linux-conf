#!/usr/bin/perl -w

use warnings;
use strict;
use Cwd;
use File::Find;
use File::Path;
use Term::ANSIColor;

die "Please install the sam2p package\n" if!(-x "/usr/bin/sam2p");
die "Please install the pdftk package\n" if!(-x "/usr/bin/pdftk");
die "Please install the imagemagick package\n" if!(-x "/usr/bin/convert");

my $defaultGlobFiles='*.jpg *.JPG *.gif *.GIF';

my $globalwarn=0;
my $verbose=0;
my $dirtokeep=0;
my @dirstoremove;
my $tabchar="\t";

my @input;
my $outputfile;
my $recursive=0;
my $removeOnSuccess=0;

while (defined(my $arg=shift(@ARGV))) {

	if($arg=~ /^-r$/i) {
		$recursive=1;
	}
	elsif($arg=~ /^-o$/i or $arg=~ /^--name$/i) {
		$outputfile=shift(@ARGV);
	}
	elsif($arg=~ /^-f$/i) {
		$removeOnSuccess=1;
	}
	elsif($arg=~ /-h/i or $arg=~ /--help/i) {
		print "Usage:\n$0 [-f] [-o outputfile] inputfile1 inputfile2 ...\n", color('blue'), "\t-f means remove the input files on successful conversion\n", color('reset'), "$0 -r\n", color('blue'),"\tRecursive mode, browse folder and convert every image of the subdirectory to one pdf\n",color('reset');
		exit 0;
	}
	# otherwise the argument is a file to convert
	else {
		push(@input, $arg);
	}

}

if($recursive == 1) {

	print "Recursive Mode ON, let's browse everything, try everything, and remove what is properly converted !\n";

	# Browse the sub dir
	#my $directory=".";
	my $directory=getcwd;
#	opendir(my $dh, $directory) || die "can't opendir $directory: $!";
#	my @subdirs = grep { -d "$directory/$_" } readdir($dh);

#	for my $dir (@subdirs) {
#		print $dir."\n";
#	}
#      	closedir $dh; 

	find(\&multidirconvert, $directory);

	foreach my $dir (@dirstoremove) {
		rmtree $dir or warn "Could not remove directory $dir: $!\n";
	}
}

else {
	$verbose=1;
	@input = glob($defaultGlobFiles) if(!exists($input[0]));
	print "=> ".getcwd."\n";
	$globalwarn=convertfiles(@input);
	if($globalwarn==0) {
		my $destfile="";
		$destfile=" to $outputfile" if(defined($outputfile) && $outputfile ne ""); 

		if($removeOnSuccess==1) {
			foreach my $file (@input) {
				unlink $file;
			}
			print color('green'),$tabchar."[Succesfully converted ", color('blue'), "and removed ", color('green'), "the ".scalar(@input)." input files$destfile]\n", color("reset");
		}
		else {
			print color('green'),$tabchar."[Succesfully converted the ".scalar(@input)." input files$destfile]\n", color("reset");
		}
	}
	else {
		print color('red'),$tabchar."[Error in the conversion of the files: ", color("blue"), join(' ',@input) , color('red'),"]\n", color("reset");
	}
}

print "Exiting with status $globalwarn (abc: a=nb directories without conversion, c=nb directories with conversion errors)\n" if($globalwarn!=0);
exit $globalwarn;

sub multidirconvert {

	# Treat only subdirectories
	return if(! -d or $_ eq '.');

	my $dir=$_;
#$dir=~ s/ /\\ /g;

	print "=> $dir\n";
	my $prevdir=getcwd;
	chdir("$dir") or die "$! $dir\n";
#my @input = glob("$dir/*.jpg $dir/*.JPG");

	my @input = glob($defaultGlobFiles);

	my $warn = convertfiles(@input);
	$globalwarn+=$warn;

	$dirtokeep=0;

# Remove directory if conversion OK and no subdir
	if($warn==0) {
		#find(sub { -d and $_ ne '.' and $dirtokeep=1 and print "rep $_\n"; }, ".");
		find(\&dircanberemoved, ".");

#supprimer le répertoire en question uniquement si warn=0 et qu'il n'y a pas de sous rep
		if($dirtokeep==0) {
			push(@dirstoremove,getcwd);
			print color('green'), $tabchar."[Successfully converted and removed]\n", color("reset");
		}
		else {
			print color('green'),$tabchar."[Successfully converted]\n",color("reset");
		}

	}
	elsif($warn!=100) {
		print color('red'),$tabchar."[Could not properly process the directory, error $warn\n]",color("reset");
	}


	chdir($prevdir);
}

# Identify if a directory can be removed after a successful conversion
sub dircanberemoved {

	return if($dirtokeep!=0);
	-d and $_ ne '.' and $dirtokeep=1;
	if(-f) {
		($_ =~  /pdf$/i || $_ !~ /jpg|gif|thumbs|\.nfo/i) and $dirtokeep=1;

	}
}

sub filesort {

	if($a=~ /^(\d+)/ && $b=~/^(\d+)/) {

		my $aa=$a; my $bb=$b; $aa=~ s/^(\d+).*/$1/; $bb=~ s/^(\d+).*/$1/;  $aa <=> $bb
	}
	else {
		$a cmp $b;
	}
}

sub convertfiles {

	my @inputfiles=@_;

	#my @sortedfiles = sort { my $aa=$a; my $bb=$b; $aa=~ s/^(\d+).*/$1/; $bb=~ s/^(\d+).*/$1/;  $aa <=> $bb } @inputfiles;
	my @sortedfiles = sort filesort @inputfiles;
	my $warn=0;
	my $pdflist="";

	# return an error if no file to be converted
	if(scalar(@inputfiles)<1) {
		$warn=100;
		warn $tabchar."No file to convert here !\n" if($verbose);
	}

	my $pdfname;
	if(defined($outputfile) && $outputfile ne "") {
		$pdfname=$outputfile;
	}
	else {
		$pdfname = cwd;
		$pdfname=~  s/.+\/(.+)+/$1.pdf/;
		$pdfname= "../".$pdfname;
		# Do not overwrite the first pdf, next ones will be output.pdf
		$pdfname="../output.pdf" if(-f $pdfname);
		# To get the final message with the output file, only in single dir mode
		$outputfile=$pdfname if($recursive==0);
	}	

	foreach my $filename (@sortedfiles) {

		if($filename=~ /(.+)\.\w+/) {
			my $outfile = $1.".pdf";

			print $tabchar."$filename => $outfile\n" if($verbose);
			my $res = `sam2p "$filename" "$outfile" 2>&1`;

			if($res =~ /sam2p: Error/) {
				$warn=-1;
				warn $tabchar."Error in sam2p conversion. Trying with imagemagick\n";
				last
			}
			elsif($res =~  /OutputRule #(\d+)/) {
				if($1 != 0) {
					unlink $outfile;
					$warn=-1;
					warn $tabchar."Non-optimal conversion from Sam2p (OutputRule $1), Using imagemagick instead\n"; #. I will censure myself and skip the other files\n";
					last;
				}
			}
			else {
				warn $tabchar."No status could be retrieved from the sam2p output for the file $filename:\n$res";
				$warn=1;
			}
			$pdflist.='"'.$outfile.'" ';

		}

		else {
			die "The file $filename should have an extension\n";
		}

	}

# Merge PDFs if everything is OK
	if($warn == 0) {
#	`pdfjoin -o "$dir" --no-landscape $pdflist`; 	
		#`pdftk $pdflist cat output "../$pdfname"`;
		(system("pdftk $pdflist cat output ".'"'."$pdfname".'"')==0) or $warn=1;
	}
	system("rm $pdflist") if(length($pdflist)>0);

	if($warn==-1) {
		my $files;
		foreach my $file (@inputfiles) {
			$files.= '"'.$file.'" '; 
		}
		my $cmd = "convert $files ".'"'."$pdfname".'"';
		$warn=0;
		(system($cmd)==0) or $warn=1;
	}

	return $warn;
}
