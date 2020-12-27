#! /usr/bin/perl -w
use strict;


my $gtf = $ARGV[0];
my $fileforward = $ARGV[1];
my $filereverse = $ARGV[2];

my %gene_strand;
my %tx_strand;
my %sense;
my %antisense;
open(IN,$gtf) or die;
while(<IN>){
        chomp;
        my @t = split /[\t\s]/;
	my $gene = $t[9];
	$gene =~s/[\";]//g;
	my $tx = $t[11];
	$tx =~s/[\";]//g;
        $gene_strand{$gene} = $t[6];
        $tx_strand{$tx} = $t[6];
	#print $gene."\t".$tx."\t".$t[6]."\n";
}
close IN;

my $filesense = $fileforward;
$filesense =~s/forward_expression/sense_expression/g;
print $filesense."\n";
my $fileantisense = $filereverse;
$fileantisense =~s/reverse_expression/antisense_expression/g;
print $fileantisense."\n";
open(OUTSENSE, ">$filesense") or die;
open(OUTANTI, ">$fileantisense") or die;
open(INF, $fileforward) or die;
while(my $line =  <INF>){
     my @t = split(/\t/, $line);
     if ($t[0]=~/^gene$/ || $t[0]=~/^transcript$/){
	print OUTSENSE $line;
	print OUTANTI $line;
     }
     elsif ((defined $gene_strand{$t[0]} && $gene_strand{$t[0]} eq "+") || (defined $tx_strand{$t[0]} && $tx_strand{$t[0]} eq "+")){
	print OUTSENSE $line;
     }elsif((defined $gene_strand{$t[0]} && $gene_strand{$t[0]} eq "-") || (defined $tx_strand{$t[0]} && $tx_strand{$t[0]} eq "-")){
	print OUTANTI $line;
     }else{
        print "ERROR: [".$t[0]."] not found \n";
     }
}
close INF;
open(INR, $filereverse) or die;
while(my $line = <INR>){
     my @t = split(/\t/, $line);
     if ((defined $gene_strand{$t[0]} && $gene_strand{$t[0]} eq "-") || (defined $tx_strand{$t[0]} && $tx_strand{$t[0]} eq "-")){
        print OUTSENSE $line;
     }elsif((defined $gene_strand{$t[0]} && $gene_strand{$t[0]} eq "+") || (defined $tx_strand{$t[0]} && $tx_strand{$t[0]} eq "+")){
        print OUTANTI $line;
     }else{ 
        if ($t[0]!~/^gene$/ && $t[0]!~/^transcript$/){
            print "ERROR: ".$t[0]." not found \n";
	}
     }
}
close INR;
close OUTSENSE;
close OUTANTI;
