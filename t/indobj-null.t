use v6;
use Test;
plan 10;

use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

my PDF::Grammar::PDF::Actions $actions .= new;

my $input = '42 5 obj null endobj';
PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my Pair $ast = $/.ast;
my PDF::IO::IndObj $ind-obj .= new( |$ast, :$input );
isa-ok $ind-obj.object, ::('PDF::COS')::('Null');
is $ind-obj.obj-num, 42, '$.obj-num';
is $ind-obj.gen-num, 5, '$.gen-num';
given $ind-obj.object -> $object {
    isa-ok $object, 'PDF::COS::Null';
    ok ! $object.defined, '$.object';
    ok Int ~~ $object;
    nok 42 ~~ $object;
}
my $content = $ind-obj.content;
isa-ok $content, Pair;
is-deeply $content, (:null(Any)), '$.content';

is-deeply $ind-obj.ast, $ast, 'ast regeneration';
