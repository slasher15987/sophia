use MooseX::Declare;
use Method::Signatures::Modifiers;

class Util::String
{
    use Constants;

    method chunk_split ($string, $chunk_length)
    {
        my @chunks = ($string =~ /.{0,$chunk_length}[^ ]* ?/g);
        return \@chunks;
    }

    method empty ($string)
    {
        $string = $self->trim($string);
        return $string eq '' || uc($string) eq 'FALSE';
    }

    method ltrim ($string)
    {
        $string =~ s/\A\s+//;
        return $string;
    }

    method rtrim ($string)
    {
        $string =~ s/\s+\z//;
        return $string;
    }

    method trim ($string)
    {
        $string = $self->ltrim($string);
        $string = $self->rtrim($string);
        return $string;
    }

    method trim_all ($string_arr)
    {
        map { $_ = $self->trim($_) } @$string_arr;
        return $string_arr;
    }
}
