/*Consulta 1 (Simples): Selecionar o nome de todos os domínios cujos valores de ticket são maiores que 20000.*/
SELECT domain as dominios
FROM Dominios
WHERE ticket > 20000;

/*Consulta 2 (Junção 2 tabelas): Ordenar, de forma decrescente, as empresas que possuem o maior número de funcionarios como administradores de domínios.*/
SELECT e.nome as Empresa, COUNT(DISTINCT f.nic_hdl_br) as Num_Func
FROM Ents_Resps e INNER JOIN Funcionario f ON e.documento=f.documento
GROUP BY nome
ORDER BY Num_Func DESC;

/*Consulta 3 (Junção 2 tabelas com junção externa): Selecionar as datas de criação e alteração dos domínios, seus endereços, o documento da empresa responsável e o papel exercido pelos funcionários, bem como suas siglas.*/
SELECT * FROM Dominios LEFT OUTER JOIN Papel ON Papel.domain=Dominios.domain
UNION ALL
SELECT * FROM Dominios RIGHT OUTER JOIN Papel ON Papel.domain=Dominios.domain
WHERE Dominios.domain=Papel.domain;

/*Consulta 4 (Junção 3 tabelas): Selecionar o nome dos funcionários e a empresa na qual ele possui ligação.*/
SELECT DISTINCT p.person, aux.nome
FROM NicHandles p INNER JOIN (SELECT f.nic_hdl_br, e.nome FROM Funcionario f INNER JOIN Ents_Resps e ON e.documento=f.documento) as aux ON p.nic_hdl_br=aux.nic_hdl_br;


/*Consulta 5 (Junção 3 tabelas): Selecionar os nomes e os tickets dos domínios e o nome de seus respectivos nameservers.*/
SELECT ticket, dominio, nameserver
FROM Dominios INNER JOIN 
(SELECT ap.domain as dominio, ns.nserver nameserver FROM Aponta ap INNER JOIN Nservers ns ON ns.nserver=ap.nserver) as nomes 
ON nomes.dominio=Dominios.domain;

/*Consulta 6 (Conjuntos): Selecionar o número de documento das empresas responsáveis por domínios criados durante os anos 2014 e 2015.*/
(SELECT documento FROM Dominios WHERE data_cadastro like '2015%')
UNION
 (SELECT documento FROM Dominios WHERE data_cadastro like '2014%') ;

/*Consulta 7 (Agregação): Selecionar a quantidade de domínios sob responsabilidade de uma mesma empresa.*/
SELECT e.nome, COUNT(DISTINCT d.domain) as qnt_dominios
FROM Ents_Resps e INNER JOIN Dominios d ON e.documento=d.documento
GROUP BY nome;

/*Consulta 8 (Agregação): Selecionar o nome das pessoas (person) que são responsáveis por mais de 2 domínios diferentes, em qualquer tipo de papel.*/
SELECT p.person as nome, count(d.domain) as qnt_dominios
FROM NicHandles p INNER JOIN Papel d ON p.nic_hdl_br=d.nic_hdl_br
GROUP BY p.person
HAVING count(d.domain) > 2;

/*Consulta 9 (Consulta Aninhada): Selecionar o nome e o docmento das empresas que estão sediadas no Rio de Janeiro*/
SELECT nome, documento
FROM Ents_Resps
WHERE id_cidade in (SELECT id_cidade FROM Cidades WHERE id_estado in (SELECT id_estado FROM Estados WHERE sigla like 'RJ'));

/*Consulta 10 (Consulta Aninhada): Selecionar os domínios cujos nameservers foram atualizados pela ultima vez entre 2010 e 2015*/
SELECT domain
FROM Aponta
WHERE nserver in (SELECT nserver FROM Nservers WHERE nslastaa BETWEEN '2009-12-31' AND '2016-01-01');

/*Consulta 11 (Relatório): Média de domínios por empresa e Total de domínios existentes*/
SELECT avg(T.qnt_dominios) as media_empresa, sum(T.qnt_dominios) as total_dominios
FROM (  SELECT e.nome, COUNT(DISTINCT d.domain) as qnt_dominios
	FROM Ents_Resps e INNER JOIN Dominios d ON e.documento=d.documento
	GROUP BY nome) as T;

/*Consulta 12 (Relatório): Estados ordenados pela quantidade de empresas responsáveis por domínios*/
SELECT T.estado as estados, COUNT(e.nome) as qnt_empresas, T.bandeira
FROM Ents_Resps e INNER JOIN (SELECT id_cidade, estado, bandeira FROM Cidades INNER JOIN Estados ON Estados.id_estado=Cidades.id_estado) as T ON T.id_cidade=e.id_cidade
GROUP BY estados
ORDER BY qnt_empresas DESC;




