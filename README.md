# NAME

Cinnamon::Helper - It's a simple helper tool of Cinnamon

# SYNOPSIS

    use strict;
    use warnings;

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


# DESCRIPTION

Cinnamon::Helper is a simple helper tool of Cinnamon

# LICENSE

Copyright (C) Masaaki Saito.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Masaaki Saito <masakyst.public@gmail.com>
