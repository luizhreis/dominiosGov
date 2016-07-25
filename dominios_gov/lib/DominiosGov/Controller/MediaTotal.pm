package DominiosGov::Controller::MediaTotal;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use Data::Dumper;

use DominiosGov::Model::Consultas;

sub pre_gerar_consulta {
	my $self = shift;
	my $itens = $self->relatorios->get_medias_e_totais($self); 

	$self->stash(
		itens => $itens,
	);
}

1;