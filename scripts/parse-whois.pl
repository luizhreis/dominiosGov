use strict;
use warnings;

use Data::Dumper;
use Text::CSV;

opendir(my $DIR, "./whois") or die "cannot open directory";

my $file_csv = "../documentos/Dominios_GovBR_basico.csv";
open my $fh_csv, "<:encoding(utf8)", $file_csv or die "$file_csv: $!";

my $file_sql = "dominiosgov.sql";
open my $fh_sql, ">:encoding(utf8)", 'meh.txt' or die "$!";

my $csv = Text::CSV->new ({
    binary    => 1, # Allow special character. Always set this
    auto_diag => 1, # Report irregularities immediately
    sep_char  => ';' 
});

my @docs = grep(/.gov.br/,readdir($DIR));
my $dados = {};
foreach my $file (@docs) {
    open my $RES, '<:encoding(utf8)', "./whois/$file" or die "could not open $file\n";
    my ($linha, $domain, $owner, $nic, $person, $created, $changed, $dns, $ownerc, $techc, $adminc, $billingc, $status, $nsstat, $nslastaa);
    my $nics = {};
    my $nservers = {};
    my @array;
    while($linha = <$RES>){
        if ($linha =~ m/^domain:/) {
            #print "----------------------------------------------\n";
            $domain = get_domain($linha);
            #print "DOMINIO: $domain\n";
            #$nservers->{domain} = [];
        }
        if ($linha =~ m/^owner:/) {
            $owner = get_owner($linha);
            #print "OWNER: $owner\n";
            $dados->{dominios}->{$domain}->{owner} = $owner;
        }
        if ($linha =~ m/^nserver:/) {
            $dns = get_nserver($linha);
            $dados->{dominios}->{$domain}->{nservers} .= $dns .',';
            #print "NSERVER: $dns\n";
        }
        if ($linha =~ m/^nsstat:/) {
            $nsstat = get_nsstat($linha);
            $dados->{nservers}->{$dns}->{nsstat} = $nsstat;
        }
        if ($linha =~ m/^nslastaa:/) {
            $nslastaa = get_nslastaa($linha);
            $dados->{nservers}->{$dns}->{nslastaa} = $nslastaa;
        }
        if ($linha =~ m/^status:/) {
            $status = get_status($linha);
            $dados->{dominios}->{$domain}->{status} = $status;
        }
        if ($linha =~ m/^owner-c:/) {
            $ownerc = get_ownerc($linha);
            $dados->{dominios}->{$domain}->{ownerc} = $ownerc;
        }
        if ($linha =~ m/^admin-c:/) {
            $adminc = get_adminc($linha);
            $dados->{dominios}->{$domain}->{adminc} = $adminc;
        }
        if ($linha =~ m/^tech-c:/) {
            $techc = get_techc($linha);
            $dados->{dominios}->{$domain}->{techc} = $techc;
        }
        if ($linha =~ m/^billing-c:/) {
            $billingc = get_billingc($linha);
            $dados->{dominios}->{$domain}->{billingc} = $billingc;
        }
        if ($linha =~ m/^nic-hdl-br:/) {
            $nic = get_nichdl($linha);
            #print "NIC: $nic\n";
            next if (exists $dados->{nics}->{$nic});
            $person = get_person($linha) if ($linha = <$RES>);
            $created = get_created($linha) if ($linha = <$RES>);
            $changed = get_changed($linha) if ($linha = <$RES>);
            $dados->{nics}->{$nic}->{person} = $person;
            $dados->{nics}->{$nic}->{created} = $created;
            $dados->{nics}->{$nic}->{changed} = $changed;
            #print "PERSON: $person\nCREATED: $created\nCHANGED: $changed\n";
        }
    }
    $nservers->{$domain} = @array;
    @array = undef;
    #print Dumper $nservers;
    close $RES;
}

$csv->getline ($fh_csv); # skip header
while (my $row = $csv->getline ($fh_csv)) {
#    print "Dominio:  $row->[0]\tNome: $row->[2]\n";
    my $dominio = $row->[0];
    $dados->{dominios}->{$dominio}->{documento} = $row->[1];
    $dados->{dominios}->{$dominio}->{uf} = $row->[3];
    $dados->{dominios}->{$dominio}->{cidade} = $row->[4];
    $dados->{dominios}->{$dominio}->{cep} = $row->[5];

#    print $fh_sql "Dominio:  $row->[0]\tNome: $row->[2]\n";
}

print Dumper $dados;

foreach my $dominio (keys %{$dados->{dominios}}){
    print $fh_sql "Dominio:  $dominio\tNome: $dados->{dominios}->{$dominio}->{owner}\tCidade: $dados->{dominios}->{$dominio}->{cidade}\n";
    #print "$dominio\n";
}
#print Dumper $dados->{nics};
#print Dumper $dados->{nservers};
close $fh_sql;
close $fh_csv;

sub get_adminc{
    my $linha = shift;
    my $adminc = (split /:/, $linha)[1];
    $adminc =~ s/\s+//;
    $adminc =~ s/\n//;
    return $adminc;
}

sub get_billingc{
    my $linha = shift;
    my $billingc = (split /:/, $linha)[1];
    $billingc =~ s/\s+//;
    $billingc =~ s/\n//;
    return $billingc;
}

sub get_changed{
    my $linha = shift;
    my $changed = (split /:/, $linha)[1];
    $changed =~ s/\s+//;
    $changed =~ s/\n//;
    return $changed;
}

sub get_created{
    my $linha = shift;
    my $created = (split /:/, $linha)[1];
    $created =~ s/\s+//;
    $created =~ s/\n//;
    return $created;
}

sub get_domain{
    my $linha = shift;
    my $domain = (split /:/, $linha)[1];
    $domain =~ s/\s//g;
    $domain =~ s/\n//;
    return $domain;
}

sub get_nichdl{
    my $linha = shift;
    my $nic = (split /:/, $linha)[1];
    $nic =~ s/\s+//;
    $nic =~ s/\n//;
    return $nic;
}

sub get_nserver{
    my $linha = shift;
    my $dns = (split /:/, $linha)[1];
    $dns =~ s/\s//g;
    $dns =~ s/\n//;
    return $dns;
}

sub get_nslastaa{
    my $linha = shift;
    my $nslastaa = (split /:/, $linha)[1];
    $nslastaa =~ s/\s+//;
    $nslastaa =~ s/\n//;
    return $nslastaa;
}

sub get_nsstat{
    my $linha = shift;
    my $nsstat = (split /:/, $linha)[1];
    $nsstat =~ s/\s+//;
    $nsstat =~ s/\n//;
    return $nsstat;
}

sub get_owner{
    my $linha = shift;
    my $owner = (split /:/, $linha)[1];
    $owner =~ s/\s+//;
    $owner =~ s/\n//;
    return $owner;
}

sub get_ownerc{
    my $linha = shift;
    my $ownerc = (split /:/, $linha)[1];
    $ownerc =~ s/\s+//;
    $ownerc =~ s/\n//;
    return $ownerc;
}

sub get_person{
    my $linha = shift;
    my $person = (split /:/, $linha)[1];
    $person =~ s/\s+//;
    $person =~ s/\n//;
    return $person;
}

sub get_status{
    my $linha = shift;
    my $status = (split /:/, $linha)[1];
    $status =~ s/\s+//;
    $status =~ s/\n//;
    return $status;
}

sub get_techc{
    my $linha = shift;
    my $techc = (split /:/, $linha)[1];
    $techc =~ s/\s+//;
    $techc =~ s/\n//;
    return $techc;
}
