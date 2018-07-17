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
__END__;
sub removeComments{
    my $dataString = shift;

    my @tokens = split("\",", $dataString);
    foreach my $index(0..$#tokens){
      $tokens[$index] = removeComment($tokens[$index]);
      $tokens[$index] = $tokens[$index]."\"," if($index != $#tokens);
    }

    return join("", @tokens);
}


sub removeComment{
    my $str = shift;

    my $startIndex = index($str, "\/\/");

    return $str if($startIndex == -1);

    my $prevQuoteIndex = index($str, "\"");
    my $quoteIndex = index($str, "\"", $startIndex);
    my $dataValueFound = 0 ;

    # Check for determining the value Item
    if($prevQuoteIndex != -1 && $prevQuoteIndex < $startIndex){
      return $str if($quoteIndex == -1);
      $dataValueFound = 1;
    }

    my $squareBracketIndex = index($str, "\]", $startIndex);
    my $flowerBracketIndex = index($str, "\}", $startIndex);

    my $endIndex = selectEndIndex($squareBracketIndex, $flowerBracketIndex);

    $endIndex = selectEndIndex($endIndex, $quoteIndex);
    return $str if ($endIndex == -1);

    # Identifying the value Item
    if($endIndex == $quoteIndex && $dataValueFound == 1){
      $squareBracketIndex = index($str, "\[");
      $flowerBracketIndex = index($str, "\{");

      if(($squareBracketIndex == -1 && $flowerBracketIndex == -1) || ($squareBracketIndex > $startIndex || $flowerBracketIndex > $startIndex)){
        my $dataItem = substr($str, $prevQuoteIndex, ($quoteIndex - $prevQuoteIndex),"");
        return removeComment($dataItem).removeComment($str);
      }
    }

    my $length = ($endIndex  - $startIndex);
    substr($str, $startIndex, $length, "");
    return removeComment($str);
}

sub selectEndIndex{
    my ($index1, $index2) = @_;

    my $selectedIndex = -1;

    if($index1 == -1){
       $selectedIndex = $index2;
    }elsif($index2 == -1){
       $selectedIndex = $index1;
    }elsif($index1 > $index2){
       $selectedIndex = $index2;
    }else{
       $selectedIndex = $index1;
    }

    return $selectedIndex;
}

