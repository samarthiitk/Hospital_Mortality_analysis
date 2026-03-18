/* =====================================================
   HOSPITAL MORTALITY DATA ANALYSIS
   Author: Samarth Singh
   Description: SQL analysis on ICU patient survival dataset
===================================================== */

-- Fix missing ethnicity values
UPDATE patient_survival.ps_data
SET ethnicity = 'Mixed'
WHERE ethnicity = '';



/* ===============================
   Mortality Count & Rate
================================ */

SELECT 
    COUNT(CASE WHEN hospital_death = 1 THEN 1 END) AS total_hospital_deaths,
    ROUND(
        COUNT(CASE WHEN hospital_death = 1 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS mortality_rate
FROM patient_survival.ps_data;



/* ===============================
   Death count by Ethnicity
================================ */

SELECT 
    ethnicity,
    COUNT(*) AS total_hospital_deaths
FROM patient_survival.ps_data
WHERE hospital_death = 1
GROUP BY ethnicity;



/* ===============================
   Death count by Gender
================================ */

SELECT 
    gender,
    COUNT(*) AS total_hospital_deaths
FROM patient_survival.ps_data
WHERE hospital_death = 1
GROUP BY gender;



/* ===============================
   Age comparison (Dead vs Alive)
================================ */

SELECT 
    hospital_death,
    ROUND(AVG(age),2) AS avg_age,
    MAX(age) AS max_age
FROM patient_survival.ps_data
GROUP BY hospital_death;



/* ===============================
   Death vs Survival by Age
================================ */

SELECT 
    age,
    COUNT(CASE WHEN hospital_death = 1 THEN 1 END) AS died,
    COUNT(CASE WHEN hospital_death = 0 THEN 1 END) AS survived
FROM patient_survival.ps_data
GROUP BY age
ORDER BY age;



/* ===============================
   Age distribution (10 year groups)
================================ */

SELECT
    CONCAT(FLOOR(age/10)*10, '-', FLOOR(age/10)*10 + 9) AS age_interval,
    COUNT(*) AS patient_count
FROM patient_survival.ps_data
GROUP BY age_interval
ORDER BY age_interval;



/* ===============================
   Death comparison by age ranges
================================ */

SELECT
    COUNT(CASE WHEN age > 65 AND hospital_death = 1 THEN 1 END) AS died_over_65,
    COUNT(CASE WHEN age BETWEEN 50 AND 65 AND hospital_death = 1 THEN 1 END) AS died_50_65,
    COUNT(CASE WHEN age > 65 AND hospital_death = 0 THEN 1 END) AS survived_over_65,
    COUNT(CASE WHEN age BETWEEN 50 AND 65 AND hospital_death = 0 THEN 1 END) AS survived_50_65
FROM patient_survival.ps_data;



/* ===============================
   Death probability by age group
================================ */

SELECT
    CASE
        WHEN age < 40 THEN 'Under 40'
        WHEN age < 60 THEN '40-59'
        WHEN age < 80 THEN '60-79'
        ELSE '80+'
    END AS age_group,
    ROUND(AVG(apache_4a_hospital_death_prob),3) AS avg_death_prob
FROM patient_survival.ps_data
GROUP BY age_group;



/* ===============================
   ICU admit source comparison
================================ */

SELECT
    icu_admit_source,
    COUNT(CASE WHEN hospital_death = 1 THEN 1 END) AS died,
    COUNT(CASE WHEN hospital_death = 0 THEN 1 END) AS survived
FROM patient_survival.ps_data
GROUP BY icu_admit_source;



/* ===============================
   Average age of deaths by ICU type
================================ */

SELECT
    icu_type,
    COUNT(*) AS deaths,
    ROUND(AVG(age),2) AS avg_age
FROM patient_survival.ps_data
WHERE hospital_death = 1
GROUP BY icu_type;



/* ===============================
   Avg weight, BMI, heart rate of deaths
================================ */

SELECT
    ROUND(AVG(weight),2) AS avg_weight,
    ROUND(AVG(bmi),2) AS avg_bmi,
    ROUND(AVG(d1_heartrate_max),2) AS avg_max_heartrate
FROM patient_survival.ps_data
WHERE hospital_death = 1;



/* ===============================
   Top 5 ethnicities with highest BMI
================================ */

SELECT
    ethnicity,
    ROUND(AVG(bmi),2) AS avg_bmi
FROM patient_survival.ps_data
GROUP BY ethnicity
ORDER BY avg_bmi DESC
LIMIT 5;



/* ===============================
   Comorbidity counts
================================ */

SELECT
    SUM(aids) AS aids,
    SUM(cirrhosis) AS cirrhosis,
    SUM(diabetes_mellitus) AS diabetes,
    SUM(hepatic_failure) AS hepatic_failure,
    SUM(immunosuppression) AS immunosuppression,
    SUM(leukemia) AS leukemia,
    SUM(lymphoma) AS lymphoma,
    SUM(solid_tumor_with_metastasis) AS solid_tumor
FROM patient_survival.ps_data;



/* ===============================
   Mortality rate
================================ */

SELECT
    ROUND(
        COUNT(CASE WHEN hospital_death = 1 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS mortality_rate
FROM patient_survival.ps_data;



/* ===============================
   Elective surgery percentage
================================ */

SELECT
    ROUND(
        COUNT(CASE WHEN elective_surgery = 1 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS elective_surgery_percentage
FROM patient_survival.ps_data;



/* ===============================
   ICU stay comparison
================================ */

SELECT
    icu_type,
    ROUND(AVG(CASE WHEN hospital_death = 1 THEN pre_icu_los_days END),2) AS stay_death,
    ROUND(AVG(CASE WHEN hospital_death = 0 THEN pre_icu_los_days END),2) AS stay_survived
FROM patient_survival.ps_data
GROUP BY icu_type;



/* ===============================
   BMI categories
================================ */

SELECT
    CASE
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi < 25 THEN 'Normal'
        WHEN bmi < 30 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category,
    COUNT(*) AS patient_count
FROM patient_survival.ps_data
WHERE bmi IS NOT NULL
GROUP BY bmi_category;



/* ===============================
   High risk SICU patients
================================ */

SELECT
    patient_id,
    apache_4a_hospital_death_prob AS death_probability
FROM patient_survival.ps_data
WHERE icu_type = 'SICU'
AND bmi > 30
ORDER BY death_probability DESC;
