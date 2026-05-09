import pandas as pd

# Specific revamps for the files to prep for SQL upload

# --- File 01: Clinical Patient ---
file_01_keep = [
    "PATIENT_ID", "CANCER_TYPE_ACRONYM", "AGE", "SEX", "ICD_10",
    "ICD_O_3_HISTOLOGY", "ICD_O_3_SITE", "NEW_TUMOR_EVENT_AFTER_INITIAL_TREATMENT",
    "PATH_N_STAGE", "PATH_T_STAGE", "PRIOR_DX", "RADIATION_THERAPY",
    "OS_STATUS", "OS_MONTHS", "DFS_MONTHS", "GENETIC_ANCESTRY_LABEL"
]

file_01_rename = {
    "PATIENT_ID": "TCGA_Patient_ID",
    "CANCER_TYPE_ACRONYM": "Cancer_Type_Acronym",
    "AGE": "Patient_Age",
    "SEX": "Sex",
    "ICD_10": "Disease_Code_ICD",
    "ICD_O_3_HISTOLOGY": "Tumor_Histology_ICD_O_3_Code",
    "ICD_O_3_SITE": "Tumor_Site_ICD_O_3_Code",
    "NEW_TUMOR_EVENT_AFTER_INITIAL_TREATMENT": "New_Tumor_Post_Treatment",
    "PATH_N_STAGE": "TNM_Node_Stage",
    "PATH_T_STAGE": "TNM_Tumor_Stage",
    "PRIOR_DX": "Prior_DX",
    "RADIATION_THERAPY": "Radiation_Therapy",
    "OS_STATUS": "Overall_Survival_Status",
    "OS_MONTHS": "Overall_Survival_Months",
    "DFS_MONTHS": "Disease_Free_Status_Months",
    "GENETIC_ANCESTRY_LABEL": "Genetic_Ancestry_Label"
}

sql_order_01 = [
    "Tumor_Site_ICD_O_3_Code", "Tumor_Histology_ICD_O_3_Code", "TNM_Tumor_Stage",
    "TCGA_Patient_ID", "Sex", "Genetic_Ancestry_Label", "Patient_Age",
    "TNM_Node_Stage", "Prior_DX", "Radiation_Therapy", "New_Tumor_Post_Treatment",
    "Cancer_Type_Acronym", "Disease_Code_ICD", "Overall_Survival_Status",
    "Overall_Survival_Months", "Disease_Free_Status_Months"
]

staging_table_01 = "staging_table_01"

# --- File 02: Clinical Sample ---
file_02_keep = [
    "PATIENT_ID", "SAMPLE_ID", "CANCER_TYPE",
    "CANCER_TYPE_DETAILED", "TUMOR_TYPE", "TUMOR_TISSUE_SITE", "TMB_NONSYNONYMOUS"
]

file_02_rename = {
    "PATIENT_ID": "TCGA_Patient_ID",
    "SAMPLE_ID": "TCGA_Sample_ID",
    "CANCER_TYPE": "Cancer_Type",
    "CANCER_TYPE_DETAILED": "Cancer_Type_Detailed",
    "TUMOR_TYPE": "Tumor_Type",
    "TUMOR_TISSUE_SITE": "Tumor_Tissue_Site",
    "TMB_NONSYNONYMOUS": "Tumor_Mutational_Burden"
}

sql_order_02 = [
    "TCGA_Patient_ID", "Cancer_Type", "Cancer_Type_Detailed", "TCGA_Sample_ID",
    "Tumor_Type", "Tumor_Tissue_Site", "Tumor_Mutational_Burden"
]

staging_table_02 = "staging_table_02"

