package DominiosGov::Controller::EmpOrdAdmin;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use Data::Dumper;

use DominiosGov::Model::Consultas;

sub pre_gerar_consulta {
	my $self = shift;
	my $itens = $self->consultas->get_empresas_ordered_by_num_admins($self); #$self->consultas->get_teste($self);

	print Dumper $self;
	print Dumper $itens;
	$self->stash(
		itens => $itens,
	);
}

1;