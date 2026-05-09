### Note

The following directory structure must exist before running the pipeline and  
`TCGA-PRAD-Database/scripts` must be the initial working directory.

---

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
