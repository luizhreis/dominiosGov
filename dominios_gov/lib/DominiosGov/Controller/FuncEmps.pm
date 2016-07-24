package DominiosGov::Controller::FuncEmps;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use Data::Dumper;

use DominiosGov::Model::Consultas;

sub pre_gerar_consulta {
	my $self = shift;
	my $itens = $self->consultas->get_funcionarios_empresas($self); 

	$self->stash(
		itens => $itens,
	);
}

1;