package Cinnamon::Helper;
use strict;
use warnings;
use Cinnamon::DSL;
use MIME::Base64;

our $VERSION = "0.01";

sub import {
    { no strict 'refs';
        my $pkg = caller(0);
        my @export_cmds =qw(cmd shell sh user ssh scp_get scp_put write_file);
        foreach my $import_cmd (@export_cmds) {
            *{"$pkg\::$import_cmd"} = *{"_$import_cmd"};
        }
    }
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

sub _shell {
    my ($type, $value) = @_;
    my $line = join ' && ', @COMMANDS;
    if (defined $type and $type eq 'escape') {
        Carp::croak "failed escape quote: [${value}]" unless $value =~ m/('|")/;
        my $quote = "\\".$value;
        $line =~ s/$value/$quote/gs;
    }
    @COMMANDS = (); #initialize
    return $line;
}

sub _sh(&) {
    my $code = shift;
    my $shell = $code->();
    return sprintf("bash -c '%s'", $shell);
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
    my $ssh = Cinnamon::Helper::_ssh($host);
    $ssh->scp_put({copy_attrs => 1, quiet => 0}, $local_file, $remote_dir);
    if ($user) {
        $ssh->system("chown $user ".Path::Class::file($remote_dir, File::Basename::basename($local_file))->absolute->stringify);
    }
}

sub _scp_get {
    my ($host, $remote_file, $local_file) = @_;
    Cinnamon::Helper::_ssh($host)->scp_get({copy_attrs => 1, quiet => 0}, $remote_file, $local_file);
}

sub _write_file {
    my ($filepath, $content) = @_;
    # return sprintf("cat <<\\_EOT_>> %s\n%s\n_EOT_\n", $filepath, $content);
    return sprintf(q{perl -MMIME::Base64 -MIO::File -e 'IO::File->new($ARGV[0], ">")->print(decode_base64($ARGV[1]))' %s '%s'}, $filepath, encode_base64($content));
}


1;
__END__

=encoding utf-8

=head1 NAME

Cinnamon::Helper - It's a simple helper tool of Cinnamon

=head1 SYNOPSIS

    # Exports some functions
    use Cinnamon::Helper;

    # execute Chain commands 
    cmd q{cd /tmp};
    cmd q{ls -la};
    run shell;

    # Execute work user(hoge)
    cmd q{cd /tmp};
    cmd q{./cpanm -l extlib JSON::XS};
    run user('hoge', shell);

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

