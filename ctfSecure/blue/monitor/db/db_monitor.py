#!/usr/bin/python3

import mysql.connector
from mysql.connector.errors import Error
from datetime import datetime, timezone, timedelta

def closeConnection(mydb):
    if mydb is not None and mydb.is_connected():
        mydb.close()

def connectToDB():
    try:
        mydb = mysql.connector.connect(
            host = "localhost",
            database = "ourdb",
            user = "offtech",
            password = "UnRsqUlTE3lufZR09gw2"
        )
        return mydb
    except Error as e:
        print(f"Error during DB connection:{e}")

def logAlert(msg):
    log = open("/tmp/logConsistency.txt", "a")
    log.write(f"{msg}\n")
    log.close()

def checkConsistency(mydb, query, flag):
    now = datetime.now(timezone(timedelta(hours=+1))).strftime("%Y-%m-%d %H:%M:%S") 
    cursor = mydb.cursor()
    cursor.execute(query)
    users = cursor.fetchall()
    if not users:
        # Empty results, all good
        if flag:
            msg = f"[{now}] All good for negative amounts"
        else:
            msg = f"[{now}] All good for not allowed transactions"
    else:
        # Found negative balance or not allowed transaction, not good
        for user in users:
            if flag:
                msg = f"[{now}]NEGATIVE USER --> {user[0]}:{user[1]}"
            else:
                msg = f"[{now}]NOT ALLOWED TRANSACTION --> {user[0]}:{user[1]}"
            
    print(msg)
    logAlert(msg)

def main():
    negative_balance_query = "SELECT username, SUM(amount) AS balance FROM transfers_secure_table_random GROUP BY (username) HAVING balance < 0;"
    not_allowed_user_query = "SELECT username, amount FROM transfers_secure_table_random WHERE username NOT IN (SELECT username FROM users_secure_table);"
    mydb = connectToDB()
    if mydb is not None and mydb.is_connected():
        checkConsistency(mydb, negative_balance_query, True)
        checkConsistency(mydb, not_allowed_user_query, False)
    closeConnection(mydb)

if __name__ == "__main__":
    main()
