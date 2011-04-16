use strict;
use warnings;

sub sophia_write {
    my ($chans, $text) = @_;
    my @channels;
    my @output;

    if (ref($chans) eq "SCALAR") {
        push @channels, $$chans;
    }
    elsif (ref($chans) eq "ARRAY") {
        @channels = @$chans;
    }

    if (ref($text) eq "SCALAR") {
        push @output, $$text;
    }
    elsif (ref($text) eq "ARRAY") {
        @output = @$text;
    }

    for my $chan (@channels) {
        $sophia::sophia->yield(privmsg => $chan => $_) for @output;
    }
}

1;