use v6;

unit class PDF::IO::IndObj;

use PDF::COS :IndRef;
has $.object handles <content obj-num gen-num>;

#| construct by wrapping a pre-existing PDF::COS
multi submethod TWEAK( PDF::COS :$!object!, :$obj-num, :$gen-num ) {
    $!object.obj-num = $_ with $obj-num;
    $!object.gen-num = $_ with $gen-num;
}

#| construct an object instance from a PDF::Grammar::PDF ast representation of
#| an indirect object: [ $obj-num, $gen-num, $type => $content ]
multi submethod TWEAK( Array :$ind-obj!, |c ) {
    $!object = PDF::COS.coerce( |$ind-obj[2], |c );
    $!object.obj-num = $ind-obj[0];
    $!object.gen-num = $ind-obj[1];
}

#| recreate a PDF::Grammar::PDF / PDF::IO::Writer compatible ast from the object
method ast returns Pair {
    :ind-obj[ $.obj-num, $.gen-num, $.content ]
}

#| create ast for an indirect reference to this object
method ind-ref returns IndRef {
    :ind-ref[ $.obj-num, $.gen-num ]
}

