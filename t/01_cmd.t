use strict;
use warnings;
use Test::More;
use Cinnamon::DSL;
#use Cinnamon::Context;
use Cinnamon::Helper;

# todo: 0.25 
# $Cinnamon::Context::CTX = Cinnamon::Context->new;

subtest "cmd" => sub {
    cmd q{ls -la};
    cmd q{ps};
    my @cmds = Cinnamon::Helper::commands();
    is "ls -la", $cmds[0];
    is "ps", $cmds[1];
    Cinnamon::Helper::clear_commands();
};

subtest "execute command chain" => sub {
    cmd q{ps};
    cmd q{ls -la};
    is "ps && ls -la", shell();
    my @cmds = Cinnamon::Helper::commands();
    is_deeply [], \@cmds;
};

subtest "escape single quote" => sub {
    cmd q{echo 'test1'};
    cmd q{echo 'test2'};
    is  q{echo \\'test1\\' && echo \\'test2\\'}, shell(escape => q{'});
    cmd q{echo "test1"};
    cmd q{echo "test2"};
    is  q{echo \\"test1\\" && echo \\"test2\\"}, shell(escape => q{"});
};

subtest "sh -c" => sub {
    cmd q{ls -la};
    is  q{sh -c 'ls -la'}, sh { shell };
};

subtest "user" => sub {
    is 'runuser -l cloudf -c "ls -la"', user('cloudf', "ls -la");
    is 'runuser -l cloudf -c "ls -la"', user(cloudf => "ls -la");
};

subtest "su" => sub {
    su 'hoge';
    is 'hoge', get('user');
    su 'fuga', '12345';
    is 'fuga', get('user');
    is '12345', get('password');
};


done_testing;
