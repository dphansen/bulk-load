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



-- We need to set the recovery model to SIMPLE or BULK_LOGGED
USE [master]
GO
ALTER DATABASE [AdventureWorksDW2012] 
SET RECOVERY SIMPLE WITH NO_WAIT
GO



USE AdventureWorksDW2012
GO




TRUNCATE TABLE [dbo].[FactProductInventory_Heap]
GO 

/* Can we make the INSERT INTO ... SELECT minimal logged ? */

DECLARE @xact_id BIGINT

BEGIN TRAN

-- This is the actual insert
-- Note the TABLOCK
INSERT INTO [dbo].[FactProductInventory_Heap] WITH (TABLOCK) 
SELECT *
FROM [dbo].[FactProductInventory]
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








-- Yap! Yay!











/* What about BULK INSERT? */
TRUNCATE TABLE [dbo].[FactProductInventory_Heap]
GO 

DECLARE @xact_id BIGINT

BEGIN TRAN

-- This is the actual insert
BULK INSERT [dbo].[FactProductInventory_Heap]
FROM 'C:\temp\FactProductInventory.txt'
WITH 
	(
		FIELDTERMINATOR =',',
		ROWTERMINATOR ='\n',
		TABLOCK -- Note the TABLOCK
	);
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




-- Minimal logged! TABLOCK did the trick









IF EXISTS (SELECT 1 FROM sys.tables 
			WHERE name = 'FactProductInventory_Heap2')
	DROP TABLE [dbo].[FactProductInventory_Heap2]
GO

CHECKPOINT

/* So... SELECT INTO ? */

DECLARE @xact_id BIGINT

BEGIN TRAN

-- This is the actual insert
SELECT *
INTO [dbo].[FactProductInventory_Heap2]
FROM [dbo].[FactProductInventory]
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






-- Better! 7906 vs 2694 entries in the transaction log






