-- ELISAPRISCO SUKOCO

-- Portofolio Project Covid 19 Data Exploration
-- Skill yang digunakan: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views


-- Cek data
SELECT *
From covid_deaths
WHERE continent is not null 
ORDER BY 3,4;

-- Data yang akan digunakan
SELECT location as negara,
	date as tanggal,
	total_cases as total_kasus,
	new_cases as kasus_baru,
	total_deaths as total_kematian,
	population as populasi
FROM covid_deaths
WHERE continent is not null 
ORDER BY 1,2;

-- Presentase kematian/kasus
SELECT location as negara,
	date as tanggal,
	total_cases as total_kasus,
	total_deaths as total_kematian,
	ROUND(((total_deaths/total_cases)*100),2) as persentase_kematian
FROM covid_deaths
WHERE continent is not null 
ORDER BY 1, 2;

-- Presentase kematian di Indonesia
SELECT location as negara,
	date as tanggal,
	total_cases as total_kasus,
	total_deaths as total_kematian,
	ROUND(((total_deaths/total_cases)*100),2) as persentase_kematian
FROM covid_deaths
WHERE location LIKE 'Indonesia'
AND continent is not null 
ORDER BY 2;

-- Presentase kasus di Indonesia
SELECT location as negara,
	date as tanggal,
	population as populasi,
	total_cases as total_kasus,
	ROUND(((total_cases/population)*100),2) as persentase_kasus
FROM covid_deaths
WHERE location = 'Indonesia'
AND continent is not null 
ORDER BY 2;

-- Presentase kasus di dunia
SELECT location as negara,
	date as tanggal,
	population as populasi,
	total_cases as total_kasus,
	ROUND(((total_cases/population)*100),2) as persentase_kasus
FROM covid_deaths
WHERE continent is not null 
ORDER BY 1,2;

-- Negara dengan infeksi tertinggi
SELECT location as negara,
	population as populasi,
	MAX(total_cases) as infeksi_tertinggi,
	ROUND(MAX((total_cases/population)),2)*100 as persentase_infeksi
FROM covid_deaths
WHERE continent is not null
AND total_cases is not null
GROUP BY location,
	population
ORDER BY 4 DESC;

-- Negara dengan kematian terbanyak
SELECT location as negara,
	MAX(total_deaths) as total_kematian
FROM covid_deaths
WHERE continent is not null
AND total_deaths is not null
GROUP BY location
ORDER BY 2 DESC;

-- Benua dengan kematian terbanyak
SELECT continent as benua,
	MAX(total_deaths) as total_kematian
FROM covid_deaths
WHERE continent is not null
AND total_deaths is not null
GROUP BY continent
ORDER BY 2 DESC;

-- Angka keseluruhan
SELECT date as tanggal,
	SUM(new_cases) as total_kasus,
	SUM(new_deaths) as total_kematian,
	ROUND(SUM(new_deaths)/SUM(new_cases),2)*100 as presentase_kematian
FROM covid_deaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) as total_kasus,
	SUM(new_deaths) as total_kematian,
	ROUND(SUM(new_deaths)/SUM(new_cases),2)*100 as presentase_kematian
FROM covid_deaths
WHERE continent is not null;

-- Join covid_deaths dengan covid_vaccinations
SELECT *
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

-- Total populasi banding vaksinasi
SELECT dea.continent as benua,
	dea.location as negara,
	dea.date as tanggal,
	dea.population as populasi,
	vac.new_vaccinations as vaksinasi,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
									ORDER BY dea.location,
									dea.date) as rolling_vaksinasi
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- Menggunakan CTE
WITH popvsvac (benua,
			   negara,
			   tanggal,
			   populasi,
			   vaksinasi,
			   rolling_vaksinasi) as (SELECT dea.continent as benua,
										dea.location as negara,
										dea.date as tanggal,
										dea.population as populasi,
										vac.new_vaccinations as vaksinasi,
										SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
																		ORDER BY dea.location,
																		dea.date) as rolling_vaksinasi
										FROM covid_deaths dea
										JOIN covid_vaccinations vac
											ON dea.location = vac.location
											AND dea.date = vac.date
										WHERE dea.continent is not null)
SELECT *,
	ROUND((rolling_vaksinasi/populasi),2)*100
FROM popvsvac
WHERE negara = 'Indonesia'

-- Temp Table
DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TABLE percent_population_vaccinated
	(continent varchar(255),
	location varchar(255),
	date date,
	population numeric,
	new_vaccinations numeric,
	rolling_vaksinasi numeric);	
INSERT INTO percent_population_vaccinated
SELECT dea.continent as benua,
	dea.location as negara,
	dea.date as tanggal,
	dea.population as populasi,
	vac.new_vaccinations as vaksinasi,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
									ORDER BY dea.location,
										dea.date) as rolling_vaksinasi
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null;
SELECT *,
	ROUND((rolling_vaksinasi/population),2)*100 as persentase_vaksinasi
FROM percent_population_vaccinated
WHERE location = 'Indonesia';

-- Creating view
DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE VIEW percent_population_vaccinated as SELECT dea.continent as benua,
													dea.location as negara,
													dea.date as tanggal,
													dea.population as populasi,
													vac.new_vaccinations as vaksinasi,
													SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
																						ORDER BY dea.location,
																							dea.date) as rolling_vaksinasi
												FROM covid_deaths dea
												JOIN covid_vaccinations vac
													ON dea.location = vac.location
													AND dea.date = vac.date
												WHERE dea.continent is not null;
												
SELECT *
FROM percent_population_vaccinated;






























