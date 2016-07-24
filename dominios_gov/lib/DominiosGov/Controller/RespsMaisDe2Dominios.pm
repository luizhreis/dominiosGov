package DominiosGov::Controller::RespsMaisDe2Dominios;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use Data::Dumper;

use DominiosGov::Model::Consultas;

sub pre_gerar_consulta {
	my $self = shift;
	my $itens = $self->consultas->get_resps_mais_de_2_dominios($self); 

	$self->stash(
		itens => $itens,
	);
}

1;