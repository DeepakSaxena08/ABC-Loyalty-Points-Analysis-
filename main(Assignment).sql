###################################################################################################################
################################################## CREATING THE TABLE ###############################################

CREATE TABLE deposite_data (
    user_id VARCHAR(50),
    datetime DATETIME,
    amount DECIMAL(10,2)
);

CREATE TABLE withdrawal_data (
    user_id VARCHAR(50),
    datetime DATETIME,
    amount DECIMAL(10,2)
);

CREATE TABLE user_gameplayed_data (
    user_id VARCHAR(50),
    game_played int(50),
    datetime DATETIME
  
);

#######################################LOADING THE DATA FROM LOCAL HOST##################################################

###############################################DEPOSITE_DATA.SCV###################################################
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/deposite data.csv'
INTO TABLE deposite_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, @datetime, amount)
SET datetime = STR_TO_DATE(@datetime, '%Y-%m-%d %H:%i:%s');

############################################ WITHDRAWAL_DATA.CSV ###################################################

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/withdrawal data.csv'
INTO TABLE withdrawal_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, @datetime, amount)
SET datetime = STR_TO_DATE(@datetime, '%Y-%m-%d %H:%i:%s');

############################################## USER GAMEPLAY DATA.CSV ###################################################

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/user gameplay data.csv'
INTO TABLE user_gameplayed_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, game_played , @datetime)
SET datetime = STR_TO_DATE(@datetime, '%Y-%m-%d %H:%i:%s');


SHOW WARNINGS;

############################################ Total Games Played ####################################################

CREATE TEMPORARY TABLE total_games AS
SELECT 
    USER_ID, 
    SUM(GAME_PLAYED) AS Total_Games
FROM 
    user_gameplayed_data
GROUP BY 
    USER_ID;

select * from total_games;


################################################ Deposit Summary ##################################################

CREATE TEMPORARY TABLE deposite_summary AS
SELECT 
    USER_ID,
    SUM(AMOUNT) AS Total_Deposite,
    COUNT(*) AS Num_Deposite
FROM 
    deposite_data
GROUP BY 
    USER_ID;

select * from deposite_summary;


############################################### Withdrawal Summary ################################################

######## note #######  I HAVE TO MAKE THE COPY OF TEMPORARY TABLE BECAUSE I HAVE EMCOUNTERED THE ERROR "FILE NOT
#####################  OPENING " AGIN ITS MEAN WE CAN NOT OPEN THE SAME T.FILE IN THE SAME QUERY AGAIN


CREATE TEMPORARY TABLE withdraw_summary_copy AS
SELECT * FROM withdraw_summary;						

CREATE TEMPORARY TABLE withdraw_summary AS
SELECT 
    USER_ID,
    SUM(AMOUNT) AS Total_Withdrawal,
    COUNT(*) AS Num_Withdrawal
FROM 
    withdrawal_data
GROUP BY 
    USER_ID;
    
select * from withdraw_summary;

######## note #######  I HAVE TO MAKE THE COPY OF TEMPORARY TABLE BECAUSE I HAVE EMCOUNTERED THE ERROR "FILE NOT"
#####################  OPEN AGIN ITS MEAN WE CAN NOT OPEN THE SAME T.FILE IN THE SAME QUERY AGAIN


CREATE TEMPORARY TABLE deposite_summary_copy AS
SELECT * FROM deposite_summary;


CREATE TEMPORARY TABLE total_games_copy AS
SELECT * FROM total_games;

############################################### GAME-DEPOSITE MERGE ################################################


CREATE TEMPORARY TABLE game_deposite_merge AS
SELECT 
    COALESCE(g.USER_ID, d.USER_ID) AS USER_ID,
    COALESCE(g.Total_Games, 0) AS Total_Games,
    COALESCE(d.Total_Deposite, 0) AS Total_Deposite,
    COALESCE(d.Num_Deposite, 0) AS Num_Deposite
FROM 
    total_games_copy g
LEFT JOIN deposite_summary d ON g.USER_ID = d.USER_ID

UNION

SELECT 
    COALESCE(g.USER_ID, d.USER_ID) AS USER_ID,
    COALESCE(g.Total_Games, 0) AS Total_Games,
    COALESCE(d.Total_Deposite, 0) AS Total_Deposite,
    COALESCE(d.Num_Deposite, 0) AS Num_Deposite
FROM 
    deposite_summary_copy d
LEFT JOIN total_games g ON g.USER_ID = d.USER_ID;


