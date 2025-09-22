-- PostGIS拡張を有効化
-- これによりPostgreSQLで地理空間データを扱えるようになります

-- PostGIS拡張を有効化
CREATE EXTENSION IF NOT EXISTS postgis;

-- PostGIS拡張の確認
SELECT PostGIS_Version();