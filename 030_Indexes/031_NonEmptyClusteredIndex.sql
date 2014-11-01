/* Demo script for Bulk load: methods for better data warehouse load performance
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com
 *
 * This script is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */



USE BulkLoadDemo
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MyCI')
	DROP TABLE dbo.MyCI
GO

-- Let's create a clustered indexed table
CREATE TABLE dbo.MyCI (
	MyKey INT NOT NULL
	, AnotherKey INT NOT NULL
	, SomeText CHAR(100) NULL
	, SomeLongText CHAR(1000) NULL
)
GO

CREATE CLUSTERED INDEX CI_MyCI ON dbo.MyCI(MyKey)
GO


-- Let us just insert a few rows into the clustered index
INSERT INTO dbo.MyCI WITH (TABLOCK) 
SELECT *
FROM dbo.SourceTable
WHERE MyKey <= 10
GO


-- Clustered index is now non-empty... let's try insert some data 
-- into it... minimal logged?

DECLARE @xact_id BIGINT

BEGIN TRAN

-- This is the actual insert
-- Note the TABLOCK
INSERT INTO dbo.MyCI WITH (TABLOCK) 
SELECT *
FROM dbo.SourceTable
WHERE MyKey > 10
ORDER BY MyKey
OPTION (RECOMPILE)
-- End of insert

-- Get the xact ID from our current explicit transaction
SELECT @xact_id = transaction_id 
FROM sys.dm_tran_current_transaction

COMMIT TRAN

-- Get the entries in the transaction log related to the
-- above transaction doing an insert
SELECT  [Current LSN], [Operation], [AllocUnitName], [Context]
	, [Transaction ID] , [Transaction Name], [Xact ID]
FROM ::fn_dblog(NULL,NULL)
WHERE [Transaction ID] = (
	SELECT TOP 1 [Transaction ID] 
	FROM ::fn_dblog(NULL,NULL)
	WHERE [Xact ID] = @xact_id)
GO




-- Nooooooooooooo! What happened?












-- Trace flag 610 to the rescue...
DBCC TRACEON(610)
GO

DBCC TRACESTATUS();
GO

-- Let's try again... 
TRUNCATE TABLE dbo.MyCI
GO


-- Insert a few rows into the clustered index. 
INSERT INTO dbo.MyCI WITH (TABLOCK) 
SELECT *
FROM dbo.SourceTable
WHERE MyKey <= 10
GO



DECLARE @xact_id BIGINT

BEGIN TRAN

-- This is the actual insert
-- Note the TABLOCK
INSERT INTO dbo.MyCI --WITH (TABLOCK) 
SELECT *
FROM dbo.SourceTable
WHERE MyKey > 10
--ORDER BY MyKey
OPTION (RECOMPILE)
-- End of insert

-- Get the xact ID from our current explicit transaction
SELECT @xact_id = transaction_id 
FROM sys.dm_tran_current_transaction

COMMIT TRAN

-- Get the entries in the transaction log related to the
-- above transaction doing an insert
SELECT  [Current LSN], [Operation], [AllocUnitName], [Context]
	, [Transaction ID] , [Transaction Name], [Xact ID]
FROM ::fn_dblog(NULL,NULL)
WHERE [Transaction ID] = (
	SELECT TOP 1 [Transaction ID] 
	FROM ::fn_dblog(NULL,NULL)
	WHERE [Xact ID] = @xact_id)
GO




-- What happens if we insert the same data with the same
-- clustered key? There is no PK, so this is perfectly OK
-- (although, probably not what you want to do :) )
-- 610 is still enabled!

DECLARE @xact_id BIGINT

BEGIN TRAN

-- This is the actual insert
-- Note the TABLOCK
INSERT INTO dbo.MyCI --WITH (TABLOCK) 
SELECT *
FROM dbo.SourceTable
--WHERE MyKey > 10
--ORDER BY MyKey
OPTION (RECOMPILE)
-- End of insert

-- Get the xact ID from our current explicit transaction
SELECT @xact_id = transaction_id 
FROM sys.dm_tran_current_transaction

COMMIT TRAN

-- Get the entries in the transaction log related to the
-- above transaction doing an insert
SELECT  [Current LSN], [Operation], [AllocUnitName], [Context]
	, [Transaction ID] , [Transaction Name], [Xact ID]
FROM ::fn_dblog(NULL,NULL)
WHERE [Transaction ID] = (
	SELECT TOP 1 [Transaction ID] 
	FROM ::fn_dblog(NULL,NULL)
	WHERE [Xact ID] = @xact_id)
GO


-- Fully logged! Page splits!


-- Let's look at what it did to fragmentation of the clustered inex
SELECT OBJECT_NAME(object_id) AS object_name
	, avg_fragmentation_in_percent
	, index_type_desc
	, *
FROM sys.dm_db_index_physical_stats (
	DB_ID ('BulkLoadDemo'),
	NULL,
	NULL,
	NULL,
	'LIMITED');






-- Turn 610 off...
DBCC TRACEOFF(610)
GO
