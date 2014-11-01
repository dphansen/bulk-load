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

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MyHeap')
	DROP TABLE dbo.MyHeap
GO

-- Let's create a heap
CREATE TABLE dbo.MyHeap (
	MyKey INT NOT NULL
	, AnotherKey INT NOT NULL
	, SomeText CHAR(100) NULL
	, SomeLongText CHAR(1000) NULL
)
GO

CREATE NONCLUSTERED INDEX NCIX_MyKey ON dbo.MyHeap(MyKey)
GO


-- Does trace flag 610 make it minimal logged
DBCC TRACEON(610)
GO

DBCC TRACESTATUS();
GO



-- Insert a few rows into the heap. 
INSERT INTO dbo.MyHeap WITH (TABLOCK) 
SELECT *
FROM dbo.SourceTable
WHERE MyKey <= 10
GO



-- Let's see if it is minimal logged...

DECLARE @xact_id BIGINT

BEGIN TRAN

-- This is the actual insert
-- Note the TABLOCK
INSERT INTO dbo.MyHeap WITH (TABLOCK) 
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



-- Fully logged!


-- A better approach:
-- 1) Disable non-clustered indexes
-- 2) Bulk load
-- 3) Rebuild indexes


-- Let's truncate the table first
TRUNCATE TABLE dbo.MyHeap
GO

-- Insert a few rows into the heap. 
INSERT INTO dbo.MyHeap WITH (TABLOCK) 
SELECT *
FROM dbo.SourceTable
WHERE MyKey <= 10
GO


-- 1) Disable index
ALTER INDEX NCIX_MyKey ON dbo.MyHeap DISABLE
GO


-- 2) Bulk load
DECLARE @xact_id BIGINT

BEGIN TRAN

-- This is the actual insert
-- Note the TABLOCK
INSERT INTO dbo.MyHeap WITH (TABLOCK) 
SELECT *
FROM dbo.SourceTable
WHERE MyKey > 10
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



-- 3) Rebuild index
DECLARE @xact_id BIGINT

BEGIN TRAN

-- This is the actual rebuild
-- Note the TABLOCK
ALTER INDEX NCIX_MyKey ON [dbo].[MyHeap] REBUILD 
-- End of rebuild

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





-- Yay! Minimal logged operations.


-- Don't disable/drop clustered indexes with this approach



-- Turn 610 off...
DBCC TRACEOFF(610)
GO
