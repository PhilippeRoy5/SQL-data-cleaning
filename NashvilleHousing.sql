-- Taking a first look at the data we are working with

SELECT *
FROM [portfolio].[dbo].[Nashville]


-- Fixing date -------

SELECT SaleDate --convert(Date, Saledate) as newDate
FROM [portfolio].[dbo].[Nashville]

alter table [portfolio].[dbo].[Nashville]
add NewDate  Date

Update [portfolio].[dbo].[Nashville]
SET NewDate = convert(Date, Saledate)


-- Checking data for missing values----

Select *
FROM [portfolio].[dbo].[Nashville]
WHERE [UniqueID ] ] is null

Select *
FROM [portfolio].[dbo].[Nashville]
WHERE [parcelID] is null

Select PropertyAddress
FROM [portfolio].[dbo].[Nashville]
WHERE [PropertyAddress] is null


--Filling out missing property address data using a join statement------

Select *
FROM [portfolio].[dbo].[Nashville]
WHERE [PropertyAddress] is null

Select *
FROM [portfolio].[dbo].[Nashville]
Order by ParcelID

Select TB1.ParcelID, TB1.PropertyAddress,TB2.ParcelID, TB2.PropertyAddress,
	isnull(TB1.PropertyAddress,TB2.PropertyAddress)
FROM [portfolio].[dbo].[Nashville] TB1
Join [portfolio].[dbo].[Nashville] TB2
	on TB1.ParcelID = TB2.ParcelID
	AND TB1.UniqueID <> TB2.UniqueID
WHERE TB1.PropertyAddress is null

Update TB1
SET PropertyAddress = isnull(TB1.PropertyAddress,TB2.PropertyAddress)
FROM [portfolio].[dbo].[Nashville] TB1
Join [portfolio].[dbo].[Nashville] TB2
	on TB1.ParcelID = TB2.ParcelID
	AND TB1.UniqueID <> TB2.UniqueID
WHERE TB1.PropertyAddress is null 


-- Granulating PropertyAddress by seperating  City and Street------
---using substring and character INDEX----

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM [portfolio].[dbo].[Nashville]

ALTER TABLE [portfolio].[dbo].[Nashville]
add Street Nvarchar(255)

Update [portfolio].[dbo].[Nashville]
SET Street = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [portfolio].[dbo].[Nashville]
add City Nvarchar(255)

Update [portfolio].[dbo].[Nashville]
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
FROM [portfolio].[dbo].[Nashville]

-- Granulating OwnerAddress by seperating Street, City and State------
---Using PARSENAME and REPLACE functions----

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1), state
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2), City
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) Street
FROM [portfolio].[dbo].[Nashville]

--Creating and Updating OwnerStreet

ALTER TABLE [portfolio].[dbo].[Nashville]
add OwnerStreet Nvarchar(255)

Update [portfolio].[dbo].[Nashville]
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


--Creating and Updating OwnerCity
ALTER TABLE [portfolio].[dbo].[Nashville]
add OwnerCity Nvarchar(255)

Update [portfolio].[dbo].[Nashville]
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


--Creating and Updating OwnerState
ALTER TABLE [portfolio].[dbo].[Nashville]
add OwnerState Nvarchar(255)

Update [portfolio].[dbo].[Nashville]
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


--Standardizing Sold as vacant column by replacing Y and N -----

Select Distinct(SoldAsVacant)
FROM [portfolio].[dbo].[Nashville]

Select SoldAsVacant,
	Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM [portfolio].[dbo].[Nashville]
Where SoldAsVacant = 'y' or SoldAsVacant = 'N'

Update [portfolio].[dbo].[Nashville]
SET SoldAsVacant = Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

-- Removing Duplicates----

With RowCTE AS(
Select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
	ORDER BY UniqueID ) RowNumber
FROM [portfolio].[dbo].[Nashville]
)
DELETE
FROM RowCTE
WHERE RowNumber > 1


--Removing unecessary columns for a Final Table ----

Select *
FROM [portfolio].[dbo].[Nashville]

ALTER TABLE [portfolio].[dbo].[Nashville]
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress