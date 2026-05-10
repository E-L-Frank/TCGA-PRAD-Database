# Example Queries

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
