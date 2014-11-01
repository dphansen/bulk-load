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


-- Let us just insert 10 rows into the heap

-- Truncate the heap 
TRUNCATE TABLE [dbo].[FactProductInventory_Heap]


-- Insert 10 rows into the heap. 
INSERT INTO [dbo].[FactProductInventory_Heap] WITH (TABLOCK) 
SELECT TOP 10 *
FROM [dbo].[FactProductInventory]
GO


-- Heap is now non-empty... let's try insert some data into it... 
-- Minimal logged?


-- First, run a CHECKPOINT - clears the log
CHECKPOINT
GO

-- Is our transaction log empty? Well... close enough :)
SELECT *
FROM ::fn_dblog(NULL,NULL)
GO



-- Insert in the heap. TABLOCK, so it is minimal logged
INSERT INTO [dbo].[FactProductInventory_Heap] WITH (TABLOCK) 
SELECT *
FROM [dbo].[FactProductInventory]


-- Are we minimal logged?
SELECT *
FROM ::fn_dblog(NULL,NULL)



-- Yay!





