
# Global Layoffs Analysis 📉

## Overview

The **Global Layoffs Analysis** project explores trends in workforce reductions across industries, regions, and funding stages. Using **SQL** for data cleaning and analysis, this project uncovers key drivers of layoffs and offers actionable insights into global layoff trends from raw datasets.

This project is structured around two datasets:
1. **`layoffs-cleaned.csv`**: A cleaned version of the raw data with duplicates removed and columns standardized.
2. **`layoffs-EDA.csv`**: Enhanced data used for exploratory analysis, including additional calculated fields for detailed insights.

---

## Project Goals

1. **Analyze Yearly Trends**:
   - Track layoffs by year and industry to uncover long-term patterns.
2. **Explore Geographic Impacts**:
   - Identify which regions are most affected by layoffs and why.
3. **Correlate Layoffs with Funding Stages**:
   - Understand how funding stages influence layoff trends in startups.

---

## Features

### 1. Data Cleaning and Transformation
- **Cleaning Steps**:
  - Removed duplicates and standardized column values (e.g., industry names, funding stages).
  - Resolved missing values by replacing or filtering them based on business rules.
  - Generated the `layoffs-cleaned.csv` dataset for consistent analysis.

### 2. SQL-Based Exploratory Analysis
- Used SQL to:
  - Aggregate layoffs by year, industry, and geographic regions.
  - Analyze funding stage correlations with layoffs.
  - Identify trends across regions and industries.

### 3. Exploratory Data Analysis (EDA)
- Created the `layoffs-EDA.csv` dataset with additional derived metrics, including:
  - Percentage of layoffs by funding stage.
  - Average layoffs per industry per year.

---

## Repository Contents

| File/Folder Name            | Description                                                                 |
|-----------------------------|-----------------------------------------------------------------------------|
| `data/layoffs-cleaned.csv`  | Cleaned dataset for reliable analysis.                                      |
| `data/layoffs-EDA.csv`      | Enhanced dataset with additional calculated fields for EDA.                 |
| `sql/`                      | SQL scripts for data cleaning and exploratory analysis.                     |
| `README.md`                 | Project overview and detailed instructions.                                |
| `LICENSE`                   | License for the project.                                                   |

---

## SQL Scripts

### **1. Yearly Layoff Trends**
Query to calculate layoffs by year and industry:
```sql
SELECT 
    Year, 
    Industry, 
    SUM(NumberOfLayoffs) AS TotalLayoffs
FROM 
    Layoffs
GROUP BY 
    Year, Industry
ORDER BY 
    Year ASC, TotalLayoffs DESC;
```

### **2. Funding Stage Analysis**
Query to analyze layoffs by funding stage:
```sql
SELECT 
    FundingStage, 
    COUNT(Company) AS CompaniesAffected, 
    SUM(NumberOfLayoffs) AS TotalLayoffs
FROM 
    Layoffs
GROUP BY 
    FundingStage
ORDER BY 
    TotalLayoffs DESC;
```

### **3. Regional Analysis**
Query to identify layoff trends by region:
```sql
SELECT 
    Region, 
    Year, 
    SUM(NumberOfLayoffs) AS TotalLayoffs
FROM 
    Layoffs
GROUP BY 
    Region, Year
ORDER BY 
    Year ASC, TotalLayoffs DESC;
```

---

## How to Use This Repository

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Sohila-Khaled-Abbas/global-layoffs-analysis.git
   ```

2. **Load the Data**:
   - Use `data/layoffs-cleaned.csv` for SQL-based analysis.
   - Use `data/layoffs-EDA.csv` for detailed exploratory analysis.

3. **Run SQL Queries**:
   - Navigate to the `sql/` folder and use the provided scripts for analysis:
     - `layoffs-by-year.sql`
     - `funding-stage-analysis.sql`
     - `geographic-trends.sql`

4. **Perform EDA**:
   - Use `layoffs-EDA.csv` to explore trends in Python, Power BI, or other analytics tools.

---

## Key Insights and Findings

### 1. Industries Most Affected
- **Top Impacted**: Technology and Retail faced the highest layoffs globally.
- **Least Affected**: Healthcare and Education remained relatively stable.

### 2. Geographic Trends
- **North America**: Largest layoffs due to a dense startup ecosystem.
- **Europe**: Layoffs primarily impacted the manufacturing sector.

### 3. Funding Stage Correlations
- **Seed and Series A**: Higher frequency of layoffs during funding challenges.
- **Late-Stage Startups (Series D+)**: Fewer but more significant layoffs.

---

## Future Enhancements

1. **Real-Time Data**:
   - Incorporate live layoff data via APIs for continuous updates.

2. **Predictive Modeling**:
   - Build machine learning models to forecast layoffs based on funding stage and industry trends.

3. **Interactive Dashboards**:
   - Create Power BI/Tableau dashboards for advanced exploration of layoff trends.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## About Me

👋 I’m **Sohila Khaled Galal Abbas**, a passionate data analyst specializing in **SQL** and **data analytics**.  
Let’s connect:  
- **LinkedIn**: [linkedin.com/in/sohilakhaledabbas](https://www.linkedin.com/in/sohilakhaledabbas)  
- **GitHub**: [github.com/Sohila-Khaled-Abbas](https://github.com/Sohila-Khaled-Abbas)



This version is designed to provide clear instructions and structure for SQL-based analysis. Let me know if you need any modifications!
