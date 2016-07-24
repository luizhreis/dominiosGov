package DominiosGov::Controller::DomsMaior2000;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use Data::Dumper;

use DominiosGov::Model::Consultas;

sub pre_gerar_consulta {
	my $self = shift;
	my $itens = $self->consultas->get_dominios_by_ticket_greater_20000($self); #$self->consultas->get_teste($self); 

	$self->stash(
		itens => $itens,
	);
}

1;