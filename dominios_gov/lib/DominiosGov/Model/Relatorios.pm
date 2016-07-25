package DominiosGov::Model::Relatorios;
use Mojo::Base -base;

has 'mysql';

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
