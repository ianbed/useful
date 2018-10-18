#!/usr/bin/perl -w
use strict;
=head1
Author: Ian Beddows
Date: 8/29/18 

Short description:	

	no seed mismatches, otherwise 1 mismatch for extension

		
=cut
use Getopt::Long;

my $usage = <<EOF;
OPTIONS:
-outfile = 
OPTIONAL:
-h|help = print usage
-b = uppercase arguments
EOF
my($help,$bold,$outfile);
#======================================================================# get options
GetOptions(
	'outfile=s' => \$outfile,	# string
    #~ '=i' => \$,	# integer
	#~ '=f' => \$,	# floating point number
    #~ 'bold' => \$bold,	# flag
	'h|help' => \$help	# flag for help
);
if (defined($help)){die print "HELP:\n",$usage;}
if (!defined($outfile)){die print "define -outfile:\n",$usage;}
#======================================================================# done with get options
open(my $out,'>',$outfile)||die;
my %data=();
my $frag_number=0;
my $seed=10;
my $polyT='TTTTTTTTTT';
while(<>){
	chomp;
	$frag_number++;
	my($frag1,$frag2)=split('\s+',$_);

	
	if(substr($frag2,-$seed) eq $polyT){
		#~ print STDOUT "\tFRAG: $frag\n";
		#~ print STDOUT "Found a polyT in read $read - frag 2\n";
		#~ print "\tFRAG1 $frag1 - ",length($frag1),"\n";
		#~ print "\tFRAG2 $frag2 - ",length($frag2),"\n";
		my $polyT_frag2_length = extend($frag2,'T');
		my $polyA_frag1_length;
		my $polyA_length;
		#~ print STDOUT "\tpolyT length $polyT_frag2_length\n";
		
		if($polyT_frag2_length == length($frag2)){
			# then quantify frag1
			$polyA_frag1_length = extend($frag1,'A');
			#~ print "\tpolyA length $polyA_frag1_length\n";
			$polyA_length = $polyT_frag2_length + $polyA_frag1_length;
		}else{
			$polyA_length = $polyT_frag2_length;
		}
		$data{$polyA_length}++;
	}
	
	if($frag_number % 100000 == 0){
		print STDOUT "\t\tfragment $frag_number\n";
	}
}

# print the output:
print $out "polyA_length\tfreq\n";
#~ foreach my $polyA_length (sort {$a<=>$b} keys %data){
for(my $polyA_length=0;$polyA_length<=202;$polyA_length++){ #
	if(exists $data{$polyA_length}){
		print $out "$polyA_length\t$data{$polyA_length}\n";
	}else{
		print $out "$polyA_length\t0\n";
	}
}
close($out);
#=======================================================================
#( Subroutines                  )
# ------------------------------------ 
#  o
#   o   \_\_    _/_/
#    o      \__/
#           (oo)\_______
#           (__)\       )\/\
#               ||----w |
#               ||     ||


sub extend {
	my $frag = shift @_;
	my $toMatch = shift @_;
	my $mismatch=0;
	
	my $i;
	for($i=length($frag)-1; $i>=0; $i--){
		#print STDOUT "\t\t$i -> ",substr($frag,$i,1),"\n";
		if(substr($frag,$i,1) eq $toMatch){
			$mismatch=0;
		}elsif($mismatch){
			last;
		}else{
			$mismatch++;
		}
	}
	
	my $c = length($frag)-1-$i-$mismatch;
	return($c);
}
