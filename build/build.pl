#!/usr/bin/perl -T

use strict;
use warnings;

# Validating the command line argument
if(!defined $ARGV[0] || $ARGV[0] =~ /^$/){
    print "Usage :\n";
    print " " x 10,"$0 <Absolute config file path>\n";
    exit(1);
}

# Untainting the input data
my ($configFile) = ($ARGV[0] =~ /^(.*)$/);

# Validating the untainted input data
if(!defined $configFile || ! -f $configFile){
    print "Failed to open the config file[$configFile], No such file exists\n";
    exit(1);
}

require Config::IniFiles;
