package Cinnamon::Helper;
use strict;
use warnings;
use parent qw(Exporter);
use Cinnamon::DSL;

our $VERSION = "0.01";

sub import {
    strict->import;
    warnings->import;
    no strict 'refs';
    my $pkg = caller(0);
    *{"$pkg\::cmd"}      = \&_cmd;
    *{"$pkg\::chain"}    = \&_chain;
    *{"$pkg\::user"}     = \&_user;
    *{"$pkg\::ssh"}      = \&_ssh;
    *{"$pkg\::scp_put"}  = \&_scp_put;
    *{"$pkg\::scp_get"}  = \&_scp_get;
}

my @COMMANDS  = (); 

sub commands {
    return @COMMANDS;
}

sub clear_commands {
    @COMMANDS = ();
}

sub _cmd {
    push @COMMANDS, shift;
}

sub _chain {
    my $line = join ' && ', @COMMANDS;
    @COMMANDS = (); #initialize
    return $line;
}

sub _user {
    my ($user, $cmd) = @_; 
    return sprintf 'runuser -l %s -c "%s"', $user, $cmd;
}

sub _ssh {
    my $host = shift;
    no strict 'subs';
    return Cinnamon::Remote->new(
        host => $host,
        user => Cinnamon::Config::user,
    )->connection;
}

sub _scp_put {
    my ($host, $local_file, $remote_dir, $user) = @_;
    say $user;
    my $ssh = ssh($host);
    $ssh->scp_put({copy_attrs => 1, quiet => 0}, $local_file, $remote_dir);
    if ($user) {
        $ssh->system("chown $user ".Path::Class::file($remote_dir, File::Basename::basename($local_file))->absolute->stringify);
    }
}

sub _scp_get {
    my ($host, $remote_file, $local_file) = @_;
    ssh($host)->scp_get({copy_attrs => 1, quiet => 0}, $remote_file, $local_file);
}


1;
__END__

=encoding utf-8

=head1 NAME

Cinnamon::Helper - It's a simple helper tool of Cinnamon

=head1 SYNOPSIS

    # Exports some functions
    use Cinnamon::Helper;

    # Chain commands 
    cmd q{cd /tmp};
    cmd q{ls -la};
    run chain;

    # Execute work user(hoge)
    cmd q{cd /tmp};
    cmd q{./cpanm -l extlib JSON::XS};
    run user('hoge', chain);

    # scp put/get wrapper
    scp_put $host, 'start_server.pl', '/home/cloudf/cloudforecast/';
    scp_get $host, '.ssh/id_rsa', 'hoge.pem';

=head1 DESCRIPTION

Cinnamon::Helper is a simple helper tool of Cinnamon 

=head1 LICENSE

Copyright (C) Masaaki Saito.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Masaaki Saito E<lt>masakyst.public@gmail.comE<gt>

=cut

