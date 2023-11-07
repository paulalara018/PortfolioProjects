Select * from PortfolioProject.dbo.NashvilleHousing order by ParcelID

--------------Standardize Date Format
Select SaleDate, CONVERT(DATE,SaleDate) from PortfolioProject.dbo.NashvilleHousing
UPDATE NashvilleHousing SET SaleDate=CONVERT(Date, SaleDate)

-- If it doesn't Update properly
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted=CONVERT(Date,SaleDate)

UPDATE PortfolioProject.dbo.NashvilleHousing  SET SaleDate = CONVERT(Date,SaleDate)

-------------------------------------------------------------
Select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--- Join the same table where parcelID is the same with different uniqueID and check
--- When propertyAddress is null
Select *, ISNULL(a.PropertyAddress, b.PropertyAddress) 
		from PortfolioProject.dbo.NashvilleHousing a 
		JOIN PortfolioProject.dbo.NashvilleHousing b
		on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ] 
		where a.PropertyAddress is null

---- Populate Property Address Data
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


---- Check changes in PropertyAddress
Select PropertyAddress from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------
-----Breaking out Address into individual columns (Address, City)

---- Check through the select how to split the address
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as Address2
from PortfolioProject.dbo.NashvilleHousing order by ParcelID

-------------------------------------------------------------------------
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE PortfolioProject.dbo.NashvilleHousing SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE PortfolioProject.dbo.NashvilleHousing SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))

Select * from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------
-----Split Owner Address (Address, City, State)
Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

Alter table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

Alter table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE PortfolioProject.dbo.NashvilleHousing SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE PortfolioProject.dbo.NashvilleHousing SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select * from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------
----- Update Fields N-NO Y-YES
Select SoldAsVacant, count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant

Select SoldAsVacant, 
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing SET 
SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

------------------------------------------------------------------------------------
----- Remove Duplicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
from PortfolioProject.dbo.NashvilleHousing
)

Select * from RowNumCTE where row_num > 1


--------------------------------------------------------------------------------------
-------------- Delete Unused Columns
Select * from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

----------------------------------------------------------------------------------------
--------------- 

