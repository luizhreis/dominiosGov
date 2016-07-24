package DominiosGov::Controller::DocsCriados20142015;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use Data::Dumper;

use DominiosGov::Model::Consultas;

sub pre_gerar_consulta {
	my $self = shift;
	my $itens = $self->consultas->get_docs_criados_entre_2014_2015($self); 

	$self->stash(
		itens => $itens,
	);
}

1;