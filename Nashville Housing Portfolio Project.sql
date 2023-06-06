--Data Cleaning in SQL Queries

Select *
From PorfolioProj.dbo.NashvilleHousing


--Standardize date format

Select SaleDateConv, Convert(Date, SaleDate)
From PorfolioProj.dbo.NashvilleHousing

Update PorfolioProj.dbo.NashvilleHousing
Set SaleDate=Convert(Date, SaleDate)

Alter table PorfolioProj.dbo.NashvilleHousing
Add SaleDateConv date

Update PorfolioProj.dbo.NashvilleHousing
Set SaleDateConv=Convert(Date, SaleDate)


--Populate Property address data

Select *
From PorfolioProj.dbo.NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From PorfolioProj.dbo.NashvilleHousing a
Join PorfolioProj.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress=isnull(a.PropertyAddress, b.PropertyAddress)
From PorfolioProj.dbo.NashvilleHousing a
Join PorfolioProj.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


--Segmenting property address into address col, city col, and state col

Select PropertyAddress
From PorfolioProj.dbo.NashvilleHousing

Select
Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
,Substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as City
From PorfolioProj.dbo.NashvilleHousing

Alter table PorfolioProj.dbo.NashvilleHousing
Add PropertyAddressNew nvarchar(255)

Update PorfolioProj.dbo.NashvilleHousing
Set PropertyAddressNew=Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

Alter table PorfolioProj.dbo.NashvilleHousing
Add PropertyCityNew nvarchar(255)

Update PorfolioProj.dbo.NashvilleHousing
Set PropertyCityNew=Substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

Select *
From PorfolioProj.dbo.NashvilleHousing


Select OwnerAddress
From PorfolioProj.dbo.NashvilleHousing

Select 
Parsename(replace(OwnerAddress, ',', '.'), 3) as AddressNew
,Parsename(replace(OwnerAddress, ',', '.'), 2) as CityNew
,Parsename(replace(OwnerAddress, ',', '.'), 1) as StateNew
From PorfolioProj.dbo.NashvilleHousing

Alter table PorfolioProj.dbo.NashvilleHousing
Add OwnerAddressNew nvarchar(255)

Update PorfolioProj.dbo.NashvilleHousing
Set OwnerAddressNew=Parsename(replace(OwnerAddress, ',', '.'), 3)

Alter table PorfolioProj.dbo.NashvilleHousing
Add OwnerCityNew nvarchar(255)

Update PorfolioProj.dbo.NashvilleHousing
Set OwnerCityNew=Parsename(replace(OwnerAddress, ',', '.'), 2)


Alter table PorfolioProj.dbo.NashvilleHousing
Add OwnerStateNew nvarchar(255)

Update PorfolioProj.dbo.NashvilleHousing
Set OwnerStateNew=Parsename(replace(OwnerAddress, ',', '.'), 1)

Select *
From PorfolioProj.dbo.NashvilleHousing


--Changing y & n to yes & no in "SoldAsVacant" field

Select distinct(SoldAsVacant),  count(SoldAsVacant)
From PorfolioProj.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
		end
From PorfolioProj.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant=Case when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
		end
From PorfolioProj.dbo.NashvilleHousing


--Removing Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by
					UniqueID
					) row_num
From PorfolioProj.dbo.NashvilleHousing
)

Delete
From RowNumCTE
where row_num>1

--Select *
--From RowNumCTE
--where row_num>1
--order by PropertyAddress

Select *
From PorfolioProj.dbo.NashvilleHousing


--Deleting unused columns

Select *
From PorfolioProj.dbo.NashvilleHousing

Alter table PorfolioProj.dbo.NashvilleHousing
Drop column PropertyAddress, OwnerAddress, SaleDate, TaxDistrict, PropertyCity
