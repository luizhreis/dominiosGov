package DominiosGov::Controller::DomsAtualizados20102015;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use Data::Dumper;

use DominiosGov::Model::Consultas;

sub pre_gerar_consulta {
	my $self = shift;
	my $itens = $self->consultas->get_dominios_atualizados_entre_2010_e_2015($self); 

	$self->stash(
		itens => $itens,
	);
}

1;