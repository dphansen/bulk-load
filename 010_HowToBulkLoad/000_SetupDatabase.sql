USE [master]
GO
ALTER DATABASE [AdventureWorksDW2012] SET RECOVERY FULL WITH NO_WAIT
GO

USE AdventureWorksDW2012
GO

CREATE TABLE [dbo].[FactProductInventory_BulkLoad] (
      [ProductKey] [INT] NOT NULL
    , [DateKey] [INT] NOT NULL
    , [MovementDate] [DATE] NOT NULL
    , [UnitCost] [MONEY] NOT NULL
    , [UnitsIn] [INT] NOT NULL
    , [UnitsOut] [INT] NOT NULL
    , [UnitsBalance] [INT] NOT NULL
    , CONSTRAINT [PK_FactProductInventory_BulkLoad] PRIMARY KEY CLUSTERED ([ProductKey] ASC, [DateKey] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    )
ON  [PRIMARY]
GO

ALTER TABLE [dbo].[FactProductInventory_BulkLoad]  WITH CHECK ADD  CONSTRAINT [FK_FactProductInventory_BulkLoad_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO

ALTER TABLE [dbo].[FactProductInventory_BulkLoad] CHECK CONSTRAINT [FK_FactProductInventory_BulkLoad_DimDate]
GO

ALTER TABLE [dbo].[FactProductInventory_BulkLoad]  WITH CHECK ADD  CONSTRAINT [FK_FactProductInventory_BulkLoad_DimProduct] FOREIGN KEY([ProductKey])
REFERENCES [dbo].[DimProduct] ([ProductKey])
GO

ALTER TABLE [dbo].[FactProductInventory_BulkLoad] CHECK CONSTRAINT [FK_FactProductInventory_BulkLoad_DimProduct]
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