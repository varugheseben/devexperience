#!/usr/bin/perl -T

use strict;
use warnings;

use Data::Dumper;
use JSON;

if(!defined $ARGV[0] && $ARGV[0] =~ /^$/){
   print "Invalid input file passed\n";
   exit(1);
}

$ARGV[0] =~ /^(.*)$/;
my $inputFile = $1;

if(!defined $inputFile || !-f $inputFile){
     print "Failed to open the input file [$inputFile]\n";
     exit(1);
}

my $FH;
if(!open($FH, "$inputFile")){
   print "Failed to open input file[$inputFile], Error[$!]\n";
   exit(1);
}

# Enabling the slurp mode
$/=undef;


my $dataJson =  <$FH>;
close $FH;

eval{
   my $jsonObj      = JSON->new();
   my $jsonVariable = $jsonObj->decode($dataJson);
   print "-----------Perl Validation using JSON Module----------\n";
   print Dumper($jsonVariable),"\n";
   print "------------------------------------------------------\n\n";
   print "----------Correcting using JSON Module--------------\n";
   my $correctedJson = $jsonObj->encode($jsonVariable);
   print "$correctedJson\n";
   print "------------------------------------------------------\n\n";
};

if($@){
  chomp $@;
  print "Parsing Error\n"," " x 10,"$@\n";
  exit(1);
}

exit(0);
