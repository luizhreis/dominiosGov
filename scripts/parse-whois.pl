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
    $dados->{dominios}->{$dominio}->{cidade} = uc($row->[4]);
    $dados->{dominios}->{$dominio}->{cep} = $row->[5];
    $dados->{dominios}->{$dominio}->{data_cadastro} = $row->[6];
    $dados->{dominios}->{$dominio}->{ultima_atualizacao} = $row->[7];
    $dados->{dominios}->{$dominio}->{ticket} = $row->[8];

#    print $fh_sql "Dominio:  $row->[0]\tNome: $row->[2]\n";
}
close $fh_csv;

#print Dumper $dados;

#gerar_inserts_nservers($dados);
#gerar_inserts_nics($dados);
#gerar_inserts_ents_resps($dados);
#gerar_inserts_funcionarios($dados);
#gerar_inserts_dominios($dados);
#gerar_inserts_aponta($dados);
gerar_inserts_papel($dados);

# foreach my $dominio (keys %{$dados->{dominios}}){
#     print $fh_sql "Dominio:  $dominio\tNome: $dados->{dominios}->{$dominio}->{owner}\tCidade: $dados->{dominios}->{$dominio}->{cidade}\n";
#     #print "$dominio\n";
# }
#print Dumper $dados->{nics};
#print Dumper $dados->{nservers};
close $fh_sql;

sub gerar_inserts_aponta{
    my $dados = shift;
    my $file_sql = "popular_aponta.sql";
    open my $fh_sql, ">:encoding(utf8)", $file_sql or die "$!";
    foreach my $dominio (keys %{$dados->{dominios}}){
        foreach my $dns ( split /,/, $dados->{dominios}->{$dominio}->{nservers} ){
            my $status = $dados->{dominios}->{$dominio}->{status};
            print $fh_sql "INSERT INTO Aponta (domain, nserver, status) VALUES ('". $dominio ."', '". $dns ."', '". $status ."');\n";
        }
    }
    close $fh_sql;
}

sub gerar_inserts_dominios{
    my $dados = shift;
    my $file_sql = "popular_dominios.sql";
    open my $fh_sql, ">:encoding(utf8)", $file_sql or die "$!";
    foreach my $dominio (keys %{$dados->{dominios}}){
        my $data_cadastro = $dados->{dominios}->{$dominio}->{data_cadastro};
        my $ultima_atualizacao = $dados->{dominios}->{$dominio}->{ultima_atualizacao};
        my $ticket = $dados->{dominios}->{$dominio}->{ticket};
        my $documento = $dados->{dominios}->{$dominio}->{documento};
        print $fh_sql "INSERT INTO Dominios (domain, data_cadastro, ultima_atualizacao, ticket, documento) VALUES ('". $dominio ."', '". $data_cadastro ."', '". $ultima_atualizacao ."', '". $ticket ."', '". $documento ."');\n";
    }
    close $fh_sql;
}

sub gerar_inserts_ents_resps{
    my $dados = shift;
    my $file_sql = "popular_ents_resps.sql";
    open my $fh_sql, ">:encoding(utf8)", $file_sql or die "$!";
    foreach my $dominio (keys %{$dados->{dominios}}){
        my $documento = $dados->{dominios}->{$dominio}->{documento};
        my $cep = $dados->{dominios}->{$dominio}->{cep};
        my $nome = $dados->{dominios}->{$dominio}->{owner};
        my $cidade = $dados->{dominios}->{$dominio}->{cidade};
        my $uf = $dados->{dominios}->{$dominio}->{uf};
        print $fh_sql "INSERT INTO Ents_Resps (documento, cep, nome, id_cidade) VALUES ('". $documento ."', '". $cep ."', '". $nome ."', (SELECT id_cidade FROM Cidades NATURAL JOIN Estados WHERE cidade LIKE '". $cidade ."' AND sigla like '". $uf ."' ));\n";
    }
    close $fh_sql;
}

