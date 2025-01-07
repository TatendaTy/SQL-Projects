SHOW TABLES;
SELECT *
FROM LOCATION
LIMIT 10;
SELECT *
FROM VISITS
LIMIT 10;
SELECT *
FROM WATER_SOURCE
LIMIT 10;
/* 2. understand the types of water sources */
SELECT distinct type_of_water_source
from water_source;
/* 3. Unpack the visits to water sources:
 Write an SQL query that retrieves all records from this table where the time_in_queue is more 
 than some crazy time, say 500 min. How would it feel to queue 8 hours for water? */
SELECT *
FROM VISITS
WHERE time_in_queue > 500;
SELECT *
FROM water_source
WHERE source_id IN ('AkRu05234224', 'HaZa21742224');
/* 4. Assess the quality of water sources:
 write a query to find records where the subject_quality_score is 10-- only looking for home taps-- 
 and where the source was visited a second time. What will this tell us?
 */
SELECT *
FROM water_quality
WHERE subjective_quality_score = 10
    AND visit_count = 2;
SELECT COUNT(*)
FROM water_quality
WHERE subjective_quality_score = 10
    AND visit_count = 2;
/* 5. Investigate pollution issues: Did you notice that we recorded contamination/pollution data for
 all of the well sources? Find the right table and print the first few rows
 */
SELECT *
FROM well_pollution
LIMIT 10;
/* write a query that checks if the results is Clean but the biological column is > 0.01 */
SELECT *
FROM well_pollution
WHERE results = 'clean'
    AND biological > 0.01;
/* find and remove the “Clean” part from all the descriptions that do have a biological contamination 
 so this mistake is not made again.
 
 Looking at the results we can see two different descriptions that we need to fix: 
 1. All records that 
 mistakenly have Clean Bacteria: E. coli should updated to Bacteria: E. coli 
 2. All records that mistakenly have Clean Bacteria: Giardia Lamblia should updated to Bacteria: Giardia Lamblia 
 3. Update the `result` to `Contaminated: Biological` where `biological` is greater than 0.01 plus current results
 is `Clean`
 */
SET SQL_SAFE_UPDATES = 0;
UPDATE well_pollution
SET description = REPLACE(
        description,
        'Clean Bacteria: E. coli',
        'Bacteria: E. coli'
    )
WHERE description LIKE '%Clean Bacteria: E. coli%'
    AND biological > 0.01;
UPDATE well_pollution
SET description = REPLACE(
        description,
        'Clean Bacteria: Giardia Lamblia',
        'Bacteria: Giardia Lamblia'
    )
WHERE description LIKE '%Clean Bacteria: Giardia Lamblia%'
    AND biological > 0.01;
UPDATE well_pollution
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
    AND results = 'Clean';
-- create a copy of the well_pollution table
CREATE TABLE md_water_services.well_pollution_copy AS (
    SELECT *
    FROM md_water_services.well_pollution
);
-- run the following queries
-- Update descriptions for E. coli contamination
UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';
-- Update descriptions for Giardia Lamblia contamination
UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';
-- Update results to indicate contamination
UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
    AND results = 'Clean';
-- Check for any remaining erroneous rows
SELECT *
FROM well_pollution_copy
WHERE description LIKE "Clean_%"
    OR (
        results = "Clean"
        AND biological > 0.01
    );
-- change the table back to the well_pollution and delete the well_pollution_copy table
UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';
UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';
UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
    AND results = 'Clean';
DROP TABLE md_water_services.well_pollution_copy;