package DominiosGov::Controller::Teste;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use Data::Dumper;

use DominiosGov::Model::Consultas;

sub pre_gerar_consulta {
	my $self = shift;
	my $nics = $self->consultas->get_teste($self);

	$self->stash(
		nics => $nics,
	);
}

1;