#!/usr/bin/perl -w
use strict;
=head1
Author: Ian Beddows
Date: 3/22/18 

Short description:	
		
		Input a directory where there are '${SAMPLE}_contamination.table' files.
		These will be found automatically and the contamination estimates writte to the output:
		
		One outfiles:
			contamination_stats.txt:
				sample	contamination	std_error
		
=cut
use Getopt::Long;

my $usage = <<EOF;
OPTIONS:
-dir
OPTIONAL:
-h|help = print usage
-b = uppercase arguments
EOF
my($help,$bold,$dir);
#======================================================================# get options
GetOptions(
	'dir=s' => \$dir,	# string
    #~ '=i' => \$,	# integer
	#~ '=f' => \$,	# floating point number
    #~ 'bold' => \$bold,	# flag
	'h|help' => \$help	# flag for help
);
if (defined($help)){die print "HELP:\n",$usage;}
if (!defined($dir)){die print "define -dir:\n",$usage;}
#======================================================================# done with get options
open(my $out,'>','contamination_stats.txt')||die;
# Print the header:
print $out join("\t",'sample','contamination','std_error'),"\n";

my @files = `ls -1 $dir|grep contamination.table`; chomp(@files);

print STDOUT "Found ",scalar @files," contamination.table files:\n";
foreach my $fh (@files){
	
	my $sample = $fh;
	$sample =~s/\_contamination.table//;
	# open & get info
	open(my $in,'<',"$dir/$fh") || die;
	my $contam;
	my $err;
	while(<$in>){
		chomp;
		next if 1..1;
		my @data = split('\t',$_);
		my $whole_bam = shift @data;
		$contam = shift @data;
		$err = shift @data;
		#~ print "\t\t$_\n";
		#~ print "contam: $contam\n";
		
	}
	
	print $out join("\t",$sample,$contam,$err),"\n";
	print STDOUT "\t$sample:\t$fh\n";
}

close($out);
