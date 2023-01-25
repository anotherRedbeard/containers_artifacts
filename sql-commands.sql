-- Creates the login sqlDrivingAdmin with password 
CREATE LOGIN sqlDrivingAdmin   
    WITH PASSWORD = '<password>';  
GO  

use mydrivingDB;
-- Creates a database user for the login created above.  
CREATE USER sqlDrivingAdmin FOR LOGIN sqlDrivingAdmin;  
GO  

alter role db_datareader add member sqlDrivingAdmin
go
alter role db_datawriter add member sqlDrivingAdmin
go