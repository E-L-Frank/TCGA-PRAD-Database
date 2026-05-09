SET FOREIGN_KEY_CHECKS = 0;

-- 1. Patient
INSERT IGNORE INTO Patient (
    TCGA_Patient_ID,
    Sex,
    Genetic_Ancestry_Label
)
SELECT DISTINCT
    TCGA_Patient_ID,
    Sex,
    Genetic_Ancestry_Label
FROM staging_table_01
WHERE TCGA_Patient_ID IS NOT NULL;


-- 2. Cancer_Incidence
INSERT INTO Cancer_Incidence (
    Patient_Age,
    TCGA_Patient_ID,
    TNM_Node_Stage,
    Prior_DX,
    Radiation_Therapy,
    New_Tumor_Post_Treatment,
    Cancer_Type,
    Cancer_Type_Detailed,
    Cancer_Type_Acronym,
    Disease_Code_ICD,
    Overall_Survival_Status,
    Overall_Survival_Months,
    Disease_Free_Status_Months
)
SELECT DISTINCT
    d2.Patient_Age,
    d2.TCGA_Patient_ID,
    d2.TNM_Node_Stage,
    d2.Prior_DX,
    d2.Radiation_Therapy,
    d2.New_Tumor_Post_Treatment,
    d3.Cancer_Type,
    d3.Cancer_Type_Detailed,
    d2.Cancer_Type_Acronym,
    d2.Disease_Code_ICD,
    d2.Overall_Survival_Status,
    d2.Overall_Survival_Months,
    d2.Disease_Free_Status_Months
FROM staging_table_01 d2
LEFT JOIN staging_table_02 d3
    ON d2.TCGA_Patient_ID = d3.TCGA_Patient_ID
WHERE d2.TCGA_Patient_ID IS NOT NULL;


-- 3. Tumor_Sample
INSERT IGNORE INTO Tumor_Sample (
    TCGA_Sample_ID,
    Tumor_Type,
    Tumor_Tissue_Site,
    Tumor_Mutational_Burden,
    Tumor_Site_ICD_O_3_Code,
    Tumor_Histology_ICD_O_3_Code,
    TNM_Tumor_Stage,
    Cancer_Incidence_ID,
    NCBI_Build
)
SELECT DISTINCT
    d3.TCGA_Sample_ID,
    d3.Tumor_Type,
    d3.Tumor_Tissue_Site,
    d3.Tumor_Mutational_Burden,
    d2.Tumor_Site_ICD_O_3_Code,
    d2.Tumor_Histology_ICD_O_3_Code,
    d2.TNM_Tumor_Stage,
    ci.Cancer_Incidence_ID,
    d19.NCBI_Build
FROM staging_table_02 d3
LEFT JOIN staging_table_01 d2
    ON d3.TCGA_Patient_ID = d2.TCGA_Patient_ID
LEFT JOIN Cancer_Incidence ci
    ON ci.TCGA_Patient_ID = d3.TCGA_Patient_ID
LEFT JOIN staging_table_03 d19
    ON d3.TCGA_Sample_ID = d19.TCGA_Sample_ID
WHERE d3.TCGA_Sample_ID IS NOT NULL;


-- 4. Gene
INSERT INTO Gene (
    Ensembl_Gene_ID,
    Hugo_Symbol,
    Entrez_Gene_ID
)
SELECT DISTINCT
    Ensembl_Gene_ID,
    Hugo_Symbol,
    Entrez_Gene_ID
FROM staging_table_03
WHERE Ensembl_Gene_ID IS NOT NULL
   OR Hugo_Symbol IS NOT NULL
   OR Entrez_Gene_ID IS NOT NULL;


-- 5. Protein
INSERT INTO Protein (
    Ensembl_Protein_ID,
    SwissProt_ID,
    Trembl_ID,
    Gene_ID,
    Transcript_ID
)
SELECT DISTINCT
    d19.Ensembl_Protein_ID,
    d19.SwissProt_ID,
    SUBSTRING_INDEX(d19.Trembl_ID, ',', 1) AS Trembl_ID,
    g.Gene_ID,
    d19.Transcript_ID
