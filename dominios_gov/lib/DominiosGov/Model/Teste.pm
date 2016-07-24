package DominiosGov::Model::Teste;
use Mojo::Base -base;

has 'mysql';

sub get_teste {
	my ($self) = @_;
	my $sql = 'SELECT * FROM NicHandles';
	my $nics = $self->pg->db->query($sql)->arrays;
	return $nics;
}

1;
