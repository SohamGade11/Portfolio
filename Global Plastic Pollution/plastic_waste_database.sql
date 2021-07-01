-- Collecting raw data for waste generated per day
DROP TABLE IF EXISTS raw_data_gen CASCADE;
CREATE TABLE raw_data_gen (
  id SERIAL,
  entity VARCHAR(128),
  code CHAR(10),
  year INTEGER,
  waste_gen_perday FLOAT,
  gdp_percapita FLOAT,
  population FLOAT,
  region CHAR(50),
  PRIMARY KEY(id)
);

\copy raw_data_gen(entity, code, year, waste_gen_perday, gdp_percapita, population, region) FROM 'datasets/per-capita-plastic-waste-vs-gdp-per-capita.csv' WITH DELIMITER ',' CSV HEADER;

-- Collecting raw data for waste mismanaged per day
DROP TABLE IF EXISTS raw_data_mis;
CREATE TABLE raw_data_mis (
  id SERIAL,
  entity VARCHAR(128),
  code CHAR(10),
  year INTEGER,
  waste_mis_perday FLOAT,
  gdp_percapita FLOAT,
  population FLOAT,
  region CHAR(50),
  PRIMARY KEY(id)
);

\copy raw_data_mis(entity, code, year, waste_mis_perday, gdp_percapita, population, region) FROM 'datasets/per-capita-mismanaged-plastic-waste-vs-gdp-per-capita.csv' WITH DELIMITER ',' CSV HEADER;

-- Creating main table
DROP TABLE IF EXISTS plastic_waste CASCADE;
CREATE TABLE plastic_waste AS
  SELECT rg.id, rg.entity, rg.code, rg.year, rg.waste_gen_perday,
        rm.waste_mis_perday, rg.gdp_percapita, rg.population, rg.region
  FROM raw_data_gen rg
  LEFT JOIN raw_data_mis rm ON rg.id = rm.id;


DROP TABLE raw_data_gen;
DROP TABLE raw_data_mis;

SELECT entity, code, year, waste_gen_perday, waste_mis_perday, gdp_percapita
  FROM plastic_waste WHERE (waste_gen_perday, waste_mis_perday) IS NOT NULL
  ORDER BY waste_mis_perday DESC LIMIT 5;

-- Updating generated waste table with mismanaged waste values since all other columns are similar
-- ALTER TABLE raw_data_gen
--   ADD COLUMN waste_mis_perday FLOAT;
--
-- UPDATE raw_data_gen SET waste_mis_perday = (SELECT waste_mis_perday FROM raw_data_mis WHERE raw_data_gen.id = raw_data_mis.id);

-- -- Droping raw mismanaged table since we do not need it anymore
-- DROP TABLE raw_data_mis;
--
--
--
-- DROP TABLE IF EXISTS region CASCADE;
-- CREATE TABLE region (
--   id SERIAL,
--   name CHAR(50) UNIQUE,
--   PRIMARY KEY(id)
-- );
-- -- inserting unique values in region table
-- INSERT INTO region(name) SELECT DISTINCT region FROM raw_data_gen;
--
--
-- -- DROP TABLE IF EXISTS year CASCADE;
-- -- CREATE TABLE year {
-- --   id SERIAL,
-- --   year INTEGER,
-- --   PRIMARY KEY(id)
-- -- };
-- -- -- inserting unique values in year table
-- -- INSERT INTO year(year) SELECT DISTINCT year FROM raw_data_gen;
--
--
-- DROP TABLE IF EXISTS gdp CASCADE;
-- CREATE TABLE gdp (
--   id SERIAL,
--   amount FLOAT,
--   PRIMARY KEY(id)
-- );
-- -- inserting gdp per capita as per the enity codes
-- INSERT INTO gdp(amount) SELECT gdp_percapita FROM raw_data_gen;
--
--
-- DROP TABLE IF EXISTS waste_gen_values CASCADE;
-- CREATE TABLE waste_gen_values (
--   id SERIAL,
--   amount FLOAT,
--   PRIMARY KEY(id)
-- );
-- -- inserting waste generated per day in kgs by an individual
-- INSERT INTO waste_gen_values(amount) SELECT waste_gen_perday FROM raw_data_gen;
--
--
-- DROP TABLE IF EXISTS waste_mis_values CASCADE;
-- CREATE TABLE waste_mis_values (
--   id SERIAL,
--   amount FLOAT,
--   PRIMARY KEY(id)
-- );
-- -- inserting waste mismanaged per day in kgs by an individual
-- INSERT INTO waste_mis_values(amount) SELECT waste_mis_perday FROM raw_data_gen;
--
--
--
-- -- Adding foreign keys to raw_data_gen table so as to get foreign key id's from lookuptables
-- ALTER TABLE raw_data_gen
--   ADD COLUMN waste_gen_id INTEGER REFERENCES waste_gen_values(id) ON DELETE CASCADE,
--   ADD COLUMN waste_mis_id INTEGER REFERENCES waste_mis_values(id) ON DELETE CASCADE,
--   ADD COLUMN gdp_id INTEGER REFERENCES gdp(id) ON DELETE CASCADE,
--   ADD COLUMN region_id INTEGER REFERENCES region(id) ON DELETE CASCADE;
--
-- UPDATE raw_data_gen
--   SET
--     waste_gen_id = (SELECT id FROM waste_gen_values WHERE
--       raw_data_gen.waste_gen_perday = waste_gen_values.amount),
--     waste_mis_id = (SELECT id FROM waste_mis_values WHERE
--       raw_data_gen.waste_mis_perday = waste_mis_values.amount),
--     gdp_id = (SELECT id FROM gdp WHERE
--       raw_data_gen.gdp_percapita = gdp.amount),
--     region_id = (SELECT id FROM region WHERE
--       raw_data_gen.region = region.name);
--
--
--
--
-- -- -- creating main table
-- -- DROP TABLE IF EXISTS plastic_waste CASCADE;
-- -- CREATE TABLE plastic_waste (
-- --   id SERIAL,
-- --   entity VARCHAR(128),
-- --   code CHAR(10),
-- --   year INTEGER,
-- --   waste_gen_id INTEGER,
-- --   waste_mis_id INTEGER,
-- --   gdp_id FLOAT,
-- --   population BIGINT,
-- --   region_id INTEGER,
-- --   PRIMARY KEY(id),
-- --   UNIQUE(entity, code, year)
-- -- );
-- -- -- inserting values in the main table
-- -- INSERT INTO plastic_waste(entity, code, year, population,
-- --    waste_gen_id, waste_mis_id, gdp_id, region_id)
-- -- SELECT entity, code, year, population,
-- --    waste_gen_id, waste_mis_id, gdp_id, region_id
-- -- FROM raw_data_gen;
-- --
-- --
-- --
-- -- -- dropping raw_data_gen since we do not need it anymore
-- -- DROP TABLE raw_data_gen;
-- --
-- --
-- --
-- -- -- executing query to see if the data model is working
-- -- SELECT entity, code, year, g.amount AS GDP_per_capita, population,
-- --   wg.amount AS waste_generated_per_person,
-- --   mg.amount AS waste_mismanaged_per_person, r.name AS continent
-- --   FROM plastic_waste p
-- --     JOIN gdp g ON p.gdp_id = g.id
-- --     JOIN waste_gen_values wg ON p.waste_gen_id = wg.id
-- --     JOIN waste_mis_values mg ON p.waste_mis_id = mg.id
-- --     JOIN region r ON p.region_id = r.id
-- --   WHERE p.year=2010 LIMIT 5;
