# 🏥 Hospital Discharge Analytics — SQL Server Project

![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-blue)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 📌 Project Overview

This project analyzes hospital patient discharge data using 
Microsoft SQL Server (T-SQL). It transforms raw admission records 
into actionable insights for hospital management, covering patient 
volumes, demographics, length of stay, and discharge timing patterns.

---

## 🎯 Business Questions Answered

| # | Question |
|---|----------|
| 1 | How many patients were successfully discharged? |
| 2 | What is the average number of discharges per day? |
| 3 | How long do patients typically stay in the hospital? |
| 4 | How many bed-days are used per discharged patient? |
| 5 | Which age groups have the most discharges? |
| 6 | What is the gender split among discharged patients? |
| 7 | Which days of the week see the most discharges? |

---

## 🗄️ Database Details

| Property       | Value                     |
|----------------|---------------------------|
| Database Name  | HealthDB                  |
| Source Table   | HDHI Admission data       |
| Clean View     | dbo.vw_AdmissionData      |
| SQL Dialect    | Microsoft T-SQL           |
| Tool Used      | SQL Server Management Studio (SSMS) |

---

## 📊 Key Metrics Analyzed

### 1️⃣ Total Discharges
- Count of all patients with OUTCOME = 'DISCHARGE'

### 2️⃣ Average Daily Discharge Rate
- Average number of patients discharged per calendar day

### 3️⃣ Average Length of Stay (LOS)
- Mean duration of hospital stay in days
- Excludes incomplete or erroneous records

### 4️⃣ Bed-Days Per Discharge
- Total bed-days consumed per discharged patient
- Key resource utilization metric

### 5️⃣ Age Group Distribution
| Age Group | Description  |
|-----------|-------------|
| 0–17      | Pediatric   |
| 18–30     | Young Adult |
| 31–45     | Adult       |
| 46–60     | Middle Age  |
| 61–75     | Senior      |
| 75+       | Elderly     |

### 6️⃣ Gender Analysis
- Male vs Female discharge distribution with percentages

### 7️⃣ Day-of-Week Discharge Patterns
- Discharge volumes by weekday (Monday through Sunday)
- Supports staffing and operational planning

---

## 🧹 Data Quality Measures
