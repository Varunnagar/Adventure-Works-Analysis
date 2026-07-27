create database adventure_works;
-- Dimcutomer Table
select * from dimcustomer;
describe dimcustomer;
ALTER TABLE dimcustomer
ADD COLUMN DateFirstPurchase_New DATE;
UPDATE dimcustomer
SET DateFirstPurchase_New =
DATE_ADD('1899-12-30', INTERVAL DateFirstPurchase DAY);
alter table dimcustomer
drop column dateFirstPurchase;
-- Dimdate Table
select * from dimdate;
describe dimdate;
alter table dimdate 
add column FullDateAlternateKey_new date after FullDateAlternateKey;
UPDATE dimdate
set FullDateAlternateKey_new = 
DATE_ADD('2005-01-01', INTERVAL FullDateAlternateKey DAY);
alter table dimdate 
drop column FullDateAlternateKey_new;
-- Dimproduct Table
describe dimproduct;
select * from dimproduct;
alter table dimproduct
drop column spanishproductname,
drop column FrenchProductName,
drop column FrenchDescription,
drop column ChineseDescription,
drop column ArabicDescription,
drop column hebrewdescription,
drop column thaidescription,
drop column GermanDescription,
drop column JapaneseDescription,
drop column TurkishDescription;
-- Fact_intrrnet_sales_new Table
select * from fact_internet_sales_new;
describe fact_internet_sales_new;
select distinct RevisionNumber
from fact_internet_sales_new;
alter table fact_internet_sales_new
drop column CarrierTrackingNumber,
drop column CustomerPONumber,
drop column UnitPriceDiscountPct,
drop column DiscountAmount,
drop column RevisionNumber;
-- factinternetsales Table
select  * from factinternetsales;
alter table factinternetsales
drop column CarrierTrackingNumber,
drop column CustomerPONumber,
drop column UnitPriceDiscountPct,
drop column DiscountAmount,
drop column RevisionNumber;



