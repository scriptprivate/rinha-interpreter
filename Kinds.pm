package Kinds;
use strict;
use warnings;
use Exporter qw(import);

our @EXPORT = qw(
    File
    Let
    Str
    Bool
    Int
    Add
    Sub
    Mul
    Div
    Rem
    Eq
    Neq
    Lt
    Gt
    Lte
    Gte
    And
    Or
    BinaryOp
    If
    Binary
    Call
    Function
    PrintFunction
    FirstFunction
    SecondFunction
    Tuple
    Var
    Loc
    Parameter
);

sub Loc {
    my ($start, $end, $filename) = @_;
    return { start => $start, end => $end, filename => $filename };
}

sub File {
    my ($name, $expression, $location) = @_;
    return { kind => 'File', name => $name, expression => $expression, location => $location };
}

sub Let {
    my ($kind, $location, $name, $value, $next) = @_;
    return { kind => $kind, location => $location, name => $name, value => $value, next => $next };
}

sub Str {
    my ($kind, $value, $location) = @_;
    return { kind => $kind, value => $value, location => $location };
}

sub Bool {
    my ($kind, $value, $location) = @_;
    return { kind => $kind, value => $value, location => $location };
}

sub Int {
    my ($kind, $value, $location) = @_;
    return { kind => $kind, value => $value, location => $location };
}

sub BinaryOp {
    my ($op) = @_;
    my %ops = (
        Add => sub { my ($x, $y) = @_; return $x + $y },
        Sub => sub { my ($x, $y) = @_; return $x - $y },
        Mul => sub { my ($x, $y) = @_; return $x * $y },
        Div => sub { my ($x, $y) = @_; return $x / $y },
        Rem => sub { my ($x, $y) = @_; return $x % $y },
        Eq  => sub { my ($x, $y) = @_; return $x == $y },
        Neq => sub { my ($x, $y) = @_; return $x != $y },
        Lt  => sub { my ($x, $y) = @_; return $x < $y },
        Gt  => sub { my ($x, $y) = @_; return $x > $y },
        Lte => sub { my ($x, $y) = @_; return $x <= $y },
        Gte => sub { my ($x, $y) = @_; return $x >= $y },
        And => sub { my ($x, $y) = @_; return $x && $y },
        Or  => sub { my ($x, $y) = @_; return $x || $y },
    );
    return $ops{$op};
}

sub If {
    my ($kind, $location, $condition, $then, $otherwise) = @_;
    return { kind => $kind, location => $location, condition => $condition, then => $then, otherwise => $otherwise };
}

sub Binary {
    my ($kind, $location, $lhs, $op, $rhs) = @_;
    return { kind => $kind, location => $location, lhs => $lhs, op => $op, rhs => $rhs };
}

sub Call {
    my ($kind, $location, $callee, $arguments) = @_;
    return { kind => $kind, location => $location, callee => $callee, arguments => $arguments };
}

sub Function {
    my ($kind, $location, $parameters, $value) = @_;
    return { kind => $kind, location => $location, parameters => $parameters, value => $value };
}

sub PrintFunction {
    my ($kind, $location, $value) = @_;
    return { kind => $kind, location => $location, value => $value };
}

sub FirstFunction {
    my ($kind, $location, $value) = @_;
    return { kind => $kind, location => $location, value => $value };
}

sub SecondFunction {
    my ($kind, $location, $value) = @_;
    return { kind => $kind, location => $location, value => $value };
}

sub Tuple {
    my ($kind, $location, $first, $second) = @_;
    return { kind => $kind, location => $location, first => $first, second => $second };
}

sub Var {
    my ($kind, $location, $text) = @_;
    return { kind => $kind, location => $location, text => $text };
}

sub Parameter {
    my ($text, $location) = @_;
    return { text => $text, location => $location };
}

1;
