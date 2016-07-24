package DominiosGov;
use Mojo::Base 'Mojolicious';
use Mojo::mysql;

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');
    $self->plugin('bootstrap3');
    $self->plugin('BootstrapHelpers');
    $self->plugin('ConsoleLogger'); 

    $self->secrets(['LeYTmFPhw3q', 'QrPTZhWJmqCjyGZmguK']);

    # Model
    $self->helper(mysql => sub { state $mysql = Mojo::mysql->new('mysql://root:luiz5481@/dominiosgov') });
    $self->helper(consultas => sub { state $consultas = DominiosGov::Model::Consultas->new(mysql => shift->mysql) });

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/')->to('home#home');
	$r->get('/consultas')->to('consultas#consultas');
	$r->get('/relatorios')->to('relatorios#relatorios');

	$r->get('/consultas/domsmaior20000')->to('DomsMaior20000#pre_gerar_consulta', template => 'consultas/domsmaior20000');
	$r->get('/consultas/empordadmin')->to('EmpOrdAdmin#pre_gerar_consulta', template => 'consultas/empordadmin');
	$r->get('/consultas/empfax')->to('EmpFax#pre_gerar_consulta', template => 'consultas/empfax');
	$r->get('/consultas/domsdns')->to('DomsDns#pre_gerar_consulta', template => 'consultas/domsdns');
	$r->get('/consultas/docscriados20142015')->to('DocsCriados20142015#pre_gerar_consulta', template => 'consultas/docscriados20142015');
	$r->get('/consultas/qtddomsmesmaemp')->to('QtdDomsMesmaEmp#pre_gerar_consulta', template => 'consultas/qtddomsmesmaemp');
	$r->get('/consultas/respsmaisde2dominios')->to('RespsMaisDe2Dominios#pre_gerar_consulta', template => 'consultas/respsmaisde2dominios');
}

1;
