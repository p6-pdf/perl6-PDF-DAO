use Test;
# this test based on PDF-API2/t/filter-runlengthdecode.t
plan 4;

use PDF::Basic::Filter::RunLength;

my $in = '--- Look at this test string. ---';
my $out = "\x[fe]-\x01 L\xffo\x16k at this test string. \xfe-";
# 254, 45, 1, 32, 76, 255, 111, 22, 107, 32, 97, 116, 32, 116, 104, 105, 115, 32, 116, 101, 115, 116, 32, 115, 116, 114, 105, 110, 103, 46, 32, 254, 45
my $filter = PDF::Basic::Filter::RunLength.new;

is_deeply $filter.encode($in),
   $out,
   q{RunLength test string is encoded correctly};

is $filter.decode($out),
   $in,
   q{RunLength test string is decoded correctly};

# Add the end-of-document marker
$out ~= "\x80";

is($filter.encode($in, :eod),
   $out,
   q{RunLength test string with EOD marker is encoded correctly});

is($filter.decode($out),
   $in,
   q{RunLength test string with EOD marker is decoded correctly});
