Select *
from Projectportfolio..Nashvillehousing

---Standardise Date format
 
 Select Saledate
 from Projectportfolio..Nashvillehousing;


 Alter table Nashvillehousing
 Add SaledateConverted Date;

 Update Nashvillehousing
 Set SaleDateConverted=CONVERT(date, SaleDate);

 Select SaledateConverted
 from Projectportfolio..Nashvillehousing;

 ----Populate Property Address data

 select *
 from Projectportfolio..Nashvillehousing
 where PropertyAddress is null


 select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress, b.PropertyAddress)
 from Projectportfolio..Nashvillehousing a
 join Projectportfolio..Nashvillehousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress=ISNULL(a.propertyaddress, b.PropertyAddress)
from Projectportfolio..Nashvillehousing a
 join Projectportfolio..Nashvillehousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

---- Breaking out address into individual columns(address,city,state)

select PropertyAddress
from Projectportfolio..Nashvillehousing;
---format

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as City
from Projectportfolio..Nashvillehousing;

Alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update Nashvillehousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

Alter table nashvillehousing
add PropertySplitCity nvarchar(255);

Update Nashvillehousing
set PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress));

Select PropertySplitAddress, PropertySplitCity, PropertyAddress
from Nashvillehousing;

---Owner Address
select OwnerAddress
from Projectportfolio..Nashvillehousing;

select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',', '.'),1)
from Projectportfolio..Nashvillehousing;

Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);


Update Nashvillehousing
set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3);

Alter Table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update Nashvillehousing
set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2);

Alter table Nashvillehousing
add OwnerSplitState nvarchar(255);

Update Nashvillehousing
set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1);

select OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
from Projectportfolio..Nashvillehousing;

------------------------------Converting Y and N to Yes and No in the SoldAsVacant column

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Projectportfolio..Nashvillehousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from Projectportfolio..Nashvillehousing;

update Nashvillehousing
set SoldAsVacant= case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end;

----Remove Duplicates

WITH RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID)
					row_num
from Projectportfolio..Nashvillehousing
)
select count(*) from RowNumCTE
where row_num>1;---counting dumplicates

WITH RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID)
					row_num
from Projectportfolio..Nashvillehousing
)
delete 
from RowNumCTE
where row_num>1;---Deleting duplicates

------Delete unused columns and redundant columns

select *
from Projectportfolio..Nashvillehousing;

Alter table Projectportfolio..Nashvillehousing
drop column SaleDate,PropertyAddress,OwnerAddress;