# --- File 03: Mutations ---
file_03_keep = [
    "Transcript_ID", "Hugo_Symbol", "Entrez_Gene_Id", "NCBI_Build", "HGVSp",
    "Amino_acids", "Chromosome", "Start_Position", "End_Position", "Strand",
    "Consequence", "Variant_Classification", "Variant_Type", "Reference_Allele",
    "Tumor_Seq_Allele1", "Tumor_Seq_Allele2", "Tumor_Sample_Barcode",
    "Match_Norm_Seq_Allele1", "Match_Norm_Seq_Allele2", "HGVSc", "Codons",
    "Allele", "BIOTYPE", "CCDS", "DISTANCE", "ENSP", "dbSNP_RS",
    "Exon_Number", "GMAF", "Gene", "IMPACT", "INTRON", "PolyPhen",
    "SIFT", "SWISSPROT", "TREMBL"
]

file_03_rename = {
    "Entrez_Gene_Id": "Entrez_Gene_ID",
    "Amino_acids": "Amino_Acids",
    "Tumor_Sample_Barcode": "TCGA_Sample_ID",
    "Match_Norm_Seq_Allele1": "Match_Norm_Sample_Allele1",
    "Match_Norm_Seq_Allele2": "Match_Norm_Sample_Allele2",
    "Codons": "Codon_Change",
    "BIOTYPE": "Biotype",
    "CCDS": "Consensus_Coding_Sequence",
    "DISTANCE": "Distance_to_feature",
    "ENSP": "Ensembl_Protein_ID",
    "dbSNP_RS": "dbSNP_rsID",
    "Gene": "Ensembl_Gene_ID",
    "IMPACT": "Functional_Impact",
    "INTRON": "Intron_Number",
    "PolyPhen": "PolyPhen_Prediction",
    "SIFT": "SIFT_Prediction",
    "SWISSPROT": "SwissProt_ID",
    "TREMBL": "Trembl_ID"
}

sql_order_03 = [
    "TCGA_Sample_ID", "NCBI_Build", "Consequence", "Ensembl_Gene_ID", "Hugo_Symbol",
    "Entrez_Gene_ID", "Ensembl_Protein_ID", "SwissProt_ID", "Trembl_ID",
    "Transcript_ID", "HGVSp", "Amino_Acids", "Codon_Change", "PolyPhen_Prediction",
    "SIFT_Prediction", "Start_Position", "End_Position", "Chromosome", "Strand",
    "Variant_Type", "Variant_Classification", "Reference_Allele",
    "Match_Norm_Sample_Allele1", "Match_Norm_Sample_Allele2", "Tumor_Seq_Allele1",
    "Tumor_Seq_Allele2", "Allele", "Consensus_Coding_Sequence", "Exon_Number",
    "Distance_to_feature", "Biotype", "dbSNP_rsID", "Functional_Impact",
    "Intron_Number", "HGVSc"
]

staging_table_03 = "staging_table_03"

# --- File 04: Structural Variants ---

file_04_rename = {}

# thisis the same as keep for the rest as the cleaning for this file renaming
sql_order_04 = ["Structural_Variant_ID", "TCGA_Sample_ID", "SV_Hugo_Symbol", "Effect_on_Frame", "Chromosome", "Position", "Start_or_End", "Event_Info"]

staging_table_04 = "staging_table_04"



# --- Create function to generate SQL files ---

# Create SQL file
sql_file_path = "../sql/03_load_cleaned_data.sql"

# Create/reset file once
with open(sql_file_path, "w", encoding="utf-8") as f:
    f.write("SET AUTOCOMMIT = 0;\n")
    f.write("SET UNIQUE_CHECKS = 0;\n")
    f.write("SET FOREIGN_KEY_CHECKS = 0;\n")
    f.write("START TRANSACTION;\n\n")

