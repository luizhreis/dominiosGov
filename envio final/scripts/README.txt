// ****** Instruções para gerar a base de dados e importar os dados! ******//

1. O script de inicialização da base encontra-se nesta pasta e se chama 'criar_database_dominiosgov.sql';
2. Para importar corretamente os dados para o banco, siga a ordem de importação abaixo:

source ./scripts/popular_estados_cidades2.sql
source ./scripts/popular_nservers.sql
source ./scripts/popular_nichandles.sql
source ./scripts/popular_ents_resps.sql
source ./scripts/popular_funcionarios.sql
source ./scripts/popular_dominios.sql
source ./scripts/popular_aponta2.sql
source ./scripts/popular_papel.sql
source ./scripts/popular_telefone.sql

3. O arquivo contendo as consultas preparadas encontra-se nesta pasta e se chama 'consultas.sql'.
