 
--**Cleaning Data in SQL Queries**--
SELECT *
FROM DataCleaning..[NashvilleHousing ]

-- Standardize Date Format
SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM DataCleaning..[NashvilleHousing ]

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

-- If it doesn't Update properly
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDate,SaleDateConverted
FROM DataCleaning..[NashvilleHousing ]

-- Populate Property Address data
SELECT UniqueID, ParcelID, PropertyAddress
FROM DataCleaning..[NashvilleHousing ]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning..[NashvilleHousing ] AS a
JOIN DataCleaning..[NashvilleHousing ] AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
__________________________________________________________________________________________________________

-- Filling Null Values for PropertyAddress
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning..[NashvilleHousing ] AS a
JOIN DataCleaning..[NashvilleHousing ] AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

__________________________________________________________________________________________________________

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM DataCleaning..[NashvilleHousing ]
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM DataCleaning..[NashvilleHousing ]


ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From DataCleaning..[NashvilleHousing ]

_________________________________________________________________________________________________________

-- Breaking out OwnerAddress into Individual Columns (Address, City, State) using parse

Select OwnerAddress
From DataCleaning..[NashvilleHousing ]

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From DataCleaning..[NashvilleHousing ]

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM DataCleaning..[NashvilleHousing ]

____________________________________________________________________________________________________

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaning..[NashvilleHousing ]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM DataCleaning..[NashvilleHousing ]

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaning..[NashvilleHousing ]
GROUP BY SoldAsVacant
_______________________________________________________________________________________________
-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM DataCleaning..[NashvilleHousing ]
--order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



SELECT *
FROM DataCleaning..[NashvilleHousing ]

_________________________________________________________________________________________________
-- Delete Unused Columns
SELECT *
FROM DataCleaning..[NashvilleHousing ]

ALTER TABLE DataCleaning..[NashvilleHousing ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
