#!/usr/bin/perl -w
use strict;
=head1
Author: Ian Beddows
Date: 3/22/18 

Short description:	
		
		Input a directory where there are '${SAMPLE}.dedup.metrics' files.
		These will be found automatically and the dedup estimates writte to the output:
		
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
open(my $out,'>','dedup_stats.txt')||die;
# Print the header:
print $out join("\t",'sample','LIBRARY'	,'UNPAIRED_READS_EXAMINED'	,'READ_PAIRS_EXAMINED'	,'SECONDARY_OR_SUPPLEMENTARY_RDS'	,'UNMAPPED_READS'	,'UNPAIRED_READ_DUPLICATES'	,'READ_PAIR_DUPLICATES'	,'READ_PAIR_OPTICAL_DUPLICATES'	,'PERCENT_DUPLICATION'	,'ESTIMATED_LIBRARY_SIZE'),"\n";

my @files = `ls -1 $dir|grep dedup.metrics`; chomp(@files);

print STDOUT "Found ",scalar @files," dedup.metrics files:\n";
foreach my $fh (@files){
	
	my $sample = $fh;
	$sample =~s/\.dedup.metrics//;
	# open & get info
	open(my $in,'<',"$dir/$fh") || die;
	my $i=0;
	while(<$in>){
		chomp;
		if($_=~/^LIBRARY/){
			$i=1;
			#~ my @data = split('\t',$_);
			#~ foreach my $field (@data){
				#~ print STDOUT "\t\t$field\n";
			#~ }
			#~ print join("\'\t\,\'",@data),"\n"; # for header
			#~ print join("\,\$",@data),"\n"; # for print out
			next;
		}elsif($i==1){
			my @data = split('\t',$_);
			my $LIBRARY = shift @data;
			my $UNPAIRED_READS_EXAMINED = shift @data;
			my $READ_PAIRS_EXAMINED = shift @data;
			my $SECONDARY_OR_SUPPLEMENTARY_RDS = shift @data;
			my $UNMAPPED_READS = shift @data;
			my $UNPAIRED_READ_DUPLICATES = shift @data;
			my $READ_PAIR_DUPLICATES = shift @data;
			my $READ_PAIR_OPTICAL_DUPLICATES = shift @data;
			my $PERCENT_DUPLICATION = shift @data;
			my $ESTIMATED_LIBRARY_SIZE = shift @data;
			#~ print STDOUT "\t\t$PERCENT_DUPLICATION\n";
			print $out join("\t",$sample,$LIBRARY,$UNPAIRED_READS_EXAMINED,$READ_PAIRS_EXAMINED,$SECONDARY_OR_SUPPLEMENTARY_RDS,$UNMAPPED_READS,$UNPAIRED_READ_DUPLICATES,$READ_PAIR_DUPLICATES,$READ_PAIR_OPTICAL_DUPLICATES,$PERCENT_DUPLICATION,$ESTIMATED_LIBRARY_SIZE),"\n";
			$i=0
		}else{
			next;
		}
	}
	
	
	print STDOUT "\t$sample:\t$fh\n";
}

close($out);
