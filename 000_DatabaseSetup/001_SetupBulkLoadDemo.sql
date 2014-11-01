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

USE master
GO

IF DATABASEPROPERTYEX ('BulkLoadDemo', 'Version') > 0
	DROP DATABASE BulkLoadDemo
GO

CREATE DATABASE BulkLoadDemo
GO


ALTER DATABASE BulkLoadDemo 
SET RECOVERY SIMPLE WITH NO_WAIT
GO

USE BulkLoadDemo
GO
CREATE TABLE dbo.SourceTable (
	MyKey INT NOT NULL
	, AnotherKey INT NOT NULL
	, SomeText CHAR(100)
	, SomeLongText CHAR(1000)
)
GO

DECLARE @i INT = 1

WHILE @i <= 100000
BEGIN
	INSERT INTO dbo.SourceTable
	VALUES (@i, @i + 1000000, 'Some text', 'Hep hey!')

	SET @i = @i + 1
END

