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

CREATE TABLE dbo.MyCI (
	MyKey INT NOT NULL
	, AnotherKey INT NOT NULL
	, SomeText CHAR(100) NULL
	, SomeLongText CHAR(1000) NULL
)
GO

-- Let's create a clustered index
CREATE CLUSTERED INDEX CI_MyCI ON dbo.MyCI(MyKey)
GO


-- Insert into empty clustered index 


DECLARE @xact_id BIGINT

BEGIN TRAN

-- This is the actual insert
-- Note the TABLOCK
INSERT INTO dbo.MyCI WITH (TABLOCK) 
SELECT *
FROM dbo.SourceTable
--ORDER BY MyKey -- Let's try without the ORDER BY!
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



-- Wait what... how could it do that without the ORDER BY?

-- Look at the query plan...
INSERT INTO dbo.MyCI WITH (TABLOCK) 
SELECT *
FROM dbo.SourceTable
--ORDER BY MyKey -- Let's try without the ORDER BY!
OPTION (RECOMPILE)



-- Implicit sort!
