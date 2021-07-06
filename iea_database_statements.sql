-- Creating a new database for this project in postgresql using superuser
-- [ CREATE DATABASE iea WITH OWNER soham ]



-- creating table for IEA public RD & D budgets
DROP TABLE IF EXISTS public_rd CASCADE;
CREATE TABLE public_rd (
  id SERIAL,
  country VARCHAR(128),
  currency_type VARCHAR(128),
  sectors VARCHAR(128),
  year INTEGER,
  amount FLOAT
)
