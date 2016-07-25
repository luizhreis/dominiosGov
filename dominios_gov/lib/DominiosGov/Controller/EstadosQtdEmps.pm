package DominiosGov::Controller::EstadosQtdEmps;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use DominiosGov::Model::Consultas;

sub pre_gerar_consulta {
	my $self = shift;
	my $itens = $self->consultas->get_estados_qtd_empresas($self); 

	$self->stash(
		itens => $itens,
	);
}

1;