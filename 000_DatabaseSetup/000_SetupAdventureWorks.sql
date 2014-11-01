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

CREATE TABLE [dbo].[FactProductInventory_Heap] (
      [ProductKey] [INT] NOT NULL
    , [DateKey] [INT] NOT NULL
    , [MovementDate] [DATE] NOT NULL
    , [UnitCost] [MONEY] NOT NULL
    , [UnitsIn] [INT] NOT NULL
    , [UnitsOut] [INT] NOT NULL
    , [UnitsBalance] [INT] NOT NULL
    )
ON  [PRIMARY]
GO

ALTER TABLE [dbo].[FactProductInventory_Heap]  WITH CHECK ADD  CONSTRAINT [FK_FactProductInventory_Heap_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO

ALTER TABLE [dbo].[FactProductInventory_Heap] CHECK CONSTRAINT [FK_FactProductInventory_Heap_DimDate]
GO

ALTER TABLE [dbo].[FactProductInventory_Heap]  WITH CHECK ADD  CONSTRAINT [FK_FactProductInventory_Heap_DimProduct] FOREIGN KEY([ProductKey])
REFERENCES [dbo].[DimProduct] ([ProductKey])
GO

ALTER TABLE [dbo].[FactProductInventory_Heap] CHECK CONSTRAINT [FK_FactProductInventory_Heap_DimProduct]
GO









CREATE TABLE [dbo].[FactProductInventory_ClusteredIndex] (
      [ProductKey] [INT] NOT NULL
    , [DateKey] [INT] NOT NULL
    , [MovementDate] [DATE] NOT NULL
    , [UnitCost] [MONEY] NOT NULL
    , [UnitsIn] [INT] NOT NULL
    , [UnitsOut] [INT] NOT NULL
    , [UnitsBalance] [INT] NOT NULL
    , CONSTRAINT [PK_FactProductInventory_ClusteredIndex] PRIMARY KEY CLUSTERED ([ProductKey] ASC, [DateKey] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    )
ON  [PRIMARY]
GO

ALTER TABLE [dbo].[FactProductInventory_ClusteredIndex]  WITH CHECK ADD  CONSTRAINT [FK_FactProductInventory_ClusteredIndex_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO

ALTER TABLE [dbo].[FactProductInventory_ClusteredIndex] CHECK CONSTRAINT [FK_FactProductInventory_ClusteredIndex_DimDate]
GO

ALTER TABLE [dbo].[FactProductInventory_ClusteredIndex]  WITH CHECK ADD  CONSTRAINT [FK_FactProductInventory_ClusteredIndex_DimProduct] FOREIGN KEY([ProductKey])
REFERENCES [dbo].[DimProduct] ([ProductKey])
GO

ALTER TABLE [dbo].[FactProductInventory_ClusteredIndex] CHECK CONSTRAINT [FK_FactProductInventory_ClusteredIndex_DimProduct]
GO








EXEC sp_configure
    'show advanced options'
  , 1;
GO
RECONFIGURE;
GO

EXEC sp_configure
    'xp_cmdshell'
  , 1
GO
RECONFIGURE
GO