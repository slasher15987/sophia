use strict;
use warnings;
use Time::Local;

sophia_module_add('common.countdown', '1.0', \&init_common_countdown, \&deinit_common_countdown);

sub init_common_countdown {
    sophia_command_add('common.countdown', \&common_countdown, 'Prints a countdown to a given date.', '');

    return 1;
}

sub deinit_common_countdown {
    delete_sub 'init_common_countdown';
    delete_sub 'common_countdown';
    sophia_command_del 'common.countdown';
    delete_sub 'deinit_common_countdown';
}

sub common_countdown {
    my $args = $_[0];
    my ($where, $content) = ($args->[ARG1], $args->[ARG2]);
    my $sophia = $args->[HEAP]->{sophia};

    my @opts = split ' ', $content;
    shift @opts;
    return if !scalar @opts;
    --$opts[1]; # decrement the month since localtime reads the month as an int from 0 .. 11
    my $times = timelocal(0,0,0,$opts[2],$opts[1],$opts[0]);

    my $curtime = time();
    my $diff = $times - $curtime;

    my $diffdays = int($diff / 86400.0);
    my $diffhours = int(($diff % 86400.0) / (3600));
    my $diffminutes = int((($diff % 86400.0) % (3600)) / 60);
    my $diffseconds = ((($diff % 86400.0) % (3600)) % 60);
    $sophia->yield(privmsg => $where->[0] => "$diffdays days, $diffhours hours, $diffminutes minutes, and $diffseconds seconds.");
}

1;
