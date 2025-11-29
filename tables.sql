CREATE TABLE SuperAdmins (
    SuperAdminId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Email NVARCHAR(200) NOT NULL,
    PasswordHash NVARCHAR(500) NOT NULL,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    TwoFactorEnabled BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);
CREATE UNIQUE NONCLUSTERED INDEX IX_SuperAdmins_Email ON SuperAdmins(Email);

CREATE TABLE Tenants (
    TenantId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(100) NOT NULL,
    Domain NVARCHAR(200) NOT NULL UNIQUE,
    SettingsJson NVARCHAR(MAX), 
    StripeAccountId NVARCHAR(100),
    IsPaymentConfigured BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);
CREATE TABLE TenantProfiles (
    ProfileId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    LegalName NVARCHAR(200),       
    TaxId NVARCHAR(50),             
    SupportEmail NVARCHAR(200),
    SupportPhone NVARCHAR(50),
    SupportHours NVARCHAR(200),
    LogoUrl NVARCHAR(500),
    FaviconUrl NVARCHAR(500),
    PrimaryColor NVARCHAR(20),      
    SecondaryColor NVARCHAR(20),    
    CONSTRAINT FK_Profiles_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);
CREATE UNIQUE NONCLUSTERED INDEX IX_Profiles_Tenant ON TenantProfiles(TenantId);

CREATE TABLE TenantAddresses (
    AddressId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    AddressLine1 NVARCHAR(200) NOT NULL,
    AddressLine2 NVARCHAR(200),
    City NVARCHAR(100) NOT NULL,
    State NVARCHAR(100) NOT NULL,
    ZipCode NVARCHAR(20) NOT NULL,
    Country NVARCHAR(100) DEFAULT 'USA',
    IsPrimary BIT DEFAULT 0,
    CONSTRAINT FK_Addresses_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);

CREATE TABLE TenantContentBlocks (
    BlockId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    SectionName NVARCHAR(100) NOT NULL,
    BlockKey NVARCHAR(100) NOT NULL,  
    ContentType NVARCHAR(50) NOT NULL,  
    ContentValue NVARCHAR(MAX),        
    SortOrder INT DEFAULT 0,
    CONSTRAINT FK_Content_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);

CREATE NONCLUSTERED INDEX IX_Content_Lookup ON TenantContentBlocks(TenantId, SectionName);

CREATE TABLE TenantUsers (
    UserId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    Email NVARCHAR(200) NOT NULL,
    PasswordHash NVARCHAR(500) NOT NULL,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Role NVARCHAR(50) NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_TenantUsers_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);
CREATE UNIQUE NONCLUSTERED INDEX IX_TenantUsers_Email ON TenantUsers(TenantId, Email);

CREATE TABLE Customers (
    CustomerId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    Email NVARCHAR(200) NOT NULL,
    PasswordHash NVARCHAR(500) NOT NULL,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Phone NVARCHAR(20),
    ExternalPaymentId NVARCHAR(200),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Customers_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);
CREATE UNIQUE NONCLUSTERED INDEX IX_Customers_Tenant_Email ON Customers(TenantId, Email);

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
CREATE UNIQUE NONCLUSTERED INDEX IX_Categories_Slug ON Categories(TenantId, Slug);
CREATE NONCLUSTERED INDEX IX_Categories_Tenant_Parent ON Categories(TenantId, ParentCategoryId);

CREATE TABLE Products (
    ProductId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
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
CREATE UNIQUE NONCLUSTERED INDEX IX_Products_SKU ON Products(TenantId, SKU);
CREATE NONCLUSTERED INDEX IX_Products_Tenant_Created ON Products(TenantId, CreatedAt DESC);

CREATE TABLE ProductCategoryMap (
    MapId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    ProductId UNIQUEIDENTIFIER NOT NULL,
    CategoryId UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT FK_PCMap_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId),
    CONSTRAINT FK_PCMap_Product FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT FK_PCMap_Category FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)
);
CREATE UNIQUE NONCLUSTERED INDEX IX_Map_Tenant_Category ON ProductCategoryMap(TenantId, CategoryId, ProductId);

CREATE TABLE Forms (
    FormId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_Forms_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);

CREATE TABLE FormQuestions (
    QuestionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    FormId UNIQUEIDENTIFIER NOT NULL,
    QuestionText NVARCHAR(500) NOT NULL,
    InputType NVARCHAR(50) NOT NULL,
    SortOrder INT DEFAULT 0,
    PageNumber INT DEFAULT 1,
    VisibilityParentQuestionId UNIQUEIDENTIFIER NULL, 
    VisibilityRequiredOptionId UNIQUEIDENTIFIER NULL, 
    CONSTRAINT FK_Questions_Form FOREIGN KEY (FormId) REFERENCES Forms(FormId),
    CONSTRAINT FK_Questions_Logic_Parent FOREIGN KEY (VisibilityParentQuestionId) REFERENCES FormQuestions(QuestionId),
    CONSTRAINT FK_Questions_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);

