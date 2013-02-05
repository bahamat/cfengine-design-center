#!/usr/bin/perl

BEGIN
{
 if (-l $0)
 {
  require FindBin;
  $0 = readlink $0;
  FindBin->again();
 }
}

use File::Basename;
use FindBin;
use lib "$FindBin::Bin/perl-lib", "$FindBin::Bin/perl-lib/File-Which-1.09/lib", "$FindBin::Bin/perl-lib/JSON-2.53/lib";

use warnings;
use strict;
use DCAPI;
use Util;

$| = 1;                         # autoflush

my $base = basename($0);
my @log;
my $api = DCAPI->new();

unless ($api->curl())
{
 $api->exit_error("$base: could not locate `curl' executable in $ENV{PATH}");
}

my $config_file = shift @ARGV;

unless ($config_file)
{
 $api->exit_error("Syntax: $base CONFIG_FILE [SERVICE_URL]");
}

my ($loaded, @errors) = $api->set_config($config_file);

unless ($loaded)
{
 $api->exit_error("$base could not load $config_file: [@errors]");
}

if (scalar @errors)
{
 $api->exit_error("$base startup errors", @errors);
}

my $data = $api->load(join '', <>);
my $debug = Util::hashref_search($data, qw/debug/);
my $version = Util::hashref_search($data, qw/dc-api-version/);
my $request = Util::hashref_search($data, qw/request/);
my $list = Util::hashref_search($request, qw/list/);
my $search = Util::hashref_search($request, qw/search/);

if ($debug)
{
 push @log, $api->data_dump();
}

unless (defined $version && $version eq $api->version())
{
 $api->exit_error("DC API Version not provided or mismatch " . $api->version(), @log);
}

unless (defined $request)
{
 $api->exit_error("No request provided.", @log);
}

if (defined $list)
{
 $api->exit_error("list not implemented yet", @log);
 # api_ok({ data => { list => [] }});
}
elsif (defined $search)
{
 $api->exit_error("search not implemented yet", @log);
 # api_ok({ data => { search => [] }});
}
else
{
 push @log, "Nothing to do, but we're OK, thanks for asking.";
 $api->ok({ log => \@log,
            data => {} });
}

exit 0;
