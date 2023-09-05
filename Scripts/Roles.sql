CREATE ROLE Author;
CREATE ROLE Listener;
CREATE ROLE Administrator;

GRANT SELECT, INSERT, DELETE, UPDATE ON audio to Author;
GRANT SELECT, INSERT, DELETE, UPDATE ON author_audio to Author;
GRANT SELECT, INSERT, UPDATE, DELETE ON genre_audio to Author;
GRANT SELECT, INSERT, UPDATE, DELETE ON nravlik to Author;
GRANT SELECT, INSERT, UPDATE, DELETE ON nravlik_albums to Author;
GRANT SELECT, INSERT, UPDATE, DELETE ON follows to Author;
GRANT SELECT ON genre to Author;
GRANT SELECT, INSERT, DELETE, UPDATE ON playlist to Author;
GRANT SELECT, INSERT, DELETE, UPDATE ON album to Author;
GRANT SELECT, INSERT, DELETE, UPDATE ON album_audio to Author;
GRANT SELECT, INSERT, DELETE, UPDATE ON album_author to Author;
GRANT SELECT, INSERT, DELETE, UPDATE ON save_audio to Author;
GRANT SELECT, INSERT, DELETE, UPDATE ON person to Author;
GRANT SELECT, INSERT, DELETE, UPDATE ON playlist_audio to Author;
GRANT SELECT, INSERT, DELETE, UPDATE ON playlist_author to Author;
GRANT SELECT, INSERT, DELETE, UPDATE ON role_person to Author;
GRANT SELECT ON role to Author;
GRANT SELECT, USAGE ON person_id_seq to Author;
GRANT SELECT ON genre_id_seq to Author;
GRANT SELECT, USAGE ON audio_id_seq to Author;
GRANT SELECT, USAGE ON playlist_id_seq to Author;
GRANT SELECT ON role_id_seq to Author;
GRANT SELECT, USAGE ON album_id_seq to Author;

GRANT SELECT, INSERT, UPDATE, DELETE ON nravlik_albums to Listener;
GRANT SELECT, INSERT, UPDATE, DELETE ON follows to Listener;
GRANT SELECT ON album to Listener;
GRANT SELECT ON album_audio to Listener;
GRANT SELECT ON album_author to Listener;
GRANT SELECT ON audio to Listener;
GRANT SELECT ON author_audio to Listener;
GRANT SELECT ON genre_audio to Listener;
GRANT SELECT ON genre to Listener;
GRANT SELECT, INSERT, DELETE, UPDATE ON playlist to Listener;
GRANT SELECT, INSERT, DELETE, UPDATE ON save_audio to Listener;
GRANT SELECT, INSERT, DELETE, UPDATE ON nravlik to Listener;
GRANT SELECT, INSERT, DELETE, UPDATE ON person to Listener;
GRANT SELECT, INSERT, DELETE, UPDATE ON playlist_audio to Listener;
GRANT SELECT, INSERT, DELETE, UPDATE ON playlist_author to Listener;
GRANT SELECT, INSERT, DELETE, UPDATE ON role_person to Listener;
GRANT SELECT ON role to Listener;
GRANT SELECT, USAGE ON person_id_seq to Listener;
GRANT SELECT, USAGE ON genre_id_seq to Listener;
GRANT SELECT, USAGE ON audio_id_seq to Listener;
GRANT SELECT, USAGE ON playlist_id_seq to Listener;
GRANT SELECT, USAGE ON role_id_seq to Listener;

GRANT ALL PRIVILEGES ON DATABASE "MusicDB" TO administrator;