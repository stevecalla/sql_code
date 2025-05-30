USE vapor;

-- CHATGPT
WITH duplicate_candidates AS (
  SELECT
    -- Normalized text fields with punctuation removed and trimmed
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.first_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")) AS first_name,
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.last_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")) AS last_name,
    p.date_of_birth,
    ph.normalized AS phone,
    TRIM(LOWER(a.postal_code)) AS postal_code,

    -- Profile IDs for traceability
    GROUP_CONCAT(p.id ORDER BY p.id) AS duplicate_profile_ids,

    -- Duplication metric
    COUNT(*) AS combo_count,

    -- Missing field indicators
    MAX(CASE WHEN p.first_name IS NULL OR p.first_name = '' THEN 1 ELSE 0 END) AS missing_first,
    MAX(CASE WHEN p.last_name IS NULL OR p.last_name = '' THEN 1 ELSE 0 END) AS missing_last,
    MAX(CASE WHEN p.date_of_birth IS NULL THEN 1 ELSE 0 END) AS missing_dob,
    MAX(CASE WHEN ph.normalized IS NULL OR ph.normalized = '' THEN 1 ELSE 0 END) AS missing_phone,
    MAX(CASE WHEN a.postal_code IS NULL OR a.postal_code = '' THEN 1 ELSE 0 END) AS missing_postal

  FROM profiles p
		LEFT JOIN users AS u ON p.user_id = u.id
		LEFT JOIN phones ph ON p.primary_phone_id = ph.id
		LEFT JOIN addresses a ON p.primary_address_id = a.id

  WHERE p.deleted_at IS NULL

  GROUP BY
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.first_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")),
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.last_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")),
    p.date_of_birth,
    ph.normalized,
    TRIM(LOWER(a.postal_code))

  HAVING COUNT(*) > 1
),
dedupe_enhanced_query AS (
  SELECT
    "chatgpt_dedupe_enhanced_query" AS query_name,
    "chatgpt_dedupe_first_last_name_dob_phone_zip" AS query_criteria,
    d.*,
    CASE
      WHEN missing_first + missing_last + missing_dob + missing_phone + missing_postal > 0 THEN 'needs_review_missing_field(s)'
      WHEN combo_count >= 21 THEN 'high_duplicate_risk_21_or_more_duplicates'
      WHEN combo_count BETWEEN 11 AND 20 THEN 'elevated_duplicate_risk_11_to_20_dupicates'
      WHEN combo_count BETWEEN 3 AND 10 THEN 'moderate_duplicate_risk_3_to_10_duplicates'
      WHEN combo_count = 2 THEN 'duplicate_risk_2_duplicates'
      ELSE 'Unlikely Duplicate'
    END AS confidence_level

  FROM duplicate_candidates AS d
  ORDER BY confidence_level DESC, combo_count DESC, last_name ASC
)
-- SELECT * FROM dedupe_enhanced_query LIMIT 10
SELECT * FROM dedupe_enhanced_query
-- SELECT * FROM dedupe_enhanced_query WHERE confidence_level IN ("duplicate_risk_2_duplicates", "moderate_duplicate_risk_3_to_10_duplicatesk")
-- SELECT query_name, query_criteria, confidence_level, FORMAT(COUNT(*), 0) FROM dedupe_enhanced_query GROUP BY confidence_level WITH ROLLUP
;

