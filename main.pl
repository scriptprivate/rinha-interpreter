use strict;
use warnings;
use lib '/app/';
use Interpreter;

my $filepath = "/app/var/rinha/source.rinha.json";
# my $filepath = $ARGV[0] if @ARGV > 0;

Interpreter::process_file($filepath);
