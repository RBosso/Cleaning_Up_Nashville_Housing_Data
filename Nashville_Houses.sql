--Cleaning Nashville Data

--SELECT * FROM Nashville_Housing.dbo.Nashville$

--Standardization of Data Format

--SELECT SaleDate, CONVERT(Date, Saledate) FROM Nashville_Housing.dbo.Nashville$

ALTER TABLE Nashville_Housing.dbo.Nashville$ ADD SaledateConvert Date
UPDATE Nashville_Housing.dbo.Nashville$ SET SaledateConvert = CONVERT(Date, SaleDate)
--SELECT SaleDateConvert, CONVERT(Date, Saledate) FROM Nashville_Housing.dbo.Nashville$


--Populating Property Address Data

--SELECT PropertyAddress FROM Nashville_Housing.dbo.Nashville$ WHERE PropertyAddress IS NULL

--SELECT * FROM Nashville_Housing.dbo.Nashville$ ORDER BY ParcelID

--    Self Join to fill in NULL Property Values
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Nashville_Housing.dbo.Nashville$ AS A JOIN Nashville_Housing.dbo.Nashville$ AS B 
ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

--    Use of ISNULL to replace NULL values
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Nashville_Housing.dbo.Nashville$ AS A JOIN Nashville_Housing.dbo.Nashville$ AS B 
ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--Breaking Up Address column into individual normalized columns (address, city, and state)

--SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
--SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
--FROM Nashville_Housing.dbo.Nashville$; 

--ALTER TABLE Nashville_Housing.dbo.Nashville$ ADD SplitAddress NVARCHAR(225);

--UPDATE Nashville_Housing.dbo.Nashville$ SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

--ALTER TABLE Nashville_Housing.dbo.Nashville$ ADD SplitCity NVARCHAR(225);

--UPDATE Nashville_Housing.dbo.Nashville$ SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

--SELECT PropertyAddress, SplitAddress, SplitCity FROM Nashville_Housing.dbo.Nashville$

SELECT PropertyAddress, SplitAddress, SplitCity FROM Nashville_Housing.dbo.Nashville$

--SELECT OwnerAddress FROM Nashville_Housing.dbo.Nashville$;
SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS Address, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS City, 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS State 
FROM Nashville_Housing.dbo.Nashville$;

ALTER TABLE Nashville_Housing.dbo.Nashville$ ADD SplitOwnerAddress NVARCHAR(225);

UPDATE Nashville_Housing.dbo.Nashville$ SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

ALTER TABLE Nashville_Housing.dbo.Nashville$ ADD SplitOwnerCity NVARCHAR(225);

UPDATE Nashville_Housing.dbo.Nashville$ SET SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2);

ALTER TABLE Nashville_Housing.dbo.Nashville$ ADD SplitOwnerState NVARCHAR(225);

UPDATE Nashville_Housing.dbo.Nashville$ SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);

SELECT OwnerAddress, SplitOwnerAddress, SplitOwnerCity, SplitOwnerState FROM Nashville_Housing.dbo.Nashville$;

--Changes Y and N to Yes and No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) FROM Nashville_Housing.dbo.Nashville$
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM Nashville_Housing.dbo.Nashville$;

UPDATE Nashville_Housing.dbo.Nashville$
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--Remove Duplicates from the Database

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num

FROM Nashville_Housing.dbo.Nashville$)
--SELECT * FROM RowNumCTE WHERE row_num > 1;
DELETE FROM RowNumCTE WHERE row_num > 1;


--Delete Unused Columns

SELECT * FROM Nashville_Housing.dbo.Nashville$

ALTER TABLE Nashville_Housing.dbo.Nashville$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
