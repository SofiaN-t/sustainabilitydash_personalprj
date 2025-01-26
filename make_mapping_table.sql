-- SELECT 
--   DISTINCT country AS original_country
-- FROM unpivot_ghg_totals_by_country
-- WHERE country REGEXP '[^ -~]';

CREATE TABLE mapping_countries(
    original_country VARCHAR(100),
    mapped_country VARCHAR(100)
);

INSERT INTO mapping_countries (original_country, mapped_country)
VALUES
('Curaçao','Curacao'),
('Côte d’Ivoire','Cote d Ivoire'),
('Réunion','Reunion'),
('São Tomé and Príncipe','Sao Tome and Principe'),
('Türkiye','Turkiye')

