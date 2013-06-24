use strict;
use warnings;
use Test::More;
use Cinnamon::Helper;

subtest "cmd" => sub {
    cmd q{ls -la};
    cmd q{ps};
    my @cmds = Cinnamon::Helper::commands();
    is "ls -la", $cmds[0];
    is "ps", $cmds[1];
    Cinnamon::Helper::clear_commands();
};

subtest "shell" => sub {
    cmd q{ps};
    cmd q{ls -la};
    is "ps && ls -la", chain();
    my @cmds = Cinnamon::Helper::commands();
    is_deeply [], \@cmds;
};

subtest "user" => sub {
    is 'runuser -l cloudf -c "ls -la"', user('cloudf', "ls -la");
};

done_testing;
