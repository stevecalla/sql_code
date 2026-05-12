SELECT * FROM ranking_list_period_entries WHERE profile_id = 2946524 ORDER BY profile_id DESC LIMIT 30;

SELECT * FROM ranking_list_period_entry_race_result ORDER BY ranking_list_period_entry_id DESC LIMIT 10;

SELECT * FROM race_results ORDER BY created_at DESC LIMIT 10;
SELECT * FROM races LIMIT 10; -- event_id
SELECT * FROM events LIMIT 10; -- events.id

-- ranking_list_period_entries.id to ranking_list_period_entry_race_result.ranking_list_period_entry_id
-- ranking_list_period_entry_race_result.race_result_id joins race_results.id

SELECT rlpe.*, rlperr.race_result_id, .id, e.name
FROM ranking_list_period_entries AS rlpe
	INNER JOIN ranking_list_period_entry_race_result AS rlperr ON rlperr.ranking_list_period_entry_id = rlpe.id
	INNER JOIN race_results AS rr ON rr.id = rlperr.race_result_id
	INNER JOIN races as r ON r.id = rr.race_id
    
        INNER JOIN events AS e ON e.id = r.event_id
WHERE rlpe.profile_id = 2479506 
ORDER BY profile_id DESC LIMIT 30;

