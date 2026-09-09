-- db_constraints.sql
-- Sovereign Alpha -- Database-Level Integrity Constraints
-- Run ONCE against the Aiven PostgreSQL instance.
--
-- Usage:
--   psql $DATABASE_URL -f db_constraints.sql

-- 1. CONFIDENCE SCORE GATE: confidence_score >= 50
--    Rejects any INSERT/UPDATE where the LLM returned sub-50 confidence.
ALTER TABLE prediction_ledger
    ADD CONSTRAINT chk_confidence_score_minimum
    CHECK (confidence_score >= 50);

-- 2. PRICE SANITY GATE: entry_price, target_price, stop_loss must be > 0
--    Prevents the zero-price corruption from LLM fallback returning 0.0.
ALTER TABLE prediction_ledger
    ADD CONSTRAINT chk_entry_price_positive
    CHECK (entry_price IS NULL OR entry_price > 0);

ALTER TABLE prediction_ledger
    ADD CONSTRAINT chk_target_price_positive
    CHECK (target_price IS NULL OR target_price > 0);

ALTER TABLE prediction_ledger
    ADD CONSTRAINT chk_stop_loss_positive
    CHECK (stop_loss IS NULL OR stop_loss > 0);

-- Verify constraints are active:
SELECT conname, pg_get_constraintdef(oid) AS definition
FROM   pg_constraint
WHERE  conrelid = 'prediction_ledger'::regclass
AND    contype  = 'c';
