#!/usr/bin/perl -w

# update.pl
#
# CGI script to perform an update for a dyn dns record.
#
# Author: Stefan Haun <tux@netz39.de>
#
# CGI parameters:
#	hostname	Domain to be updated
#	secret		The update secret
#	ip		The new IP, omit to delete the A record


# TODO update lastupdate


use strict;
use DBI;
use CGI;
use File::Spec;

my $config_file = "/etc/dyn/update_dyn.config";
my $dyn_update = "/usr/lib/dyn/dyn_update.sh";

# see http://stackoverflow.com/a/15687293
sub silently($) {
    #Turn off STDOUT
    open my $saveout, ">&STDOUT";
    open STDOUT, '>', File::Spec->devnull();
           
    #Run passed function
    my $func = $_[0];
    $func->();
                        
    #Restore STDOUT
    open STDOUT, ">&", $saveout;
}


## Konfiguration laden
my %config;

open( CONFIG, "< $config_file" ) || die "Could not open configuration file!";

while (<CONFIG>) {

	# Kommentare und Leerzeilen ignorieren
	next if m/^#|^$/;
	chomp;

	# Schluessel und Wert extrahieren
	my $key;
	my $value;

	( $key, $value ) = m/(.*?):\s*(.*)/;

	# Ergebnis pruefen
	die "Invalid configuration line: $_" unless $key && $value;

	# zum config-hash hinzufuegen oder anhaengen, falls der Schluessel
	# schon existiert
	if ( $config{$key} ) {
		$config{$key} .= " " . $value;
	} else {
		$config{$key} = $value;
	}
}

close(CONFIG);


# Parameter auslesen, CGI-Access
my $q = CGI->new();

my $q_hostname = $q->param('hostname');
my $q_ip = $q->param('myip');
my $q_secret = $q->param('secret');

# Start CGI response
print $q->header('text/html');

my @missing;
# Check parameters
if (! $q_hostname) {
  push(@missing, "hostname");
}
if (! $q_secret) {
  push(@missing, "secret");
}

if (@missing) {
  print "err Missing parameter(s): ";
  print join(', ', @missing);
  print "\n";
  exit 1;
}


# DB-Verbindung herstellen
my $drh = DBI->install_driver("mysql");
my $dbh = DBI->connect($config{'db_dsn'}, 
                       $config{'db_user'}, $config{'db_pass'});
if ($DBI::err) {
  print "911 Could not connect to database: $DBI::errstr\n";
  exit 1;
}




# Check domain and get secret

my $sth = $dbh->prepare("SELECT password FROM dyndns WHERE domain=?");
$sth->bind_param(1, $q_hostname);
$sth->execute();

my $secret;
$sth->bind_columns(\$secret);

$sth->fetch();

$sth->finish();
$dbh->disconnect();

# have a look at the results

# If secret is empty, fetch was not successful
if (! $secret) {
  print "nohost Host $q_hostname does not exist in database!\n";
  exit 1;
}

# Check secret
if ($secret ne $q_secret) {
  print "badauth Hostname secret mismatch!\n";
  exit 1;
}

my @args;
push(@args, $q_hostname);
push(@args, $q_ip) if ($q_ip);

# see http://stackoverflow.com/a/15687293
sub dns_functor {
  # Send DynDNS update
  system("$dyn_update", @args);
}
silently(\&dns_functor);

if ($? == -1) {
  print "911 Error calling the update script ($dyn_update): $!\n";
} elsif ($? & 127) {
  printf "911 child died with signal %d, %s coredump\n",
    ($? & 127), ($? & 128) ? 'with' : 'without';
} elsif ($? == 1) {
  print "911 internal error, invalid arguments to update script\n";
} elsif ($? == 2) {
  print "dnserr error on calling nsupdate!\n";
} else {
  # Everything is fine, send the result
  print "good";
  print " $q_ip" if ($q_ip);
  print "\n";
  exit 0;
}


#something went wrong if we get here
exit 1;



### Fertig :)
