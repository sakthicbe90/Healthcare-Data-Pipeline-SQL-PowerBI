AutoCare Hospital Admissions: End-to-End Relational Analytics Pipeline
📖 Project Introduction
Modern healthcare systems generate massive amounts of administrative and clinical data. However, this information often sits trapped in disconnected, unstructured flat files, making it nearly impossible for leadership to glean cross-departmental insights.
This portfolio project simulates a real-world scenario where a Data Analyst at AutoCare Hospital is tasked with answering critical executive questions regarding patient throughput, demographic distributions, and clinical outcomes.
Instead of building isolated, static reports from raw spreadsheets, this project engineers a robust, end-to-end data pipeline. The workflow ingests three distinct raw healthcare datasets, transforms them into a highly optimized relational database schema within SQL Server using strict referential integrity, and surfaces actionable insights through an interactive, executive-facing Power BI dashboard.
Key Business Questions Addressed:
1. What is the total volume of patient discharges?
2. What is the average daily discharge rate across the facility?
3. What is the average Length of Stay (ALOS) per patient admission?
4. How are patient discharges distributed across distinct age demographics?
5. What is the patient volume breakdown by gender?
6. Which days of the week experience peak patient discharge traffic?

🛠️ Phase 1: Data Extraction & Database Ingestion (EL)
1. Data Sourcing
The raw data is extracted from the Kaggle dataset repository and consists of three separate entity tracking tables in flat CSV format:
• HDHI Admission data.csv (Core patient transactional log)
• Population data.csv (Regional baseline demographics)
• Mortality data.csv (Patient mortality logs)
2. Ingestion Mechanism
Using the SQL Server Import and Export Wizard, the raw CSV files were mapped and loaded directly into a local SQL Server instance database named auto care DB.
During this initial "Extract & Load" phase, the data was intentionally staged into generic tables with no structural rules, constraints, or indexing applied:
• stg_Admissions
• stg_Population
• stg_Mortality

 Phase 2: Relational Database Schema & Architecture
![Database Schema Diagram](schema_diagram.png)

Entity-Relationship Diagram (ERD) Text Breakdown
To transition this project from a collection of flat files into an enterprise-grade relational structure, the datasets were organized into a Star-like Schema Configuration. This layout establishes a central fact table surrounded by descriptive dimension tables to ensure high performance and data integrity.
1. Central Fact Table: stg_Admissions
This table acts as the transactional core of the entire database, logging every patient admission event at AutoCare Hospital.
• Primary Key (PK): SNO (Serial Number). This column holds a completely unique integer for every row, representing an individual admission record. Note: The Medical Record Number (MRD) cannot be the primary key here because a single patient can be admitted to the hospital multiple times over their lifespan.
• Foreign Key 1 (FK): Locality. This text column contains the patient's area of residence. It maps directly back to the Region_Name in the Population table, creating a Many-to-One (N:1) relationship (many patients can live in the same geographic region).
• Key Field: MRD (Medical Record Number). This unique patient identifier is used to track individual clinical histories and connects directly to the mortality logs.
2. Regional Dimension Table: stg_Population
This table acts as a master geographic lookup table containing baseline regional demographic counts.
• Primary Key (PK): Region_Name. This column stores unique geographical territory names with zero duplicates, serving as the parent record for patient residence filtering.
3. Clinical Dimension Table: stg_Mortality
This specialized table tracks confirmed patient death outcomes across the hospital network.
• Primary/Foreign Key (PK, FK): MRD. Because a single human being can logically only experience a final mortality outcome once, the MRD serves as a unique identifier here. It maps back to the MRD field in the core Admissions table, establishing a One-to-One (1:1) relationship extension.


 
