-- Cleaning Data in SQL Queries

SELECT *
FROM nashville_housing;

-- Standardize the sale_date

SELECT saledate, saledate::DATE
FROM nashville_housing;

ALTER TABLE nashville_housing
ALTER COLUMN saledate TYPE DATE;
UPDATE nashville_housing
SET saledate = saledate::DATE;

-- Populate Property Address data

SELECT
FROM nashville_housing;
-- WHERE propertyaddress IS NULL;

SELECT
	a.parcelid,
	a.propertyaddress,
	b.parcelid,
	b.propertyaddress,
	COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL
ORDER BY 2;

UPDATE nashville_housing
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

-- Breaking out Address into Individual Columsn (Address, CIty, State)

SELECT propertyaddress
FROM nashville_housing;

SELECT
	propertyaddress,
	SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress) - 1) AS address,
	SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 1) AS city
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN property_split_address VARCHAR(255),
ADD COLUMN property_split_city VARCHAR (255);

UPDATE nashville_housing
SET
	property_split_address = SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress) - 1),
	property_split_city = SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 1);

SELECT *
FROM nashville_housing;

SELECT owneraddress
FROM nashville_housing;

SELECT
	owneraddress,
	SPLIT_PART(owneraddress, ',', 1) AS address,
	SPLIT_PART(owneraddress, ',', 2) AS city,
	SPLIT_PART(owneraddress, ',', 3) AS state
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN owner_split_address VARCHAR(255),
ADD COLUMN owner_split_city VARCHAR(255),
ADD COLUMN owner_split_state VARCHAR(255);

UPDATE nashville_housing
SET
	owner_split_address = SPLIT_PART(owneraddress, ',', 1),
	owner_split_city = SPLIT_PART(owneraddress, ',', 2),
	owner_split_state = SPLIT_PART(owneraddress, ',', 3);

SELECT * FROM nashville_housing;

-- Change Y and N  to Yes and NO is 'Sold as Vacant' field

SELECT
	soldasvacant,
	COUNT(*)
FROM nashville_housing
GROUP BY 1
ORDER BY 2;

SELECT
	soldasvacant,
	CASE
		WHEN soldasvacant = 'Y' THEN 'Yes'
		WHEN soldasvacant = 'N' THEN 'No'
		ELSE soldasvacant
	END AS soldasvacant_new
FROM nashville_housing
WHERE soldasvacant IN ('Y','N');

UPDATE nashville_housing
SET soldasvacant = 
	CASE
		WHEN soldasvacant = 'Y' THEN 'Yes'
		WHEN soldasvacant = 'N' THEN 'No'
		ELSE soldasvacant
	END 
WHERE soldasvacant IN ('Y','N');

-- Remove Duplicates

SELECT *
FROM nashville_housing;

WITH ranked AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
		PARTITION BY 
			parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference,
			ownername
		ORDER BY 
			uniqueid
			) AS rnk
		FROM nashville_housing
)
SELECT *
FROM ranked 
WHERE rnk > 1;


WITH ranked AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
		PARTITION BY 
			parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference,
			ownername
		ORDER BY 
			uniqueid
			) AS rnk
		FROM nashville_housing
)
DELETE FROM nashville_housing n
USING ranked r
WHERE n.uniqueid = r.uniqueid AND rnk > 1;

-- Delete some unused columns

SELECT *
FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN propertyaddress,
DROP COLUMN	owneraddress,
DROP COLUMN	taxdistrict;