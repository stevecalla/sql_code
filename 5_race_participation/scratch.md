
-- TODO = PARTICIPATION & MEMBERSHIP PERIOD DATA

-- DOCUMENT THE QUERY

-- RERUNNING DATA
    -- race results match - new / repeat stats
    -- mp match - create excel report summary

-- SETUP TIME TO REVIEW WITH TEAM

-- 2019 WITH SAM
    -- participation data = also large number of non-matches
    -- TBD

-- update the query logic for memberships with overlapping to take into account memberships that don't end in a given year but raced in that year
    -- modify logic for membership periods with overlapping race results
        0_ current logic counts based on membership period end year
        1_ need to consider 3-Year that have ends in future years but raced in current year
        2_ need to consider youth annual that have ends in future years but raced in current year
            -- has starts_mp = current year && start_date_races = current year

-------------------------
*************************
-------------------------
    #1-- match membership periods with overlapping race results
        -- DONE create data set that matches membership periods with overlapping race results
        -- DONE add the repeat / new field from the membership sales table
        -- DONE add member state, region
        -- DONE run all data from 2010 forward & QA
        -- DONE membership with matching race result = filter out duplicate race results 
            -- EXAMPLE: 1000906 has a duplicate for Dino Gravel Tri
        -- DONE ADD FIELDS
            -- add new vs repeat, lapsed vs otherwise
            -- add all member geo info such as state, lat, long, country, zip
            -- add membership sales event info such as name & ids
        
        -- create summary queries & put data in excel

        -- automate data every night - using created at / updated at dates
        -- add data to looker
        -- CONNECT POWER PIVOT TO USAT SERVER DB
        
    #2 -- match race results with overlapping membership periods
        -- DONE create data set that matches race results with overlapping membership periods
        -- DONE create # of races summary
        -- DONE create summary queries & put data in excel
        -- DONE add the repeat / new field from the membership sales table
        -- DONE add member state, region
        -- DONE run all data from 2010 forward & QA
        -- DONE double check duplicate SQL statement - is okay; id_rr should never be null
        -- DONE ADD FIELDS
            -- add new vs repeat, lapsed vs otherwise
            -- add all member geo info such as state, lat, long, country, zip
            -- add membership sales event info such as name & ids

        -- automate data every night - using created at / updated at dates
        -- add data to looker
        -- CONNECT POWER PIVOT TO USAT SERVER DB

    #3 -- OTHER
        -- add lifetime races per member?
        -- create participation profile
        -- CREATE RACE RESULTS PROFILES
            -- races - results by race id, a race profile data set
            -- participant - results by participant results, a participant profile dataset

    #4 -- DONE = CONVERSATION WITH SAM = Agenda:
        -- CREATED LOGIC TO MATCH
            -- race results with matching memberships
            -- memberships with matching race results
        -- Review slack note re: membership sales with no race result match
        -- Review membership sales race event id vs race results event id
        -- Logic to match membership with race results for a particular year?
            -- Ends_mp logic

**************************
-- QUERY LIBRARY
**************************
    -- race count by year
        -- 5_race_participation\local_participation_raw_queries_031625.sql
        -- run QUERY #1
    -- participation per profile id
        -- RUN QUERY #2A
        -- 5_race_participation\local_participation_raw_queries_031625.sql
        -- run SELECT * FROM participant_race_count_average; 
    -- participation by race count
        -- RUN QUERY #2B
        -- 5_race_participation\local_participation_raw_queries_031625.sql
        -- run SELECT * FROM summarize_by_count;

