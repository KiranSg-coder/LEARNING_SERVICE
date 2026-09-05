-- Phase 4: stop embedding REVIEW into daily progression.
-- Retention for guided topics is owned by REVIEW_SERVICE (Today's Reviews).
-- This script patches USP_GET_OR_CREATE_DAILY_LEARNING_PLAN by disabling the
-- REVIEW slot insert. Re-apply full 04_PLAN_PROCEDURES.sql only if you need
-- to restore the old block, then re-run this gate.
--
-- Practical approach: set a guard variable. Because CREATE OR ALTER must replace
-- the whole procedure, operators should edit section 4 in 04_PLAN_PROCEDURES.sql
-- to:
--   DECLARE @SKIPGUIDEDREVIEWSLOTS BIT = 1;
--   IF @SKIPGUIDEDREVIEWSLOTS = 0 AND @REVIEWTOPICID IS NOT NULL ...
--
-- Until that full redeploy, LEARNING_SERVICE filters REVIEW out of the Continue
-- Learning response and FE hides REVIEW from the timeline.

PRINT 'Phase 4 note: prefer Node/FE filter + event publish; optional SQL gate in 04_PLAN_PROCEDURES.sql';
GO
