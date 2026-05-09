-- Create Tables
CREATE TABLE Patient (
    TCGA_Patient_ID CHAR(12) PRIMARY KEY,
    Sex CHAR(4),
    Genetic_Ancestry_Label VARCHAR(9)
);

CREATE TABLE Cancer_Incidence (
    Cancer_Incidence_ID INT AUTO_INCREMENT PRIMARY KEY,
    Patient_Age TINYINT UNSIGNED,
    TCGA_Patient_ID CHAR(12) NOT NULL,
    TNM_Node_Stage VARCHAR(3),
    Prior_DX VARCHAR(55),
    Radiation_Therapy VARCHAR(3),
    New_Tumor_Post_Treatment VARCHAR(3),
    Cancer_Type VARCHAR(100),
    Cancer_Type_Detailed VARCHAR(255),
    Cancer_Type_Acronym VARCHAR(10),
    Disease_Code_ICD CHAR(10),
    Overall_Survival_Status CHAR(15),
    Overall_Survival_Months DECIMAL(10,2),
    Disease_Free_Status_Months DECIMAL(10,2),
    FOREIGN KEY (TCGA_Patient_ID) REFERENCES Patient(TCGA_Patient_ID)
);

CREATE TABLE Tumor_Sample (
    TCGA_Sample_ID VARCHAR(20) PRIMARY KEY,
    Tumor_Type VARCHAR(50),
    Tumor_Tissue_Site VARCHAR(100),
    Tumor_Mutational_Burden DECIMAL(10,2),
    Tumor_Site_ICD_O_3_Code VARCHAR(10),
    Tumor_Histology_ICD_O_3_Code CHAR(10),
    TNM_Tumor_Stage CHAR(5),
    Cancer_Incidence_ID INT,
    NCBI_Build VARCHAR(10),
    FOREIGN KEY (Cancer_Incidence_ID) REFERENCES Cancer_Incidence(Cancer_Incidence_ID)
);

CREATE TABLE Mutation_Event (
    Mutation_Event_ID INT AUTO_INCREMENT PRIMARY KEY,
    TCGA_Sample_ID VARCHAR(20), -- including this at start to ensure this is UNIQUE in case multiple have exact same mutation events
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

CREATE TABLE Consequence (
    Consequence_ID INT AUTO_INCREMENT PRIMARY KEY,
    Consequence VARCHAR(102)
);

CREATE TABLE Mutation_Consequence (
    Mutation_Consequence_ID INT AUTO_INCREMENT PRIMARY KEY,
    Consequence_ID INT,
    Mutation_Event_ID INT,
    FOREIGN KEY (Consequence_ID) REFERENCES Consequence(Consequence_ID),
    FOREIGN KEY (Mutation_Event_ID) REFERENCES Mutation_Event(Mutation_Event_ID)
);

CREATE TABLE Structural_Variant (
    Structural_Variant_ID INT PRIMARY KEY,
    Effect_on_Frame VARCHAR(10),
    Event_Info VARCHAR(26)
);

CREATE TABLE Structural_Variant_Sample (
    SV_Sample_ID INT AUTO_INCREMENT PRIMARY KEY,
    TCGA_Sample_ID VARCHAR(20),
    Structural_Variant_ID INT,
    FOREIGN KEY (TCGA_Sample_ID) REFERENCES Tumor_Sample(TCGA_Sample_ID),
    FOREIGN KEY (Structural_Variant_ID) REFERENCES Structural_Variant(Structural_Variant_ID)
);

CREATE TABLE Gene (
    Gene_ID INT AUTO_INCREMENT PRIMARY KEY,
    Ensembl_Gene_ID VARCHAR(15),
    Hugo_Symbol VARCHAR(15),
    Entrez_Gene_ID DECIMAL(15, 6)
);

CREATE TABLE Structural_Variant_Breakpoints (
    Breakpoint_ID INT AUTO_INCREMENT PRIMARY KEY,
    Structural_Variant_ID INT,
    Chromosome CHAR(2),
    Position BIGINT,
    SV_Hugo_ID VARCHAR(15),
    Start_or_End CHAR(5),
    FOREIGN KEY (Structural_Variant_ID) REFERENCES Structural_Variant(Structural_Variant_ID)
);

CREATE TABLE Mutation_Gene (
    Mutation_Gene_ID INT AUTO_INCREMENT PRIMARY KEY,
    Gene_ID INT,
    Mutation_Event_ID INT,
    FOREIGN KEY (Gene_ID) REFERENCES Gene(Gene_ID),
    FOREIGN KEY (Mutation_Event_ID) REFERENCES Mutation_Event(Mutation_Event_ID)
);

CREATE TABLE Mutations_Samples (
    Mutation_Sample_ID INT AUTO_INCREMENT PRIMARY KEY,
    TCGA_Sample_ID VARCHAR(20),
    Mutation_Event_ID INT,
    FOREIGN KEY (TCGA_Sample_ID) REFERENCES Tumor_Sample(TCGA_Sample_ID),
    FOREIGN KEY (Mutation_Event_ID) REFERENCES Mutation_Event(Mutation_Event_ID)
);

CREATE TABLE Protein (
    Protein_ID INT AUTO_INCREMENT PRIMARY KEY,
    Ensembl_Protein_ID VARCHAR(15),
    SwissProt_ID VARCHAR(65),
    Trembl_ID VARCHAR(30),
    Gene_ID INT,
    Transcript_ID CHAR(15),
    FOREIGN KEY (Gene_ID) REFERENCES Gene(Gene_ID)
);

CREATE TABLE Mutation_Protein (
    Mutation_Protein_ID INT AUTO_INCREMENT PRIMARY KEY,
    Mutation_Event_ID INT,
    Protein_ID INT,
    HGVSp VARCHAR(34),
    Amino_Acids VARCHAR(14),
    Codon_Change VARCHAR(39),
    PolyPhen_Prediction VARCHAR(24),
    SIFT_Prediction VARCHAR(32),
    FOREIGN KEY (Protein_ID) REFERENCES Protein(Protein_ID),
    FOREIGN KEY (Mutation_Event_ID) REFERENCES Mutation_Event(Mutation_Event_ID)
);