CREATE TABLE FormQuestionOptions (
    OptionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    QuestionId UNIQUEIDENTIFIER NOT NULL,
    Label NVARCHAR(200) NOT NULL,
    Value NVARCHAR(200) NOT NULL,
    IsDisqualifier BIT DEFAULT 0,
    CONSTRAINT FK_Options_Question FOREIGN KEY (QuestionId) REFERENCES FormQuestions(QuestionId),
    CONSTRAINT FK_Options_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);
ALTER TABLE FormQuestions ADD CONSTRAINT FK_Questions_Logic_Option FOREIGN KEY (VisibilityRequiredOptionId) REFERENCES FormQuestionOptions(OptionId);

CREATE TABLE ProductFormMap (
    MapId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    ProductId UNIQUEIDENTIFIER NOT NULL,
    FormId UNIQUEIDENTIFIER NOT NULL,
    SortOrder INT DEFAULT 0,
    CONSTRAINT FK_PFMap_Product FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT FK_PFMap_Form FOREIGN KEY (FormId) REFERENCES Forms(FormId)
);

CREATE TABLE CategoryFormMap (
    MapId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    CategoryId UNIQUEIDENTIFIER NOT NULL,
    FormId UNIQUEIDENTIFIER NOT NULL,
    IsRequired BIT DEFAULT 1,
    CONSTRAINT FK_CFMap_Category FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT FK_CFMap_Form FOREIGN KEY (FormId) REFERENCES Forms(FormId)
);

CREATE TABLE Orders (
    OrderId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    CustomerId UNIQUEIDENTIFIER NOT NULL,

    Currency NVARCHAR(10) DEFAULT 'USD',        
    Subtotal DECIMAL(18, 2) NOT NULL,
    TaxAmount DECIMAL(18, 2) DEFAULT 0.00,     
    DiscountAmount DECIMAL(18, 2) DEFAULT 0.00, 
    Total DECIMAL(18, 2) NOT NULL,
    
    PaymentGatewayTransactionId NVARCHAR(200), 
    PaymentMethodType NVARCHAR(50),            
    OrderStatus NVARCHAR(50) DEFAULT 'Open',                
    PaymentStatus NVARCHAR(50) DEFAULT 'Pending',           
    FulfillmentStatus NVARCHAR(50) DEFAULT 'Unfulfilled',   
    ShippingAddressJson NVARCHAR(MAX),
    IntakeAnswersJson NVARCHAR(MAX),
    PaidAt DATETIME2 NULL,
    ShippedAt DATETIME2 NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    AppliedDiscountCode NVARCHAR(50),

    CONSTRAINT FK_Orders_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId),
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId)
);

CREATE TABLE OrderTransactions (
    TransactionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrderId UNIQUEIDENTIFIER NOT NULL,
    
    GatewayResponseJson NVARCHAR(MAX),
    PaymentGatewayTransactionId NVARCHAR(200),  
    
    Type NVARCHAR(50) NOT NULL,    
    Amount DECIMAL(18, 2) NOT NULL, 
    Currency NVARCHAR(10) DEFAULT 'USD',
    
    Status NVARCHAR(50) NOT NULL,  
    ErrorMessage NVARCHAR(500),    
    
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_Transactions_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId),
    CONSTRAINT FK_Transactions_Order FOREIGN KEY (OrderId) REFERENCES Orders(OrderId)
);

CREATE NONCLUSTERED INDEX IX_Transactions_Order ON OrderTransactions(TenantId, OrderId);

CREATE TABLE Discounts (
    DiscountId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    Code NVARCHAR(50) NOT NULL, 
    Type NVARCHAR(20) NOT NULL, 
    Value DECIMAL(18, 2) NOT NULL, 
    MinOrderAmount DECIMAL(18, 2),
    UsageLimit INT, 
    UsageCount INT DEFAULT 0,
    StartDate DATETIME2,
    EndDate DATETIME2,
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_Discounts_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);
CREATE UNIQUE NONCLUSTERED INDEX IX_Discounts_Code ON Discounts(TenantId, Code);
CREATE NONCLUSTERED INDEX IX_Orders_Tenant_Date ON Orders(TenantId, CreatedAt DESC);
CREATE NONCLUSTERED INDEX IX_Orders_Customer ON Orders(TenantId, CustomerId);

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
CREATE NONCLUSTERED INDEX IX_OrderItems_Tenant_Order ON OrderItems (TenantId, OrderId)
INCLUDE (ProductId, ProductName, Quantity, UnitPrice, Total);

CREATE TABLE Faqs (
    FaqId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    Question NVARCHAR(500) NOT NULL,
    Answer NVARCHAR(MAX) NOT NULL, 
    SortOrder INT DEFAULT 0, 
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Faqs_Tenant FOREIGN KEY (TenantId) REFERENCES Tenants(TenantId)
);
CREATE NONCLUSTERED INDEX IX_Faqs_Tenant ON Faqs(TenantId);
