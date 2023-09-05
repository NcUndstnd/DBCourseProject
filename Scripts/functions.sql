/* get info about user by username */
CREATE OR REPLACE FUNCTION get_info_by_username(user_name TEXT)
    RETURNS SETOF person AS
$$
DECLARE
BEGIN
    RETURN QUERY SELECT *
                 FROM person p
                 WHERE (p.username = user_name);
END;
$$
    LANGUAGE plpgsql;

/* get amount of nravlicks */
CREATE OR REPLACE FUNCTION get_amount_of_nravlicks_by_audio_id(_audio_id INTEGER)
    RETURNS INTEGER AS
$$
DECLARE
    result INTEGER;
BEGIN
    SELECT count(n.audio_id)
    INTO result
    FROM nravlik n
    WHERE n.audio_id = _audio_id;
    RETURN result;
END;
$$
    LANGUAGE plpgsql;

/* get all audios from author by author name */
CREATE OR REPLACE FUNCTION get_all_audios_by_author_name(author_name TEXT)
    RETURNS SETOF audio AS
$$
BEGIN
    RETURN QUERY SELECT a.id, a.name, a.text, a.upload_date
                 FROM author_audio aa
                          JOIN person p ON p.id = aa.author_id
                          JOIN audio a ON a.id = aa.audio_id
                 WHERE (p.username = author_name);
END;
$$
    LANGUAGE plpgsql;

