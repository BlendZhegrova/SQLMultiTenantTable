CREATE TABLE Tenants (
    TenantId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(100) NOT NULL,
    Domain NVARCHAR(200) NOT NULL UNIQUE,
    SettingsJson NVARCHAR(MAX),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE ProductCategoryMap (
    MapId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    ProductId UNIQUEIDENTIFIER NOT NULL,
    CategoryId UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT FK_Map_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId),
    CONSTRAINT FK_Map_Product FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT FK_Map_Category FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)
);

CREATE TABLE Categories (
    CategoryId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    ParentCategoryId UNIQUEIDENTIFIER NULL,
    Name NVARCHAR(100) NOT NULL,
    Slug NVARCHAR(100) NOT NULL,
    SortOrder INT DEFAULT 0,
    CONSTRAINT FK_Categories_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId),
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentCategoryId) REFERENCES Categories(CategoryId)
);

CREATE TABLE Products (
    ProductId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    FormId UNIQUEIDENTIFIER NULL, 
    SKU NVARCHAR(50) NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Slug NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    BasePrice DECIMAL(18, 2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    ImagesJson NVARCHAR(MAX),
    AttributesJson NVARCHAR(MAX),
    IsSubscription BIT DEFAULT 0,
    SubscriptionInterval INT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Products_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);

CREATE TABLE Forms (
    FormId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    QuestionsJson NVARCHAR(MAX),
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_Forms_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);

CREATE TABLE Customers (
    CustomerId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    Email NVARCHAR(200) NOT NULL,
    PasswordHash NVARCHAR(500) NOT NULL,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Phone NVARCHAR(20),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Customers_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId),
    CONSTRAINT UQ_Tenant_Email UNIQUE(TenantId, Email)
);

CREATE TABLE Orders (
    OrderId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    CustomerId UNIQUEIDENTIFIER NOT NULL,
    Subtotal DECIMAL(18, 2) NOT NULL,
    Total DECIMAL(18, 2) NOT NULL,
    PaymentStatus NVARCHAR(50) NOT NULL,
    FulfillmentStatus NVARCHAR(50) NOT NULL,
    ShippingAddressJson NVARCHAR(MAX),
    IntakeAnswersJson NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Orders_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId),
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId)
);

CREATE TABLE OrderItems (
    OrderItemId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrderId UNIQUEIDENTIFIER NOT NULL,
    ProductId UNIQUEIDENTIFIER NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18, 2) NOT NULL,
    Total DECIMAL(18, 2) NOT NULL,
    CONSTRAINT FK_OrderItems_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId),
    CONSTRAINT FK_OrderItems_Order FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    CONSTRAINT FK_OrderItems_Product FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

CREATE UNIQUE NONCLUSTERED INDEX IX_Categories_Tenant_Parent ON Categories(TenantId, ParentCategoryId);
CREATE UNIQUE NONCLUSTERED INDEX IX_Categories_Slug ON Categories(TenantId, Slug);

CREATE UNIQUE NONCLUSTERED INDEX IX_Products_Tenant_Created ON Products(TenantId, CreatedAt DESC);
CREATE UNIQUE NONCLUSTERED INDEX IX_Products_SKU ON Products(TenantId, SKU);

CREATE UNIQUE NONCLUSTERED INDEX IX_Map_Tenant_Category ON ProductCategoryMap(TenantId, CategoryId, ProductId);

CREATE UNIQUE NONCLUSTERED INDEX IX_Customers_Tenant_Email ON Customers(TenantId, Email);

CREATE UNIQUE NONCLUSTERED INDEX IX_Orders_Tenant_Date ON Orders(TenantId, CreatedAt DESC);
CREATE UNIQUE NONCLUSTERED INDEX IX_Orders_Customer ON Orders(TenantId, CustomerId);

CREATE NONCLUSTERED INDEX IX_OrderItems_Tenant_Order ON OrderItems (TenantId, OrderId)
INCLUDE (ProductId, ProductName, Quantity, UnitPrice, Total);
