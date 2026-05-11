-- get SQL version
SELECT VERSION();

-- Create the database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS TCGA_PRAD
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Switch to the new database
USE TCGA_PRAD;

-- Create staging tables
CREATE TABLE staging_table_01 (
    Tumor_Site_ICD_O_3_Code VARCHAR(10),
    Tumor_Histology_ICD_O_3_Code CHAR(10),
    TNM_Tumor_Stage CHAR(5),
    TCGA_Patient_ID CHAR(12),
    Sex CHAR(4),
    Genetic_Ancestry_Label VARCHAR(9),
    Patient_Age TINYINT UNSIGNED,
    TNM_Node_Stage VARCHAR(3),
    Prior_DX VARCHAR(55),
    Radiation_Therapy VARCHAR(3),
    New_Tumor_Post_Treatment VARCHAR(3),
    Cancer_Type_Acronym VARCHAR(10),
    Disease_Code_ICD CHAR(10),
    Overall_Survival_Status CHAR(15),
    Overall_Survival_Months DECIMAL(10,2),
    Disease_Free_Status_Months DECIMAL(10,2)

);

CREATE TABLE staging_table_02 (
    TCGA_Patient_ID CHAR(12),
    Cancer_Type VARCHAR(100),
    Cancer_Type_Detailed VARCHAR(255),
    TCGA_Sample_ID VARCHAR(20),
    Tumor_Type VARCHAR(50),
    Tumor_Tissue_Site VARCHAR(100),
    Tumor_Mutational_Burden DECIMAL(10,2)
);

CREATE TABLE staging_table_03 (
    TCGA_Sample_ID VARCHAR(20),
    NCBI_Build VARCHAR(10),
    Consequence VARCHAR(102),
    Ensembl_Gene_ID VARCHAR(15),
    Hugo_Symbol VARCHAR(15),
    Entrez_Gene_ID DECIMAL(15, 6),
    Ensembl_Protein_ID VARCHAR(15),
    SwissProt_ID VARCHAR(65),
    Trembl_ID VARCHAR(30),
    Transcript_ID CHAR(15),
    HGVSp VARCHAR(34),
    Amino_Acids VARCHAR(14),
    Codon_Change VARCHAR(39),
    PolyPhen_Prediction VARCHAR(24),
    SIFT_Prediction VARCHAR(32),
    Start_Position BIGINT,
    End_Position BIGINT,
    Chromosome VARCHAR(2),
    Strand VARCHAR(2),
    Variant_Type VARCHAR(3),
    Variant_Classification VARCHAR(22),
    Reference_Allele VARCHAR(1290),
    Match_Norm_Sample_Allele1 VARCHAR(1290),
    Match_Norm_Sample_Allele2 VARCHAR(1290),
    Tumor_Seq_Allele1 VARCHAR(1290),
    Tumor_Seq_Allele2 VARCHAR(18),
    Allele VARCHAR(18),
    Consensus_Coding_Sequence VARCHAR(11),
    Exon_Number VARCHAR(7),
    Distance_to_feature VARCHAR(4),
    Biotype VARCHAR(34),
    dbSNP_rsID VARCHAR(23),
    Functional_Impact VARCHAR(8),
    Intron_Number VARCHAR(7),
    HGVSc VARCHAR(50)
);

CREATE TABLE staging_table_04 (
    Structural_Variant_ID INT,
    TCGA_Sample_ID VarChar(20),
    SV_Hugo_Symbol VarChar(50),
    Effect_on_Frame VARCHAR(10),
    Chromosome CHAR(2),
    Position BIGINT,
    Start_or_End CHAR(5),
    Event_Info VARCHAR(26)
);

