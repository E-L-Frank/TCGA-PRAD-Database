# TCGA-PRAD-Database

## Project Summary

Prostate cancer is among the leading causes of cancer-related death in men worldwide, and, while multiple genetic mechanisms have been identified, the causes are not completely understood.
This project creates a relational database that utilizes select data from [The Cancer Genome Atlas Prostate Adenocarcinoma (TCGA-PRAD) PanCancer Atlas 2018 study](https://www.cbioportal.org/study/summary?id=prad_tcga_pan_can_atlas_2018) ; it provides a structured environment for the analysis of the cohort's mutational profile and genomic architecture by cataloging both discrete mutation events and complex structural variants.

By combining clinical and demographic patient data with sample-specific metadata, the resulting database is designed to assist researchers in identifying key single-nucleotide polymorphisms (SNPs) that may contribute to the pathogenesis and clinical progression of prostate adenocarcinoma.

This was the final project for Databases for Bioinformatics (BINF-6970-01) at Georgetown University.


## Data Source
The dataset is comprised of select files from [The Cancer Genome Atlas Prostate Adenocarcinoma PanCancer Atlas 2018 (TCGA-PRAD) study](https://www.cbioportal.org/study/summary?id=prad_tcga_pan_can_atlas_2018). Source files were retrieved from cBioPortal for Cancer Genomics in early 2025. The raw files included 495 prostate tumor tissue samples from 495 patients.

Of the 27 data files downloaded, four were selected to support the primary purpose of the project: creating a tool to identify important and interesting SNPs by integrating data on the cohort’s mutational profile and genomic architecture. The database integrates four primary dimensions of the TCGA-PRAD collected data: 
* **Patient Metrics:** Clinical and demographic records for the TCGA-PRAD research participants (01_data_clinical_patient.txt)
* **Biospecimen Metadata:** Clinical attributes and tumor-specific data for the collected prostate tissue samples (02_data_clinical_sample.txt)
* **Mutational Catalog:** Mutation events identified within the samples' genetic makeup (03_data_mutations.txt)
* **Structural Variations:** Large-scale genomic rearrangements and structural variants (04_data_sv.txt)

## Tools and Technologies
* DBMS: MySQL and phpMyAdmin v5.2.3
* Python v3.14.0
* Pandas v3.0.2
* Analyses were conducted on macOS 15.6.1 (24G90) running on Apple Silicon ARM64 architecture (Apple M1)

## Repository Structure

* **data:** contains the raw and cleaned data files
* **diagrams:** contains visual representations of the database structure
* **scripts:** contains the Python script used to clean the raw data, generate the clean data files, and generate the SQL code for loading the cleaned data (03_load_cleaned_data.sql)
* **sql:** contains the SQL scripts used to generate the database
* **docs:** contains further details about the database, such as the data dictionary, data exploration, and database design process

The full repository structure is as follows:

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

## How to Recreate the Database

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

## Documentation and Diagrams

* Relational Data Model (shown below) can be found in diagrams/Relational_Model_Diagram.png
* The resulting overarching table structure created in phpMyAdmin can be found in diagrams/phpMyAdmin_overview.png
* The data dictionary can be found in docs/data_dictionary.md
* The detailed write-up can be found in docs/project_writeup.md. 
* Example queries (one shown below) can be found in docs/example_queries.md

## Relational Data Model

The database follows this structure:
![image](/diagrams/Relational_Model_Diagram.png)

## Example Query

### Find the 20 genes that contain the greatest number of mutations ###

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

This query will produce the following result:
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

These results help to demonstrate the utility of the database. Many of the top occurring genes are well-known drivers or frequently mutated markers of prostate adenocarcinoma. To give a few examples:
* **SPOP**: SPOP mutations are one of the most common mutations found in prostate cancer. ([Nakazawa et al., 2021](https://pmc.ncbi.nlm.nih.gov/articles/PMC8688331/))
* **TP53**: mutations in TP53, which encodes the tumor suppressor protein, p53, occur in up to half of metastatic prostate cancer cases. ([Maddah et al., 2024](https://www.sciencedirect.com/science/article/abs/pii/S1558767324001964))
* **FOXA1**: plays a role in regulating androgen receptor function in the prostate; evidence for its role as both an oncogene and tumor suppressor, depending on the subtype ([Dong et al., 2022](https://pmc.ncbi.nlm.nih.gov/articles/PMC10226509/))

More example queries can be found in [docs/example_queries.md](https://github.com/E-L-Frank/TCGA-PRAD-Database/blob/main/docs/example_queries.md)

---
### **AI use disclosure:** AI was used in the course of this project.
