package DominiosGov::Controller::EstadosQtdEmps;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use Data::Dumper;

use DominiosGov::Model::Relatorios;

sub pre_gerar_consulta {
	my $self = shift;
	my $itens = $self->relatorios->get_estados_qtd_empresas($self); 

	$self->stash(
		itens => $itens,
	);
}

1;