######## note #######  I HAVE TO MAKE THE COPY OF TEMPORARY TABLE BECAUSE I HAVE EMCOUNTERED THE ERROR "FILE NOT"
#####################  OPEN AGIN ITS MEAN WE CAN NOT OPEN THE SAME T.FILE IN THE SAME QUERY AGAIN



CREATE TEMPORARY TABLE game_deposite_merge_copy AS
SELECT * FROM game_deposite_merge;

############################################### GAME-DEPOSITE-WITHDRAWAL MERGE ################################################

######## note #######  USING UNION TO REPLICATE THE FULL OUTER JOIN
#####################  
CREATE TEMPORARY TABLE merged_data AS

-- LEFT JOIN part
SELECT 
    COALESCE(gd.USER_ID, w.USER_ID) AS USER_ID,
    COALESCE(gd.Total_Deposite, 0) AS Total_Deposite,
    COALESCE(gd.Num_Deposite, 0) AS Num_Deposite,
    COALESCE(gd.Total_Games, 0) AS Total_Games,
    COALESCE(w.Total_Withdrawal, 0) AS Total_Withdrawal,
    COALESCE(w.Num_Withdrawal, 0) AS Num_Withdrawal
FROM 
    game_deposite_merge_copy gd
LEFT JOIN withdraw_summary w ON gd.USER_ID = w.USER_ID

UNION

-- RIGHT JOIN part
SELECT 
    COALESCE(gd.USER_ID, w.USER_ID) AS USER_ID,
    COALESCE(gd.Total_Deposite, 0) AS Total_Deposite,
    COALESCE(gd.Num_Deposite, 0) AS Num_Deposite,
    COALESCE(gd.Total_Games, 0) AS Total_Games,
    COALESCE(w.Total_Withdrawal, 0) AS Total_Withdrawal,
    COALESCE(w.Num_Withdrawal, 0) AS Num_Withdrawal
FROM 
    withdraw_summary_copy w
LEFT JOIN game_deposite_merge gd ON w.USER_ID = gd.USER_ID;


#################################### Part A - Calculating loyalty points###########################################

############################################# user loyalty points #################################################

CREATE TABLE user_loyalty AS
SELECT 
    USER_ID,
    Total_Deposite,
    Num_Deposite,
    Total_Withdrawal,
    Num_Withdrawal,
    Total_Games,
    
    ROUND(
        (0.01 * Total_Deposite) +
        (0.005 * Total_Withdrawal) +
        (0.001 * GREATEST(Num_Deposite - Num_Withdrawal, 0)) +
        (0.2 * Total_Games), 2
    ) AS Loyalty_Points
FROM 
    merged_data;

select * from user_loyalty;


###################################################################################################################

############# On each day, there are 2 slots for each of which the loyalty points are to be calculated:###########

############################################### S1 from 12am to 12pm #############################################

############################################### s2 from 12pm to 12am ###############################################

######## Based on the above information and the data provided answer the following questions:

################# Find Playerwise Loya Ity points earned by Players in the following slots:-#######################

############################################ Qa. 2nd October Slot S 1 ##############################################

SELECT 
    g.USER_ID,
    
    ROUND(
        0.01 * IFNULL(d.Deposite_Amount, 0) +
        0.005 * IFNULL(w.Withdraw_Amount, 0) +
        0.001 * GREATEST(IFNULL(d.Deposite_Count, 0) - IFNULL(w.Withdraw_Count, 0), 0) +
        0.2 * IFNULL(g.Total_Games, 0),
        2
    ) AS Loyalty_Points

FROM (
    SELECT USER_ID, SUM(GAME_PLAYED) AS Total_Games
    FROM user_gameplayed_data
    WHERE DATETIME BETWEEN '2022-10-02 00:00:00' AND '2022-10-02 11:59:59'
    GROUP BY USER_ID
) g

LEFT JOIN (
    SELECT USER_ID, SUM(AMOUNT) AS Deposite_Amount, COUNT(*) AS Deposite_Count
    FROM deposite_data
    WHERE DATETIME BETWEEN '2022-10-02 00:00:00' AND '2022-10-02 11:59:59'
    GROUP BY USER_ID
) d ON g.USER_ID = d.USER_ID

LEFT JOIN (
    SELECT USER_ID, SUM(AMOUNT) AS Withdraw_Amount, COUNT(*) AS Withdraw_Count
    FROM withdrawal_data
    WHERE DATETIME BETWEEN '2022-10-02 00:00:00' AND '2022-10-02 11:59:59'
    GROUP BY USER_ID
) w ON g.USER_ID = w.USER_ID;


