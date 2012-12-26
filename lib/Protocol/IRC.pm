use MooseX::Declare;
use Method::Signatures::Modifiers;

class Protocol::IRC
{
    use API::Log qw(:ALL);
    use POE qw(Component::IRC);

    method _001 (@args)
    {
        my $heap = $args[HEAP - 1];
        my $sophia = $heap->{sophia};

        if ($sophia->{password})
        {
            $sophia->yield(privmsg => 'NickServ' => sprintf('identify %s %s', $sophia->{nick}, $sophia->{password}));
        }

        if ($heap->{usermodes})
        {
            $sophia->yield(mode => sprintf('%s %s', $sophia->{nick}, $heap->{usermodes}));
        }

        for my $chan (keys %{$heap->{channels}})
        {
            $sophia->yield(join => $chan);
        }
    }

    method _332 (@args)
    {
        my $heap = $args[HEAP - 1];
        my $channel_data = $args[ARG2 - 1];
        my $channel = lc $channel_data->[0];
        my $topic   = $channel_data->[1];

        $heap->{channel_topics}{$channel} = $topic;
        return;
    }

    method _default (@args)
    {
        my ($event, $args) = @args[ARG0 - 1 .. $#args];
        my @output = ( "$event: " );

        ARG: for my $arg (@$args)
        {
            if (ref $arg eq 'ARRAY')
            {
                push @output, '[' . join(',', @$arg) . ']';
                next ARG;
            }

            push @output, "'$arg'";
        }

        print join ' ', @output, "\n";
        return;
    }

    method _disconnected (@args)
    {
        my $heap = $args[HEAP - 1];
        my $sophia = $heap->{sophia};
        $sophia->yield('shutdown');
        return;
    }

    method _error (@args)
    {
        _log('sophia', $args[ARG0 - 1]);
        return;
    }

    method _shutdown (@args)
    {
        my $heap = $args[HEAP - 1];

        if ($heap->{SYSTEM}{RESTART})
        {
            do "$sophia::BASE{BIN}/sophia";
        }

        exit;
    }

    method _sigint (@args)
    {
        my $heap = $args[HEAP - 1];
        my $sophia = $heap->{sophia};
        $sophia->yield(quit => 'Shutting down ... ');

        $args[KERNEL - 1]->sig_handled();
        return;
    }

    method _start (@args)
    {
        my $kernel = $args[KERNEL - 1];
        $kernel->sig(INT => 'sig_int');

        my $heap = $args[HEAP - 1];
        my $sophia = $heap->{sophia};
        if (!$sophia)
        {
            error_log('sophia', "Unable to get sophia instance from heap (start): $!\n");
        }

        $sophia->yield(register => 'all');
        $sophia->yield(connect  => { });

        return;
    }

    method _stop (@args)
    {
    }

    method _topic (@args)
    {
        my ($heap, $chan, $topic) = @args[HEAP - 1, ARG1 - 1, ARG2 - 1];
        $chan = lc $chan;

        $heap->{channel_topics}{$chan} = $topic;
        return;
    }
}
