# Table of Contents

- [Data Dictionary by File](#data-dictionary-by-file)
  - [FILE: 01_data_clinical_patient.txt](#file-01_data_clinical_patienttxt)
  - [FILE: 02_data_clinical_sample.txt](#file-02_data_clinical_sampletxt)
  - [FILE: 03_data_mutations.txt](#file-03_data_mutationstxt)
  - [FILE: 04_data_sv.txt](#file-04_data_svtxt)

- [Database Dictionary by Table](#database-dictionary-by-table)
  - [Table: Patient](#table-patient)
  - [Table: Cancer_Incidence](#table-cancer_incidence)
  - [Table: Tumor_Sample](#table-tumor_sample)
  - [Table: Mutation_Event](#table-mutation_event)
  - [Table: Gene](#table-gene)
  - [Table: Protein](#table-protein)
  - [Table: Mutation_Protein](#table-mutation_protein)
  - [Table: Consequence](#table-consequence)
  - [Table: Structural_Variant](#table-structural_variant)
  - [Table: Structural_Variant_Breakpoints](#table-structural_variant_breakpoints)
  - [Table: Structural_Variant_Sample](#table-structural_variant_sample)


# Data Dictionary by File

Each column I used during data clean-up or chose, organized by its original file, a brief description of the data within, the table it is in within the database, and the data type. :contentReference[oaicite:0]{index=0}

## FILE: 01_data_clinical_patient.txt

============================================================

**Description of file:** clinical and demographic data about each patient in the study.

| Database Column Name | Original column name | Data Description | Database Table | Data Type |
|---|---|---|---|---|
| TCGA_Patient_ID | PATIENT_ID | Unique identifier assigned to each patient; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | Patient / Cancer_Incidence | CHAR(12) |
| Cancer_Type_Acronym | CANCER_TYPE_ACRONYM | Abbreviation for cancer type of interest | Cancer_Incidence | VARCHAR(10) |
| Patient_Age | AGE | Age of patient at the time they joined the study | Cancer_Incidence | TINYINT UNSIGNED |
| Sex | SEX | Biological sex of patient | Patient | CHAR(4) |
| Disease_Code_ICD | ICD_10 | Diagnosis code from the International Classification of Diseases, 10th Revision, describing disease | Cancer_Incidence | CHAR(10) |
| Tumor_Histology_ICD_O_3_Code | ICD_O_3_HISTOLOGY | Histology classification code from the International Classification of Diseases for Oncology, 3rd Edition, describing tumor cell type and morphology | Tumor_Sample | CHAR(10) |
| Tumor_Site_ICD_O_3_Code | ICD_O_3_SITE | Anatomical site code from the International Classification of Diseases for Oncology, 3rd Edition, indicating the primary location of the tumor in the body | Tumor_Sample | VARCHAR(10) |
| New_Tumor_Post_Treament | NEW_TUMOR_EVENT_AFTER_INITIAL_TREATMENT | If the patient developed an additional tumor after treatment. | Cancer_Incidence | VARCHAR(3) |
| TNM_Node_Stage | PATH_N_STAGE | Describes the extent of cancer spread to nearby lymph nodes, part of the TNM Classification of Malignant Tumors staging system. | Cancer_Incidence | VARCHAR(3) |
| TNM_Tumor_Stage | PATH_T_STAGE | Describes the size/extent of the primary tumor, part of the TNM Classification of Malignant Tumors staging system. | Tumor_Sample | CHAR(5) |
| Prior_DX | PRIOR_DX | If the patient had a prior diagnosis of cancer. | Cancer_Incidence | VARCHAR(55) |
| Radiation_Therapy | RADIATION_THERAPY | If the patient had radiation therapy as part of treatment. | Cancer_Incidence | VARCHAR(3) |
| Overall_Survival_Status | OS_STATUS | If the patient was alive or deceased at last follow-up appointment. | Cancer_Incidence | CHAR(15) |
| Overall_Survival_Months | OS_MONTHS | Survival time, in months, of the patient from time of study enrollment until last follow-up appointment or death. | Cancer_Incidence | DECIMAL(10,2) |
| Disease_Free_Status_Months | DFS_MONTHS | Months spent disease-free following treatment. | Cancer_Incidence | DECIMAL(10,2) |
| Genetic_Ancestry_Label | GENETIC_ANCESTRY_LABEL | Genetic ancestry classification inferred from genomic data. | Patient | VARCHAR(9) |

## FILE: 02_data_clinical_sample.txt

============================================================

Description of file: clinical information about each sample collected by the study.

| Database Column Name | Original column name | Data Description | Database Table | Data Type |
|---|---|---|---|---|
| TCGA_Sample_ID | SAMPLE_ID | Unique identifier assigned to each sample; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | Tumor_Sample (Primary Key) | VARCHAR(20) |
| TCGA_Patient_ID | PATIENT_ID | Unique identifier assigned to each patient; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | Patient / Cancer_Incidence | CHAR(12) |
| Cancer_Type | CANCER_TYPE | Broad classification of the sample’s cancer type | Cancer_Incidence | VARCHAR(100) |
| Cancer_Type_Detailed | CANCER_TYPE_DETAILED | Detailed classification of the sample’s cancer type | Cancer_Incidence | VARCHAR(255) |
| Tumor_Type | TUMOR_TYPE | Type of tissue sampled, such as tumor or normal | Tumor_Sample | VARCHAR(50) |
| Tumor_Tissue_Site | TUMOR_TISSUE_SITE | Anatomical location from which the sample was taken | Tumor_Sample | VARCHAR(100) |
| Tumor_Mutational_Burden | TMB_NONSYNONYMOUS | Number of non-synonymous mutations within coding regions found within DNA sequencing of the tumor | Tumor_Sample | DECIMAL(10,2) |

## FILE: 03_data_mutations.txt

============================================================

**Description of file:** information about mutations found within each TCGA sample; additionally, information about any corresponding proteins.

| Database Column Name | Original column name | Data Description | Database Table | Data Type |
|---|---|---|---|---|
| Transcript_ID | Transcript_ID | Ensembl unique transcript ID within which the mutation is located | Protein | CHAR(15) |
| Hugo_Symbol | Hugo_Symbol | Gene symbol for gene impacted by mutation; assigned by the HUGO Gene Nomenclature Committee | Gene | VARCHAR(15) |
| Entrez_Gene_ID | Entrez_Gene_Id | Numeric gene identifier from the NCBI Entrez Gene database | Gene | DECIMAL(15, 6) |
| NCBI_Build | NCBI_Build | Reference genome version used. | Tumor_Sample | VARCHAR(10) |
| HGVSp | HGVSp | Protein-level mutation description using HGVS nomenclature | Mutation_Protein | VARCHAR(34) |
| Amino_Acids | Amino_acids | Amino acid change caused by mutation | Mutation_Protein | VARCHAR(14) |
| Chromosome | Chromosome | Chromosome where the mutation occurred | Mutation_Event | VARCHAR(2) |
| Start_Position | Start_Position | Genomic coordinate where the mutation begins | Mutation_Event | BIGINT |
| End_Position | End_Position | Genomic coordinate where the mutation ends | Mutation_Event | BIGINT |
| Strand | Strand | DNA strand orientation for the mutation | Mutation_Event | VARCHAR(2) |
| Consequence | Consequence | Variant type caused by the mutation | Consequence | VARCHAR(102) |
| Variant_Classification | Variant_Classification | Type of mutation | Mutation_Event | VARCHAR(22) |
| Variant_Type | Variant_Type | Structural change caused by mutation | Mutation_Event | VARCHAR(3) |
| Reference_Allele | Reference_Allele | Nucleotide/s in the reference genome found at the same location as the mutation | Mutation_Event | VARCHAR(1290) |
| Tumor_Seq_Allele1 | Tumor_Seq_Allele1 | First allele observed in tumor sequencing data | Mutation_Event | VARCHAR(1290) |
| Tumor_Seq_Allele2 | Tumor_Seq_Allele2 | Second allele observed in the tumor sequencing data. | Mutation_Event | VARCHAR(18) |
| TCGA_Sample_ID | Tumor_Sample_Barcode | Unique identifier assigned to each sample; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | Mutation_Event / Tumor_Sample | VARCHAR(20) |
| Match_Norm_Sample_Allele1 | Match_Norm_Seq_Allele1 | First allele observed in the matched normal sample | Mutation_Event | VARCHAR(1290) |
| Match_Norm_Sample_Allele2 | Match_Norm_Seq_Allele2 | Second allele observed in the matched normal sample | Mutation_Event | VARCHAR(1290) |
| HGVSc | HGVSc | Coding DNA-level mutation description using HGVS nomenclature | Mutation_Event | VARCHAR(50) |
| HGVSp | HGVSp | Protein mutation description using HGVS nomenclature | Mutation_Protein | VARCHAR(39) |
| Codon_Change | Codons | Reference and altered codon sequence caused by mutation | Mutation_Event | VARCHAR(18) |
| Allele | Allele | Alternate allele associated with mutation | Mutation_Event | VARCHAR(34) |
| Biotype | BIOTYPE | Functional transcript type | Mutation_Event | VARCHAR(11) |
| Consensus_Coding_Sequence | CCDS | Unique identifier for the Consensus Coding Sequence (CCDS) database transcript corresponding with that of the mutation | Mutation_Event | VARCHAR(4) |
| Distance_to_feature | DISTANCE | Distance from mutation to nearest annotated genomic feature | Protein | VARCHAR(15) |
| Ensembl_Protien_ID | ENSP | Ensembl protein identifier associated with the affected transcript | Mutation_Event | VARCHAR(23) |
| dbSNP_rsID | dbSNP_RS | dbSNP reference SNP ID (rsID) associated with the variant | Mutation_Event | VARCHAR(7) |
| Exon_Number | Exon_Number | Exon of the gene in which the mutation occurred | Not found in provided SQL | N/A |
| Ensembl_Gene_ID | Gene | Ensembl gene identifier associated with the affected transcript | Mutation_Event | VARCHAR(8) |
| Functional_Impact | IMPACT | Predicted impact on the gene/protein | Mutation_Event | VARCHAR(7) |
| Intron_Number | INTRON | Intron of the gene in which the mutation occurred | Mutation_Protein | VARCHAR(24) |
| PolyPhen_Prediction | PolyPhen | Predicted severity of the mutation’s functional impact | Mutation_Protein | VARCHAR(32) |
| SIFT_Prediction | SIFT | Predicts severity of impact on the associated protein, based on any amino acid substitution caused by mutation | Protein | VARCHAR(65) |
| SwissProt_ID | SWISSPROT | UniProt/Swiss-Prot protein database accession associated with the gene or transcript | Protein | VARCHAR(30) |
| Trembl_ID | TREMBL | UniProt/TrEMBL protein database accession associated with the gene or transcript | Protein | VARCHAR(30) |
| * Used for data cleaning | DBVS | Variant quality/annotation flags | * Used for data cleaning | * Used for data cleaning |
| * Used for data cleaning | FILTER | Quality control decision made by the variant calling pipeline | * Used for data cleaning | * Used for data cleaning |

## FILE: 04_data_sv.txt

============================================================

**Description of file:** information about structural variants found within samples; focuses on DNA.

| Database_Column Name | Original column name | Data Description | Database Table | Data Type |
|---|---|---|---|---|
| TCGA_Sample_ID | Sample_Id | Unique identifier assigned to each sample; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | Tumor_Sample / Mutation_Event / Structural_Variant_Sample | VARCHAR(20) |
| Chromosome | Site1_Chromosome, Site2_Chromosome | Chromosome within which the structural variant break point occurred | Mutation_Event / Structural_Variant_Breakpoints | VARCHAR(2) / CHAR(2) |
| SV_Hugo_Symbol | Site1_Hugo_Symbol, Site2_Hugo_Symbol | Gene symbol for gene impacted by structural variant breakpoint; assigned by the HUGO Gene Nomenclature Committee | Structural_Variant_Breakpoints | VARCHAR(15) |
| Position | Site1_Position, Site2_Position | Genomic coordinate for the structural variant breakpoint | Structural_Variant_Breakpoints | BIGINT |
| Effect_on_Frame | Site2_Effect_On_Frame | Effect of the structural variant on the reading frame | Structural_Variant | VARCHAR(10) |
| Event_Info | Event_Info | Impact of the structural variant (such as gene fusions) | Structural_Variant | VARCHAR(26) |

**Note:** rows were split for this file so that site_1 and site_2 information was captured in the database as “Start_or_End”—where Start corresponds to site_1 and end corresponds to site_2—which is why two original columns correspond to one database column.

# Database Dictionary by Table

## Table: Patient

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| TCGA_Patient_ID | PATIENT_ID | Unique identifier assigned to each patient; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | CHAR(12) |
| Sex | SEX | Biological sex of patient | CHAR(4) |
| Genetic_Ancestry_Label | GENETIC_ANCESTRY_LABEL | Genetic ancestry classification inferred from genomic data. | VARCHAR(9) |

## Table: Cancer_Incidence

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| TCGA_Patient_ID | PATIENT_ID | Unique identifier assigned to each patient; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | CHAR(12) |
| Cancer_Type_Acronym | CANCER_TYPE_ACRONYM | Abbreviation for cancer type of interest | VARCHAR(10) |
| Patient_Age | AGE | Age of patient at the time they joined the study | TINYINT UNSIGNED |
| Disease_Code_ICD | ICD_10 | Diagnosis code from the International Classification of Diseases, 10th Revision, describing disease | CHAR(10) |
| Cancer_Type | CANCER_TYPE | Broad classification of the sample’s cancer type | VARCHAR(100) |
| Cancer_Type_Detailed | CANCER_TYPE_DETAILED | Detailed classification of the sample’s cancer type | VARCHAR(255) |
| New_Tumor_Post_Treament | NEW_TUMOR_EVENT... | If the patient developed an additional tumor after treatment. | VARCHAR(3) |
| TNM_Node_Stage | PATH_N_STAGE | Describes the extent of cancer spread to nearby lymph nodes, part of the TNM Classification of Malignant Tumors staging system. | VARCHAR(3) |
| Prior_DX | PRIOR_DX | If the patient had a prior diagnosis of cancer. | VARCHAR(55) |
| Radiation_Therapy | RADIATION_THERAPY | If the patient had radiation therapy as part of treatment. | VARCHAR(3) |
| Overall_Survival_Status | OS_STATUS | If the patient was alive or deceased at last follow-up appointment. | CHAR(15) |
| Overall_Survival_Months | OS_MONTHS | Survival time, in months, of the patient from time of study enrollment until last follow-up appointment or death. | DECIMAL(10,2) |
| Disease_Free_Status_Months | DFS_MONTHS | Months spent disease-free following treatment. | DECIMAL(10,2) |

## Table: Tumor_Sample

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| TCGA_Sample_ID | SAMPLE_ID | Unique identifier assigned to each sample; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | VARCHAR(20) |
| Tumor_Type | TUMOR_TYPE | Type of tissue sampled, such as tumor or normal | VARCHAR(50) |
| Tumor_Tissue_Site | TUMOR_TISSUE_SITE | Anatomical location from which the sample was taken | VARCHAR(100) |
| Tumor_Mutational_Burden | TMB_NONSYNONYMOUS | Number of non-synonymous mutations within coding regions found within DNA sequencing of the tumor | DECIMAL(10,2) |
| Tumor_Histology_ICD_O_3_Code | ICD_O_3_HISTOLOGY | Histology classification code from the International Classification of Diseases for Oncology, 3rd Edition, describing tumor cell type and morphology | CHAR(10) |
| Tumor_Site_ICD_O_3_Code | ICD_O_3_SITE | Anatomical site code from the International Classification of Diseases for Oncology, 3rd Edition, indicating the primary location of the tumor in the body | VARCHAR(10) |
| TNM_Tumor_Stage | PATH_T_STAGE | Describes the size/extent of the primary tumor, part of the TNM Classification of Malignant Tumors staging system. | CHAR(5) |
| NCBI_Build | NCBI_Build | Reference genome version used. | VARCHAR(10) |

## Table: Mutation_Event

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| TCGA_Sample_ID | Tumor_Sample_Barcode | Unique identifier assigned to each sample; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | VARCHAR(20) |
| Chromosome | Chromosome | Chromosome where the mutation occurred | VARCHAR(2) |
| Start_Position | Start_Position | Genomic coordinate where the mutation begins | BIGINT |
| End_Position | End_Position | Genomic coordinate where the mutation ends | BIGINT |
| Strand | Strand | DNA strand orientation for the mutation | VARCHAR(2) |
| Variant_Classification | Variant_Classification | Type of mutation | VARCHAR(22) |
| Variant_Type | Variant_Type | Structural change caused by mutation | VARCHAR(3) |
| Reference_Allele | Reference_Allele | Nucleotide/s in the reference genome found at the same location as the mutation | VARCHAR(1290) |
| Tumor_Seq_Allele1 | Tumor_Seq_Allele1 | First allele observed in tumor sequencing data | VARCHAR(1290) |
| Tumor_Seq_Allele2 | Tumor_Seq_Allele2 | Second allele observed in the tumor sequencing data. | VARCHAR(18) |
| Match_Norm_Sample_Allele1 | Match_Norm_Seq_Allele1 | First allele observed in the matched normal sample | VARCHAR(1290) |
| Match_Norm_Sample_Allele2 | Match_Norm_Seq_Allele2 | Second allele observed in the matched normal sample | VARCHAR(1290) |
| HGVSc | HGVSc | Coding DNA-level mutation description using HGVS nomenclature | VARCHAR(50) |
| Codon_Change | Codons | Reference and altered codon sequence caused by mutation | VARCHAR(18) |
| Allele | Allele | Alternate allele associated with mutation | VARCHAR(34) |
| Biotype | BIOTYPE | Functional transcript type | VARCHAR(11) |
| Consensus_Coding_Sequence | CCDS | Unique identifier for the Consensus Coding Sequence (CCDS) database transcript corresponding with that of the mutation | VARCHAR(4) |
| dbSNP_rsID | dbSNP_RS | dbSNP reference SNP ID (rsID) associated with the variant | VARCHAR(23) |
| Exon_Number | Exon_Number | Exon of the gene in which the mutation occurred | VARCHAR(7) |
| Ensembl_Gene_ID | Gene | Ensembl gene identifier associated with the affected transcript | VARCHAR(8) |
| Functional_Impact | IMPACT | Predicted impact on the gene/protein | VARCHAR(7) |
| Intron_Number | INTRON | Intron of the gene in which the mutation occurred | VARCHAR(7) |

## Table: Gene

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| Hugo_Symbol | Hugo_Symbol | Gene symbol for gene impacted by mutation; assigned by the HUGO Gene Nomenclature Committee | VARCHAR(15) |
| Entrez_Gene_ID | Entrez_Gene_Id | Numeric gene identifier from the NCBI Entrez Gene database | DECIMAL(15, 6) |

## Table: Protein

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| Transcript_ID | Transcript_ID | Ensembl unique transcript ID within which the mutation is located | CHAR(15) |
| Ensembl_Protien_ID | ENSP | Ensembl protein identifier associated with the affected transcript | VARCHAR(15) |
| SwissProt_ID | SWISSPROT | UniProt/Swiss-Prot protein database accession associated with the gene or transcript | VARCHAR(65) |
| Trembl_ID | TREMBL | UniProt/TrEMBL protein database accession associated with the gene or transcript | VARCHAR(30) |
| Distance_to_feature | DISTANCE | Distance from mutation to nearest annotated genomic feature | VARCHAR(15) |

## Table: Mutation_Protein

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| HGVSp | HGVSp | Protein-level mutation description using HGVS nomenclature | VARCHAR(34) |
| Amino_Acids | Amino_acids | Amino acid change caused by mutation | VARCHAR(14) |
| PolyPhen_Prediction | PolyPhen | Predicted severity of the mutation’s functional impact | VARCHAR(24) |
| SIFT_Prediction | SIFT | Predicts severity of impact on the associated protein, based on any amino acid substitution caused by mutation | VARCHAR(32) |

## Table: Consequence

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| Consequence | Consequence | Variant type caused by the mutation | VARCHAR(102) |

## Table: Structural_Variant

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| Effect_on_Frame | Site2_Effect_On_Frame | Effect of the structural variant on the reading frame | VARCHAR(10) |
| Event_Info | Event_Info | Impact of the structural variant (such as gene fusions) | VARCHAR(26) |

## Table: Structural_Variant_Breakpoints

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| Chromosome | Site1_Chromosome, Site2_Chromosome | Chromosome within which the structural variant break point occurred | CHAR(2) |
| SV_Hugo_ID (Symbol) | Site1_Hugo_Symbol, Site2_Hugo_Symbol | Gene symbol for gene impacted by structural variant breakpoint; assigned by the HUGO Gene Nomenclature Committee | VARCHAR(15) |
| Position | Site1_Position, Site2_Position | Genomic coordinate for the structural variant breakpoint | BIGINT |

## Table: Structural_Variant_Sample

| Database Column Name | Original Column Name | Data Description | Data Type |
|---|---|---|---|
| TCGA_Sample_ID | Sample_Id | Unique identifier assigned to each sample; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | VARCHAR(20) |