############################################## Qb. 16th October Slot S2 #########################################################


SELECT 
    g.USER_ID,
    
    ROUND(
        0.01 * IFNULL(d.Deposite_Amount, 0) +
        0.005 * IFNULL(w.Withdraw_Amount, 0) +
        0.001 * GREATEST(IFNULL(d.Deposite_Count, 0) - IFNULL(w.Withdraw_Count, 0), 0) +
        0.2 * IFNULL(g.Total_Games, 0),
        2
    ) AS Loyalty_Points

FROM (
    SELECT USER_ID, SUM(GAME_PLAYED) AS Total_Games
    FROM user_gameplayed_data
    WHERE DATETIME BETWEEN '2022-10-16 12:00:00' AND '2022-10-16 23:59:59'
    GROUP BY USER_ID
) g

LEFT JOIN (
    SELECT USER_ID, SUM(AMOUNT) AS Deposite_Amount, COUNT(*) AS Deposite_Count
    FROM deposite_data
    WHERE DATETIME BETWEEN '2022-10-16 12:00:00' AND '2022-10-16 23:59:59'
    GROUP BY USER_ID
) d ON g.USER_ID = d.USER_ID

LEFT JOIN (
    SELECT USER_ID, SUM(AMOUNT) AS Withdraw_Amount, COUNT(*) AS Withdraw_Count
    FROM withdrawal_data
    WHERE DATETIME BETWEEN '2022-10-16 12:00:00' AND '2022-10-16 23:59:59'
    GROUP BY USER_ID
) w ON g.USER_ID = w.USER_ID;

######################################### QC. 18th October Slot S1 ##############################################################


SELECT 
    g.USER_ID,
    
    ROUND(
        0.01 * IFNULL(d.Deposite_Amount, 0) +
        0.005 * IFNULL(w.Withdraw_Amount, 0) +
        0.001 * GREATEST(IFNULL(d.Deposite_Count, 0) - IFNULL(w.Withdraw_Count, 0), 0) +
        0.2 * IFNULL(g.Total_Games, 0),
        2
    ) AS Loyalty_Points

FROM (
    SELECT USER_ID, SUM(GAME_PLAYED) AS Total_Games
    FROM user_gameplayed_data
    WHERE DATETIME BETWEEN '2022-10-18 00:00:00' AND '2022-10-18 11:59:59'
    GROUP BY USER_ID
) g

LEFT JOIN (
    SELECT USER_ID, SUM(AMOUNT) AS Deposite_Amount, COUNT(*) AS Deposite_Count
    FROM deposite_data
    WHERE DATETIME BETWEEN '2022-10-18 00:00:00' AND '2022-10-18 11:59:59'
    GROUP BY USER_ID
) d ON g.USER_ID = d.USER_ID

LEFT JOIN (
    SELECT USER_ID, SUM(AMOUNT) AS Withdraw_Amount, COUNT(*) AS Withdraw_Count
    FROM withdrawal_data
    WHERE DATETIME BETWEEN '2022-10-18 00:00:00' AND '2022-10-18 11:59:59'
    GROUP BY USER_ID
) w ON g.USER_ID = w.USER_ID;


########################################### QD. 26th October Slot S2 ############################################################


SELECT 
    g.USER_ID,
    
    ROUND(
        0.01 * IFNULL(d.Deposite_Amount, 0) +
        0.005 * IFNULL(w.Withdraw_Amount, 0) +
        0.001 * GREATEST(IFNULL(d.Deposite_Count, 0) - IFNULL(w.Withdraw_Count, 0), 0) +
        0.2 * IFNULL(g.Total_Games, 0),
        2
    ) AS Loyalty_Points

FROM (
    SELECT USER_ID, SUM(GAME_PLAYED) AS Total_Games
    FROM user_gameplayed_data
    WHERE DATETIME BETWEEN '2022-10-26 12:00:00' AND '2022-10-26 23:59:59'

    GROUP BY USER_ID
) g

LEFT JOIN (
    SELECT USER_ID, SUM(AMOUNT) AS Deposite_Amount, COUNT(*) AS Deposite_Count
    FROM deposite_data
    WHERE DATETIME BETWEEN '2022-10-26 12:00:00' AND '2022-10-26 23:59:59'

    GROUP BY USER_ID
) d ON g.USER_ID = d.USER_ID

