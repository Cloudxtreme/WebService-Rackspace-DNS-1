package WebService::Rackspace::DNS;

use 5.010;
use Any::Moose;
with 'Web::API';

=head1 NAME

WebService::Rackspace::DNS - an interface to rackspace.com's RESTful Cloud DNS API using Web::API

=head1 VERSION

Version 0.1

=cut

our $VERSION = '0.1';

has 'location' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub { '' },
);

has 'commands' => (
    is      => 'rw',
    default => sub {
        {
            # needed for login()
            tokens => {
                method    => 'POST',
                path      => 'tokens',
                mandatory => [ 'user', 'api_key' ],
                wrapper   => [ 'auth', 'RAX-KSKEY:apiKeyCredentials' ],
            },

            # limits
            limits      => { path        => 'limits' },
            limit_types => { path        => 'limits/types' },
            limit       => { pre_id_path => 'limits', require_id => 1 },

            # domains
            domains => { path        => 'domains' },
            domain  => { pre_id_path => 'domains', require_id => 1 },
            domain_history => {
                pre_id_path  => 'domains',
                post_id_path => 'changes',
                require_id   => 1,
            },
            zonefile => {
                pre_id_path  => 'domains',
                post_id_path => 'export',
                require_id   => 1,
            },
            create_domain => {
                method    => 'POST',
                path      => 'domains',
                mandatory => ['domains'],
            },
            import_domain => {
                method    => 'POST',
                path      => 'domains/import',
                mandatory => ['domains'],

                # mandatory          => [ 'contents' ],
                # default_attributes => { contentType => 'BIND_9' },
            },
            update_domain => {
                method      => 'PUT',
                pre_id_path => 'domains',
                require_id  => 1,
            },
            update_domains => {
                method    => 'PUT',
                path      => 'domains',
                mandatory => ['domains'],
            },
            delete_domain => {
                method      => 'DELETE',
                pre_id_path => 'domains',
                require_id  => 1,
            },
            delete_domains => {
                method    => 'DELETE',
                path      => 'domains',
                mandatory => ['id'],
            },
            subdomains => {
                pre_id_path  => 'domains',
                post_id_path => 'subdomains',
                require_id   => 1,
            },

            # records
            records => {
                pre_id_path  => 'domains',
                post_id_path => 'records',
                require_id   => 1,
            },
            record => {
                pre_id_path  => 'domains',
                post_id_path => 'records/:record_id',
                require_id   => 1,
            },
            create_record => {
                method       => 'POST',
                pre_id_path  => 'domains',
                post_id_path => 'records',
                require_id   => 1,
            },
            update_record => {
                method       => 'PUT',
                pre_id_path  => 'domains',
                post_id_path => 'records/:record_id',
                require_id   => 1,
            },
            update_records => {
                method       => 'PUT',
                pre_id_path  => 'domains',
                post_id_path => 'records',
                require_id   => 1,
            },
            delete_record => {
                method       => 'DELETE',
                pre_id_path  => 'domains',
                post_id_path => 'records/:record_id',
                require_id   => 1,
            },
            delete_records => {
                method       => 'DELETE',
                pre_id_path  => 'domains',
                post_id_path => 'records',
                require_id   => 1,
            },

            # PTRs
            ptrs => {
                pre_id_path => 'rdns',
                require_id  => 1,
                mandatory   => ['href'],
            },
            ptr => {
                pre_id_path  => 'rdns',
                post_id_path => ':record_id',
                require_id   => 1,
                mandatory    => ['href'],
            },
            create_ptr => {
                method    => 'POST',
                path      => 'rdns',
                mandatory => [ 'recordsList', 'link' ],
            },
            update_ptr => {
                method    => 'PUT',
                path      => 'rdns',
                mandatory => [ 'recordsList', 'link' ],
            },
            delete_ptr => {
                method      => 'DELETE',
                pre_id_path => 'rdns',
                require_id  => 1,
                mandatory   => ['href'],
                optional    => ['ip'],
            },

            # jobs status
            status => {
                pre_id_path        => 'status',
                require_id         => 1,
                default_attributes => { showDetails => 'true' },
            },
        };
    },
);