sub gerar_inserts_funcionarios{
    my $dados = shift;
    my $file_sql = "popular_funcionarios.sql";
    open my $fh_sql, ">:encoding(utf8)", $file_sql or die "$!";
    foreach my $dominio (keys %{$dados->{dominios}}){
        my $documento = $dados->{dominios}->{$dominio}->{documento};
        my $ownerc = $dados->{dominios}->{$dominio}->{ownerc};
        my $adminc = $dados->{dominios}->{$dominio}->{adminc};
        my $techc = $dados->{dominios}->{$dominio}->{techc};
        my $billingc = $dados->{dominios}->{$dominio}->{billingc};
        print $fh_sql "INSERT INTO Funcionarios (documento, nic_hdl_br) VALUES ('". $documento ."', '". $ownerc ."');\n";
        print $fh_sql "INSERT INTO Funcionarios (documento, nic_hdl_br) VALUES ('". $documento ."', '". $adminc ."');\n";
        print $fh_sql "INSERT INTO Funcionarios (documento, nic_hdl_br) VALUES ('". $documento ."', '". $techc ."');\n";
        print $fh_sql "INSERT INTO Funcionarios (documento, nic_hdl_br) VALUES ('". $documento ."', '". $billingc ."');\n";
    }
    close $fh_sql;
}

sub gerar_inserts_nics{
    my $dados = shift;
    my $file_sql = "popular_nichandles.sql";
    open my $fh_sql, ">:encoding(utf8)", $file_sql or die "$!";
    foreach my $nic (keys %{$dados->{nics}}){
        print $fh_sql "INSERT INTO NicHandles (nic_hdl_br, person, created, changed) VALUES ('". $nic ."', '". $dados->{nics}->{$nic}->{person} ."', '". $dados->{nics}->{$nic}->{created} ."', '". $dados->{nics}->{$nic}->{changed} ."');\n";
    }
    close $fh_sql;
}

sub gerar_inserts_nservers{
    my $dados = shift;
    my $file_sql = "popular_nservers.sql";
    open my $fh_sql, ">:encoding(utf8)", $file_sql or die "$!";
    foreach my $nserver (keys %{$dados->{nservers}}){
        print $fh_sql "INSERT INTO Nservers (nserver, nsstat, nslastaa) VALUES ('". $nserver ."', '". $dados->{nservers}->{$nserver}->{nsstat} ."', '". $dados->{nservers}->{$nserver}->{nslastaa} ."');\n";
        #print $fh_sql "Dominio:  $dominio\tNome: $dados->{dominios}->{$dominio}->{owner}\tCidade: $dados->{dominios}->{$dominio}->{cidade}\n";
        #print "$dominio\n";
    }
    close $fh_sql;
}

sub gerar_inserts_papel{
    my $dados = shift;
    my $file_sql = "popular_papel.sql";
    open my $fh_sql, ">:encoding(utf8)", $file_sql or die "$!";
    foreach my $dominio (keys %{$dados->{dominios}}){
        my $ownerc = $dados->{dominios}->{$dominio}->{ownerc};
        my $adminc = $dados->{dominios}->{$dominio}->{adminc};
        my $techc = $dados->{dominios}->{$dominio}->{techc};
        my $billingc = $dados->{dominios}->{$dominio}->{billingc};
        print $fh_sql "INSERT INTO Papel (domain, nic_hdl_br, tipo) VALUES ('". $dominio ."', '". $ownerc ."', 'owner-c');\n";
        print $fh_sql "INSERT INTO Papel (domain, nic_hdl_br, tipo) VALUES ('". $dominio ."', '". $adminc ."', 'admin-c');\n";
        print $fh_sql "INSERT INTO Papel (domain, nic_hdl_br, tipo) VALUES ('". $dominio ."', '". $techc ."', 'tech-c');\n";
        print $fh_sql "INSERT INTO Papel (domain, nic_hdl_br, tipo) VALUES ('". $dominio ."', '". $billingc ."', 'billing-c');\n";
    }
    close $fh_sql;
}

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
    $nsstat =~ s/[[:alpha:]]//g;
    $nsstat =~ s/\s//g;
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
