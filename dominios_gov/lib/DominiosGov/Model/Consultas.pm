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
	my $sql = 'SELECT domain as dominios FROM Dominios WHERE ticket > 20000;';
	my $dominios = $self->mysql->db->query($sql)->arrays;
	return $dominios;
}

sub get_empresas_com_fax{
	my ($self) = @_;
	my $sql = "SELECT e.nome as Empresa, t.ddd as DDD, t.numero as Número FROM Ents_Resps e FULL OUTER JOIN Telefones t ON t.documento=e.documento WHERE t.tipo='Fax';";
	my $empresas = $self->mysql->db->query($sql)->arrays;
	return $empresas;
}

sub get_empresas_ordered_by_num_admins{
	my ($self) = @_;
	my $sql = 'SELECT e.nome as Empresa, COUNT(DISTINCT f.nic_hdl_br) as Num_Func FROM Ents_Resps e INNER JOIN Funcionario f ON e.documento=f.documento GROUP BY nome ORDER BY Num_Func;';
	my $empresas = $self->mysql->db->query($sql)->arrays;
	return $empresas;
}

sub get_dominios_e_dns{
	my ($self) = @_;
	my $sql = 'SELECT ticket, dominio, nameserver FROM Dominios INNER JOIN (SELECT ap.domain as dominio, ns.nserver nameserver FROM Aponta ap INNER JOIN Nservers ns ON ns.nserver=ap.nserver) as nomes ON nomes.dominio=Dominios.domain;';
	my $dominios = $self->mysql->db->query($sql)->arrays;
	return $dominios;
}

sub get_docs_criados_entre_2014_2015{
	my ($self) = @_;
	my $sql = "(SELECT documento FROM Dominios WHERE data_cadastro like '2015%') UNION (SELECT documento FROM Dominios WHERE data_cadastro like '2014%');";
	my $documentos = $self->mysql->db->query($sql)->arrays;
	return $documentos;
}

sub get_qtd_dominios_mesma_empresa{
	my ($self) = @_;
	my $sql = 'SELECT e.nome, COUNT(DISTINCT d.domain) as qnt_dominios FROM Ents_Resps e INNER JOIN Dominios d ON e.documento=d.documento GROUP BY nome;';
	my $dominios = $self->mysql->db->query($sql)->arrays;
	return $dominios;
}

sub get_resps_mais_de_2_dominios{
	my ($self) = @_;
	my $sql = 'SELECT p.person as nome, count(d.domain) as qnt_dominios FROM NicHandles p INNER JOIN Papel d ON p.nic_hdl_br=d.nic_hdl_br GROUP BY p.person HAVING count(d.domain) > 2;';
	my $nomes = $self->mysql->db->query($sql)->arrays;
	return $nomes;
}

1;