def export_to_optimized_sql(df, table_name, file_path, batch_size=2000):
    """
    Generates a SQL file with LOCK TABLES, DISABLE KEYS, and Batched Inserts.
    """
    with open(file_path, 'a', encoding='utf-8') as f:
        # Performance Headers
        f.write(f"\nLOCK TABLES `{table_name}` WRITE;\n")
        f.write(f"ALTER TABLE `{table_name}` DISABLE KEYS;\n\n")

        columns = ", ".join([f"`{col}`" for col in df.columns])

        # Batched Inserts
        for i in range(0, len(df), batch_size):
            batch = df.iloc[i:i + batch_size]

            f.write(f"INSERT INTO `{table_name}` ({columns}) VALUES\n")

            rows = []
            for row in batch.values:
                # Format values: handle NaNs as NULL, escape strings
                formatted_values = []
                for val in row:
                    if pd.isna(val):
                        formatted_values.append("NULL")
                    elif isinstance(val, (int, float)):
                        formatted_values.append(str(val))
                    else:
                        # Escape single quotes for SQL
                        clean_val = str(val).replace("'", "''")
                        formatted_values.append(f"'{clean_val}'")

                rows.append("(" + ", ".join(formatted_values) + ")")

            f.write(",\n".join(rows) + ";\n\n")

        # Performance Footers
        f.write(f"ALTER TABLE `{table_name}` ENABLE KEYS;\n")
        f.write("UNLOCK TABLES;\n")

# --- Create Function to reformat table 04 ---
def structural_variant_long_format(full_path):

    # Load file
    df = pd.read_csv(
        full_path,
        sep="\t",
        low_memory=False,
        comment="#"
    )

    # Add unique SV ID
    df["Structural_Variant_ID"] = range(1, len(df) + 1)

    # Create Site1 dataframe
    site1 = pd.DataFrame({
        "Structural_Variant_ID": df["Structural_Variant_ID"],
        "TCGA_Sample_ID": df["Sample_Id"],
        "Start_or_End": "Start",
        "Chromosome": df["Site1_Chromosome"],
        "SV_Hugo_Symbol": df["Site1_Hugo_Symbol"],
        "Position": df["Site1_Position"],
        "Effect_on_Frame": df["Site2_Effect_On_Frame"],
        "Event_Info": df["Event_Info"]
    })

    # Create Site2 dataframe
    site2 = pd.DataFrame({
        "Structural_Variant_ID": df["Structural_Variant_ID"],
        "TCGA_Sample_ID": df["Sample_Id"],
        "Start_or_End": "End",
        "Chromosome": df["Site2_Chromosome"],
        "SV_Hugo_Symbol": df["Site2_Hugo_Symbol"],
        "Position": df["Site2_Position"],
        "Effect_on_Frame": df["Site2_Effect_On_Frame"],
        "Event_Info": df["Event_Info"]
    })

    # Combine into long format
    df_long = pd.concat(
        [site1, site2],
        ignore_index=True
    )

    # Sort rows
    df_long = df_long.sort_values(
        by=["Structural_Variant_ID", "Start_or_End"]
    )

    # Reset index
    df_long = df_long.reset_index(drop=True)

    return df_long


# --- Execution ---

file_configs = {
    "01_data_clinical_patient.txt": (file_01_keep, file_01_rename, sql_order_01, staging_table_01),
    "02_data_clinical_sample.txt": (file_02_keep, file_02_rename, sql_order_02, staging_table_02),
    "03_data_mutations.txt": (file_03_keep, file_03_rename, sql_order_03, staging_table_03),
    "04_data_sv.txt": (sql_order_04, file_04_rename, sql_order_04, staging_table_04)
}


