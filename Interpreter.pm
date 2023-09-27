package Interpreter;
use strict;
use warnings;
use lib '/app/';
use Kinds;
use JSON;

our @EXPORT = qw(
    process_file
);

my %cache;
my $max_cache_size = 1_000_000;

sub cache {
    my ($fn) = @_;
    return sub {
        my ($key) = join(",", @_);
        if (exists $cache{$key}) {
            return $cache{$key};
        }
        my $result = $fn->(@_);
        if (scalar(keys %cache) < $max_cache_size) {
            $cache{$key} = $result;
        } else {
            delete $cache{(keys %cache)[0]};
        }
        return $result;
    };
}

sub identify_type {
    my ($node) = @_;
    my $location = Loc(%{ $node->{location} });

    if (defined $node->{kind} && $node->{kind} eq "File") {
        return File($node->{name}, identify_type($node->{expression}), $location);
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Let") {
        return Let("Let", $location, identify_type($node->{name}), identify_type($node->{value}), identify_type($node->{next}));
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Function") {
        return Function("Function", $location, [map { identify_type($_) } @{ $node->{parameters} }], identify_type($node->{value}));
    }
    elsif (defined $node->{kind} && $node->{kind} eq "If") {
        return If("If", $location, identify_type($node->{condition}), identify_type($node->{then}), identify_type($node->{otherwise}));
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Call") {
        return Call("Call", $location, $node->{callee}->{text}, [map { identify_type($_) } @{ $node->{arguments} }]);
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Var") {
        return Var("Var", $location, $node->{text});
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Binary") {
        return Binary("Binary", $location, identify_type($node->{lhs}), $node->{op}, identify_type($node->{rhs}));
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Int") {
        return Int("Int", $location, $node->{value});
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Str") {
        return Str("Str", $location, $node->{value});
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Bool") {
        return Bool("Bool", $location, $node->{value});
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Print") {
        return PrintFunction("Print", $location, identify_type($node->{value}));
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Tuple") {
        return Tuple("Tuple", $location, identify_type($node->{first}), identify_type($node->{second}));
    }
    elsif (defined $node->{kind} && $node->{kind} eq "First") {
        return FirstFunction("First", $location, identify_type($node->{value}));
    }
    elsif (defined $node->{kind} && $node->{kind} eq "Second") {
        return SecondFunction("Second", $location, identify_type($node->{value}));
    }
    else {
        return Parameter($node->{text}, $location);
    }
}

sub read_node {
    my ($ast, $context) = @_;

    if (defined $ast->{kind} && $ast->{kind} eq "File") {
        return read_node($ast->{expression}, $context);
    }
    elsif (defined $ast->{kind} && $ast->{kind} eq "Let") {
        my $node = read_node($ast->{value}, $context);
        $context->{$ast->{name}->{text}} = $node;
        return read_node($ast->{next}, $context);
    }
    elsif (defined $ast->{kind} && $ast->{kind} eq "If") {
        my $condition_result = read_node($ast->{condition}, $context);
        return $condition_result ? read_node($ast->{then}, $context) : read_node($ast->{otherwise}, $context);
    }
    elsif (defined $ast->{kind} && $ast->{kind} eq "Binary") {
        my $lhs = read_node($ast->{lhs}, $context);
        my $rhs = read_node($ast->{rhs}, $context);
        my $op = $ast->{op};
        return $op->($lhs, $rhs);
    }
    elsif (defined $ast->{kind} && $ast->{kind} eq "Call") {
        my $method = $context->{$ast->{callee}};
        my %method_context = %$context;
        my @arguments = @{$ast->{arguments}};
        foreach my $argument (@arguments) {
            $method_context{$method->{parameters}->[$_]->{text}} = read_node($argument, \%method_context);
        }
        return read_node($method->{value}, \%method_context);
    }
    elsif (defined $ast->{kind} && $ast->{kind} eq "Var") {
        return $context->{$ast->{text}};
    }
    elsif (defined $ast->{kind} && $ast->{kind} eq "Print") {
        my $result = read_node($ast->{value}, $context);
        if (ref($result) eq 'JSON::PP::Boolean') {
            print lc($result);
        } elsif (ref($result) eq 'ARRAY') {
            print "($result->[0], $result->[1])";
        } else {
            print $result;
        }
        return $result;
    }
    elsif (defined $ast->{kind} && $ast->{kind} eq "First") {
        my $node = read_node($ast->{value}, $context);
        if (ref($node) eq 'ARRAY') {
            return read_node($node->[0], $context);
        }
        die "Error: first method only accepts tuple as parameter";
    }
    elsif (defined $ast->{kind} && $ast->{kind} eq "Second") {
        my $node = read_node($ast->{value}, $context);
        if (ref($node) eq 'ARRAY') {
            return read_node($node->[1], $context);
        }
        die "Error: second method only accepts tuple as parameter";
    }
    else {
        return $ast;
    }
}

sub process_file {
    my ($filepath) = @_;

    open my $file, '<', $filepath or die "Unable to open file $filepath: $!";
    my $json_content = do { local $/; <$file> };
    close $file;

    my $ast = decode_json($json_content);
    my %context_variables;

    my $tree = identify_type($ast);

    eval {
        read_node($tree, \%context_variables);
    };

    if ($@) {
        print "Error: $@\n";
    }
}

1;
