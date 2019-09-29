drop Database if exists diseaseGenomics;
Create Database diseaseGenomics;
use diseaseGenomics;

-- to represent an organism
create table organisms (
    genus						varchar(30)		not null,	
	species 					varchar(30)		unique			not null,
    common_name					varchar(30)		primary key,
    chromosome_count			int				not null,
    average_life_span_days		int				not null
); 

-- to represent a gene
create table genes (
	organism		varchar(30)	,
	gene_id			VARCHAR(30)			primary key,
    locus			char(30) 			not null,
    chromosome		int 				not null,
    size_inBP		int,
    
    constraint genes_fk_organism foreign key (organism) references organisms(common_name) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- to represent a organ
create table organs (
    organName			varchar(30) 		primary key, 
    link 				varchar(300)
);

-- to represent a protein
create table proteins (
	protein_id					int					primary key,
    organ						varchar(30) ,
    gene						VARCHAR(30),
	size_In_AA					int					not null,
    name						VARCHAR(200),
    
    constraint proteins_fk_gene foreign key (gene) references genes(gene_id) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint proteins_fk_organ foreign key (organ) references organs (organName) ON DELETE CASCADE ON UPDATE CASCADE
);

-- to represent diseases
create table diseases (
    name			char(30) 	primary key,
    -- https web link to further resources
    link		varchar(200)
    );
    
-- to associate organisms with having certain organs
create table organism_organs (
	organism				VARCHAR(30),
    organ					varchar(30) ,
    
    constraint organism_organs_fk_organism foreign key (organism) 
    references organisms(common_name) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint organism_organs_fk_organ foreign key (organ)
    references organs(organName) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint organism_organs_pk primary key(organism, organ)
);

-- to associate organisms with having certain diseases
create table organism_diseases (
	disease 		CHAR(30),
    organism		CHAR(30),
    
    constraint organism_diseases_pk primary key(disease, organism),
    constraint organism_diseases_fk_disease foreign key (disease) references diseases(name) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint organism_diseases_fk_organism foreign key (organism) references organisms(common_name) ON DELETE CASCADE ON UPDATE CASCADE
);

-- to associate certain genes with certain diseases
create table disease_causing_genes (
	gene			VARCHAR(30),
    disease	        CHAR(30),
    
    constraint disease_mutations_pk primary key(disease, gene),
    constraint disease_mutations_fk_disease foreign key (disease) references diseases(name) ON DELETE RESTRICT ON UPDATE CASCADE,
	constraint disease_mutations_fk_mutation foreign key (gene) references genes(gene_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
    
-- ** Procedure definitions ** 
/* READ PROCEDURES */ 

-- to see all the information in a given table 
DROP procedure if exists see_table ;
DELIMITER $$
CREATE PROCEDURE 
see_table(IN input VARCHAR(30))
  BEGIN 
  SET @t1 =CONCAT('SELECT * FROM ',input);
  PREPARE stmt2 FROM @t1;
  EXECUTE stmt2;
  DEALLOCATE PREPARE stmt2;
  END $$
  DELIMITER ;
  
-- to see all the values in a column of a given table.  
DROP procedure if exists see_table_field ;
DELIMITER $$
CREATE PROCEDURE 
see_table_field(IN fieldName VARCHAR(30) , IN tableName VARCHAR(30))
  BEGIN 
  SET @t1 =CONCAT('SELECT ', fieldName, ' FROM ', tableName);
  PREPARE stmt2 FROM @t1;
  EXECUTE stmt2;
  DEALLOCATE PREPARE stmt2;
  END $$
  DELIMITER ;
  
-- to return the information of organisms with a chromosome count over the given number. 
drop procedure if exists chromosome_over;  
DELIMITER $$
CREATE PROCEDURE 
chromosome_over(IN val INT)
	BEGIN
    select * from organisms where val < chromosome_count;
    END $$
    DELIMITER ;
    

-- to return the information of organisms with a lifespan under the given number. 
drop procedure if exists days_under;  
DELIMITER $$
CREATE PROCEDURE 
days_under(IN val INT)
	BEGIN
    select * from organisms where val > average_life_span_days;
    END $$
    DELIMITER ;
    

-- to return the name and size of the largest gene in basepairs stored in the database.
drop procedure if exists max_gene;  
DELIMITER $$
CREATE PROCEDURE 
max_gene()
	BEGIN
    select gene_id, size_inBP from genes where size_inBP = (select max(size_inBP) from genes);
    END $$
    DELIMITER ;
    
-- to return the name and size of the smallest gene in basepairs stored in the database.
drop procedure if exists min_gene;  
DELIMITER $$
CREATE PROCEDURE 
min_gene()
	BEGIN
    select gene_id, size_inBP from genes where size_inBP = (select min(size_inBP) from genes);
    END $$
    DELIMITER ;
    
-- returns total number of basepairs stored for the given organism
DROP procedure if exists BP_stored;
DELIMITER //
CREATE procedure BP_stored( IN organismX varchar(30))
BEGIN
	select sum(size_inBP) AS base_pairs  from genes where organism = organismX;
    END //
    DELIMITER ; 
    
-- to return the genes stored for a given organism
DROP procedure if exists organism_genes;
DELIMITER //
create procedure organism_genes(IN givenOrganism varchar(30))
BEGIN 
	select gene_id, locus, chromosome, size_inBP from genes where organism = givenOrganism;
    END //
    DELIMITER ;
    
/* END OF READ PROCEDURES */ 

/* CREATE PROCEDURES */    
-- to add an organism to the organisms table
DROP procedure if exists addToOrganisms;
DELIMITER // 
create procedure addToOrganisms(IN genusADD VARCHAR(30), IN speciesADD VARCHAR(30),
								IN common_nameADD VARCHAR(30), IN chrmsm int,
                                IN avgLife int)
BEGIN                                 
INSERT INTO organisms(genus, species, common_name, chromosome_count, average_life_span)
VALUES (genusADD, speciesADD, common_nameADD, chrmsm, avgLife);
END //
DELIMITER ;


-- to add a gene to the genes table.    
DROP procedure if exists addToGenes;
DELIMITER // 
create procedure addToGenes(IN organismADD VARCHAR(30), IN geneIdADD VARCHAR(30),
	IN locusADD CHAR(30), IN chrAdd int, IN sizeBPAdd int)
    BEGIN
    INSERT INTO genes(organism, gene_id,locus,chromosome, size_inBP)
    VALUES (organismADD, geneIdADD, locusADD, chrADD, sizeBPAdd);
    END //
    DELIMITER ;
    
-- to add a disease to the diseases table. 
DROP procedure if exists addToDiseases;
DELIMITER //
create procedure addToDiseases(IN diseaseNameAdd VARCHAR(30), IN linkADD VARCHAR(200))
BEGIN 
INSERT INTO diseases(name, link)
VALUES (diseaseNameAdd, linkADD);
END // 
DELIMITER ;
/* END OF CREATE PROCEDURES */

/* DELETE PROCEDURES */
-- to drop a row from the given table with the given conditions 
DROP procedure if exists drop_row;
DELIMITER $$
CREATE PROCEDURE
drop_row(IN tName VARCHAR(30), IN identifier VARCHAR(30), IN val VARCHAR(30))
BEGIN 
SET @variable = val;
SET @t3 = CONCAT('DELETE FROM ', tName, ' where ', identifier, '= ? ');
prepare stmt3 FROM @t3;
EXECUTE stmt3 using @variable;
DEALLOCATE PREPARE stmt3;
END $$
DELIMITER ; 
/* END OF DELETE PROCEDURES */

/* UPDATE PROCEDURES */
-- to modify a row in the proteins table.
DROP procedure if exists modify_proteins_row;
DELIMITER $$
CREATE PROCEDURE
modify_proteins_row(IN val VARCHAR(30),
IN prot_idMod INT , IN organMOD VARCHAR(30), IN geneMOD VARCHAR(30), IN sizeMOD int, IN nameMod VARCHAR(200))
BEGIN 
SET @Nid = prot_idMod;
SET @Norg = organMod;
SET @Ngene = geneMOD;
SET @Nsize = sizeMOD;
SET @Nname = nameMOD;
SET @variable = val;
SET @t3 = CONCAT('UPDATE proteins ' , 'SET protein_id = ? ,', 'organ = ? ,', 'gene = ? ,', 'size_In_AA = ? ,',
					'name = ? ' , 'WHERE protein_id = ?');
prepare stmt4 from @t3;
EXECUTE stmt4 using @Nid, @Norg, @Ngene, @Nsize, @Nname, @variable;
DEALLOCATE PREPARE stmt4;
END $$
DELIMITER ; 
-- test:
-- call modify_proteins_row('5', 200, "Lung", "aceH", 123123, "wack_shit"); 

-- to modify a row in the organism_diseases table
DROP PROCEDURE IF EXISTS modify_orgDis_row;
DELIMITER $$ 
CREATE PROCEDURE
modify_orgDis_row(IN oldOName VARCHAR(30), IN oldDi VARCHAR(200), IN newOName VARCHAR(30), IN newDi VARCHAR(200))
BEGIN
SET @oldOrg = oldOName;
SET @oldD = oldDi;
SET @newOrg = newOName;
SET @newD = newDi;
SET @t3 = CONCAT('UPDATE organism_diseases ' , 'SET disease = ? ,', 'organism = ? ', 'WHERE disease = ? and organism = ? ');
prepare stmt5 from @t3;
EXECUTE stmt5 using @newD, @newOrg, @oldD, @oldOrg;
DEALLOCATE PREPARE stmt5;
END $$
DELIMITER ; 
-- test:
-- call modify_orgDis_row('Fruit_Fly', 'Diamond_Blackfan_Anaemia', 'Mouse', 'ABCD_Disorder');

-- to modify a row in the organism_organs table
DROP PROCEDURE IF EXISTS modify_orgOrgs_row;
DELIMITER $$ 
CREATE PROCEDURE
modify_orgOrgs_row(IN oldCreature VARCHAR(30), IN oldO VARCHAR(30), 
					IN newCreature VARCHAR(30), IN newO VARCHAR(30))
BEGIN
SET @oldCre = oldCreature;
SET @oldOrg = oldO;
SET @newCre = newCreature;
SET @newOrg = newO;
SET @t4 = CONCAT('UPDATE organism_organs ' , 'SET organism = ? ,', 'organ = ? ', 'WHERE organism = ? and organ = ? ');
prepare stmt6 from @t4;
EXECUTE stmt6 using @newCre, @newOrg, @oldCre, @oldOrg;
DEALLOCATE PREPARE stmt6;
END $$
DELIMITER ; 
-- test:
-- call modify_orgOrgs_row('African_clawed_frog', 'Brain', 'African_clawed_frog', 'Hand');
/* END OF UPDATE PROCEDURES */