sub commands {
    my ($self) = @_;
    return $self->commands;
}

=head1 SYNOPSIS

Please refer to the API documentation at L<http://docs.rackspace.com/cdns/api/v1.0/cdns-devguide/content/overview.html>

    use WebService::Rackspace::DNS;
    use Data::Dumper;
    
    my $dns = WebService::Rackspace::DNS->new(
        debug   => 1,
        user    => 'jsmith',
        api_key => 'aaaaa-bbbbb-ccccc-12345678',
    );
    
    my $response = $dns->create_domain(
        domains => [ {
            name => "blablub.com",
            emailAddress => 'bleep@bloop.com',
            recordsList => {
                records => [ {
                    name => "blablub.com",
                    type => "MX",
                    priority => 10,
                    data => "127.0.0.1"
                },
                {
                    name => "ftp.blablub.com",
                    ttl  => 3600,
                    type => "A",
                    data => "127.0.0.1"
                    comment => "A record for FTP server",
                } ],
            },
        } ]
    );
    print Dumper($response);

    $response = $dns->status(id => "some-funny-long-job-identifier");
    print Dumper($response);

=head1 SUBROUTINES/METHODS

=head2 limits

=head2 limit_types

=head2 limit

=head2 domains

=head2 domain

=head2 domain_history

=head2 zonefile

=head2 create_domain

=head2 import_domain

=head2 update_domain

=head2 update_domains

=head2 delete_domain

=head2 delete_domains

=head2 subdomains

=head2 records

=head2 record

=head2 create_record

=head2 update_record

=head2 update_records

=head2 delete_record

=head2 delete_records

=head2 ptrs

=head2 ptr

=head2 create_ptr

=head2 update_ptr

=head2 delete_ptr

=head2 status

=head1 INTERNALS

=head2 login

do rackspace's strange non-standard login token thing

=cut

sub login {
    my ($self) = @_;

    # rackspace uses one authentication URL for all their services
    my $base_url = $self->base_url;

    if (uc($self->location) eq 'UK') {
        $self->base_url('https://lon.identity.api.rackspacecloud.com/v2.0');
    }
    else {
        $self->base_url('https://identity.api.rackspacecloud.com/v2.0');
    }

    $self->debug(0);    #debug
    my $res = $self->tokens(user => $self->user, api_key => $self->api_key);
    $self->debug(1);    #debug

    # set special auth header token for future requests
    if (exists $res->{content}->{access}->{token}->{id}) {
        $self->header(
            { 'X-Auth-Token' => $res->{content}->{access}->{token}->{id} });

        # add tenant ID to previous base_url
        $self->base_url(
            $base_url . $res->{content}->{access}->{token}->{tenant}->{id});
    }

    return $res;
}

=head2 BUILD

basic configuration for the client API happens usually in the BUILD method when using Web::API

=cut

sub BUILD {
    my ($self) = @_;

    $self->user_agent(__PACKAGE__ . ' ' . $VERSION);
    $self->content_type('application/json');

    # $self->extension('json');
    $self->auth_type('none');
    $self->mapping({
            user    => 'username',
            api_key => 'apiKey',
            1       => "true",
            0       => "false",
            email   => 'emailAddress',
    });

    if (uc($self->location) eq 'UK') {
        $self->base_url('https://lon.dns.api.rackspacecloud.com/v1.0/');
    }
    else {
        $self->base_url('https://dns.api.rackspacecloud.com/v1.0/');
    }

    my $res = $self->login;
    return $res if (exists $res->{error});

    return $self;
}

=head1 AUTHOR

Tobias Kirschstein, C<< <lev at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-WebService-Rackspace-DNS at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-Rackspace-DNS>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::Rackspace::DNS

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-Rackspace-DNS>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-Rackspace-DNS>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-Rackspace-DNS>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-Rackspace-DNS/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Tobias Kirschstein.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of WebService::Rackspace::DNS
