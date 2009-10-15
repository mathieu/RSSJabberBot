#!/usr/bin/perl
use Net::Jabber::Bot;
use XML::Smart;
use utf8;
use strict;



# Simple RSS bot (yjesus@security-projects.com)
# It works fine with Feedburner


my @commands = ("help","please","killme");

#my $channel = 'test_evebot';
my $channel = 'eve';

my %forum_list = (
	$channel => \@commands,
	);

my $url = 'http://10.3.3.49/eveBIM.xml' ;

my ($last_title, $last_link) = checa();

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
	message_function => \&new_bot_message , 
	background_function => \&background_checks , 
	loop_sleep_time => 15 , 
	process_timeout => 5 , 
	forums_and_responses => \%forum_list , 
	ignore_server_messages => 1 , 
	ignore_self_messages => 1 , 
	out_messages_per_second => 4 , 
	max_message_size => 1000 , 
	max_messages_per_hour => 100 
)|| die "ooops\n" ;

$bot->Start();

sub new_bot_message {
    my %bot_message_hash = @_;

    my $user = $bot_message_hash{reply_to} ;
    my $message = lc($bot_message_hash{body});


    if ($message =~ m/\bhelp\b/) {
        $bot->SendGroupMessage($channel, "Hi I'm a RSS-BOT for jabber !!");
    }
}



sub background_checks {
    my ($title, $link) = checa();

    return if ($last_title eq $title);

    $bot->SendGroupMessage($channel, "$title");
    $bot->SendGroupMessage($channel, "$link");
      
    $last_title=$title; # Now make the new title recieved the most recent title.
}

sub checa {
    my $XML ;

    eval { $XML = XML::Smart->new($url) };
    if ($@) { return undef }

    $XML = $XML->cut_root ;
    my $title =$XML->{channel}{item}[0]{title}[0] ;
    my $link =$XML->{channel}{item}[0]{link}[0] ;

    utf8::encode($title);
    utf8::encode($link);

    return($title, $link)
}
