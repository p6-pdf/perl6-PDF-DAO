use v6;
# based on Perl 5's PDF::API::Core::PDF::Filter::ASCIIHexDecode

class PDF::Storage::Filter::ASCIIHex {

    # Maintainer's Note: ASCIIHexDecode is described in the PDF 1.7 spec
    # in section 7.4.2.
    use PDF::Storage::Blob;
    use PDF::Storage::Util :resample;

    multi method encode(Str $input, |c --> PDF::Storage::Blob) {
	$.encode( $input.encode("latin-1"), |c)
    }
    multi method encode(Blob $input --> PDF::Storage::Blob) {

	BEGIN my uint8 @Hex = map *.ord, flat '0' .. '9', 'a' .. 'f';

	my @buf = resample( $input, 8, 4).map: {@Hex[$_]};
	@buf.push: '>'.ord;

	PDF::Storage::Blob.new( @buf );
    }

    multi method decode(Blob $input, |c) {
	$.decode( $input.decode("latin-1"), |c);
    }
    multi method decode(Str $input, Bool :$eod = False --> PDF::Storage::Blob) {

        my Str $str = $input.subst(/\s/, '', :g);

        if $str && $str.substr(*-1,1) eq '>' {
            $str = $str.chop;
        }
        else {
           die "missing end-of-data marker '>' at end of hexadecimal encoding"
               if $eod
        }

        # "If the filter encounters the EOD marker after reading an odd
        # number of hexadecimal digits, it shall behave as if a 0 (zero)
        # followed the last digit."

        $str ~= '0'
            unless $str.codes %% 2;

        die "Illegal character(s) found in ASCII hex-encoded stream: {$0.Str.perl}"
            if $str ~~ m:i/(< -[0..9 A..F]>)/;

        my uint8 @bytes = $str.comb.map: -> \a, \b { :16(a ~ b) };

	PDF::Storage::Blob.new( @bytes );
    }
}
