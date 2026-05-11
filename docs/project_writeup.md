
# Table of Contents
- [Project Overview](#project-overview)
- [Repository Structure](#repository-structure)
- [Data Source](#data-source)
- [Data Cleaning](#data-cleaning)
- [Database Design](#database-design)
- [Data Dictionary](#data-dictionary)
- [Script Map](#script-map)
- [Reproduction Instructions](#reproduction-instructions)
- [Outputs](#outputs)
- [Limitations and Future Work](#limitations-and-future-work)
  
# Project Overview

Prostate cancer is among the leading causes of cancer-related death in men worldwide, and, while multiple genetic mechanisms have been identified, the causes are not completely understood.
This project creates a relational database that utilizes select data from The Cancer Genome Atlas Prostate Adenocarcinoma (TCGA-PRAD) PanCancer Atlas 2018 study; it provides a structured environment for the analysis of the cohort's mutational profile and genomic architecture by cataloging both discrete mutation events and complex structural variants.

By combining clinical and demographic patient data with sample-specific metadata, the resulting database is designed to assist researchers in identifying key single-nucleotide polymorphisms (SNPs) that may contribute to the pathogenesis and clinical progression of prostate adenocarcinoma.

This was the final project for *Databases for Bioinformatics* (BINF-6970-01) at Georgetown University.

### Repository Structure

```text
TCGA-PRAD-Database/
├── README.md
├── .gitignore
├── scripts/
│   └── 01_clean_data_create_sql_upload.py
│
├── sql/
│   ├── 01_create_staging_tables.sql
│   ├── 02_create_final_tables.sql
│   ├── 03_load_cleaned_data.sql
│   └──04_migrate_data.sql
│
├── diagrams/
│   ├── Relational_Model_diagram.png
│   └── phpMyAdmin_overview.png
│
├── docs/
│   ├── data_dictionary.md
│   ├── example_queries.md
│   ├──  script_execution_order.md
│   └── project_writeup.md
│
└── data/
    ├── cleaned/
    │   ├── 01_cleaned_data_clinical_patient.txt
    │   ├── 02_cleaned_data_clinical_sample.txt
    │   ├── 03_cleaned_data_mutations.txt
    │   └── 04_cleaned_data_sv.txt
    │
    └── raw/
        ├── 01_data_clinical_patient.txt
        ├── 02_data_clinical_sample.txt
        ├── 03_data_mutations.txt
        └── 04_data_sv.txt

```

# Data Source
The dataset is comprised of select files from [The Cancer Genome Atlas Prostate Adenocarcinoma PanCancer Atlas 2018 (TCGA-PRAD) study](https://www.cbioportal.org/study/summary?id=prad_tcga_pan_can_atlas_2018). Source files were retrieved from cBioPortal for Cancer Genomics in early 2025. The raw files included 495 prostate tumor tissue samples from 495 patients.

Of the 27 data files downloaded, four were selected to support the primary purpose of the project: creating a tool to identify important and interesting SNPs by integrating data on the cohort’s mutational profile and genomic architecture. The database integrates four primary dimensions of the TCGA-PRAD collected data: 
* **Patient Metrics:** Clinical and demographic records for the TCGA-PRAD research participants (01_data_clinical_patient.txt)
* **Biospecimen Metadata:** Clinical attributes and tumor-specific data for the collected prostate tissue samples (02_data_clinical_sample.txt)
* **Mutational Catalog:** Mutation events identified within the samples' genetic makeup (03_data_mutations.txt)
* **Structural Variations:** Large-scale genomic rearrangements and structural variants (04_data_sv.txt)
# Data Cleaning
* Features were filtered out from the raw data files if they were empty, if they did not support the primary goal of identifying interesting SNPs, or if their information was captured elsewhere in a feature retained in the cleaned data files.
* For all files, any duplicated rows were dropped as part of quality control to help prevent primary key violations.
* Features were reordered in each file to match the order of the corresponding SQL staging table for ease of upload.
* TREMBL_ID in 03_data_mutations.txt had multiple IDs in one cell; only the first instance of each ID was kept.
* Feature names were standardized to be consistent across the cleaned data files to ensure correct uploading to the SQL staging tables and for user ease.
* Many features were renamed from abbreviations or shortened identifiers for ease of user.
* Data types were formatted to ensure correct uploading to the SQL staging tables. 
* 04_data_sv.txt was reformatted so that structural variant breakpoint information of“site_1” and “site_2” features were captured in the same table —a feature “Start_or_End” was added where “Start” corresponds to “site_1” and " End " corresponds to “site_2”. This treats each "breakpoint" as an entity, which is more aligned with Third Normal Form.

* The SQL upload file was created so that it uploads data in chunks of 2000 lines to help avoid loading issues.
---
### Quality Control
To restrict the dataset to higher-confidence somatic mutations that may contribute to PRAD and to drop likely germline mutations, the following features in 03_data_mutations.txt were used as quality control filters for the mutation events data: 
* **FILTER**: a quality control decision made by the variant calling pipeline. Had to be “PASS” in order to be kept in the cleaned data. Helped avoid common variants and keep the cleaned dataset to likely higher confidence somatic mutations. 
* **DBVS**: Database verification. A database annotation flag field–mutation entries were flagged by the pipeline as lower-confidence somatic mutations/likely germline mutations (ex. Low-confidence/suspicious calls, likely germline mutation, potential sequencing artifacts, etc). Only mutation events that were not flagged were kept to try to limit the clean data to higher-confidence somatic variants.
* **Annotation_Status**: the annotation pipeline was successful or not; kept only “SUCCESS” mutations that were annotated by the pipeline.

Prior to quality control, there were **34192** mutation event entries, and after, there were **22431** mutation event entries.
### Missing Values 
The 01_clean_data_create_sql_upload.py script was written to provide a report on the cleaned data and any missing values. The full output is below, but of particular note:
* After dropping any duplicates, none of the rows in the raw data files had more than 75% of their data missing, so no rows were dropped
* Only two features had more than 50% of their data missing, both from the raw file, 03_data_mutations.txt:
| **Distance_to_feature** | Distance from mutation to nearest annotated genomic feature | 99.38% |
| **Intron_Number** | Intron of the gene in which the mutation occurred | 95.91% |
Both of these features were kept under the assumption that the majority of the notated mutations occurred within exonic regions rather than intronic regions, and since the lack of data in these features did not majorly detract from the functionality of the database.
 ---
**Full Output**:
```console
*** Processing 01_data_clinical_patient.txt ***
✅ All 16 expected columns found.
Final Shape: (494, 16)
Columns with missing data:
                            Missing Count  Percentage (%)
Disease_Free_Status_Months            160           32.39
TNM_Node_Stage                         73           14.78
New_Tumor_Post_Treatment               58           11.74
Radiation_Therapy                      46            9.31
TNM_Tumor_Stage                         7            1.42
No rows missing more than 75% data.
SQL script generated: ../sql/03_load_cleaned_data.sql
----------------------------------------

*** Processing 02_data_clinical_sample.txt ***
✅ All 7 expected columns found.
Final Shape: (494, 7)
No rows missing more than 75% data.
SQL script generated: ../sql/03_load_cleaned_data.sql
----------------------------------------

*** Processing 03_data_mutations.txt ***
✅ All 36 expected columns found.
Final Shape: (22431, 35)
Columns with missing data:
                           Missing Count  Percentage (%)
Distance_to_feature                22291           99.38
Intron_Number                      21513           95.91
SIFT_Prediction                    10318           46.00
Trembl_ID                           9830           43.82
PolyPhen_Prediction                 9422           42.00
dbSNP_rsID                          4225           18.84
HGVSp                               2810           12.53
Codon_Change                        2703           12.05
Amino_Acids                         2606           11.62
SwissProt_ID                        1091            4.86
Exon_Number                         1041            4.64
Consensus_Coding_Sequence            878            3.91
Ensembl_Protein_ID                   303            1.35
HGVSc                                140            0.62
No rows missing more than 75% data.
SQL script generated: ../sql/03_load_cleaned_data.sql
----------------------------------------

*** Processing 04_data_sv.txt ***
✅ All 8 expected columns found.
Final Shape: (3782, 8)
Columns with missing data:
                 Missing Count  Percentage (%)
Effect_on_Frame           1544           40.82
No rows missing more than 75% data.
SQL script generated: ../sql/03_load_cleaned_data.sql
----------------------------------------
```
# Database Design
## Relational Model Diagram
![image](/diagrams/Relational_Model_Diagram.png)
## Design Decisions
The database has a hierarchical structure of Patient → Cancer Incidence → Tissue Sample → Molecular Data to ensure data integrity by linking clinical outcomes directly to specific mutations. It is a one-to-many progression, where one patient may have multiple cancer incidences, which may have multiple tissue samples, which may yield multiple instances of genomic data. It is designed with centralized hub tables, such as Mutation_Event, to allow quick joins, such as between mutations and their functional impacts (Protein table) or their genomic locations (Gene table). Junction tables allow for many-to-many relationships—this reflects biological reality. For example, one gene may have many different mutations, and one mutation may affect multiple genes. This structure maximizes data integrity by minimizing redundancy in the large biological TCGA-PRAD dataset. Business rules include TCGA_Patient_ID CHAR(12) NOT NULL in Cancer_Incidence with a Foreign Key, so that the clinical data is always linked to a patient; Patient_Age TINYINT UNSIGNED, so that there are no negative ages added in, and so that the ages are within a reasonable range (under 255 years); 
Deviation from Normal Forms

## Normal Forms and Deviations

In order to promote user ease and avoid complex joins, the database is not in the 5th normal form. 
Certain descriptive features, such as Variant_Classification or Biotype, were kept in their table, Mutation_Event, instead of being moved to separate lookup tables with IDs. Keeping them in the main table allows for faster queries than if the database design were further normalized. The Gene_ID was intentionally included in the Protein table as a denormalization choice. While this relationship is technically discoverable through the Mutation_Event table, this allows for user ease and less/more simplified joins. The SV_Hugo_ID was stored as a string in the Structural_Variant_Breakpoints table instead of referring to the Hugo_Symbol in the Gene table in order to improve query performance and avoid complex joins. Also, this allows for logical separation between mutation events and structural variants, which may include multiple mutation events. 
## Relationships and Constraints
**Primary Keys and Entity Integrity**
To ensure entity integrity, every table uses a primary key (PK), which is either a unique genomic identifier or a surrogate auto-incrementing integer.
* Patient: TCGA_Patient_ID (Natural Key - CHAR)
* Cancer_Incidence: Cancer_Incidence_ID (Surrogate Key - INT)
* Tumor_Sample: TCGA_Sample_ID (Natural Key - VARCHAR)
* Mutation_Event: Mutation_Event_ID (Surrogate Key - INT)
* Consequence: Consequence_ID (Surrogate Key - INT)
* Mutation_Consequence: Mutation_Consequence_ID (Surrogate Key - INT)
* Structural_Variant: Structural_Variant_ID (User-defined - INT)
* Structural_Variant_Sample: SV_Sample_ID (Surrogate Key - INT)
* Gene: Gene_ID (Surrogate Key - INT)
* Structural_Variant_Breakpoints: Breakpoint_ID (Surrogate Key - INT)
* Mutation_Gene: Mutation_Gene_ID (Surrogate Key - INT)
* Mutations_Samples: Mutation_Sample_ID (Surrogate Key - INT)
* Protein: Protein_ID (Surrogate Key - INT)
* Mutation_Protein: Mutation_Protein_ID (Surrogate Key - INT)

**Foreign Keys and Referential Integrity**
To ensure referential integrity, standard foreign key constraints are used to prevent the deletion of a parent record if child records exist.
| Table                          | Foreign Key Column     | References (Parent Table)                     |
|--------------------------------|------------------------|------------------------------------------------|
| Cancer_Incidence              | TCGA_Patient_ID        | Patient(TCGA_Patient_ID)                      |
| Tumor_Sample                  | Cancer_Incidence_ID    | Cancer_Incidence(Cancer_Incidence_ID)         |
| Mutation_Consequence          | Consequence_ID         | Consequence(Consequence_ID)                   |
| Mutation_Consequence          | Mutation_Event_ID      | Mutation_Event(Mutation_Event_ID)             |
| Structural_Variant_Sample     | TCGA_Sample_ID         | Tumor_Sample(TCGA_Sample_ID)                  |
| Structural_Variant_Sample     | Structural_Variant_ID  | Structural_Variant(Structural_Variant_ID)     |
| Structural_Variant_Breakpoints| Structural_Variant_ID  | Structural_Variant(Structural_Variant_ID)     |
| Mutation_Gene                 | Gene_ID                | Gene(Gene_ID)                                 |
| Mutation_Gene                 | Mutation_Event_ID      | Mutation_Event(Mutation_Event_ID)             |
| Mutations_Samples             | TCGA_Sample_ID         | Tumor_Sample(TCGA_Sample_ID)                  |
| Mutations_Samples             | Mutation_Event_ID      | Mutation_Event(Mutation_Event_ID)             |
| Protein                       | Gene_ID                | Gene(Gene_ID)                                 |
| Mutation_Protein              | Protein_ID             | Protein(Protein_ID)                           |
| Mutation_Protein              | Mutation_Event_ID      | Mutation_Event(Mutation_Event_ID)             |

**Null Rules**
* **Implicit NOT NULL**: All columns defined as PRIMARY KEY automatically enforce a NOT NULL constraint.
* **Explicit NOT NULL**: Found in Cancer_Incidence.TCGA_Patient_ID. This ensures that every cancer record is strictly associated with a patient.
* **Implicit NULL**: Most genomic metadata columns (e.g., dbSNP_rsID, PolyPhen_Prediction) allow nulls. This is appropriate for biological data where specific predictions or IDs may be unavailable.

**Unique Constraints**
* **Primary Keys:** All PKs listed above are implicitly unique.
* **Candidate Keys:** While not explicitly declared with the UNIQUE keyword, TCGA_Sample_ID in Mutation_Event is unique, since part of data cleaning included filtering duplicate rows, so any duplicated mutation event within a patient sample that is exactly the same will be removed.

**Check Constraints**
* **Domain Constraints** (Data Types): Use of specific data types to limit input (e.g., CHAR(12) for IDs and TINYINT for age).
* **Value Constraints:** Patient_Age Uses UNSIGNED in the Cancer_Incidence table. This serves as a check to prevent negative numbers from being entered for age.
# Data Dictionary
## Data Dictionary Table of Contents

- [Database Dictionary by Table](#database-dictionary-by-table)
  - [Table: Patient](#table-patient)
  - [Table: Cancer_Incidence](#table-cancer_incidence)
  - [Table: Tumor_Sample](#table-tumor_sample)
  - [Table: Mutation_Event](#table-mutation_event)
  - [Table: Gene](#table-gene)
  - [Table: Mutation_Gene](#table-mutation_gene)
  - [Table: Protein](#table-protein)
  - [Table: Mutation_Protein](#table-mutation_protein)
  - [Table: Consequence](#table-consequence)
  - [Table: Mutation_Consequence](#table-mutation_consequence)
  - [Table: Structural_Variant](#table-structural_variant)
  - [Table: Structural_Variant_Breakpoints](#table-structural_variant_breakpoints)
  - [Table: Structural_Variant_Sample](#table-structural_variant_sample)
 
- [Data Dictionary by File](#data-dictionary-by-file)
  - [FILE: 01_data_clinical_patient.txt](#file-01_data_clinical_patienttxt)
  - [FILE: 02_data_clinical_sample.txt](#file-02_data_clinical_sampletxt)
  - [FILE: 03_data_mutations.txt](#file-03_data_mutationstxt)
  - [FILE: 04_data_sv.txt](#file-04_data_svtxt)

# Database Dictionary by Table

## Table: Patient
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** TCGA_Patient_ID | PATIENT_ID | Unique identifier assigned to each patient; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | CHAR(12) |
| Sex | SEX | Biological sex of patient | CHAR(4) |
| Genetic_Ancestry_Label | GENETIC_ANCESTRY_LABEL | Genetic ancestry classification inferred from genomic data. | VARCHAR(9) |

## Table: Cancer_Incidence
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** Cancer_Incidence_ID | N/A | Unique numeric ID for each time a patient is diagnosed with cancer | Int |
| **FK** TCGA_Patient_ID | PATIENT_ID | Unique identifier assigned to each patient; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | CHAR(12) |
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
| :--- | :--- | :--- | :--- |
| **PK** TCGA_Sample_ID | SAMPLE_ID | Unique identifier assigned to each sample; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | VARCHAR(20) |
| **FK** Cancer_Incidence_ID | N/A | Unique ID for each time a patient is diagnosed with cancer | Int |
| Tumor_Type | TUMOR_TYPE | Type of tissue sampled, such as tumor or normal | VARCHAR(50) |
| Tumor_Tissue_Site | TUMOR_TISSUE_SITE | Anatomical location from which the sample was taken | VARCHAR(100) |
| Tumor_Mutational_Burden | TMB_NONSYNONYMOUS | Number of non-synonymous mutations within coding regions found within DNA sequencing of the tumor | DECIMAL(10,2) |
| Tumor_Histology_ICD_O_3_Code | ICD_O_3_HISTOLOGY | Histology classification code from the International Classification of Diseases for Oncology, 3rd Edition, describing tumor cell type and morphology | CHAR(10) |
| Tumor_Site_ICD_O_3_Code | ICD_O_3_SITE | Anatomical site code from the International Classification of Diseases for Oncology, 3rd Edition, indicating the primary location of the tumor in the body | VARCHAR(10) |
| TNM_Tumor_Stage | PATH_T_STAGE | Describes the size/extent of the primary tumor, part of the TNM Classification of Malignant Tumors staging system. | CHAR(5) |
| NCBI_Build | NCBI_Build | Reference genome version used. | VARCHAR(10) |

## Table: Mutations_Samples
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** Mutation_Sample_ID | N/A | Unique numeric ID for each mutation event linked to a specific sample | Int |
| **FK** Mutation_Event_ID | N/A | Unique numeric ID for a mutation | Int |
| **FK** TCGA_Sample_ID | Tumor_Sample_Barcode | Unique identifier assigned to each sample; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | VARCHAR(20) |

## Table: Mutation_Event
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** Mutation_Event_ID | N/A | Unique numeric ID for a mutation | Int |
| **FK** Mutation_Sample_ID | N/A | Unique numeric ID for each mutation event linked to a specific sample | Int |
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
| :--- | :--- | :--- | :--- |
| **PK** Gene_ID | N/A | Unique numeric ID for each gene | Int |
| Hugo_Symbol | Hugo_Symbol | Gene symbol for gene impacted by mutation; assigned by the HUGO Gene Nomenclature Committee | VARCHAR(15) |
| Entrez_Gene_ID | Entrez_Gene_Id | Numeric gene identifier from the NCBI Entrez Gene database | DECIMAL(15, 6) |

## Table: Mutation_Gene
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** Mutation_Gene_ID | N/A | Unique numeric ID for each mutation event linked to a specific gene | Int |
| **FK** Mutation_Event_ID | N/A | Unique numeric ID for a mutation | Int |
| **FK** Gene_ID | N/A | Unique numeric ID for each gene | Int |

## Table: Protein
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** Protein_ID | N/A | Unique numeric ID for each protein | Int |
| **FK** Gene_ID | N/A | Unique numeric ID for each gene | Int |
| Transcript_ID | Transcript_ID | Ensembl unique transcript ID within which the mutation is located | CHAR(15) |
| Ensembl_Protien_ID | ENSP | Ensembl protein identifier associated with the affected transcript | VARCHAR(15) |
| SwissProt_ID | SWISSPROT | UniProt/Swiss-Prot protein database accession associated with the gene or transcript | VARCHAR(65) |
| Trembl_ID | TREMBL | UniProt/TrEMBL protein database accession associated with the gene or transcript | VARCHAR(30) |
| Distance_to_feature | DISTANCE | Distance from mutation to nearest annotated genomic feature | VARCHAR(15) |

## Table: Mutation_Protein
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** Mutation_Protein_ID | N/A | Unique numeric ID for each mutation event linked to a specific protein | Int |
| **FK** Protein_ID | N/A | Unique numeric ID for each protein | Int |
| **FK** Mutation_Event_ID | N/A | Unique numeric ID for a mutation | Int |
| HGVSp | HGVSp | Protein-level mutation description using HGVS nomenclature | VARCHAR(34) |
| Amino_Acids | Amino_acids | Amino acid change caused by mutation | VARCHAR(14) |
| PolyPhen_Prediction | PolyPhen | Predicted severity of the mutation’s functional impact | VARCHAR(24) |
| SIFT_Prediction | SIFT | Predicts severity of impact on the associated protein, based on any amino acid substitution caused by mutation | VARCHAR(32) |

## Table: Consequence
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** Consequence ID | N/A | Unique numeric ID for each type of consequence of a mutation event | Int |
| Consequence | Consequence | Variant type caused by the mutation | VARCHAR(102) |

## Table: Mutation_Consequence
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** Mutation_Consequence_ID | N/A | Unique numeric ID for each consequence linked to a specific sample | Int |
| **FK** Mutation_Event_ID | N/A | Unique numeric ID for a mutation | Int |
| **FK** Consequence ID | N/A | Unique numeric ID for each type of consequence of a mutation event | Int |

## Table: Structural_Variant
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** Structural_Variant_ID | N/A | Unique numeric ID for each structural variant | Int |
| Effect_on_Frame | Site2_Effect_On_Frame | Effect of the structural variant on the reading frame | VARCHAR(10) |
| Event_Info | Event_Info | Impact of the structural variant (such as gene fusions) | VARCHAR(26) |

## Table: Structural_Variant_Breakpoints
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** Breakpoint_ID | N/A | Unique numeric ID for each breakpoint | Int |
| **FK** Structural_Variant_ID | N/A | Unique numeric ID for each structural variant | Int |
| Chromosome | Site1_Chromosome, Site2_Chromosome | Chromosome within which the structural variant break point occurred | CHAR(2) |
| SV_Hugo_ID (Symbol) | Site1_Hugo_Symbol, Site2_Hugo_Symbol | Gene symbol for gene impacted by structural variant breakpoint; assigned by the HUGO Gene Nomenclature Committee | VARCHAR(15) |
| Position | Site1_Position, Site2_Position | Genomic coordinate for the structural variant breakpoint | BIGINT |

## Table: Structural_Variant_Sample
| Database Column Name | Original Column Name | Data Description | Data Type |
| :--- | :--- | :--- | :--- |
| **PK** SV_Sample_ID | N/A | Unique numeric ID for each structural variant linked to a specific sample | Int |
| **FK** Structural_Variant_ID | N/A | Unique numeric ID for each structural variant | Int |
| **FK** TCGA_Sample_ID | Sample_Id | Unique identifier assigned to each sample; follows the standard TCGA barcoding (https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/) | VARCHAR(20) |


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


# Script Map

## Script Descriptions

### Python
* **01_clean_data_create_sql_upload.py**: takes the raw data file, cleans the data, creates the cleaned data files, and writes the SQL code to upload the data and saves it to *03_load_cleaned_data.sql*.

### SQL
* **01_create_staging_tables.sql**: creates TCGA-PRAD database and the staging tables where the data from each cleaned file will be uploaded
* **02_create_final_tables.sql**: creates the final database tables, which follow the structure of the Relational Model Diagram
* **03_load_cleaned_data.sql**: loads the cleaned data to the staging tables
* **04_migrate_data.sql**: migrates the data from the staging tables to the final tables and then deletes the staging tables
* **database_dump.sql**: combines the code from the four .sql files above so that this single file may be run to recreate the entire database

---
### Note

The following directory structure must exist before running the pipeline and  
`TCGA-PRAD-Database/scripts` must be the initial working directory.

## Execution Order

```text
1)	01_clean_data_create_sql_upload.py
2)	01_create_staging_tables.sql
3)	02_create_final_tables.sql
4)	03_load_cleaned_data.sql
5)	04_migrate_data.sql
```

## Prior to Run Directory Structure
```text
TCGA-PRAD-Database/
├── scripts/
│   └── 01_clean_data_create_sql_upload.py
│
├── sql/
│   ├── 01_create_staging_tables.sql
│   ├── 03_load_cleaned_data.sql
│   └── 04_migrate_data.sql
│
└── data/
    ├── cleaned/
    │
    └── raw/
        ├── 01_data_clinical_patient.txt
        ├── 02_data_clinical_sample.txt
        ├── 03_data_mutations.txt
        └── 04_data_sv.txt
```

## Post Run Directory Structure

```text
TCGA-PRAD-Database/
├── scripts/
│   └── 01_clean_data_create_sql_upload.py
│
├── sql/
│   ├── 01_create_staging_tables.sql
│   ├── 02_create_final_tables.sql
│   ├── 03_load_cleaned_data.sql
│   └── 04_migrate_data.sql
│
└── data/
    ├── cleaned/
    │   ├── 01_cleaned_data_clinical_patient.txt
    │   ├── 02_cleaned_data_clinical_sample.txt
    │   ├── 03_cleaned_data_mutations.txt
    │   └── 04_cleaned_data_sv.txt
    │
    └── raw/
        ├── 01_data_clinical_patient.txt
        ├── 02_data_clinical_sample.txt
        ├── 03_data_mutations.txt
        └── 04_data_sv.txt
```
# Reproduction Instructions

### Tools and Technologies
* DBMS: MySQL and phpMyAdmin v5.2.3
* Python v3.14.0
* Pandas v3.0.2
* Analyses were conducted on macOS 15.6.1 (24G90) running on Apple Silicon ARM64 architecture (Apple M1)
---
This method uses the database dump file (database_dump.sql) and is the most direct.
1. Download [database_dump.sql](https://github.com/E-L-Frank/TCGA-PRAD-Database/blob/main/sql/database_dump.sql)
2. Open terminal
3. Navigate to folder containing database_dump.sql
4. Log into MySQL and create the database using the following command
```console
mysql -u your_username -p < database_dump.sql
```
5. Confirm that the tables are loaded using the following command
```console
mysql -u your_username -p -e "USE TCGA_PRAD; SHOW TABLES;"
```

For instructions on how to generate the database using the raw data files and written scripts, go to [TCGA-PRAD-Database/docs/script_execution.md](https://github.com/E-L-Frank/TCGA-PRAD-Database/blob/main/docs/script_execution_order.md) 
# Outputs
## Populated Database
Below is a view of the populated database in phpMyAdmin:
![image](/diagrams/phpMyAdmin_overview.png)
## Example Queries
## Find the 20 genes that contain the greatest number of mutations

```mysql
SELECT 
    g.Hugo_Symbol, 
    COUNT(mg.Mutation_Event_ID) AS mutation_count
FROM Gene g
JOIN Mutation_Gene mg ON g.Gene_ID = mg.Gene_ID
GROUP BY g.Gene_ID, g.Hugo_Symbol
ORDER BY mutation_count DESC
LIMIT 20;
```

### Result
| **Hugo_Symbol** | **mutation_count** |
| :--- | :--- |
| TTN | 76 |
| SPOP | 56 |
| MUC16 | 40 |
| TP53 | 37 |
| KMT2C | 34 |
| FOXA1 | 34 |
| SYNE1 | 33 |
| KMT2D | 30 |
| CSMD3 | 21 |
| RYR2 | 21 |
| SPTA1 | 21 |
| HMCN1 | 19 |
| RYR3 | 19 |
| LRP1B | 19 |
| OBSCN | 19 |
| MUC17 | 17 |
| ATM | 17 |
| USH2A | 17 |
| PTEN | 16 |
| DCHS2 | 16 |

## Find the average number of mutated genes per patient
```mysql
SELECT AVG(gene_count) AS average_mutated_genes
FROM (
    SELECT 
        p.TCGA_Patient_ID, 
        COUNT(DISTINCT mg.Gene_ID) AS gene_count
    FROM Patient p
    JOIN Cancer_Incidence ci ON p.TCGA_Patient_ID = ci.TCGA_Patient_ID
    JOIN Tumor_Sample ts ON ci.Cancer_Incidence_ID = ts.Cancer_Incidence_ID
    JOIN Mutations_Samples ms ON ts.TCGA_Sample_ID = ms.TCGA_Sample_ID
    JOIN Mutation_Event me ON ms.Mutation_Event_ID = me.Mutation_Event_ID
    JOIN Mutation_Gene mg ON me.Mutation_Event_ID = mg.Mutation_Event_ID
    GROUP BY p.TCGA_Patient_ID
) AS patient_counts;
```

### Result
**42.0347**

## Find the most commonly occurring SNPs with rsIDs
```mysql
SELECT 
    me.dbSNP_RSID, 
    g.Hugo_Symbol,
    me.Chromosome,
    me.Start_Position,
    me.End_Position,
    me.Variant_Classification,
    COUNT(DISTINCT ms.TCGA_Sample_ID) AS sample_count
FROM Mutation_Event me
JOIN Mutation_Gene mg ON me.Mutation_Event_ID = mg.Mutation_Event_ID
JOIN Gene g ON mg.Gene_ID = g.Gene_ID
JOIN Mutations_Samples ms ON me.Mutation_Event_ID = ms.Mutation_Event_ID
WHERE me.dbSNP_RSID IS NOT NULL AND me.dbSNP_RSID != ''
GROUP BY 
    me.dbSNP_RSID, 
    g.Hugo_Symbol, 
    me.Chromosome, 
    me.Start_Position, 
    me.End_Position, 
    me.Variant_Classification
HAVING sample_count > 1
ORDER BY sample_count DESC
LIMIT 1000;
```

### Result (head)
| dbSNP_RSID | Hugo_Symbol | Chromosome | Start_Position | End_Position | Variant_Classification | sample_count |
| :--- | :--- | :--- | ---: | ---: | :--- | ---: |
| rs1057519966 | SPOP | 17 | 47696426 | 47696426 | Missense_Mutation | 8 |
| rs1057519968 | SPOP | 17 | 47696432 | 47696432 | Missense_Mutation | 8 |
| rs193921065 | SPOP | 17 | 47696424 | 47696424 | Missense_Mutation | 6 |
| rs1057519967 | SPOP | 17 | 47696425 | 47696425 | Missense_Mutation | 5 |
| rs193920894 | SPOP | 17 | 47696643 | 47696643 | Missense_Mutation | 4 |
| rs1057519971 | SPOP | 17 | 47696688 | 47696688 | Missense_Mutation | 4 |
| rs1057519964 | SPOP | 17 | 47696644 | 47696644 | Missense_Mutation | 4 |
| novel | FOXA1 | 14 | 38061223 | 38061228 | In_Frame_Del | 3 |
| rs121913233 | HRAS | 11 | 533874 | 533874 | Missense_Mutation | 3 |
| rs770624311 | SYNDIG1 | 20 | 24565546 | 24565546 | Missense_Mutation | 2 |
| rs778953302 | OR10G8 | 11 | 123900990 | 123900990 | Missense_Mutation | 2 |
| rs769967221 | PCDH19 | X | 99662413 | 99662413 | Nonsense_Mutation | 2 |
| rs763495821 | GGT5 | 22 | 24621251 | 24621251 | Missense_Mutation | 2 |
| rs763412043 | HNF1A | 12 | 121434123 | 121434123 | Silent | 2 |
| rs761395206 | XKR4 | 8 | 56436082 | 56436082 | Missense_Mutation | 2 |
| rs755499977 | ITGAL | 16 | 30518157 | 30518157 | Missense_Mutation | 2 |
| rs751942292 | TMEM132B | 12 | 126138738 | 126138738 | Missense_Mutation | 2 |
| rs587781991 | TP53 | 17 | 7578526 | 7578526 | Missense_Mutation | 2 |
| rs773837915 | POU2F1 | 1 | 167367303 | 167367303 | Missense_Mutation | 2 |
| rs777776928 | BTBD11 | 12 | 107937778 | 107937778 | Frame_Shift_Del | 2 |
| rs1355967136 | CHRM3 | 1 | 240070781 | 240070781 | Silent | 2 |
| rs782421028 | PCDHB7 | 5 | 140553130 | 140553130 | Silent | 2 |
| rs782636374 | PCDHA6 | 5 | 140209185 | 140209185 | Silent | 2 |
| rs786203436 | TP53 | 17 | 7578443 | 7578443 | Missense_Mutation | 2 |
| rs876660807 | TP53 | 17 | 7577566 | 7577566 | Missense_Mutation | 2 |
| rs951758185 | ADAD2 | 16 | 84229837 | 84229837 | Missense_Mutation | 2 |
| rs968538456 | CHST6 | 16 | 75512471 | 75512471 | 3'UTR | 2 |
| rs995456849 | HEY2 | 6 | 126080681 | 126080681 | Silent | 2 |
| rs121913273 | PIK3CA | 3 | 178936082 | 178936082 | Missense_Mutation | 2 |
| novel | FABP6 | 5 | 159665722 | 159665722 | 3'UTR | 2 |
| novel | FAM111A | 11 | 58920573 | 58920574 | Frame_Shift_Ins | 2 |
| novel | KATNAL2 | 18 | 44549172 | 44549172 | Intron | 2 |
| novel | MUC17 | 7 | 100679721 | 100679721 | Missense_Mutation | 2 |
| rs1045359996 | OR1C1 | 1 | 247921334 | 247921334 | Silent | 2 |
| rs1057517840 | TP53 | 17 | 7578222 | 7578223 | Frame_Shift_Del | 2 |
| rs1057519912 | MED12 | X | 70349258 | 70349258 | Missense_Mutation | 2 |
| rs1057519972 | SPOP | 17 | 47696689 | 47696689 | Missense_Mutation | 2 |
| rs1057519978 | TP53 | 17 | 7578509 | 7578509 | Missense_Mutation | 2 |
| rs530556816 | RAB37 | 17 | 72736966 | 72736966 | Silent | 2 |
| rs121913355 | BRAF | 7 | 140481402 | 140481402 | Missense_Mutation | 2 |
| rs121913400 | CTNNB1 | 3 | 41266101 | 41266101 | Missense_Mutation | 2 |
| rs121913412 | CTNNB1 | 3 | 41266124 | 41266124 | Missense_Mutation | 2 |
| rs1266973210 | MECOM | 3 | 168819875 | 168819875 | Missense_Mutation | 2 |
| rs1285565282 | CHRNA10 | 11 | 3687407 | 3687407 | Missense_Mutation | 2 |
| novel | C11orf24 | 11 | 68029279 | 68029279 | Missense_Mutation | 2 |
| rs1412672912 | LYST | 1 | 235944227 | 235944227 | Nonsense_Mutation | 2 |
| rs28931588 | CTNNB1 | 3 | 41266097 | 41266097 | Missense_Mutation | 2 |


## Find the 10 most commonly occurring mutations that also occur in the most commonly mutated genes
```mysql
SELECT 
    g.Hugo_Symbol,
    me.dbSNP_RSID,
    me.Variant_Classification,
    me.Functional_Impact,
    COUNT(DISTINCT ms.TCGA_Sample_ID) AS sample_frequency
FROM Mutation_Event me
JOIN Mutation_Gene mg ON me.Mutation_Event_ID = mg.Mutation_Event_ID
JOIN Gene g ON mg.Gene_ID = g.Gene_ID
JOIN Mutations_Samples ms ON me.Mutation_Event_ID = ms.Mutation_Event_ID
WHERE me.dbSNP_RSID IS NOT NULL AND me.dbSNP_RSID != ''
GROUP BY 
    g.Hugo_Symbol, 
    me.dbSNP_RSID,
    me.Variant_Classification,
    me.Functional_Impact
ORDER BY sample_frequency DESC
LIMIT 10;
```

### Result

| Hugo_Symbol | dbSNP_RSID | Variant_Classification | Functional_Impact | sample_frequency |
| :--- | :--- | :--- | :--- | :--- |
| TTN | novel | Missense_Mutation | MODERATE | 14 |
| FOXA1 | novel | In_Frame_Del | MODERATE | 11 |
| SYNE1 | novel | Missense_Mutation | MODERATE | 10 |
| KMT2D | novel | Frame_Shift_Del | HIGH | 9 |
| SPOP | rs1057519966 | Missense_Mutation | MODERATE | 8 |
| SPOP | rs1057519968 | Missense_Mutation | MODERATE | 8 |
| DCHS2 | novel | Missense_Mutation | MODERATE | 7 |
| KMT2C | novel | Missense_Mutation | MODERATE | 7 |
| MACF1 | novel | Missense_Mutation | MODERATE | 7 |
| SPTA1 | novel | Missense_Mutation | MODERATE | 7 |	


# Limitations and Future Work
**Known weaknesses**
- Did not create composite keys for junction tables
- Did not include every TREMBL_ID for a mutation event (kept the first one and dropped the rest)
- Because this is a static database (the TCGA project is over and no new patients or samples are being added to the dataset), many cleaning decisions and variable assignments were done based on the existing data (ex. In Mutation_Event, Match_Norm_Sample_Allele1 in Mutation_Event is VarChar(1290), since that is the largest value in that feature, but Tumor_Seq_Allele2 is VarChar(18) since that is the largest value in that feature). Because of the static dataset, the database was not designed to be as flexible as it could be if it were meant to readily accept new data. 

**Source Data Issues**
- The original dataset did not include matched files of full clinical data of the normal prostate tissue samples collected from the TCGA-PRAD study. It did include the normal alleles in the mutation file.
- The metadata files were very sparse and did not include detailed information, if any, about the features within the data files
- Naming of the features was inconsistent across data files (ex. different files had different names for TCGA_Patient_ID)
- Many of the features within the files were completely empty

**Ideas for Improvement and Potential Future Work**
- Find and integrate normal tumor sample data to allow for patient-level comparative analysis (though this would be difficult due to the more static nature of the database, discussed above)
- Create a dashboard for user ease and visualization
- Include transcriptomic and proteomic expression data
---
###**AI use disclosure:** AI was used in the course of this project.