-- CALLA #1:
WITH duplicate_candidates AS (
  SELECT
    -- Normalized text fields with punctuation removed and trimmed
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.first_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")) AS first_name,
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.last_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")) AS last_name,
    p.date_of_birth,
    TRIM(LOWER(u.email)) AS email,

    -- Profile IDs for traceability
    GROUP_CONCAT(p.id ORDER BY p.id) AS duplicate_profile_ids,

    -- Duplication metric
    COUNT(*) AS combo_count,

    -- Missing field indicators
    MAX(CASE WHEN p.first_name IS NULL OR p.first_name = '' THEN 1 ELSE 0 END) AS missing_first,
    MAX(CASE WHEN p.last_name IS NULL OR p.last_name = '' THEN 1 ELSE 0 END) AS missing_last,
    MAX(CASE WHEN p.date_of_birth IS NULL THEN 1 ELSE 0 END) AS missing_dob,
    MAX(CASE WHEN u.email IS NULL OR u.email = '' THEN 1 ELSE 0 END) AS missing_email

  FROM profiles p
		LEFT JOIN users AS u ON p.user_id = u.id
		LEFT JOIN phones ph ON p.primary_phone_id = ph.id
		LEFT JOIN addresses a ON p.primary_address_id = a.id

  WHERE p.deleted_at IS NULL

  GROUP BY
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.first_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")),
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.last_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")),
    p.date_of_birth,
    LOWER(u.email)

  HAVING COUNT(*) > 1
),
dedupe_enhanced_query AS (
  SELECT
    "calla_#1_dedupe_enhanced_query" AS query_name,
    "calla_#1_dedupe_first_last_name_dob_email" AS query_criteria,
    d.*,
    CASE
      WHEN missing_first + missing_last + missing_dob + missing_email > 0 THEN 'needs_review_missing_field(s)'
      WHEN combo_count >= 21 THEN 'high_duplicate_risk_21_or_more_duplicates'
      WHEN combo_count BETWEEN 11 AND 20 THEN 'elevated_duplicate_risk_11_to_20_dupicates'
      WHEN combo_count BETWEEN 3 AND 10 THEN 'moderate_duplicate_risk_3_to_10_duplicates'
      WHEN combo_count = 2 THEN 'duplicate_risk_2_duplicates'
      ELSE 'Unlikely Duplicate'
    END AS confidence_level

  FROM duplicate_candidates AS d
  ORDER BY confidence_level DESC, combo_count DESC, last_name ASC
)
-- SELECT * FROM dedupe_enhanced_query LIMIT 10
-- SELECT * FROM dedupe_enhanced_query
-- SELECT * FROM dedupe_enhanced_query WHERE confidence_level IN ("duplicate_risk_2_duplicates", "moderate_duplicate_risk_3_to_10_duplicatesk")
SELECT query_name, query_criteria, confidence_level, FORMAT(COUNT(*), 0) FROM dedupe_enhanced_query GROUP BY confidence_level WITH ROLLUP
;

-- CALLA #2
WITH duplicate_candidates AS (
  SELECT
    -- Normalized text fields with punctuation removed and trimmed
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.first_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")) AS first_name,
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.last_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")) AS last_name,
    TRIM(LOWER(u.email)) AS email,

    -- Profile IDs for traceability
    GROUP_CONCAT(p.id ORDER BY p.id) AS duplicate_profile_ids,

    -- Duplication metric
    COUNT(*) AS combo_count,

    -- Missing field indicators
    MAX(CASE WHEN p.first_name IS NULL OR p.first_name = '' THEN 1 ELSE 0 END) AS missing_first,
    MAX(CASE WHEN p.last_name IS NULL OR p.last_name = '' THEN 1 ELSE 0 END) AS missing_last,
    MAX(CASE WHEN p.date_of_birth IS NULL THEN 1 ELSE 0 END) AS missing_dob,
    MAX(CASE WHEN u.email IS NULL OR u.email = '' THEN 1 ELSE 0 END) AS missing_email

  FROM profiles p
		LEFT JOIN users AS u ON p.user_id = u.id
		LEFT JOIN phones ph ON p.primary_phone_id = ph.id
		LEFT JOIN addresses a ON p.primary_address_id = a.id

  WHERE p.deleted_at IS NULL

  GROUP BY
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.first_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")),
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(p.last_name), "'", ""), ",", ""), ".", ""), "-", ""), "/", "")),
    LOWER(u.email)

  HAVING COUNT(*) > 1
),
dedupe_enhanced_query AS (
  SELECT
    "dedupe_enhanced_query" AS query_name,
    "calla_#2_dedupe_first_last_name_email" AS query_criteria,
    d.*,
    CASE
      WHEN missing_first + missing_last + missing_email > 0 THEN 'needs_review_missing_field(s)'
      WHEN combo_count >= 21 THEN 'high_duplicate_risk_21_or_more_duplicates'
      WHEN combo_count BETWEEN 11 AND 20 THEN 'elevated_duplicate_risk_11_to_20_dupicates'
      WHEN combo_count BETWEEN 3 AND 10 THEN 'moderate_duplicate_risk_3_to_10_duplicates'
      WHEN combo_count = 2 THEN 'duplicate_risk_2_duplicates'
      ELSE 'Unlikely Duplicate'
    END AS confidence_level

  FROM duplicate_candidates AS d
  ORDER BY confidence_level DESC, combo_count DESC, last_name ASC
)
-- SELECT * FROM dedupe_enhanced_query LIMIT 10
SELECT * FROM dedupe_enhanced_query
-- SELECT * FROM dedupe_enhanced_query WHERE confidence_level IN ("duplicate_risk_2_duplicates", "moderate_duplicate_risk_3_to_10_duplicatesk")
-- SELECT query_name, query_criteria, confidence_level, FORMAT(COUNT(*), 0) FROM dedupe_enhanced_query GROUP BY confidence_level WITH ROLLUP
;
