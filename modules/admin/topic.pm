use strict;
use warnings;

sophia_module_add('admin.topic', '1.0', \&init_admin_topic, \&deinit_admin_topic);

sub init_admin_topic {
    sophia_command_add('admin.topic', \&admin_topic, 'Displays or change the channel\'s topic.', '');
    sophia_global_command_add('topic', \&admin_topic, 'Displays or change the channel\'s topic.', '');

    return 1;
}

sub deinit_admin_topic {
    delete_sub 'init_admin_topic';
    delete_sub 'admin_topic';
    sophia_command_del 'admin.topic';
    sophia_command_del 'sophia.topic';
    delete_sub 'deinit_admin_topic';
}

sub admin_topic {
    my $param = $_[0];
    my @args = @{$param};
    my ($who, $where, $content) = @args[ARG0 .. ARG2];

    my $idx = index $content, ' ';
    unless ($idx > -1) {
        $sophia::sophia->yield( topic => $where->[0] );
        return;
    }

    return unless is_admin($who);

    $content = substr $content, $idx + 1;
    $sophia::sophia->yield( topic => $where->[0] => $content );
}

1;
