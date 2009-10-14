#!/usr/bin/perl
use strict;
use warnings;
use POE;
use POE::Component::RSSAggregator;
use Net::Jabber::Bot;

my @commands = ("help","please","killme");

my $channel ="eve";

my %forum_list = (
	$channel => \@commands,
	);

my $bot = Net::Jabber::Bot->new ( 
	server => 'bscw.cstb.fr' , # Name of server when sending messages internally. 
    conference_server => 'conference.bscw.cstb.fr' , 
    server_host => 'bscw.cstb.fr'  , # used to specify what jabber server to connect to on connect?
	tls => 0 , # set to 1 for google
	connection_type => 'tcpip' , 
	port => 443 , 
	username => 'evebot' , 
	password => 'evebot' , 
	alias => 'evebot' , 
#	message_function => \&new_bot_message , 
#	background_function => \&background_checks , 
	loop_sleep_time => 15 , 
	process_timeout => 5 , 
	forums_and_responses => \%forum_list , 
	ignore_server_messages => 1 , 
	ignore_self_messages => 1 , 
	out_messages_per_second => 4 , 
	max_message_size => 1000 , 
	max_messages_per_hour => 100 
);

sub new_bot_message {
	
};

sub background_checks {
	
};

my @feeds = (
    {   url   => "http://10.3.3.49/eveBIM.xml",
        name  => "eveBIM",
        delay => 10,
    },
    {   url   => "http://bscw.cstb.fr/pub/bscw.cgi/106882?op=rssfeed",
        name  => "blog",
        delay => 300,
    },
);

POE::Session->create(
    inline_states => {
        _start      => \&init_session,
        handle_feed => \&handle_feed,
    },
);

$poe_kernel->run();

sub init_session {
    my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
    $heap->{rssagg} = POE::Component::RSSAggregator->new(
        alias    => 'rssagg',
        debug    => 0,
        callback => $session->postback("handle_feed"),
        tmpdir   => '/tmp',        # optional caching 
    );
    $kernel->post( 'rssagg', 'add_feed', $_ ) for @feeds;
}

sub handle_feed {
    my ( $kernel, $feed ) = ( $_[KERNEL], $_[ARG1]->[0] );
    for my $headline ( $feed->late_breaking_news ) {

        # do stuff with the XML::RSS::Headline object
        print $headline->headline . "\n";
		$bot->SendGroupMessage($channel, $headline->headline);
		$bot->SendGroupMessage($channel, $headline->url);
    }
}