LEFT JOIN (
    SELECT USER_ID, SUM(AMOUNT) AS Withdraw_Amount, COUNT(*) AS Withdraw_Count
    FROM withdrawal_data
    WHERE DATETIME BETWEEN '2022-10-26 12:00:00' AND '2022-10-26 23:59:59'

    GROUP BY USER_ID
) w ON g.USER_ID = w.USER_ID;


############################ Q2. Calculate overall loyalty points earned and #######################################
################# rank players on the basis of loyalty points in the month of October. ############################
######## In case of tie, number of games played should be taken as the next criteria for ranking.##################

###################################################################################################################


###################################################  game_oct ###


CREATE TEMPORARY TABLE game_oct AS
SELECT 
    USER_ID,
    SUM(GAME_PLAYED) AS Total_Games
FROM user_gameplayed_data
WHERE DATETIME BETWEEN '2022-10-01' AND '2022-10-31'
GROUP BY USER_ID;


###################################################  deposite_oct ###

select * from deposite_oct
CREATE TEMPORARY TABLE deposite_oct AS
SELECT 
    USER_ID,
    SUM(AMOUNT) AS Total_Deposite,
    COUNT(*) AS Num_Deposite
FROM deposite_data
WHERE DATETIME BETWEEN '2022-10-01' AND '2022-10-31'
GROUP BY USER_ID;

####################################################  withdraw_oct ###


DROP TEMPORARY TABLE IF EXISTS withdraw_oct;
CREATE TEMPORARY TABLE withdraw_oct AS
SELECT 
    USER_ID,
    SUM(AMOUNT) AS Total_Withdrawal,
    COUNT(*) AS Num_Withdrawal
FROM withdrawal_data
WHERE DATETIME BETWEEN '2022-10-01' AND '2022-10-31'
GROUP BY USER_ID;

######## note #######  I HAVE TO MAKE THE COPY OF TEMPORARY TABLE BECAUSE I HAVE EMCOUNTERED THE ERROR "FILE NOT"
#####################  OPEN AGIN ITS MEAN WE CAN NOT OPEN THE SAME T.FILE IN THE SAME QUERY AGAIN


create temporary table  game_oct_copy as
select * from game_oct ;

create temporary table deposite_oct_copy as
select * from deposite_oct;

################################################# game_deposite_merge_oct ##########################################


CREATE TEMPORARY TABLE game_deposite_merge_oct AS
SELECT 
    COALESCE(g.USER_ID, d.USER_ID) AS USER_ID,
    IFNULL(g.Total_Games, 0) AS Total_Games,
    IFNULL(d.Total_Deposite, 0) AS Total_Deposite,
    IFNULL(d.Num_Deposite, 0) AS Num_Deposite
FROM 
    game_oct_copy g
LEFT JOIN deposite_oct d ON g.USER_ID = d.USER_ID

UNION

SELECT 
    COALESCE(g.USER_ID, d.USER_ID) AS USER_ID,
    IFNULL(g.Total_Games, 0) AS Total_Games,
    IFNULL(d.Total_Deposite, 0) AS Total_Deposite,
    IFNULL(d.Num_Deposite, 0) AS Num_Deposite
FROM 
    deposite_oct_copy d
LEFT JOIN game_oct g ON g.USER_ID = d.USER_ID;



######## note #######  I HAVE TO MAKE THE COPY OF TEMPORARY TABLE BECAUSE I HAVE EMCOUNTERED THE ERROR "FILE NOT"
#####################  OPEN AGIN ITS MEAN WE CAN NOT OPEN THE SAME T.FILE IN THE SAME QUERY AGAIN

CREATE TEMPORARY TABLE game_deposite_merge_oct_copy AS
SELECT * FROM game_deposite_merge_oct;

CREATE TEMPORARY TABLE withdraw_oct_copy as
select * from withdraw_oct;

################################################# merged_october_data ############################################

CREATE TEMPORARY TABLE merged_october_data AS
SELECT 
    COALESCE(gd.USER_ID, w.USER_ID) AS USER_ID,
    IFNULL(gd.Total_Games, 0) AS Total_Games,
    IFNULL(gd.Total_Deposite, 0) AS Total_Deposite,
    IFNULL(gd.Num_Deposite, 0) AS Num_Deposite,
    IFNULL(w.Total_Withdrawal, 0) AS Total_Withdrawal,
    IFNULL(w.Num_Withdrawal, 0) AS Num_Withdrawal
FROM 
    game_deposite_merge_oct_copy gd
LEFT JOIN withdraw_oct w ON gd.USER_ID = w.USER_ID

UNION

