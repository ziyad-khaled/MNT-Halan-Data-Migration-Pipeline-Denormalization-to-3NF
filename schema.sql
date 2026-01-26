-- Halan Logistics Final Production Schema
-- Optimized for Data Migration and Arabic Text Support

CREATE DATABASE IF NOT EXISTS halan 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_0900_ai_ci;

USE halan;

-- 1. SUPPORTING INFRASTRUCTURE
CREATE TABLE warehouse (
    WareHouseID INT AUTO_INCREMENT PRIMARY KEY,
    WareHouse VARCHAR(255),
    HubName VARCHAR(255)
);

CREATE TABLE location (
    LocationID INT AUTO_INCREMENT PRIMARY KEY,
    Governorate VARCHAR(255),
    Region VARCHAR(255),
    IsAppVisible TINYINT(1),
    WareHouseID INT,
    FOREIGN KEY (WareHouseID) REFERENCES warehouse(WareHouseID)
);

CREATE TABLE subregions (
    SubRegionID INT AUTO_INCREMENT PRIMARY KEY,
    SubRegion VARCHAR(255),
    RouteName VARCHAR(1024),
    IsAppVisible TINYINT(1),
    IsDeliveryActive TINYINT(1),
    locationID INT,
    FOREIGN KEY (locationID) REFERENCES location(LocationID)
);

-- 2. ACCOUNTS & PROFILES
CREATE TABLE accounts (
    AccountID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerCode INT 
);

CREATE TABLE customerservice (
    CustomerServiceID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerServiceNotes TEXT,
    CustomerNotes TEXT
);

CREATE TABLE customer (
    ProfileID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerName VARCHAR(255),
    CustomerPhoneNumber VARCHAR(50),
    CustomerAddress VARCHAR(2048),
    AccountID INT,
    LocationID INT,
    -- TripNumber removed from here as discussed
    FOREIGN KEY (AccountID) REFERENCES accounts(AccountID),
    FOREIGN KEY (LocationID) REFERENCES location(LocationID)
);

-- 3. LOGISTICS
CREATE TABLE shippingrepresentative (
    ShippingRepresentativeID INT AUTO_INCREMENT PRIMARY KEY,
    ShippingRepresentativeName VARCHAR(255),
    ShippingRepresentativeType VARCHAR(100),
    OutsourcingCompany VARCHAR(255)
);

CREATE TABLE vehicle (
    VehicleID INT AUTO_INCREMENT PRIMARY KEY,
    VehicleType VARCHAR(100),
    VehicleNumber VARCHAR(50),
    VehicleSourceType VARCHAR(100),
    VehicleOutsourcingCompany VARCHAR(255)
);

CREATE TABLE trip (
    TripNumber VARCHAR(100) PRIMARY KEY,
    VehicleID INT,
    ShippingRepresentativeID INT,
    FOREIGN KEY (VehicleID) REFERENCES vehicle(VehicleID),
    FOREIGN KEY (ShippingRepresentativeID) REFERENCES shippingrepresentative(ShippingRepresentativeID)
);

-- 4. CORE ORDERS (The Central Anchor)
CREATE TABLE paymentmethod (
    PaymentMethodID INT AUTO_INCREMENT PRIMARY KEY,
    PaymentMethod VARCHAR(100)
);

CREATE TABLE orders (
    OrderNumber VARCHAR(100) PRIMARY KEY,
    OrderStatus VARCHAR(100),
    CreationDate DATETIME,
    DeliveryDate DATETIME,
    DeliveredDate DATETIME,
    TotalOrderWeight DECIMAL(10,3),
    OrderVia VARCHAR(100),
    CreatedBy VARCHAR(255),
    ProfileID INT,
    PaymentMethodID INT,
    CustomerServiceID INT,
    TripNumber VARCHAR(100),
    -- SalesID and CashBackID removed to reverse cardinality and ease insertion
    FOREIGN KEY (ProfileID) REFERENCES customer(ProfileID),
    FOREIGN KEY (PaymentMethodID) REFERENCES paymentmethod(PaymentMethodID),
    FOREIGN KEY (CustomerServiceID) REFERENCES customerservice(CustomerServiceID),
    FOREIGN KEY (TripNumber) REFERENCES trip(TripNumber)
);

-- 5. FINANCIALS (Reversed Cardinality: Child of Orders)
CREATE TABLE sales (
    SalesID INT AUTO_INCREMENT PRIMARY KEY,
    GrossSales DECIMAL(15,2),
    ProductsPromotions DECIMAL(15,2),
    DiscountOnInvoice DECIMAL(15,2),
    CustomerExperienceDiscount DECIMAL(15,2),
    ReturnsGrossSales DECIMAL(15,2),
    OrderNumber VARCHAR(100) UNIQUE, -- 1:1 relationship pointing back to Orders
    FOREIGN KEY (OrderNumber) REFERENCES orders(OrderNumber)
);

CREATE TABLE cashback (
    CashBackID INT AUTO_INCREMENT PRIMARY KEY,
    NetSalesBeforeCashback DECIMAL(15,2),
    RedeemedCashback DECIMAL(15,2),
    NetSalesAfterCashback DECIMAL(15,2),
    CreditUsed DECIMAL(15,2),
    ReturnedCashback DECIMAL(15,2),
    OrderNumber VARCHAR(100) UNIQUE, -- 1:1 relationship pointing back to Orders
    FOREIGN KEY (OrderNumber) REFERENCES orders(OrderNumber)
);