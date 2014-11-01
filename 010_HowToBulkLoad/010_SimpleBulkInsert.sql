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

USE [master]
GO
ALTER DATABASE [AdventureWorksDW2012] 
SET RECOVERY FULL WITH NO_WAIT
GO

USE AdventureWorksDW2012
GO

-- Let's get the time it takes to load
SET STATISTICS TIME ON

-- Truncate that heap
TRUNCATE TABLE [dbo].[FactProductInventory_Heap]
GO 

DBCC DROPCLEANBUFFERS
GO

-- First, a normal row-by-row insert
INSERT INTO [dbo].[FactProductInventory_Heap]
SELECT *
FROM [dbo].[FactProductInventory]
GO

-- CPU time = 3812 ms,  elapsed time = 6407 ms.


-- Truncate again...
TRUNCATE TABLE [dbo].[FactProductInventory_Heap]
GO 

DBCC DROPCLEANBUFFERS
GO

-- Let's try a BULK INSERT from a text file
BULK INSERT [dbo].[FactProductInventory_Heap]
FROM 'c:\temp\FactProductInventory.txt'
WITH 
	(
		FIELDTERMINATOR =',',
		ROWTERMINATOR ='\n'
	);

-- CPU time = 1390 ms,  elapsed time = 3490 ms.



TRUNCATE TABLE [dbo].[FactProductInventory_Heap]
GO 


DBCC DROPCLEANBUFFERS
GO

-- What abou the bcp utility?
-- Remember that service user have access to folder
-- This should normally be run from the command shell
EXEC xp_cmdshell 'bcp AdventureWorksDW2012.dbo.FactProductInventory_Heap in "c:\temp\FactProductInventory.txt" -c -T -S sql2014demo01\sqldemo01 -t,'
GO

--  CPU time = 0 ms,  elapsed time = 4432 ms.





IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FactProductInventory_Heap2')
	DROP TABLE [dbo].[FactProductInventory_Heap2]
GO

DBCC DROPCLEANBUFFERS
GO

-- SELECT INTO - is that faster?
SELECT *
INTO [dbo].[FactProductInventory_Heap2]
FROM [dbo].[FactProductInventory]


-- CPU time = 438 ms,  elapsed time = 1028 ms.



-- Why is bulk logged from text file not sigificant faster than row-by-row?
-- Why is SELECT INTO so much faster?
