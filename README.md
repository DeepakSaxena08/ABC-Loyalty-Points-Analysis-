# 🎮 ABC Pvt. Ltd. – Loyalty Points Analysis

This project analyzes deposit, withdrawal, and gameplay data to calculate **loyalty points** for users of a gaming platform.  
It also ranks players fairly and distributes a bonus pool of ₹50,000 to the top 50 players.

## 📂 Contents
- `main(Assignment).sql` → End-to-end SQL code (table creation → data load → loyalty points → ranking → bonus allocation)
- `data/` → Sample CSV data (deposit, withdrawal, gameplay)
- `report/` → Project report and slides
- `visuals/` → Charts and banners

## 📊 Business Problem
- Calculate loyalty points based on deposits, withdrawals, and games
- Rank players (loyalty points + games as tie-breaker)
- Allocate bonus pool proportionally
- Analyze average deposits and games

## 🛠️ Tech Used
- **MySQL 8.0**
- Excel/CSV (input)
- PowerPoint / PDF (output report)

## 🚀 Run Instructions
1. Create a new database in MySQL:
   ```sql
   CREATE DATABASE abc_loyalty;
   USE abc_loyalty;
