# 🎮 ABC Pvt. Ltd. – Loyalty Points Analysis
## 📌 Project Overview
This project simulates a **real-world gaming platform** where users deposit money, play games, and withdraw winnings.  

The company wanted to design a **Loyalty Rewards System** to:
- ✅ Calculate **loyalty points** for every user  
- ✅ Rank players fairly (using **tie-breakers**)  
- ✅ Distribute a **bonus pool of ₹50,000** among the **Top 50 loyal players**  

As a Data Analyst, I built this system entirely in **MySQL**, from **raw data cleaning → loyalty point calculation → ranking → bonus allocation**.

---

## 🎯 Objectives
1. 📊 Calculate monthly **loyalty points** for each user  
2. 🏆 Rank users by loyalty points (tie-breaker = games played)  
3. 🎖️ Build a **Top 50 leaderboard**  
4. 💰 Distribute ₹50,000 bonus proportionally among top 50  
5. 🔎 Analyze overall user behavior (deposits, withdrawals, gameplay)  

---

## 🗂️ Dataset
Three input datasets were used:

1. **User Gameplay Data** → `USER_ID`, `GAMEPLAYED`, `LONG_DATE`  
2. **Deposit Data** → `USER_ID`, `DATETIME`, `AMOUNT`  
3. **Withdrawal Data** → `USER_ID`, `DATETIME`, `AMOUNT`  

---

## 🧮 Loyalty Points Formula
The loyalty formula was designed to balance **financial activity** and **engagement**:

Loyalty Points =
(0.01 × Total_Deposits)

(0.005 × Total_Withdrawals)

(0.001 × MAX(Deposit_Count – Withdrawal_Count, 0))

(0.2 × Total_Games_Played)

markdown
Copy code

---

## 🔧 Approach & Methodology
1. 📥 **Data Preparation**  
   - Imported CSVs → MySQL  
   - Cleaned dates & null values  

2. 🔄 **Data Aggregation (October 2023)**  
   - Total games, deposits, withdrawals  
   - Transaction counts  

3. 🗃️ **Data Merging**  
   - Used **UNION + LEFT JOIN** to simulate `FULL OUTER JOIN` in MySQL  

4. 🧮 **Loyalty Points Calculation**  
   - Applied weighted formula  
   - Used `GREATEST()` to avoid negatives  

5. 🏅 **Ranking Users**  
   - `RANK() OVER (ORDER BY Loyalty DESC, Games DESC)`  
   - Tie-breaking by games played  

6. 💰 **Bonus Distribution**  
   - Selected Top 50  
   - Proportional allocation:  
     ```
     Bonus = (User_Loyalty / Total_Loyalty_Top50) × 50000
     ```

---

## 📊 Key Insights
- Top 50 users contributed **most deposits & games**  
- Gameplay strongly influenced loyalty ranking  
- Bonus distribution was **fair & proportional**  
- Avg Deposit per User (Oct): ₹XXXX  
- Avg Games per User (Oct): XX  

---

## 📂 Repository Structure
ABC-Loyalty-Points-Analysis/
├── main(Assignment).sql # Full SQL code (all steps)
├── data/ # Sample CSVs
├── report/ # PDF & PPT report
├── visuals/ # Leaderboard charts, banner
└── README.md # Project documentation

yaml
Copy code

---

## 🚀 How to Run
1. Create database:
   ```sql
   CREATE DATABASE abc_loyalty;
   USE abc_loyalty;
Run the script:

bash
Copy code
mysql -u <username> -p abc_loyalty < main(Assignment).sql
View outputs:

user_loyalty_oct → Loyalty points

Leaderboard query → Ranked users

Bonus query → Bonus distribution
