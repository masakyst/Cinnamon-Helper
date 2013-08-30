use strict;
use warnings;
use Test::More;
use Cinnamon::DSL;
use Cinnamon::Helper;
use MIME::Base64;

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

subtest "bash -c" => sub {
    cmd q{ls -la};
    is  q{bash -c 'ls -la'}, sh { shell };
};

subtest "user" => sub {
    is 'runuser -l cloudf -c "ls -la"', user('cloudf', "ls -la");
    is 'runuser -l cloudf -c "ls -la"', user(cloudf => "ls -la");
};

subtest "write_file" => sub {
    my $path = '/etc/hoge.conf';
    my $cont = "abcd
efg
hij";
#is "cat <<\\_EOT_>> ${path}\n${cont}\n_EOT_\n", write_file($path => $cont);
    is sprintf('perl -MMIME::Base64 -MIO::File -e \'IO::File->new($ARGV[0], ">")->print(decode_base64($ARGV[1]))\' %s \'%s\'', $path, encode_base64($cont)), write_file($path => $cont);
};

done_testing;
