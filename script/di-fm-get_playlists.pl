#!/usr/bin/perl 

use strict;
use warnings;
use autodie;

use JSON;
use Data::Dumper;
use WWW::Mechanize;
use Getopt::Long;
use Pod::Usage;

my $help;
my $man;
my $premium;
my $username;
my $password;
my $m3u;

GetOptions(
  'help|?'            => \$help,
  'man'               => \$man,
  'premium'           => \$premium,
  'm3u'               => \$m3u,
  'username|user|u=s' => \$username,
  'password|pass|p=s' => \$password
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;
pod2usage("Username and password needed if premium")
  if $premium && !( $username && $password);

my $directory_uri  = 'http://listen.di.fm/public3';
my $mech           = WWW::Mechanize->new();
my $login_attempts = 0;
my $logged_in      = 0;
my $playlist_limit = -1;

$mech->agent_alias( 'Linux Mozilla' );

sub playlist_uri {
  my ($playlist) = @_;
  my $playlist_name = $playlist->{key};

  if ( $premium ) {
    "http://www.di.fm/listen/$playlist_name/256k.pls"
  } else {
    $playlist->{playlist};
  }
}

sub login_if_needed {
  while (! $logged_in ) {

    my $title = $mech->response->headers->{title};
    
    if ( $title && $title =~ m/login/i ) {
      if ( ! $login_attempts ) {
        $mech->submit_form(
          form_name  => 'login',
          fields     => {
            amember_login => $username,
            amember_pass  => $password,
          }
        );

        $login_attempts++;
        
      } else {
        die "Login failed:  " . $mech->response->content;
      }
    } else {
      $logged_in = 1;
    }
  }
}

my $directory_res = $mech->get( $directory_uri ) ;
my $playlists     = from_json( $mech->response->content );

for my $playlist ( @$playlists ) {

  next unless $playlist_limit; 
  
  $playlist_limit--;
  
  my $pl_uri = playlist_uri( $playlist );
  $mech->get( $pl_uri );
  
  login_if_needed();

  #Because the redirect doesn't work after login
  $mech->get( $pl_uri ) if $mech->is_html; 
  
  my $filename = $playlist->{key} . ( $m3u ? ".m3u" : ".pls" );

  print "Saving $filename\n"; 

  my $content = $mech->response->content();
  open my $fh , ">" , $filename;
  
  if ( $m3u ) {
    my @lines = split $/ , $content;
    @lines = grep { m/^File/ } @lines;
    map { s/^File\d+=//g } @lines; 
    $content = join $/ , @lines;
  }
  
  $fh->print( $content , $/ ); 
  
}

__END__

=head1 NAME

    di-fm-get_playlists.pl - A tool for scraping all the playlists from di.fm

=head1 SYNOPSIS

    di-fm-getplaylists.pl [options]

     Options:
       --help            brief help message
       --man             full documentation
       --premium         Set this flag if you want the premium streams.
       --m3u             Set if you want the files converted to m3u playlists.
       --user=<username> Username of your account
       --pass=<password> Password of the account

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION



=cut
