package DominiosGov::Model::Consultas;
use Mojo::Base -base;

has 'mysql';

sub get_teste {
	my ($self) = @_;
	my $sql = 'SELECT * FROM NicHandles';
	my $nics = $self->mysql->db->query($sql)->arrays;
	return $nics;
}

sub get_dominios_by_ticket_greater_20000{
	my ($self) = @_;
	my $sql = 'SELECT domain as dominios FROM Dominios WHERE ticket > 20000 LIMIT 100;';
	my $dominios = $self->mysql->db->query($sql)->arrays;
	return $dominios;
}

sub get_empresas_com_fax{
	my ($self) = @_;
	my $sql = "SELECT e.nome as Empresa, t.ddd as DDD, t.numero as Número FROM Ents_Resps e FULL OUTER JOIN Telefones t ON t.documento=e.documento WHERE t.tipo='Fax' LIMIT 100;";
	my $empresas = $self->mysql->db->query($sql)->arrays;
	return $empresas;
}

sub get_empresas_ordered_by_num_admins{
	my ($self) = @_;
	my $sql = 'SELECT e.nome as Empresa, COUNT(DISTINCT f.nic_hdl_br) as Num_Func FROM Ents_Resps e INNER JOIN Funcionario f ON e.documento=f.documento GROUP BY nome ORDER BY Num_Func LIMIT 100;';
	my $empresas = $self->mysql->db->query($sql)->arrays;
	return $empresas;
}

sub get_dominios_e_dns{
	my ($self) = @_;
	my $sql = 'SELECT ticket, dominio, nameserver FROM Dominios INNER JOIN (SELECT ap.domain as dominio, ns.nserver nameserver FROM Aponta ap INNER JOIN Nservers ns ON ns.nserver=ap.nserver) as nomes ON nomes.dominio=Dominios.domain LIMIT 100;';
	my $dominios = $self->mysql->db->query($sql)->arrays;
	return $dominios;
}

sub get_docs_criados_entre_2014_2015{
	my ($self) = @_;
	my $sql = "(SELECT documento FROM Dominios WHERE data_cadastro like '2015%') UNION (SELECT documento FROM Dominios WHERE data_cadastro like '2014%') LIMIT 100;";
	my $documentos = $self->mysql->db->query($sql)->arrays;
	return $documentos;
}

sub get_qtd_dominios_mesma_empresa{
	my ($self) = @_;
	my $sql = 'SELECT e.nome, COUNT(DISTINCT d.domain) as qnt_dominios FROM Ents_Resps e INNER JOIN Dominios d ON e.documento=d.documento GROUP BY nome LIMIT 100;';
	my $dominios = $self->mysql->db->query($sql)->arrays;
	return $dominios;
}

sub get_resps_mais_de_2_dominios{
	my ($self) = @_;
	my $sql = 'SELECT p.person as nome, count(d.domain) as qnt_dominios FROM NicHandles p INNER JOIN Papel d ON p.nic_hdl_br=d.nic_hdl_br GROUP BY p.person HAVING count(d.domain) > 2 LIMIT 100;';
	my $nomes = $self->mysql->db->query($sql)->arrays;
	return $nomes;
}

sub get_datas_mais_infos{
	my ($self) = @_;
	my $sql = 'SELECT * FROM Dominios LEFT OUTER JOIN Papel ON Papel.domain=Dominios.domain UNION ALL SELECT * FROM Dominios RIGHT OUTER JOIN Papel ON Papel.domain=Dominios.domain WHERE Dominios.domain=Papel.domain LIMIT 100;';
	my $nomes = $self->mysql->db->query($sql)->arrays;
	return $nomes;
}

sub get_funcionarios_empresas{
	my ($self) = @_;
	my $sql = 'SELECT DISTINCT p.person, aux.nome FROM NicHandles p INNER JOIN (SELECT f.nic_hdl_br, e.nome FROM Funcionario f INNER JOIN Ents_Resps e ON e.documento=f.documento) as aux ON p.nic_hdl_br=aux.nic_hdl_br LIMIT 100;';
	my $nomes = $self->mysql->db->query($sql)->arrays;
	return $nomes;
}

sub get_empresas_no_rio{
	my ($self) = @_;
	my $sql = "SELECT nome, documento FROM Ents_Resps WHERE id_cidade in (SELECT id_cidade FROM Cidades WHERE id_estado in (SELECT id_estado FROM Estados WHERE sigla like 'RJ')) LIMIT 100;";
	my $nomes = $self->mysql->db->query($sql)->arrays;
	return $nomes;
}

sub get_dominios_atualizados_entre_2010_e_2015{
	my ($self) = @_;
	my $sql = "SELECT domain FROM Aponta WHERE nserver in (SELECT nserver FROM Nservers WHERE nslastaa BETWEEN '2009-12-31' AND '2016-01-01') LIMIT 100;";
	my $nomes = $self->mysql->db->query($sql)->arrays;
	return $nomes;
}

sub get_medias_e_totais{
	my ($self) = @_;
	my $sql = 'SELECT avg(T.qnt_dominios) as media_empresa, sum(T.qnt_dominios) as total_dominios FROM (  SELECT e.nome, COUNT(DISTINCT d.domain) as qnt_dominios FROM Ents_Resps e INNER JOIN Dominios d ON e.documento=d.documento GROUP BY nome) as T LIMIT 100;';
	my $dominios = $self->mysql->db->query($sql)->arrays;
	return $dominios;
}

sub get_estados_qtd_empresas{
	my ($self) = @_;
	my $sql = 'SELECT T.estado as estados, COUNT(e.nome) as qnt_empresas, T.bandeira FROM Ents_Resps e INNER JOIN (SELECT id_cidade, estado, bandeira FROM Cidades INNER JOIN Estados ON Estados.id_estado=Cidades.id_estado) as T ON T.id_cidade=e.id_cidade GROUP BY estados ORDER BY qnt_empresas DESC LIMIT 100;';
	my $dominios = $self->mysql->db->query($sql)->arrays;
	return $dominios;
}

1;
