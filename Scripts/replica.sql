-- Role: rep_user
-- DROP ROLE IF EXISTS rep_user;

CREATE USER replica_user WITH PASSWORD 'password123';
ALTER USER replica_user WITH REPLICATION LOGIN;

SELECT * FROM pg_create_logical_replication_slot('music_replication_slot', 'pgoutput');
3
SELECT * FROM pg_replication_slots;
SELECT * FROM pg_stat_replication;

SELECT pg_stop_replication('my_subscription');
SELECT pg_drop_replication_slot('music_replication_slot');
SELECT pg_drop_replication_slot('pg_16627_sync_16447_7233229427087881376');
SELECT pg_drop_replication_slot('pg_16627_sync_16456_7233229427087881376');
SELECT pg_drop_replication_slot('pg_16627_sync_16471_7233229427087881376');
SELECT pg_drop_replication_slot('pg_16627_sync_16478_7233229427087881376');
SELECT pg_drop_replication_slot('pg_16627_sync_16493_7233229427087881376');
SELECT pg_drop_replication_slot('pg_16627_sync_16503_7233229427087881376');
SELECT pg_drop_replication_slot('pg_16627_sync_16518_7233229427087881376');
SELECT pg_drop_replication_slot('pg_16627_sync_16598_7233229427087881376');
SELECT pg_drop_replication_slot('pg_16627_sync_16429_7233229427087881376');

CREATE PUBLICATION music_publication FOR ALL TABLES;
CREATE PUBLICATION my_publication FOR ALL TABLES;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO replica_user;