FROM staging_table_03 d19
LEFT JOIN Gene g
    ON g.Ensembl_Gene_ID <=> d19.Ensembl_Gene_ID
   AND g.Hugo_Symbol <=> d19.Hugo_Symbol
   AND g.Entrez_Gene_ID <=> d19.Entrez_Gene_ID
WHERE d19.Ensembl_Protein_ID IS NOT NULL
   OR d19.SwissProt_ID IS NOT NULL
   OR d19.Trembl_ID IS NOT NULL
   OR d19.Transcript_ID IS NOT NULL;


-- 6. Mutation_Event
INSERT INTO Mutation_Event (
    TCGA_Sample_ID,
    Start_Position,
    End_Position,
    Chromosome,
    Strand,
    Variant_Type,
    Variant_Classification,
    Reference_Allele,
    Match_Norm_Sample_Allele1,
    Match_Norm_Sample_Allele2,
    Tumor_Seq_Allele1,
    Tumor_Seq_Allele2,
    Allele,
    Consensus_Coding_Sequence,
    Exon_Number,
    Distance_to_feature,
    Biotype,
    dbSNP_rsID,
    Functional_Impact,
    Intron_Number,
    HGVSc
)
SELECT
    TCGA_Sample_ID,
    Start_Position,
    End_Position,
    Chromosome,
    Strand,
    Variant_Type,
    Variant_Classification,
    Reference_Allele,
    Match_Norm_Sample_Allele1,
    Match_Norm_Sample_Allele2,
    Tumor_Seq_Allele1,
    Tumor_Seq_Allele2,
    Allele,
    Consensus_Coding_Sequence,
    Exon_Number,
    Distance_to_feature,
    Biotype,
    dbSNP_rsID,
    Functional_Impact,
    Intron_Number,
    HGVSc
FROM staging_table_03;


-- 7. Consequence
INSERT INTO Consequence (
    Consequence
)
SELECT DISTINCT
    Consequence
FROM staging_table_03
WHERE Consequence IS NOT NULL;


-- 8. Mutation_Consequence
INSERT INTO Mutation_Consequence (
    Consequence_ID,
    Mutation_Event_ID
)
SELECT DISTINCT
    c.Consequence_ID,
    me.Mutation_Event_ID
FROM staging_table_03 d19
JOIN Consequence c
    ON c.Consequence = d19.Consequence
JOIN Mutation_Event me
    ON me.Start_Position <=> d19.Start_Position
   AND me.End_Position <=> d19.End_Position
   AND me.Chromosome <=> d19.Chromosome
   AND me.Strand <=> d19.Strand
   AND me.Variant_Type <=> d19.Variant_Type
   AND me.Variant_Classification <=> d19.Variant_Classification
   AND me.Reference_Allele <=> d19.Reference_Allele
   AND me.Tumor_Seq_Allele1 <=> d19.Tumor_Seq_Allele1
   AND me.Tumor_Seq_Allele2 <=> d19.Tumor_Seq_Allele2;


-- 9. Mutation_Gene
INSERT INTO Mutation_Gene (
    Gene_ID,
    Mutation_Event_ID
)
SELECT DISTINCT
    g.Gene_ID,
    me.Mutation_Event_ID
FROM staging_table_03 d19
JOIN Gene g
    ON g.Ensembl_Gene_ID <=> d19.Ensembl_Gene_ID
   AND g.Hugo_Symbol <=> d19.Hugo_Symbol
   AND g.Entrez_Gene_ID <=> d19.Entrez_Gene_ID
JOIN Mutation_Event me
    ON me.Start_Position <=> d19.Start_Position
   AND me.End_Position <=> d19.End_Position
   AND me.Chromosome <=> d19.Chromosome
   AND me.Strand <=> d19.Strand
   AND me.Variant_Type <=> d19.Variant_Type
   AND me.Variant_Classification <=> d19.Variant_Classification
   AND me.Reference_Allele <=> d19.Reference_Allele
   AND me.Tumor_Seq_Allele1 <=> d19.Tumor_Seq_Allele1
   AND me.Tumor_Seq_Allele2 <=> d19.Tumor_Seq_Allele2;


