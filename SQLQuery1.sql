/****** Script do comando SelectTopNRows de SSMS  ******/
Select * 
From [Data Cleaning].dbo.NashvilleHousing



-------------------------------------------------
/**** Padronizar datas / Standardize dates ****/

Select SaleDateConverted, CONVERT(date, SaleDate)
From [Data Cleaning].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)



----------------------------------------------------------------
/**** Popular dados de endereço / Populate addresses data ****/

Select *
From [Data Cleaning].dbo.NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning].dbo.NashvilleHousing a
JOIN [Data Cleaning].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning].dbo.NashvilleHousing a
JOIN [Data Cleaning].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-----------------------------------------------------------------------------------------------------------------
/**** Separar endereços por blocos (rua, cidade, estado) / Split addresses by zones (address, city, state) ****/

Select PropertyAddress
From [Data Cleaning].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From [Data Cleaning].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select * 
From [Data Cleaning].dbo.NashvilleHousing


Select OwnerAddress
From [Data Cleaning].dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Data Cleaning].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * 
From [Data Cleaning].dbo.NashvilleHousing



----------------------------------------------------------------------------------------------
/**** Padronizando dados de coluna objetiva / Standardizing data of an objective column ****/

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Data Cleaning].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Data Cleaning].dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



---------------------------------------------------
/**** Remover duplicatas / Remove duplicates ****/

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num
From [Data Cleaning].dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


Select *
From [Data Cleaning].dbo.NashvilleHousing



---------------------------------------------------------------------
/**** Deletando colunas inutilizadas / Deleting unused columns ****/

Select *
From [Data Cleaning].dbo.NashvilleHousing

ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
DROP COLUMN SaleDate