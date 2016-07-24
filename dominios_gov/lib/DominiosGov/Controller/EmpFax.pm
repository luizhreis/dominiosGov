package DominiosGov::Controller::EmpFax;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;

use Data::Dumper;

use DominiosGov::Model::Consultas;

sub pre_gerar_consulta {
	my $self = shift;
	my $itens = $self->consultas->get_empresas_com_fax($self); 

	print Dumper $self;
	print Dumper $itens;
	$self->stash(
		itens => $itens,
	);
}

1;