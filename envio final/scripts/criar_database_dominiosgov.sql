CREATE TABLE Estados (
id_estado serial PRIMARY KEY,
estado varchar(128) NOT NULL,
bandeira varchar(255) NOT NULL,
sigla char(2) NOT NULL
);

CREATE TABLE Cidades(
cidade varchar(128),
id_cidade serial PRIMARY KEY,
id_estado bigint unsigned,
FOREIGN KEY(id_estado) REFERENCES Estados (id_estado) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Nservers (
nserver varchar(255) PRIMARY KEY,
nsstat date,
nslastaa date
);

CREATE TABLE NicHandles (
person varchar(128),
nic_hdl_br varchar(16) PRIMARY KEY,
changed date,
created date
);

CREATE TABLE Ents_Resps (
documento varchar(32) PRIMARY KEY,
cep char(9),
nome varchar(128),
id_cidade bigint unsigned,
FOREIGN KEY(id_cidade) REFERENCES Cidades (id_cidade) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Telefones (
tipo varchar(16),
ddd numeric(3),
numero numeric(9),
documento varchar(32),
PRIMARY KEY(ddd,numero),
FOREIGN KEY(documento) REFERENCES Ents_Resps (documento) ON UPDATE CASCADE ON DELETE CASCADE
/*falha: chave estrangeira*/
);

CREATE TABLE Funcionario (
documento varchar(32),
nic_hdl_br varchar(16),
PRIMARY KEY(documento,nic_hdl_br),
FOREIGN KEY(documento) REFERENCES Ents_Resps (documento) ON UPDATE CASCADE ON DELETE RESTRICT,
FOREIGN KEY(nic_hdl_br) REFERENCES NicHandles (nic_hdl_br) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Dominios (
data_cadastro date,
ultima_atualizacao date,
domain varchar(255) PRIMARY KEY,
ticket numeric(9),
documento varchar(32),
FOREIGN KEY(documento) REFERENCES Ents_Resps (documento) ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE TABLE Aponta (
status varchar(64),
domain varchar(255),
nserver varchar(255),
PRIMARY KEY(domain,nserver),
FOREIGN KEY(domain) REFERENCES Dominios (domain),
FOREIGN KEY(nserver) REFERENCES Nservers (nserver)
);

CREATE TABLE Papel (
tipo varchar(16),
nic_hdl_br varchar(16),
domain varchar(255),
PRIMARY KEY(tipo,nic_hdl_br,domain),
FOREIGN KEY(nic_hdl_br) REFERENCES NicHandles (nic_hdl_br) ON UPDATE CASCADE ON DELETE RESTRICT,
FOREIGN KEY(domain) REFERENCES Dominios (domain) ON UPDATE CASCADE ON DELETE CASCADE
);


