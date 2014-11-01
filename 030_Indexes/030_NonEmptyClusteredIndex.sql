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


-- Let us just insert a few rows into the clustered index

-- Truncate the clustered index 
TRUNCATE TABLE [dbo].[FactProductInventory_ClusteredIndex]


-- Insert a few rows into the clustered index. 
INSERT INTO [dbo].[FactProductInventory_ClusteredIndex] WITH (TABLOCK) 
SELECT *
FROM [dbo].[FactProductInventory]
WHERE ProductKey = 1
GO


-- Clustered index is now non-empty... let's try insert some data 
-- into it... minimal logged?


-- First, run a CHECKPOINT - clears the log
CHECKPOINT
GO

-- Is our transaction log empty? Well... close enough :)
SELECT *
FROM ::fn_dblog(NULL,NULL)
GO



-- Insert in the clustered index. TABLOCK, so it should be minimal logged
INSERT INTO [dbo].[FactProductInventory_ClusteredIndex] WITH (TABLOCK) 
SELECT *
FROM [dbo].[FactProductInventory]
WHERE ProductKey > 1
ORDER BY ProductKey, DateKey


-- Are we minimal logged?
SELECT *
FROM ::fn_dblog(NULL,NULL)



-- Nooooooooooooo! What happened?













-- Trace flag 610 to the rescue...

DBCC TRACEON(610)


DBCC TRACESTATUS();
GO


-- Let us just insert a few rows into the clustered index (again :) )

-- Truncate the clustered index 
TRUNCATE TABLE [dbo].[FactProductInventory_ClusteredIndex]


-- Insert a few rows into the clustered index. 
INSERT INTO [dbo].[FactProductInventory_ClusteredIndex] WITH (TABLOCK) 
SELECT *
FROM [dbo].[FactProductInventory]
WHERE ProductKey = 1
GO


-- Clustered index is now non-empty... let's try insert some data 
-- into it... minimal logged?


-- First, run a CHECKPOINT - clears the log
CHECKPOINT
GO

-- Is our transaction log empty? Well... close enough :)
SELECT *
FROM ::fn_dblog(NULL,NULL)
GO



-- Insert in the clustered index. No need for TABLOCK even!
INSERT INTO [dbo].[FactProductInventory_ClusteredIndex] WITH (TABLOCK) 
SELECT *
FROM [dbo].[FactProductInventory]
WHERE ProductKey > 1
ORDER BY ProductKey, DateKey


-- Are we minimal logged?
SELECT *
FROM ::fn_dblog(NULL,NULL)



-- Nooooooooooooo! What happened?










DBCC TRACEON(610)


















-- Let us just insert a few rows into the clustered index (again :) )

-- Truncate the clustered index 
TRUNCATE TABLE [dbo].[FactProductInventory_ClusteredIndex]


-- Insert a few rows into the clustered index. 
INSERT INTO [dbo].[FactProductInventory_ClusteredIndex] WITH (TABLOCK) 
SELECT *
FROM [dbo].[FactProductInventory]
WHERE ProductKey = 1
GO


ALTER TABLE [dbo].[FactProductInventory_ClusteredIndex] 
NOCHECK CONSTRAINT [FK_FactProductInventory_ClusteredIndex_DimDate]

ALTER TABLE [dbo].[FactProductInventory_ClusteredIndex] 
NOCHECK CONSTRAINT [FK_FactProductInventory_ClusteredIndex_DimProduct]


-- Clustered index is now non-empty... let's try insert some data 
-- into it... minimal logged?


-- First, run a CHECKPOINT - clears the log
CHECKPOINT
GO

-- Is our transaction log empty? Well... close enough :)
SELECT *
FROM ::fn_dblog(NULL,NULL)
GO



DBCC TRACEON(610)

-- Insert in the clustered index. No need for TABLOCK even!
INSERT INTO [dbo].[FactProductInventory_ClusteredIndex] WITH (TABLOCK) 
SELECT *
FROM [dbo].[FactProductInventory]
WHERE ProductKey > 1
ORDER BY ProductKey, DateKey


-- Are we minimal logged?
SELECT *
FROM ::fn_dblog(NULL,NULL)



-- Nooooooooooooo! What happened?