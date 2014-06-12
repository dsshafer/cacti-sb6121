#!/usr/bin/perl
# Retrieve signal diagnostics from a Motorola Surfboard 6120/6121 cable modem
# for use with Cacti
#
# Copy to an appropriate location, e.g. /usr/local/share/cacti/scripts/

use strict;
use Getopt::Std;

my %data;
my $body;
my $hostname;
my %opts;

getopt('fh', \%opts);

if ($opts{'f'}) {
  open FILE, "<" . $opts{'f'};
  $body = do { local $/; <FILE> };
}
else {
  if ($opts{'h'}) {
    $hostname = $opts{'h'};
  }
  else {
    $hostname = '192.168.100.1';
  }

  my $URL='http://' . $hostname . '/cmSignalData.htm';
  $body = `GET -t 10 $URL`;
}

# Parse Downstream data
if ($body =~ /<CENTER>.*<FONT color=#ffffff>Downstream <\/FONT>(.*?)<\/CENTER>/s) {
  my $downstream = $1;

  # Downstream Signal to Noise Ratios
  if ($downstream =~ /<TR><TD>Signal to Noise Ratio<\/TD>(.*?)<\/TR>/s) {
    my $downstream_snr = $1;

    my $i = 0;
    while ($downstream_snr =~ /<TD>([0-9]+) dB&nbsp;<\/TD>/g) {
      $i++;
      $data{'downstream_snr_' . $i} = $1;
    }
    die "Didn't find at least one channel" unless ($i > 0);
  }
  else {
    die "Didn't find downstream signal to noise ratios";
  }

  # Downstream Power Levels
  if ($downstream =~ /<TR><TD>Power Level.*?<\/TR>(.*?)<\/TR>/s) {
    my $downstream_power = $1;
    print "downstream_power = \"$downstream_power\"";
    my $i = 0;
    while ($downstream_power =~ /<TD>(-?[0-9]+) dBmV\n&nbsp;<\/TD>/gs) {
      $i++;
      $data{'downstream_power_' . $i} = $1;
    }
    die "Didn't find at least one channel" unless ($i > 0);
  }
  else {
    die "Didn't find downstream power levels";
  }

}
else {
  die "Didn't find downstream data";
}


# Parse Upstream data
if ($body =~ /<CENTER>.*<FONT color=#ffffff>Upstream <\/FONT>(.*?)<\/CENTER>/s) {
  my $upstream = $1;

  # Upstream Power Levels
  if ($upstream =~ /<TR><TD>Power Level(.*?)<\/TR>/s) {
    my $upstream_power = $1;
    my $i = 0;
    while ($upstream_power =~ /<TD>([0-9]+) dBmV&nbsp;<\/TD>/gs) {
      $i++;
      $data{'upstream_power_' . $i} = $1;
    }
    die "Didn't find at least one channel" unless ($i > 0);
  }
  else {
    die "Didn't find upstream power levels";
  }

}
else {
  die "Didn't find upstream data";
}


# Parse Signal Stats (Codewords)
if ($body =~ /<CENTER>.*<FONT color=#ffffff>Signal Stats \(Codewords\)<\/FONT>(.*?)<\/CENTER>/s) {
  my $signal_stats = $1;

  # Total Unerrored Codewords
  if ($signal_stats =~ /<TR><TD>Total Unerrored Codewords<\/TD>(.*?)<\/TR>/s) {
    my $unerrored_codewords = $1;
    my $i = 0;
    while ($unerrored_codewords =~ /<TD>([0-9]+)&nbsp;<\/TD>/gs) {
      $i++;
      $data{'unerrored_codewords_' . $i} = $1;
    }
    die "Didn't find at least one channel" unless ($i > 0);
  }
  else {
    die "Didn't find unerrored codeword counters";
  }

  # Total Correctable Codewords
  if ($signal_stats =~ /<TR><TD>Total Correctable Codewords<\/TD>(.*?)<\/TR>/s) {
    my $correctable_codewords = $1;
    my $i = 0;
    while ($correctable_codewords =~ /<TD>([0-9]+)&nbsp;<\/TD>/gs) {
      $i++;
      $data{'correctable_codewords_' . $i} = $1;
    }
    die "Didn't find at least one channel" unless ($i > 0);
  }
  else {
    die "Didn't find correctable codeword counters";
  }

  # Total Uncorrectable Codewords
  if ($signal_stats =~ /<TR><TD>Total Uncorrectable Codewords<\/TD>(.*?)<\/TR>/s) {
    my $uncorrectable_codewords = $1;
    my $i = 0;
    while ($uncorrectable_codewords =~ /<TD>([0-9]+)&nbsp;<\/TD>/gs) {
      $i++;
      $data{'uncorrectable_codewords_' . $i} = $1;
    }
    die "Didn't find at least one channel" unless ($i > 0);
  }
  else {
    die "Didn't find uncorrectable codeword counters";
  }
}
else {
  die "Didn't find signal stats";
}


# Output
my @pairs;
foreach my $key (sort keys %data)
  {
    push @pairs, "$key:$data{$key}";
  }
print join " ", @pairs;