/* get all audios in playlist */
CREATE OR REPLACE FUNCTION get_all_audios_from_playlist_by_playlist_id(_playlist_id INTEGER)
    RETURNS TABLE
            (
                audio_name VARCHAR(32),
                authors     TEXT
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT a.name, string_agg(username, ', ') authors
        FROM playlist_audio paud
                 JOIN audio a ON a.id = paud.audio_id
                 JOIN author_audio aa ON aa.audio_id = a.id
                 JOIN person p ON p.id = aa.author_id
        WHERE paud.playlist_id = _playlist_id
        GROUP BY a.name;
END;
$$
    LANGUAGE plpgsql;

/* get info about audio by audio id */
CREATE OR REPLACE FUNCTION get_audio_info_by_audio_id(_audio_id INTEGER)
    RETURNS TABLE
            (
                authors     TEXT,
                audio_name  VARCHAR(32),
                upload_date TIMESTAMP
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT string_agg(p.username, ', '), a.name, a.upload_date
        FROM author_audio aa
                 JOIN audio a ON a.id = aa.audio_id
                 JOIN person p ON p.id = aa.author_id
        WHERE aa.audio_id = _audio_id
        GROUP BY a.name, a.upload_date;
END;
$$
    LANGUAGE plpgsql;

/* get audio by genre */
CREATE OR REPLACE FUNCTION get_all_audios_by_genre(genre_name TEXT)
    RETURNS TABLE
            (
                audio_id          INT,
                audio_name        VARCHAR(32),
                text              VARCHAR(10000),
                audio_upload_date TIMESTAMP,
                authors           TEXT
            )
AS
$$
BEGIN
    RETURN QUERY SELECT a.id, a.name, a.text, a.upload_date, string_agg(p.username, ', ')
                 FROM genre_audio ga
                          JOIN genre g ON ga.genre_id = g.id
                          JOIN audio a ON ga.audio_id = a.id
                          JOIN author_audio aa on a.id = aa.audio_id
                          JOIN person p on p.id = aa.author_id
                 WHERE (g.name = genre_name)
                 GROUP BY a.id;
END;
$$
    LANGUAGE plpgsql;

/* get save audio by username */
CREATE OR REPLACE FUNCTION get_all_save_audio_by_username(user_name TEXT)
    RETURNS SETOF audio AS
$$
BEGIN
    RETURN QUERY SELECT a.id, a.name, a.text, a.upload_date
                 FROM save_audio sa
                          JOIN person p ON sa.person_id = p.id
                          JOIN audio a ON sa.audio_id = a.id
                 WHERE (p.username = user_name);
END;
$$
    LANGUAGE plpgsql;
	
/* get audio by name */
CREATE OR REPLACE FUNCTION get_audio_by_name(audio_name TEXT)
    RETURNS SETOF audio AS
$$
BEGIN
    RETURN QUERY
        SELECT *
        FROM audio a
        WHERE a.name ILIKE '%' || audio_name || '%';
END;
$$
    LANGUAGE plpgsql;

/* get playlists by name */
CREATE OR REPLACE FUNCTION get_playlists_by_name(playlist_name TEXT)
    RETURNS SETOF playlist AS
$$
BEGIN
    RETURN QUERY
        SELECT *
        FROM playlist p
        WHERE p.name ILIKE '%' || playlist_name || '%';
END;
$$
    LANGUAGE plpgsql;

/* get audio by author name */
CREATE OR REPLACE FUNCTION get_audio_by_author_name(author_name TEXT)
    RETURNS SETOF audio AS
$$
BEGIN
    RETURN QUERY
        SELECT a.id, a.name, a.text, a.upload_date
        FROM audio a
                 JOIN author_audio aa ON a.id = aa.audio_id
                 JOIN person p ON aa.author_id = p.id
        WHERE p.username ILIKE author_name || '%';
END;
$$
    LANGUAGE plpgsql;

--procedures

--add Audio
CREATE OR REPLACE PROCEDURE public.new_audio(
	IN _name text,
	IN _text text,
	IN _image text,
	IN user_names text,
	IN genres text)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    res              audio;
	user_names_array text[] = string_to_array(user_names, ',');
    genres_array     text[] = string_to_array(genres, ',');
BEGIN
	IF((SELECT role_id FROM role_person WHERE person_id = 
	  	(SELECT id FROM person WHERE username = user_names)) = 0)
	THEN
		INSERT INTO audio(name, text, image, upload_date) VALUES (_name, _text, _image, now()) RETURNING * INTO res;

		FOR r IN 1..cardinality(user_names_array)
        LOOP
            INSERT INTO author_audio (author_id, audio_id)
            VALUES ((SELECT id FROM person WHERE username = user_names_array[r]),
                    res.id);
        END LOOP;
		
		FOR r IN 1..cardinality(genres_array)
			LOOP
				INSERT INTO genre_audio (genre_id, audio_id)
				VALUES ((SELECT g.id FROM genre g WHERE g.name = genres_array[r]),
						res.id);
			END LOOP;
	END IF;
END;
$BODY$;
ALTER PROCEDURE public.new_audio(text, text, text, text, text)
    OWNER TO Administrator;
	
--change_audio
CREATE OR REPLACE PROCEDURE public.change_audio(
	IN _id int,
	IN _name text,
	IN _text text,
	IN _image text,
	IN user_names text,
	IN genres text,
	IN _upload_date timestamp)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    res              audio;
	user_names_array text[] = string_to_array(user_names, ',');
    genres_array     text[] = string_to_array(genres, ',');
BEGIN
	UPDATE audio
		SET name = _name, 
			text = _text,
			image = _image,
			upload_date = _upload_date
		WHERE id = _id;

	DELETE FROM author_audio WHERE audio_id = _id;
	FOR r IN 1..cardinality(user_names_array)
		LOOP
			INSERT INTO author_audio (author_id, audio_id)
			VALUES ((SELECT id FROM person WHERE username = user_names_array[r]),
					_id);
		END LOOP;
		
	DELETE FROM genre_audio WHERE audio_id = _id;
	FOR r IN 1..cardinality(genres_array)
		LOOP
			INSERT INTO genre_audio (genre_id, audio_id)
			VALUES ((SELECT id FROM genre WHERE genre_name = genres_array[r]),
					_id);
		END LOOP;
END;
$BODY$;
ALTER PROCEDURE public.change_audio(int, text, text, text, text, text, timestamp)
    OWNER TO Administrator;
	
--delete audio
CREATE OR REPLACE PROCEDURE public.delete_audio(
	IN pers_id int,
	IN audio_name text)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DELETE FROM audio
		WHERE (name = audio_name AND id = (
			SELECT audio_id FROM author_audio WHERE author_id = pers_id));
	DELETE FROM author_audio
		WHERE audio_id = (SELECT audio_id FROM author_audio WHERE author_id = pers_id);
	DELETE FROM playlist_audio
		WHERE audio_id = (SELECT audio_id FROM author_audio WHERE author_id = pers_id);
	DELETE FROM album_audio
		WHERE audio_id = (SELECT audio_id FROM author_audio WHERE author_id = pers_id);
END;
$BODY$;
ALTER PROCEDURE public.delete_audio(int, text)
    OWNER TO Administrator;
	
--add nravlicks
CREATE OR REPLACE PROCEDURE public.add_nravlicks(
	IN pers_id int,
	IN aud_id int)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO nravlik (person_id, audio_id) 
	VALUES (pers_id, aud_id);
END;
$BODY$;
ALTER PROCEDURE public.add_nravlicks(int, int)
    OWNER TO Administrator;
	
--delete nravlciks
CREATE OR REPLACE PROCEDURE public.delete_nravlicks(
	IN pers_id int,
	IN aud_id int)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    DELETE FROM nravlik 
	WHERE (person_id == pers_id && audio_id == aud_id);
END;
$BODY$;
ALTER PROCEDURE public.delete_nravlicks(int, int)
    OWNER TO Administrator;

--save audio
CREATE OR REPLACE PROCEDURE public.save_audio(
	IN pers_id int,
	IN aud_id int)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO save_audio (person_id, audio_id) 
	VALUES (pers_id, aud_id);
END;
$BODY$;
ALTER PROCEDURE public.new_audio(text, text, text, text, text)
    OWNER TO Administrator;

--new_Playlist
CREATE OR REPLACE PROCEDURE public.new_playlist(
	IN playlist_name text,
	IN playlist_description text,
	IN _image text,
	IN audios text,
	IN authors text)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    res           playlist;
    audios_array  text[] = string_to_array(audios, ',');
BEGIN
    INSERT INTO playlist (name, description, creation_date, image)
    VALUES (playlist_name, playlist_description, now(), _image)
    RETURNING * INTO res;
	   INSERT INTO playlist_author (playlist_id, author_id)
       VALUES (res.id, (SELECT id FROM person WHERE username = authors));
    FOR r IN 1..cardinality(audios_array)
        LOOP
            INSERT INTO playlist_audio (playlist_id, audio_id)
            VALUES (res.id,
                    (SELECT a.id FROM audio a where a.id = audios_array[r]::integer));
        END LOOP;
END;
$BODY$;
ALTER PROCEDURE public.new_playlist(text, text, text, text, text)
    OWNER TO Administrator;

--change playlist
CREATE OR REPLACE PROCEDURE public.change_playlist(
	IN _id int,
	IN _name text,
	IN _description text,
	IN _image text,
	IN _audios text)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	audios_array  text[] = string_to_array(_audios, ',');
BEGIN
	UPDATE playlist
		SET name = _name, 
			description = _description,
			image = _image
		WHERE id = _id;

	DELETE FROM playlist_audio WHERE playlist_id = _id;
    FOR r IN 1..cardinality(audios_array)
        LOOP
            INSERT INTO playlist_audio (playlist_id, audio_id)
            VALUES (_id,
                    (SELECT id FROM audio where id = audios_array[r]::integer));
        END LOOP;
END;
$BODY$;
ALTER PROCEDURE public.change_playlist(int, text, text, text, text)
    OWNER TO Administrator;
	
--delete playlist
CREATE OR REPLACE PROCEDURE public.delete_playlist(
	_id int
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DELETE FROM playlist
		WHERE id = _id;
	DELETE FROM playlist_audio
		WHERE playlist_id = _id;
	DELETE FROM playlist_author
		WHERE playlist_id = _id;
END;
$BODY$;
ALTER PROCEDURE public.delete_playlist(int, text)
    OWNER TO Administrator;

--register person
CREATE OR REPLACE PROCEDURE public.register_person(
	IN _lname text,
	IN _password text,
	IN _email text)
LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE
		res			person;
	BEGIN
		INSERT INTO person(username, password, email, registration_date)
			VALUES(_lname, _password, _email, now()) 
			RETURNING * INTO res;
				INSERT INTO role_person (person_id, role_id)
				VALUES (res.id, (SELECT p.id FROM role p WHERE p.name = 'Default'));
	END;
$BODY$;
ALTER PROCEDURE public.register_person(text, text, text)
    OWNER TO Administrator;

--delete person
CREATE OR REPLACE PROCEDURE public.delete_person(
	IN user_name text)
LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE user_id int;
BEGIN
	SELECT person.id INTO STRICT user_id
		FROM person 
		WHERE username = user_name;
	DELETE FROM nravlik WHERE person_id = user_id;
	
	DELETE FROM audio WHERE id IN
		(SELECT audio_id FROM author_audio WHERE author_id = user_id);
	DELETE FROM author_audio WHERE author_id = user_id;
	
	DELETE FROM playlist WHERE id IN 
		(SELECT playlist_id FROM playlist_author WHERE author_id = user_id);
	DELETE FROM playlist_audio WHERE playlist_id IN
		(SELECT playlist_id FROM playlist_author WHERE author_id = user_id);
	
	DELETE FROM playlist_author WHERE author_id = user_id;
	
	DELETE FROM role_person WHERE person_id = user_id;
	DELETE FROM save_audio WHERE person_id = user_id;
	DELETE FROM person WHERE id = user_id;
END;
$BODY$;
ALTER PROCEDURE public.delete_person(text)
    OWNER TO Administrator;

--change person info
CREATE OR REPLACE PROCEDURE public.change_person(
	IN _lname text,
	IN _password text,
	IN _email text,
	IN _role int)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
		UPDATE person
			SET username = _lname, 
				password = _password,
				email = _email
			WHERE username = _lname;
		UPDATE role_person
			SET role_id = _role
			WHERE person_id = (SELECT id FROM person WHERE username = _lname);
END;
$BODY$;
ALTER PROCEDURE public.change_person(text, text, text, int)
    OWNER TO Administrator;
	
--new_album
CREATE OR REPLACE PROCEDURE public.new_album(
	IN album_name text,
	IN album_description text,
	IN _image text,
	IN audios text,
	IN authors text)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    res           album;
    audios_array  text[] = string_to_array(audios, ',');
	authors_array text[] = string_to_array(authors, ',');
BEGIN
    INSERT INTO album (name, description, creation_date, image)
    VALUES (album_name, album_description, now(), _image)
    RETURNING * INTO res;
    FOR r IN 1..cardinality(authors_array)
        LOOP
            INSERT INTO album_author (album_id, author_id)
            VALUES (res.id,
                    (SELECT id FROM person WHERE username = authors_array[r]));
        END LOOP;
    FOR r IN 1..cardinality(audios_array)
        LOOP
            INSERT INTO album_audio (album_id, audio_id)
            VALUES (res.id,
                    (SELECT id FROM audio where id = audios_array[r]::integer));
        END LOOP;
END;
$BODY$;
ALTER PROCEDURE public.new_album(text, text, text, text, text)
    OWNER TO Administrator;
	
--delete album
CREATE OR REPLACE PROCEDURE public.delete_album(
	_id int
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DELETE FROM album
		WHERE id = _id;
	DELETE FROM album_audio
		WHERE album_id = _id;
	DELETE FROM album_author
		WHERE album_id = _id;
END;
$BODY$;
ALTER PROCEDURE public.delete_album(int)
    OWNER TO Administrator;

--change album
CREATE OR REPLACE PROCEDURE public.change_album(
	IN _id int,
	IN _name text,
	IN _description text,
	IN _image text,
	IN _audios text,
	IN _user_names text,
	IN _creation_date timestamp)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	user_names_array text[] = string_to_array(_user_names, ',');
	audios_array  text[] = string_to_array(_audios, ',');
BEGIN
	UPDATE album
		SET name = _name, 
			description = _description,
			image = _image,
			creation_date = _creation_date
		WHERE id = _id;

	DELETE FROM album_author WHERE album_id = _id;
	FOR r IN 1..cardinality(user_names_array)
        LOOP
            INSERT INTO album_author (album_id, author_id)
            VALUES (_id,
                    (SELECT id FROM person WHERE username = user_names_array[r]));
        END LOOP;

	DELETE FROM album_audio WHERE album_id = _id;
    FOR r IN 1..cardinality(audios_array)
        LOOP
            INSERT INTO album_audio (album_id, audio_id)
            VALUES (_id,
                    (SELECT id FROM audio where id = audios_array[r]::integer));
        END LOOP;
END;
$BODY$;
ALTER PROCEDURE public.change_album(int, text, text, text, text, text, timestamp)
    OWNER TO Administrator;

--new genre
CREATE OR REPLACE PROCEDURE public.new_genre(
	IN _name character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO genre(genre_name)
		VALUES (_name);
END;
$BODY$;
ALTER PROCEDURE public.new_genre(character varying)
    OWNER TO administrator;

--delete genre
CREATE OR REPLACE PROCEDURE public.delete_genre(
	IN _name character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DELETE FROM genre 
		WHERE genre_name = _name;
	DELETE FROM genre_audio 
		WHERE genre_id = (SELECT id FROM genre WHERE genre_name = _name);
END;
$BODY$;
ALTER PROCEDURE public.delete_genre(character varying)
    OWNER TO administrator;

--change genre
CREATE OR REPLACE PROCEDURE public.change_genre(
	IN _id int,
	IN _name character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	UPDATE genre
		SET genre_name = _name
		WHERE id = _id;
END;
$BODY$;
ALTER PROCEDURE public.change_genre(int, character varying)
    OWNER TO administrator;
	
--new_nravlik
CREATE OR REPLACE PROCEDURE public.new_nravlik(
	IN _audio_id int,
	IN _person_id int
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO nravlik(person_id, audio_id)
		VALUES (_person_id, _audio_id);
END;
$BODY$;
ALTER PROCEDURE public.new_nravlik(int,int)
    OWNER TO administrator;

--delete_nravlik
CREATE OR REPLACE PROCEDURE public.delete_nravlik(
	IN _audio_id int,
	IN _person_id int
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DELETE FROM nravlik
		WHERE (person_id = _person_id AND _audio_id = _audio_id);
END;
$BODY$;
ALTER PROCEDURE public.delete_nravlik(int,int)
    OWNER TO administrator;
	
--new_nravlik_album
CREATE OR REPLACE PROCEDURE public.new_nravlik_album(
	IN _album_id int,
	IN _person_id int
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO nravlik_albums(person_id, album_id)
		VALUES (_person_id, _album_id);
END;
$BODY$;
ALTER PROCEDURE public.new_nravlik_album(int,int)
    OWNER TO administrator;

--delete_nravlik_album
CREATE OR REPLACE PROCEDURE public.delete_nravlik_album(
	IN _album_id int,
	IN _person_id int
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DELETE FROM nravlik_albums
		WHERE (person_id = _person_id AND album_id = _album_id);
END;
$BODY$;
ALTER PROCEDURE public.delete_nravlik_album(int,int)
    OWNER TO administrator;
	
--new_follow
CREATE OR REPLACE PROCEDURE public.new_follow(
	IN _author_id int,
	IN _person_id int
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO follows(person_id, author_id)
		VALUES (_person_id, _author_id);
END;
$BODY$;
ALTER PROCEDURE public.new_follow(int,int)
    OWNER TO administrator;

--delete_follow
CREATE OR REPLACE PROCEDURE public.delete_follow(
	IN _author_id int,
	IN _person_id int
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DELETE FROM follows
		WHERE (person_id = _person_id AND author_id = _author_id);
END;
$BODY$;
ALTER PROCEDURE public.delete_follow(int,int)
    OWNER TO administrator;

--JSON
CREATE OR REPLACE PROCEDURE public.export_to_json_tracks()
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	COPY (
		SELECT jsonb_agg(gt) FROM (
			SELECT audio.id, audio.name, audio.text, audio.upload_date, 
				audio.image, genre.genre_name, person.username
				FROM audio 
				INNER JOIN genre_audio 
					ON audio.id = genre_audio.audio_id
				INNER JOIN genre 
					ON genre_audio.genre_id = genre.id
				INNER JOIN author_audio
					ON audio.id = author_audio.audio_id
				INNER JOIN person
					ON author_audio.author_id = person.id
			ORDER BY audio.id
		) gt
	) TO 'C:\Program Files\PostgreSQL\15\data\ee\tracks.json';
END;
$BODY$;

CREATE OR REPLACE PROCEDURE public.import_from_json_tracks(path_to_file text)
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	json_string	jsonb;
BEGIN
	json_string := pg_read_file(path_to_file);
	
	DELETE FROM json_buffer;
	
	INSERT INTO json_buffer (id, name, text, upload_date, image, genre_name, username)
	SELECT (obj->>'id')::numeric, obj->>'name', obj->>'text', (obj->>'upload_date')::timestamp, obj->>'image', obj->>'genre_name', obj->>'username'
	FROM jsonb_array_elements(json_string) AS obj;

	INSERT INTO audio (id, name, text, upload_date, image)
		SELECT id, name, text, upload_date, image
			FROM json_buffer;
	INSERT INTO genre_audio(audio_id, genre_id)
		SELECT json_buffer.id, genre.id
			FROM json_buffer
			INNER JOIN genre
				ON json_buffer.genre_name = genre.genre_name;
	INSERT INTO author_audio(audio_id, author_id)
		SELECT json_buffer.id, person.id
			FROM json_buffer
			INNER JOIN person
				ON json_buffer.username = person.username;
END;
$BODY$;
