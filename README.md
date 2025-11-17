# Hospital-Readmission-Prediction-Analysis-SQL

![](Focus_hospital.jpg)

# Introduction

This project is an SQL project about the likelihood of hospital readmission

**_Disclaimer_** : **_All datasets and reports do not represent any company, institution, or country, but are used to demonstrate Analysis using sql_**

# Objective 

To Identify Risk Factors of the likelihood of patient readmission

# The following were achieved using SQL
- Data Merging
- Data Structure and Type Casting
- Feature Engineering (Indexing)
- Data Cleaning

# Step-by-Step and Findings

- Data Merging

The data was successfully merged with the query written

Using (UNION ALL) to combine the datasets (train_data, test_data) into a single table.

    UNION ALL

    SELECT
        age::INTEGER,
        gender::TEXT,
        primary_diagnosis::TEXT,
        num_procedures::INTEGER,
        days_in_hospital::INTEGER,
        comorbidity_score::NUMERIC,
        discharge_to::TEXT,
        FALSE::BOOLEAN AS readmitted,  
        'test'::TEXT AS source
    FROM test_data


- Data Structure and Type Casting

A new table schema was created (CREATE TABLE AS) and explicitly converting data types (e.g., age::INTEGER, readmitted::BOOLEAN).

- Feature Engineering (Indexing)
  
A unique, sequential patient identifier was created (patient_id) using the ROW_NUMBER() window function.

- Data Cleaning

The data was achieved by using removing duplicates using **PARTITION BY clauses and the DELETE statement**. out of **7,000 rows**, **8 rows** were deleted to maintain the total number of **6,992 rows** after successful cleaning

![](data_cleaning.JPG)

# The Analysis

This includes the analysis and the findings 

- To categorize by age to count the total diseases by age range
- The ultimate goal of the analysis is to understand the patient profile associated with readmission
- To calculate the Readmission Rate for each Discharge Location
- To analyze how the Primary Diagnosis affects the readmission rate
- To determine if there is any significant difference in the readmission rate between males and females

# Insights


## To categorize by age to count the total diseases by age range


- Chronic diseases like Kidney Disease, Heart Disease, Hypertension, COPD, and Diabetes are consistently leading causes of readmission across all age groups.

- Unexpectedly, the youngest age group (0–40) shows the highest readmission numbers, which may require targeted intervention.

- The decline in readmission numbers in older adults (81+) may reflect system-level or patient-level factors rather than a true reduced risk.
  

## The ultimate goal of the analysis is to understand the patient profile associated with readmission


- Hospital Readmission Summary (Key Points)

Total patients analyzed: 4,996

- 18.8% of patients were readmitted (about 1 in 5)

- 81.2% were not readmitted



