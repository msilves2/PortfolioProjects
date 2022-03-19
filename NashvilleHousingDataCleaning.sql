
 --Cleaning Data in SQL Querries
 --I believe that the SaleDateConverted is appearing as an invalid
 --column name because I ran the update twice. It works though.
 SELECT SaleDateConverted, CONVERT(date,SaleDate)
 FROM [Portfolio Projects].dbo.NashvilleHousingData

 UPDATE NashvilleHousingData
 SET SaleDate = CONVERT(date,SaleDate)

 ALTER TABLE NashvilleHousingData
 ADD SaleDateConverted Date;

  UPDATE NashvilleHousingData
 SET SaleDateConverted = CONVERT(date,SaleDate)

 -- Populate Property Address Data
  SELECT *
 FROM [Portfolio Projects].dbo.NashvilleHousingData
-- WHERE PropertyAddress is NULL
ORDER BY ParcelID

  SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM [Portfolio Projects].dbo.NashvilleHousingData a
 JOIN [Portfolio Projects].dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Projects].dbo.NashvilleHousingData a
 JOIN [Portfolio Projects].dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

	-- Breaking out Addresses into individual columns (Address, City, State)
SELECT PropertyAddress
FROM [Portfolio Projects].dbo.NashvilleHousingData

 SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
 , SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
 FROM [Portfolio Projects].dbo.NashvilleHousingData

 ALTER TABLE NashvilleHousingData
 ADD PropertySplitAddress Nvarchar(255);

 UPDATE NashvilleHousingData
 SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

  ALTER TABLE NashvilleHousingData
 ADD PropertySplitCity Nvarchar(255);

 UPDATE NashvilleHousingData
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

 --Owner Address Section
 SELECT OwnerAddress
  FROM [Portfolio Projects].dbo.NashvilleHousingData

  SELECT 
  PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
 , PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
 , PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
  FROM [Portfolio Projects].dbo.NashvilleHousingData


  ALTER TABLE NashvilleHousingData
 ADD OwnerSplitAddress Nvarchar(255);

 UPDATE NashvilleHousingData
 SET OwnerSplitAddress =   PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

  ALTER TABLE NashvilleHousingData
 ADD OwnerSplitCity Nvarchar(255);

 UPDATE NashvilleHousingData
 SET OwnerSplitCity =   PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

 ALTER TABLE NashvilleHousingData
 ADD OwnerSpltState Nvarchar(255);

 UPDATE NashvilleHousingData
 SET OwnerSpltState =   PARSENAME(REPLACE(OwnerAddress,',', '.'),1)


 --Dealing with SoldAsVacant

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldasVacant)
 FROM [Portfolio Projects].dbo.NashvilleHousingData
 Group by SoldAsVacant
 Order by 2


 SELECT SoldAsVacant
 , CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 		WHEN SoldasVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
  FROM [Portfolio Projects].dbo.NashvilleHousingData

  Update NashvilleHousingData
  SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 		WHEN SoldasVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


 -- Remove Duplicates (Need to be careful with these to not delete data, for educational purposes)


 WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num

FROM [Portfolio Projects].dbo.NashvilleHousingData
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress





-- Delete Unused Columns
SELECT *
FROM [Portfolio Projects].dbo.NashvilleHousingData

ALTER TABLE [Portfolio Projects].dbo.NashvilleHousingData
DROP COLUMN SaleDate