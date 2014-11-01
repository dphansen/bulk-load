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

-- Let us just insert 10 rows into the heap


-- Insert 10 rows into the heap. 
INSERT INTO dbo.MyHeap WITH (TABLOCK) 
SELECT TOP 10 *
FROM dbo.SourceTable
GO


-- Heap is now non-empty... let's try insert some data into it... 
-- Minimal logged?

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





-- Yay!





