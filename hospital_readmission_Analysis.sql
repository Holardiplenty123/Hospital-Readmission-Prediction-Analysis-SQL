
--- merging the data together
CREATE TABLE hospital_readmission_project AS
WITH combined AS (
    SELECT
        age::INTEGER,
        gender::TEXT,
        primary_diagnosis::TEXT,
        num_procedures::INTEGER,
        days_in_hospital::INTEGER,
        comorbidity_score::NUMERIC,
        discharge_to::TEXT,
        readmitted::BOOLEAN,  -- This column exists in 'train_data'
        'train'::TEXT AS source
    FROM train_data

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
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE WHEN source = 'train' THEN 1 ELSE 2 END,
            age
    ) AS patient_id,
    age,
    gender,
    primary_diagnosis,
    num_procedures,
    days_in_hospital,
    comorbidity_score,
    discharge_to,
    readmitted,
    source
FROM combined;

Select * from hospital_readmission_project limit 200;

--- checking for missing values
SELECT
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN primary_diagnosis IS NULL THEN 1 ELSE 0 END) AS missing_primary_diagnosis,
    SUM(CASE WHEN num_procedures IS NULL THEN 1 ELSE 0 END) AS missing_num_procedures,
    SUM(CASE WHEN days_in_hospital IS NULL THEN 1 ELSE 0 END) AS missing_days_in_hospital,
    SUM(CASE WHEN comorbidity_score IS NULL THEN 1 ELSE 0 END) AS missing_comorbidity_score,
    SUM(CASE WHEN discharge_to IS NULL THEN 1 ELSE 0 END) AS missing_discharge_to
FROM hospital_readmission_project;


--- checking for duplicates
SELECT
    age, gender, primary_diagnosis, num_procedures, days_in_hospital, comorbidity_score, discharge_to, readmitted,
    COUNT(*) AS duplicate_count
FROM hospital_readmission_project
GROUP BY
    age, gender, primary_diagnosis, num_procedures, days_in_hospital, comorbidity_score, discharge_to, readmitted
HAVING
    COUNT(*) > 1;

--- delete the duplicates columns
DELETE FROM hospital_readmission_project
WHERE patient_id IN (
    SELECT patient_id
    FROM (
        SELECT
            patient_id,
            ROW_NUMBER() OVER(
                PARTITION BY
                    age, gender, primary_diagnosis, num_procedures,
                    days_in_hospital, comorbidity_score, discharge_to, readmitted
                ORDER BY patient_id
            ) as rn
        FROM hospital_readmission_project
    ) AS T
    WHERE T.rn > 1 
);

SELECT COUNT(*) FROM hospital_readmission_project;

Select * from hospital_readmission_project;

--- EDA

SELECT
    -- Age
    COUNT(age) AS count_age,
    ROUND(AVG(age), 2) AS mean_age,
    ROUND(STDDEV(age), 2) AS stddev_age,
    MIN(age) AS min_age,
    MAX(age) AS max_age,

    -- Number of Procedures
    COUNT(num_procedures) AS count_procedures,
    ROUND(AVG(num_procedures), 2) AS mean_procedures,
    ROUND(STDDEV(num_procedures), 2) AS stddev_procedures,
    MIN(num_procedures) AS min_procedures,
    MAX(num_procedures) AS max_procedures,

    -- Days in Hospital
    COUNT(days_in_hospital) AS count_days,
    ROUND(AVG(days_in_hospital), 2) AS mean_days,
    ROUND(STDDEV(days_in_hospital), 2) AS stddev_days,
    MIN(days_in_hospital) AS min_days,
    MAX(days_in_hospital) AS max_days,

    -- Comorbidity Score
    COUNT(comorbidity_score) AS count_comorbidity,
    ROUND(AVG(comorbidity_score), 2) AS mean_comorbidity,
    ROUND(STDDEV(comorbidity_score), 2) AS stddev_comorbidity,
    MIN(comorbidity_score) AS min_comorbidity,
    MAX(comorbidity_score) AS max_comorbidity
FROM hospital_readmission_project;


--- Grouping of diseases by age range
SELECT
    CASE
        WHEN age BETWEEN 0 AND 40 THEN '0-40 Years'
        WHEN age BETWEEN 41 AND 60 THEN '41-60 Years'
        WHEN age BETWEEN 61 AND 80 THEN '61-80 Years'
        ELSE '81+ Years'
    END AS Age_Group,
    primary_diagnosis,
    COUNT(*) AS Total_Count
FROM
    hospital_readmission_project
GROUP BY
    Age_Group, primary_diagnosis
ORDER BY
    Age_Group, Total_Count DESC;
	
--- to determine people that need readmission
SELECT
    readmitted,
    COUNT(*) AS total_patients,
    -- Average Age of the group
    ROUND(AVG(age), 2) AS avg_age,
    -- Average Number of Procedures
    ROUND(AVG(num_procedures), 2) AS avg_num_procedures,
    -- Average Days in Hospital
    ROUND(AVG(days_in_hospital), 2) AS avg_days_in_hospital,
    -- Average Comorbidity Score
    ROUND(AVG(comorbidity_score), 2) AS avg_comorbidity_score
FROM
    hospital_readmission_project
WHERE
    source = 'train' -- Only analyze the training data where the label is known
GROUP BY
    readmitted
ORDER BY
    readmitted;


---Readmission Rate by Discharge Location
SELECT
    discharge_to,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN readmitted = TRUE THEN 1 ELSE 0 END) AS total_readmitted,
    -- Calculate the percentage of readmitted patients for each discharge location
    ROUND(AVG(CASE WHEN readmitted = TRUE THEN 1.0 ELSE 0 END) * 100, 2) AS readmission_rate_percent
FROM
    hospital_readmission_project
WHERE
    source = 'train' -- Crucial: Only analyze data where readmitted status is known
GROUP BY
    discharge_to
ORDER BY
    readmission_rate_percent DESC;

--- Readmission Rate by Primary Diagnosis
SELECT
    primary_diagnosis,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN readmitted = TRUE THEN 1 ELSE 0 END) AS total_readmitted,
    -- Calculate the percentage of readmitted patients for each diagnosis
    ROUND(AVG(CASE WHEN readmitted = TRUE THEN 1.0 ELSE 0 END) * 100, 2) AS readmission_rate_percent
FROM
    hospital_readmission_project
WHERE
    source = 'train' -- Focus only on data where the readmitted status is known
GROUP BY
    primary_diagnosis
ORDER BY
    readmission_rate_percent DESC;

--- Readmission Rate by Gender
SELECT
    gender,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN readmitted = TRUE THEN 1 ELSE 0 END) AS total_readmitted,
    -- Calculate the percentage of readmitted patients for each gender
    ROUND(AVG(CASE WHEN readmitted = TRUE THEN 1.0 ELSE 0 END) * 100, 2) AS readmission_rate_percent
FROM
    hospital_readmission_project
WHERE
    source = 'train' -- Analyzing only the labeled data
GROUP BY
    gender
ORDER BY
    readmission_rate_percent DESC;