# Business Problem & Project Objective

## 1. The Business Context
The client is a UK-based online retailer specializing in unique all-occasion gifts. Despite having a large transaction volume (500,000+ records), the business lacks a centralized view of performance. They rely on raw transactional logs and do not have visibility into customer retention or regional performance.

## 2. The Problem
The stakeholders are currently unable to answer critical questions:
* **Churn:** Which customers have stopped buying, and how much revenue is at risk?
* **Seasonality:** When do sales peak, and how should inventory be planned?
* **Geography:** Which markets are driving growth, and which are underperforming?

## 3. The Objective
Build an end-to-end Business Intelligence pipeline to:
1.  **Ingest and clean** raw transaction data to remove errors (cancellations, missing IDs).
2.  **Develop a Churn Risk model** using SQL to flag customers inactive for 90+ days.
3.  **Visualize KPIs** in Power BI to track Revenue, AOV, and Churn Rate in real-time.