SELECT 
    COALESCE(gd.USER_ID, w.USER_ID) AS USER_ID,
    IFNULL(gd.Total_Games, 0) AS Total_Games,
    IFNULL(gd.Total_Deposite, 0) AS Total_Deposite,
    IFNULL(gd.Num_Deposite, 0) AS Num_Deposite,
    IFNULL(w.Total_Withdrawal, 0) AS Total_Withdrawal,
    IFNULL(w.Num_Withdrawal, 0) AS Num_Withdrawal
FROM 
    withdraw_oct_copy w
LEFT JOIN game_deposite_merge_OCT gd ON w.USER_ID = gd.USER_ID;

########################################## user_loyalty_oct ######################################################

DROP temporary table IF  EXISTS user_loyalty_oct;
CREATE TEMPORARY TABLE user_loyalty_oct AS
SELECT 
    USER_ID,
    Total_Deposite,
    Num_Deposite,
    Total_Withdrawal,
    Num_Withdrawal,
    Total_Games,
    ROUND(
        0.01 * Total_Deposite +
        0.005 * Total_Withdrawal +
        0.001 * GREATEST(Num_Deposite - Num_Withdrawal, 0) +
        0.2 * Total_Games,
        2
    ) AS Loyalty_Points
FROM merged_october_data;
  
  
  ########################################## user_loyalty_oct WITH RANK ###########################################
  
  
  SELECT 
    USER_ID,
    Total_Deposite,
    Num_Deposite,
    Total_Withdrawal,
    Num_Withdrawal,
    Total_Games,
    Loyalty_Points,
    RANK() OVER (
        ORDER BY Loyalty_Points DESC, Total_Games DESC
    ) AS Loyalty_Rank
FROM user_loyalty_oct;

  
  select * from user_loyalty_oct;


#################################### Q3. What is the average deposit amount? #############################################################################

SELECT 
    ROUND(AVG(Amount), 2) AS Avg_Deposite_Amount
FROM 
    deposite_data;
    
########################## 4. What is the average deposit amount per user in a month?##############################

############# NOTE - I AM ASSUMING THE OCT MONTH
SELECT 
    ROUND(AVG(User_Deposite), 2) AS Avg_Deposite_Per_User
FROM (
    SELECT 
        USER_ID,
        SUM(AMOUNT) AS User_Deposite
    FROM 
        deposite_data
    WHERE 
        DATETIME BETWEEN '2022-10-01' AND '2022-10-31'
    GROUP BY 
        USER_ID
) AS per_user
;

########################## Q5. What is the average number of games played per user?####################################################################################


SELECT 
    ROUND(AVG(Total_Games), 2) AS Avg_Games_Per_User
FROM (
    SELECT 
        USER_ID,
        
        
        SUM(GAME_PLAYED) AS Total_Games
    FROM 
        user_gameplayed_data
    GROUP BY USER_ID
) AS user_games;
 

############### Part B - How much bonus should be allocated to leaderboard players? ###############################

####################### After calculating the loyalty points for the whole month ##################################
##################### find out which 50 players are at the top of the leaderboard #################################
###### The company has allocated a pool of Rs 50000 to be given away as a bonus money to the loyal players ########
########### Now the company needs to determine how much bonus money should be given to the players ################

########################### Should they base it on the amount of loyalty points? ################################## 
######################### Should it be based on number of games? Or something else? ###############################

### That's for you to figure out.


 ############################# NOTE 1. Only top 50 ranked players are awarded bonus ###############################



##################################### PROPORTIONAL TO LOYALTY POINTS ##############################################


######################## LOYALTY POINTS ARE DESIGNED TO REFLECT USER VALUE TO THE PLATFORM --- ####################
################################# BASED ON DEPOSITE, WITHDRAWAL AND GAMEPLAY ######################################

#          METHOD------(( USER LOYALTY PONITS )/ ( TOTAL LOYALTY POINTS OF TOP 50 ) ) * 50000


DROP TEMPORARY TABLE IF EXISTS top50_users_loyalty;

CREATE TEMPORARY TABLE top50_users_loyalty AS
SELECT 
    user_id, 
    loyalty_points
FROM 
    user_loyalty
ORDER BY 
    loyalty_points DESC
LIMIT 50;


SELECT 
    SUM(loyalty_points) 
INTO 
    @total_lp 
FROM 
    top50_users_loyalty;
    
select sum(bonus_amount) from (
SELECT 
    user_id,
    loyalty_points,
    ROUND((loyalty_points / @total_lp) * 50000, 2) AS bonus_amount
FROM 
    top50_users_loyalty

) as t;