-- 10. Mutations_Samples
INSERT INTO Mutations_Samples (
    TCGA_Sample_ID,
    Mutation_Event_ID
)
SELECT DISTINCT
    me.TCGA_Sample_ID,
    me.Mutation_Event_ID
FROM Mutation_Event me
WHERE me.TCGA_Sample_ID IN (
    SELECT TCGA_Sample_ID
    FROM Tumor_Sample
);


-- 11. Mutation_Protein
INSERT INTO Mutation_Protein (
    Mutation_Event_ID,
    Protein_ID,
    HGVSp,
    Amino_Acids,
    Codon_Change,
    PolyPhen_Prediction,
    SIFT_Prediction
)
SELECT DISTINCT
    me.Mutation_Event_ID,
    p.Protein_ID,
    d19.HGVSp,
    d19.Amino_Acids,
    d19.Codon_Change,
    d19.PolyPhen_Prediction,
    d19.SIFT_Prediction
FROM staging_table_03 d19
JOIN Gene g
    ON g.Ensembl_Gene_ID <=> d19.Ensembl_Gene_ID
   AND g.Hugo_Symbol <=> d19.Hugo_Symbol
   AND g.Entrez_Gene_ID <=> d19.Entrez_Gene_ID
JOIN Protein p
    ON p.Gene_ID <=> g.Gene_ID
   AND p.Ensembl_Protein_ID <=> d19.Ensembl_Protein_ID
   AND p.SwissProt_ID <=> d19.SwissProt_ID
   AND p.Trembl_ID <=> SUBSTRING_INDEX(d19.Trembl_ID, ',', 1)
   AND p.Transcript_ID <=> d19.Transcript_ID
JOIN Mutation_Event me
    ON me.Start_Position <=> d19.Start_Position
   AND me.End_Position <=> d19.End_Position
   AND me.Chromosome <=> d19.Chromosome
   AND me.Strand <=> d19.Strand
   AND me.Variant_Type <=> d19.Variant_Type
   AND me.Variant_Classification <=> d19.Variant_Classification
   AND me.Reference_Allele <=> d19.Reference_Allele
   AND me.Tumor_Seq_Allele1 <=> d19.Tumor_Seq_Allele1
   AND me.Tumor_Seq_Allele2 <=> d19.Tumor_Seq_Allele2;


-- 12. Structural_Variant
INSERT IGNORE INTO Structural_Variant (
    Structural_Variant_ID,
    Effect_on_Frame,
    Event_Info
)
SELECT DISTINCT
    Structural_Variant_ID,
    Effect_on_Frame,
    Event_Info
FROM staging_table_04
WHERE Structural_Variant_ID IS NOT NULL;


-- 13. Structural_Variant_Sample
INSERT INTO Structural_Variant_Sample (
    TCGA_Sample_ID,
    Structural_Variant_ID
)
SELECT DISTINCT
    TCGA_Sample_ID,
    Structural_Variant_ID
FROM staging_table_04
WHERE TCGA_Sample_ID IN (
    SELECT TCGA_Sample_ID FROM Tumor_Sample
);


-- 14. Structural_Variant_Breakpoints
INSERT INTO Structural_Variant_Breakpoints (
    Structural_Variant_ID,
    Chromosome,
    Position,
    SV_Hugo_ID,
    Start_or_End
)
SELECT DISTINCT
    Structural_Variant_ID,
    Chromosome,
    Position,
    SV_Hugo_Symbol,
    Start_or_End
FROM staging_table_04
WHERE Structural_Variant_ID IS NOT NULL;


SET FOREIGN_KEY_CHECKS = 1;

ALTER TABLE Mutation_Event
DROP COLUMN TCGA_Sample_ID;

DROP TABLE IF EXISTS staging_table_01;
DROP TABLE IF EXISTS staging_table_02;
DROP TABLE IF EXISTS staging_table_03;
DROP TABLE IF EXISTS staging_table_04;