# Run cleaning loop and create sql tables
for file_name, (keep, rename, sql_order, staging_table) in file_configs.items():
    full_path = f"../data/raw/{file_name}"

    try:
        print(f"\n*** Processing {file_name} ***")
        if file_name == "04_data_sv.txt":
            df = structural_variant_long_format(full_path)
        else:
        # TCGA files often have 4-5 lines of headers before the actual header row
            df = pd.read_csv(full_path, sep="\t", low_memory=False, comment='#')

        # Data filtering/cleaning for file 03
        if file_name == "03_data_mutations.txt":
            df = df[
                (df["FILTER"] == "PASS") &  # Use filter column for QC made by variant caller
                (df["DBVS"] == ".") &  # Use DBVS column (variant quality / db annotation) to filter
                (df["Annotation_Status"] == "SUCCESS")
                # Use Annotation Status column to see if it was successfully filtered
                ]

        # Check for missing columns before processing
        missing_from_source = set(keep) - set(df.columns)
        if missing_from_source:
            print(f"⚠️  WARNING: The following expected columns were NOT found in {file_name}:")
            for col in missing_from_source:
                print(f"   - {col}")
        else:
            print(f"✅ All {len(keep)} expected columns found.")

        # Filter and Rename
        existing_cols = [col for col in keep if col in df.columns]
        df = df[existing_cols].rename(columns=rename)

        #Trembl cleaning for 03
        if file_name == "03_data_mutations.txt":
            # Keep first assigned Trembl ID, if multiple
            df["Trembl_ID"] = (
                df["Trembl_ID"]
                .fillna("")
                .str.split(",")
                .str[0]
                .replace("", pd.NA)
            )

        # Strip only leading and trailing whitespace from all string columns
        string_cols = df.select_dtypes(include=['object', 'string']).columns
        df[string_cols] = df[string_cols].apply(lambda x: x.str.strip())

        # Drop any duplicate rows
        df = df.drop_duplicates()

        # Check if any SQL order columns are missing after renaming
        missing_for_sql = set(sql_order) - set(df.columns)
        if missing_for_sql:
            print(f"ALERT: Columns missing for SQL staging in {file_name}:")
            for col in missing_for_sql:
                print(f"   - {col}")

        # Reorder safely (only columns that actually exist after renaming)
        valid_sql_order = [c for c in sql_order if c in df.columns]
        df = df[valid_sql_order]

        # Strip whitespace and normalize IDs
        id_cols = ["TCGA_Patient_ID", "TCGA_Sample_ID"]
        for col in id_cols:
            if col in df.columns:
                df[col] = df[col].astype(str).str.strip()

        print(f"Final Shape: {df.shape}")

        # Turn empties into NULL so works for SQL
        all_numeric_cols = [
            "Overall_Survival_Months", "Disease_Free_Status_Months", "Patient_Age",
            "Tumor_Mutational_Burden", "Entrez_Gene_ID", "Start_Position", "End_Position"
        ]

        for col in all_numeric_cols:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors='coerce')

        df = df.replace(['.', ' ', 'nan', 'NaN', 'None'], pd.NA)


        # Missing values report (Columns)

        per = 75
        missing_stats = df.isna().sum()
        if missing_stats.any():
            report_df = pd.DataFrame({
                'Missing Count': missing_stats,
                'Percentage (%)': (df.isna().mean() * 100).round(2)
            }).query('`Missing Count` > 0').sort_values(by='Missing Count', ascending=False)
            print(f"Columns with missing data:\n{report_df}")

        # Missing values report (Rows)
        row_missing_pct = (df.isna().sum(axis=1) / len(df.columns)) * 100
        sparse_rows = df[row_missing_pct > per]

        if not sparse_rows.empty:
            print(f"Found {len(sparse_rows)} rows missing > {per}% data.")
            # Use whichever ID is available for the preview
            id_preview = "TCGA_Patient_ID" if "TCGA_Patient_ID" in df.columns else "TCGA_Sample_ID"
            print(sparse_rows[[id_preview]].head())
        else:
            print(f"No rows missing more than {per}% data.")


        # Save Cleaned data file
        table_name = file_name.replace(".txt", "").replace(" ", "_")
        parts = table_name.split("_")
        prefix = parts[0]
        suffix = "_".join(parts[1:])

        clean_file_path = f"../data/cleaned/{prefix}_cleaned_{suffix}.txt"
        df.to_csv(clean_file_path, sep="\t", index=False)

        # Save SQL Upload File
        sql_file_path = "../sql/03_load_cleaned_data.sql"

        export_to_optimized_sql(df, staging_table, sql_file_path)
        print(f"SQL script generated: {sql_file_path}")

        print("-" * 40)
    except FileNotFoundError:
        print(f"File not found: {file_name}. Please check that the directories and data files are correct.")
        continue

# Finish sql file
with open(sql_file_path, "a", encoding="utf-8") as f:
    f.write("COMMIT;\n")
    f.write("SET FOREIGN_KEY_CHECKS = 1;\n")
    f.write("SET UNIQUE_CHECKS = 1;\n")
    f.write("SET AUTOCOMMIT = 1;\n")
