SELECT * FROM vapor.events;

SELECT 
    -- EVENTS TABLE
    events.id AS id_events,
    events.event_type_id AS event_type_id_events,
    events.name AS name_events,
    
    events.created_at AS created_at_events,
    events.starts AS starts_events,
    events.ends AS ends_events,
    events.status AS status_events,

    events.race_director_id AS race_director_id_events,
    events.last_season_event_id AS last_season_event_id,

    events.city AS city_events,
    events.state AS state_events,
    events.country_name AS country_name_events,
    events.country AS country_events
FROM events;