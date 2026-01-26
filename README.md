# MNT-Halan-Data-Migration-Pipeline-Denormalization-to-3NF

1. Project Overview

A high-performance ETL and Database Design project transforming 1M+ rows of messy B2C logistics data into a normalized MySQL schema. Optimized ingestion with Python/SQLAlchemy, resolved complex Arabic encoding (utf8mb4), and implemented a 3NF ERD to handle unique account-profile relationships.

2. The Project Journey: Challenges & Solutions

Challenge A: The Encoding Crisis (Arabic Text Support)

The Problem: During the Python ingestion phase (SQLAlchemy), Arabic text was being corrupted or displayed as garbled characters (Mojibake).

The Insight: I discovered that while utf8 is standard, MySQL’s utf8mb4_0900_ai_ci is the superior collation for modern Arabic support. SQLAlchemy's default often creates a mismatch.
The Solution: I standardized the entire database and connection strings to utf8mb4, ensuring full data integrity for names and addresses in Arabic.

Challenge B: Data Archeology & Normalization
The Problem: The raw data was heavily denormalized (50+ columns). Specifically, the "Customer Name" field was being used as a "dumping ground" for notes and addresses (up to 95 characters).

The Solution: I refactored the schema into a One-to-Many relationship between Accounts and Profiles. This allowed one Account Code to host multiple customer profiles with unique addresses.

Challenge C: The Phone Number Standard
The Problem: Excel stripped leading zeros from phone numbers, and some entries included inconsistent country codes, making the data unusable for automated SMS/calling.

The Solution: I converted these to VARCHAR and applied the E.164 International Standard logic. I noted Google’s libphonenumber as the best-practice tool for future validation.

Challenge D: 1-Million Row Performance Optimization
The Problem: Initial INSERT queries were hanging for over 15 minutes or timing out.

The Solution: 1. Implemented B-Tree Indexing on all foreign key columns. 2. Used Bulk Transactions (START TRANSACTION). 3. Temporarily disabled FOREIGN_KEY_CHECKS during the load.

Result: Reduced migration time to under 5 minutes.

3. Data Architecture (ERD)
![Database ERD](./intial ERD.png)
![Database ERD](./Final_ERD.png)

5. How to Use This Repository
Prerequisites:

Python 3.x

MySQL Server

Libraries: pandas, sqlalchemy, pymysql 

Setup:

Clone the repo: git clone https://github.com/yourusername/your-repo-name

Install dependencies: pip install -r requirements.txt

Run the schema setup: Import schema.sql into your MySQL instance.

Run the migration: Open migrate_data.ipynb to execute the ETL pipeline.

I learned how to handle PII (Personally Identifiable Information), why you chose VARCHAR over INT for phone numbers, and how you balanced database performance vs. data integrity. This shows you have "Senior" thinking even if you are just starting out.
