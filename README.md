AutoCare Hospital Admissions: End-to-End Relational Analytics Pipeline
📖 Project Introduction
Modern healthcare analytics recognizes that public health outcomes do not exist in a vacuum; environmental factors profoundly shape patient volumes and hospital constraints. However, air quality logs, weather metrics, and clinical admission records are rarely consolidated, leaving leadership blind to how environmental shocks influence daily operations.
This portfolio project simulates a real-world scenario where a Data Analyst at AutoCare Hospital is tasked with answering critical executive questions regarding patient throughput, clinical outcomes, and their specific relationships to daily atmospheric pollution levels.
Instead of building isolated, static reports from raw spreadsheets, this project engineers a robust, end-to-end data pipeline. The workflow ingests three distinct raw data categories (Hospital Admissions, Air Quality/Pollution index logs, and Patient Mortality records), transforms them into a highly optimized relational database schema within SQL Server using strict referential integrity, and surfaces actionable insights through an interactive, executive-facing Power BI dashboard.

Key Business Questions Addressed:
1. Operational Benchmarks: What is the total volume of patient discharges, average daily discharge rate, and average Length of Stay (ALOS) across the facility?
2. Demographic Footprint: How are patient admissions and discharges distributed across distinct age demographics and gender classifications?
3. Weekly Fluctuations: Which days of the week experience peak patient discharge traffic and admission surges?
4. Air Quality Correlatives: Do spikes in the Air Quality Index (AQI) or specific particulates (like PM2.5) directly correlate with immediate surges in daily hospital admission volumes?
5. Weather & Strain: How do extreme changes in daily environmental variables—such as maximum temperature peaks or humidity fluctuations—impact a patient's average Length of Stay (ALOS)?
Severe Pollution Outcomes: Is there a measurable relationship between periods of severe air pollution index (AQI) scores and critical clinical metrics like post-admission mortality outcomes?

🛠️ Phase 1: Data Extraction & Database Ingestion (EL)
1. Data Sourcing
The raw data is extracted from the Kaggle dataset repository and consists of three separate entity tracking tables in flat CSV format:
• HDHI Admission data.csv (Core patient transactional log)
• Pollution data.csv (Regional baseline demographics)
• Mortality data.csv (Patient mortality logs)
2. Ingestion Mechanism
Using the SQL Server Import and Export Wizard, the raw CSV files were mapped and loaded directly into a local SQL Server instance database named auto care DB.
During this initial "Extract & Load" phase, the data was intentionally staged into generic tables with no structural rules, constraints, or indexing applied:
• stg_Admissions
• stg_Pollution
• stg_Mortality

 Phase 2: Relational Database Schema & Architecture
![Database Schema Diagram](schema_diagram.png)

Entity-Relationship Diagram (ERD) Text Breakdown
To transition this project from a collection of flat files into an enterprise-grade relational structure, the datasets were organized into a Star-like Schema Configuration. This layout establishes a central transactional fact table surrounded by descriptive environmental and clinical dimension tables to maximize performance and guarantee data integrity.
1. Central Fact Table: stg_Admissions
This table acts as the transactional core of the entire database, logging every individual patient admission event at AutoCare Hospital.
• Primary Key (PK): SNO (Serial Number). This column holds a completely unique integer for every row, representing a specific admission record. Note: The Medical Record Number (MRD) cannot be the primary key here because a single patient can be admitted to the hospital multiple times over their lifespan.
• Foreign Key 1 (FK): Admission_Date. This column records the calendar date of the patient's entry. It maps directly back to the DATE primary key column in the stg_Pollution table, creating a Many-to-One (N:1) relationship (multiple patients can be admitted on the exact same date under the same environmental conditions).
• Key Field: MRD (Medical Record Number). This unique patient identifier tracks clinical histories across individual rows and connects directly to the mortality logs.
2. Environmental Dimension Table: stg_Pollution
This table acts as a chronological timeline lookup containing master records of localized daily atmospheric pollution metrics and weather status updates.
• Primary Key (PK): DATE. This column stores completely unique calendar dates with zero duplicates, serving as the master anchor for cross-examining admission volumes against daily Air Quality Index (AQI) ratings, PM2.5 averages, temperature peaks, and humidity levels.
3. Clinical Dimension Table: stg_Mortality
This specialized table tracks confirmed patient death outcomes across the hospital network.
• Primary/Foreign Key (PK, FK): MRD. Because an individual patient can logically only experience a final mortality outcome once, the MRD serves as a completely unique identifier here. It maps directly back to the matching MRD field in the core stg_Admissions table, establishing a clean One-to-One (1:1) relationship extension.




 
