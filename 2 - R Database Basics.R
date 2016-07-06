######################################
### R For The SQL Server Developer ###
### Kevin Feasel                   ###
### 2 - R Database Basics          ###
######################################

#Note that packages are case-sensitive!
install.packages("RODBC", repos = "http://cran.us.r-project.org")
library(RODBC)

#Get help on RODBC
help(RODBC)
RShowDoc("RODBC", package="RODBC")

#Open a connection to our local SQL Server.
#We created PASSData as an ODBC connection.
conn <- odbcConnect("PASSData")

#Get a list of tables in the dbo schema.
sqlTables(conn, schema = "dbo")
#Pull in a particular table as a data frame.
registrations <- sqlFetch(conn, "dbo.SQLSatRegistrations")

#Show the top 5 registrations.
head(registrations, 5)

#Run a query to retrieve data.
#Queries are lazy executed, meaning that they will not
#run until you act upon them.
sessions <- sqlQuery(conn, paste("SELECT TOP(50) EventName, EventDate, SessionName",
                                 "FROM dbo.SQLSatSessions",
                                 "WHERE SatNum = 217",
                                 "ORDER BY SessionName DESC"))

head(sessions, 5)



#We can also create tables, insert records, and drop tables,
#but the most common use will probably be selecting from
#a table or set of tables for analysis.

#Close our ODBC connection.
close(conn)