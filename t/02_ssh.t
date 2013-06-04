use strict;
use warnings;
use Test::More skip_all => 'TODO';

use Net::OpenSSH;
use Cinnamon::Remote;
use Cinnamon::Helper;

no strict 'refs';
no warnings 'redefine';
local *Net::OpenSSH::new = sub {
    my ($class, $host, %args) = @_; 
    bless {}, $class;
};

subtest "ssh connection" => sub {
    local *Net::OpenSSH::capture2 = sub {
        my ($self, $cmd) = @_;
        return ($cmd, $cmd);
    };
    my $remote = Cinnamon::Remote->new(host => 'localhost', user => 'app'); 
    ok $remote;
};
