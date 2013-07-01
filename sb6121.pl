#!/usr/bin/perl
# Retrieve signal diagnostics from a Motorola Surfboard 6121 cable modem
# for use with Cacti
#
# Copy to an appropriate location, e.g. /usr/local/share/cacti/scripts/

use strict;

my %data;
my $hostname;

# Default to '192.168.100.1' if no hostname specified
if ($ARGV[0] ne '')
  {
    $hostname = $ARGV[0];
  }
else
  {
    $hostname = '192.168.100.1';
  }

my $URL='http://' . $hostname . '/cmSignalData.htm';

# Fetch data
my $body = `GET $URL`;

# Isolate Downstream data
my ($junk, $downstream) =
  split(/<TH><FONT color=#ffffff>Downstream <\/FONT><\/TH>/, $body);

# Isolate Upstream data
my ($downstream, $upstream) =
  split(/<TH><FONT color=#ffffff>Upstream <\/FONT><\/TH>/, $downstream);

# Isolate Signal Stats (Codewords) data
my ($upstream, $codewords) =
  split(/<TH><FONT color=#ffffff>Signal Stats \(Codewords\)<\/FONT><\/TH>/,
        $upstream);

# Downstream SNR
my ($junk, $down_snr) = split(/Signal to Noise Ratio<\/TD>\n<TD>/, $downstream);
($data{'down_snr_1'}, $data{'down_snr_2'}, $data{'down_snr_3'}, $down_snr) =
  split(/ dB&nbsp;<\/TD><TD>/, $down_snr);
($data{'down_snr_4'}, $down_snr) = split(/ dB&nbsp;<\/TD><\/TR>/, $down_snr);

# Downstream Power Level
my ($junk, $down_power) = split(/Power Level.*<\/TABLE><\/TD>\n<TD>/,
                                $down_snr);
 
($data{'down_power_1'}, $data{'down_power_2'}, $data{'down_power_3'},
  $down_power) =
    split(/ dBmV\n&nbsp;<\/TD><TD>/, $down_power);
($data{'down_power_4'}, $down_power) = split(/ dBmV\n&nbsp;<\/TD><\/TR>/, $down_power);

# Upstream Power Level
my ($junk, $upstream) = split(/Power Level<\/TD>\n<TD>/, $upstream);
($data{'up_power'}, $junk) = split(/ dBmV/, $upstream);

# Isolate Codewords
my ($junk, $unerrored) = split(/Total Unerrored Codewords<\/TD>\n<TD>/,
                               $codewords);
my ($unerrored, $correctable) =
  split(/Total Correctable Codewords<\/TD>\n<TD>/, $unerrored);
my ($correctable, $uncorrectable) =
  split(/Total Uncorrectable Codewords<\/TD>\n<TD>/, $correctable);

# Unerrored Codewords
($data{'unerrored_1'}, $data{'unerrored_2'}, $data{'unerrored_3'}, $unerrored) =
  split(/&nbsp;<\/TD><TD>/, $unerrored);
($data{'unerrored_4'}, $junk) =
  split(/&nbsp;/, $unerrored);

# Correctable Codewords
($data{'correctable_1'}, $data{'correctable_2'}, $data{'correctable_3'}, $correctable) =
  split(/&nbsp;<\/TD><TD>/, $correctable);
($data{'correctable_4'}, $junk) =
  split(/&nbsp;/, $correctable);

# Uncorrectable
($data{'uncorrectable_1'}, $data{'uncorrectable_2'}, $data{'uncorrectable_3'},
  $uncorrectable) =
    split(/&nbsp;<\/TD><TD>/, $uncorrectable);
($data{'uncorrectable_4'}, $junk) = split(/&nbsp;/, $uncorrectable);

# Output
my @pairs;
foreach my $key (sort keys %data)
  {
    push @pairs, "$key:$data{$key}";
  }
print join " ", @pairs;
