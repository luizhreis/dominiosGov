#!/usr/bin/perl

  use strict;
  use warnings;
  use Text::CSV;
  #use Text::CSV::Encoded;

  my $file_csv = "Dominios_GovBR_basico.csv";
  open my $fh_csv, "<:encoding(utf8)", $file_csv or die "$file_csv: $!";
  open my $fh_sql, ">:encoding(utf8)", 'meh.txt' or die "$!";

  my $csv = Text::CSV->new ({
      binary    => 1, # Allow special character. Always set this
      auto_diag => 1, # Report irregularities immediately
      sep_char  => ';' 
      });

  # while (my $row = $csv->getline ($fh)) {
  #     print "@$row\n";
  #     }

  $csv->getline ($fh_csv); # skip header
  while (my $row = $csv->getline ($fh_csv)) {
      print "Dominio:  $row->[0]\tNome: $row->[2]\n";
      print $fh_sql "Dominio:  $row->[0]\tNome: $row->[2]\n";
      }
  
# $csv->column_names ($csv->getline ($fh)); # use header
# while (my $row = $csv->getline_hr ($fh)) {
#  printf "Dominio: %s\nNome: %s\n", $row->{dominio}, $row->{nome};
# }
close $fh;