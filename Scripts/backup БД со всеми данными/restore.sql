--
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2
-- Dumped by pg_dump version 15.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE "MusicDB";
--
-- Name: MusicDB; Type: DATABASE; Schema: -; Owner: administrator
--

CREATE DATABASE "MusicDB" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251' TABLESPACE = musicservicedefault;


ALTER DATABASE "MusicDB" OWNER TO administrator;

\connect "MusicDB"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: change_album(integer, text, text, text, text, text, timestamp without time zone); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.change_album(IN _id integer, IN _name text, IN _description text, IN _image text, IN _audios text, IN _user_names text, IN _creation_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.change_album(IN _id integer, IN _name text, IN _description text, IN _image text, IN _audios text, IN _user_names text, IN _creation_date timestamp without time zone) OWNER TO administrator;

--
-- Name: change_audio(integer, text, text, text, text, text, timestamp without time zone); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.change_audio(IN _id integer, IN _name text, IN _text text, IN _image text, IN user_names text, IN genres text, IN _upload_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.change_audio(IN _id integer, IN _name text, IN _text text, IN _image text, IN user_names text, IN genres text, IN _upload_date timestamp without time zone) OWNER TO administrator;

--
-- Name: change_genre(integer, character varying); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.change_genre(IN _id integer, IN _name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE genre
		SET genre_name = _name
		WHERE id = _id;
END;
$$;


ALTER PROCEDURE public.change_genre(IN _id integer, IN _name character varying) OWNER TO administrator;

--
-- Name: change_person(text, text, text, integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.change_person(IN _lname text, IN _password text, IN _email text, IN _role integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
		UPDATE person
			SET username = _lname, 
				password = md5(_password),
				email = _email
			WHERE username = _lname;
		UPDATE role_person
			SET role_id = _role
			WHERE person_id = (SELECT id FROM person WHERE username = _lname);
END;
$$;


ALTER PROCEDURE public.change_person(IN _lname text, IN _password text, IN _email text, IN _role integer) OWNER TO administrator;

--
-- Name: change_playlist(integer, text, text, text, text); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.change_playlist(IN _id integer, IN _name text, IN _description text, IN _image text, IN _audios text)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.change_playlist(IN _id integer, IN _name text, IN _description text, IN _image text, IN _audios text) OWNER TO administrator;

--
-- Name: delete_album(integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.delete_album(IN _id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM album
		WHERE id = _id;
	DELETE FROM album_audio
		WHERE album_id = _id;
	DELETE FROM album_author
		WHERE album_id = _id;
END;
$$;


ALTER PROCEDURE public.delete_album(IN _id integer) OWNER TO administrator;

--
-- Name: delete_audio(integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.delete_audio(IN _audio_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM audio
		WHERE id =_audio_id;
	DELETE FROM author_audio
		WHERE audio_id = _audio_id;
	DELETE FROM playlist_audio
		WHERE audio_id = _audio_id;
	DELETE FROM album_audio
		WHERE audio_id = _audio_id;
END;
$$;


ALTER PROCEDURE public.delete_audio(IN _audio_id integer) OWNER TO administrator;

--
-- Name: delete_follow(integer, integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.delete_follow(IN _author_id integer, IN _person_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM follows
		WHERE (person_id = _person_id AND author_id = _author_id);
END;
$$;


ALTER PROCEDURE public.delete_follow(IN _author_id integer, IN _person_id integer) OWNER TO administrator;

--
-- Name: delete_genre(character varying); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.delete_genre(IN _name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM genre 
		WHERE genre_name = _name;
	DELETE FROM genre_audio 
		WHERE genre_id = (SELECT id FROM genre WHERE genre_name = _name);
END;
$$;


ALTER PROCEDURE public.delete_genre(IN _name character varying) OWNER TO administrator;

--
-- Name: delete_nravlik(integer, integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.delete_nravlik(IN _audio_id integer, IN _person_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM nravlik
		WHERE (person_id = _person_id AND _audio_id = _audio_id);
END;
$$;


ALTER PROCEDURE public.delete_nravlik(IN _audio_id integer, IN _person_id integer) OWNER TO administrator;

--
-- Name: delete_nravlik_album(integer, integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.delete_nravlik_album(IN _album_id integer, IN _person_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM nravlik_albums
		WHERE (person_id = _person_id AND album_id = _album_id);
END;
$$;


ALTER PROCEDURE public.delete_nravlik_album(IN _album_id integer, IN _person_id integer) OWNER TO administrator;

--
-- Name: delete_person(text); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.delete_person(IN user_name text)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.delete_person(IN user_name text) OWNER TO administrator;

--
-- Name: delete_playlist(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_playlist(IN _id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM playlist
		WHERE id = _id;
	DELETE FROM playlist_audio
		WHERE playlist_id = _id;
	DELETE FROM playlist_author
		WHERE playlist_id = _id;
END;
$$;


ALTER PROCEDURE public.delete_playlist(IN _id integer) OWNER TO postgres;

--
-- Name: delete_saved_audio(integer, integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.delete_saved_audio(IN pers_id integer, IN aud_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM save_audio
		WHERE (person_id = pers_id AND audio_id = aud_id);
END;
$$;


ALTER PROCEDURE public.delete_saved_audio(IN pers_id integer, IN aud_id integer) OWNER TO administrator;

--
-- Name: deletecycleprocedure(); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.deletecycleprocedure()
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM playlist;
	END;
$$;


ALTER PROCEDURE public.deletecycleprocedure() OWNER TO administrator;

--
-- Name: export_to_json_tracks(); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.export_to_json_tracks()
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.export_to_json_tracks() OWNER TO administrator;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audio; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.audio (
    id integer NOT NULL,
    name character varying(32) NOT NULL,
    text character varying(1000),
    image text,
    upload_date timestamp without time zone NOT NULL
);


ALTER TABLE public.audio OWNER TO administrator;

--
-- Name: get_all_audios_by_author_name(text); Type: FUNCTION; Schema: public; Owner: administrator
--

CREATE FUNCTION public.get_all_audios_by_author_name(author_name text) RETURNS SETOF public.audio
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT a.id, a.name, a.text, a.image, a.upload_date
                 FROM author_audio aa
                          JOIN person p ON p.id = aa.author_id
                          JOIN audio a ON a.id = aa.audio_id
                 WHERE (p.username = author_name);
END;
$$;


ALTER FUNCTION public.get_all_audios_by_author_name(author_name text) OWNER TO administrator;

--
-- Name: get_all_audios_by_genre(text); Type: FUNCTION; Schema: public; Owner: administrator
--

CREATE FUNCTION public.get_all_audios_by_genre(_genre_name text) RETURNS TABLE(audio_id integer, audio_name character varying, text character varying, audio_upload_date timestamp without time zone, authors text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT a.id, a.name, a.text, a.upload_date, string_agg(p.username, ', ')
                 FROM genre_audio ga
                          JOIN genre g ON ga.genre_id = g.id
                          JOIN audio a ON ga.audio_id = a.id
                          JOIN author_audio aa on a.id = aa.audio_id
                          JOIN person p on p.id = aa.author_id
                 WHERE (g.genre_name = _genre_name)
                 GROUP BY a.id;
END;
$$;


ALTER FUNCTION public.get_all_audios_by_genre(_genre_name text) OWNER TO administrator;

--
-- Name: get_all_audios_from_playlist_by_playlist_id(integer); Type: FUNCTION; Schema: public; Owner: administrator
--

CREATE FUNCTION public.get_all_audios_from_playlist_by_playlist_id(_playlist_id integer) RETURNS TABLE(audio_name character varying, authors text)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.get_all_audios_from_playlist_by_playlist_id(_playlist_id integer) OWNER TO administrator;

--
-- Name: get_amount_of_nravlicks_by_audio_id(integer); Type: FUNCTION; Schema: public; Owner: administrator
--

CREATE FUNCTION public.get_amount_of_nravlicks_by_audio_id(_audio_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    result INTEGER;
BEGIN
    SELECT count(n.audio_id)
    INTO result
    FROM nravlik n
    WHERE n.audio_id = _audio_id;
    RETURN result;
END;
$$;


ALTER FUNCTION public.get_amount_of_nravlicks_by_audio_id(_audio_id integer) OWNER TO administrator;

--
-- Name: get_audio_by_name(text); Type: FUNCTION; Schema: public; Owner: administrator
--

CREATE FUNCTION public.get_audio_by_name(audio_name text) RETURNS SETOF public.audio
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT *
        FROM audio a
        WHERE a.name ILIKE '%' || audio_name || '%';
END;
$$;


ALTER FUNCTION public.get_audio_by_name(audio_name text) OWNER TO administrator;

--
-- Name: get_audio_info_by_audio_id(integer); Type: FUNCTION; Schema: public; Owner: administrator
--

CREATE FUNCTION public.get_audio_info_by_audio_id(_audio_id integer) RETURNS TABLE(authors text, audio_name character varying, upload_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT string_agg(p.username, ', '), a.name, a.upload_date
        FROM author_audio aa
                 JOIN audio a ON a.id = aa.audio_id
                 JOIN person p ON p.id = aa.author_id
        WHERE aa.audio_id = _audio_id
        GROUP BY a.name, a.upload_date;
END;
$$;


ALTER FUNCTION public.get_audio_info_by_audio_id(_audio_id integer) OWNER TO administrator;

--
-- Name: person; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.person (
    id integer NOT NULL,
    username character varying(32) NOT NULL,
    password character varying(60) NOT NULL,
    email character varying(256) NOT NULL,
    registration_date timestamp without time zone NOT NULL
);


ALTER TABLE public.person OWNER TO administrator;

--
-- Name: get_info_by_username(text); Type: FUNCTION; Schema: public; Owner: administrator
--

CREATE FUNCTION public.get_info_by_username(user_name text) RETURNS SETOF public.person
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    RETURN QUERY SELECT *
                 FROM person p
                 WHERE (p.username = user_name);
END;
$$;


ALTER FUNCTION public.get_info_by_username(user_name text) OWNER TO administrator;

--
-- Name: playlist; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.playlist (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    description character varying(5000),
    creation_date date NOT NULL,
    image text
);


ALTER TABLE public.playlist OWNER TO administrator;

--
-- Name: get_playlists_by_name(text); Type: FUNCTION; Schema: public; Owner: administrator
--

CREATE FUNCTION public.get_playlists_by_name(playlist_name text) RETURNS SETOF public.playlist
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT *
        FROM playlist p
        WHERE p.name ILIKE '%' || playlist_name || '%';
END;
$$;


ALTER FUNCTION public.get_playlists_by_name(playlist_name text) OWNER TO administrator;

--
-- Name: import_from_json_tracks(text); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.import_from_json_tracks(IN path_to_file text)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.import_from_json_tracks(IN path_to_file text) OWNER TO administrator;

--
-- Name: insertcycleprocedure(numeric); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.insertcycleprocedure(IN cycle_count numeric)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	FOR counter IN 1..cycle_count
		LOOP
			INSERT INTO playlist(id, name, description, creation_date) 
				VALUES (counter, 'stringType', 'Description', '2023-04-04');
		END LOOP;
/*			INSERT INTO playlist(id, name, description, creation_date) 
				VALUES
					(658324, 'Jazz', 'Jazz playlis', '2023-05-04'),
					(836853, 'Hip-Hop', 'Hip-Hop playlist', '2023-05-05'),
					(386392, 'Pop', 'Pop playlist', '2023-05-07'),
					(547283, 'Classic', 'Classic playlist', '2023-05-06'),
					(174392, 'Dub', 'Dub playlist', '2023-05-08');
*/
	END;
$$;


ALTER PROCEDURE public.insertcycleprocedure(IN cycle_count numeric) OWNER TO administrator;

--
-- Name: new_album(text, text, text, text, text); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.new_album(IN album_name text, IN album_description text, IN _image text, IN audios text, IN authors text)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.new_album(IN album_name text, IN album_description text, IN _image text, IN audios text, IN authors text) OWNER TO administrator;

--
-- Name: new_audio(text, text, text, text, text); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.new_audio(IN _name text, IN _text text, IN _image text, IN user_names text, IN genres text)
    LANGUAGE plpgsql
    AS $$
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
				VALUES ((SELECT id FROM genre WHERE genre_name = genres_array[r]),
						res.id);
			END LOOP;
	END IF;
END;
$$;


ALTER PROCEDURE public.new_audio(IN _name text, IN _text text, IN _image text, IN user_names text, IN genres text) OWNER TO administrator;

--
-- Name: new_follow(integer, integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.new_follow(IN _author_id integer, IN _person_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO follows(person_id, author_id)
		VALUES (_person_id, _author_id);
END;
$$;


ALTER PROCEDURE public.new_follow(IN _author_id integer, IN _person_id integer) OWNER TO administrator;

--
-- Name: new_genre(character varying); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.new_genre(IN _name character varying)
    LANGUAGE plpgsql
    AS $$BEGIN
	INSERT INTO genre(genre_name)
		VALUES (_name);
END;$$;


ALTER PROCEDURE public.new_genre(IN _name character varying) OWNER TO administrator;

--
-- Name: new_nravlik(integer, integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.new_nravlik(IN _audio_id integer, IN _person_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO nravlik(person_id, audio_id)
		VALUES (_person_id, _audio_id);
END;
$$;


ALTER PROCEDURE public.new_nravlik(IN _audio_id integer, IN _person_id integer) OWNER TO administrator;

--
-- Name: new_nravlik_album(integer, integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.new_nravlik_album(IN _album_id integer, IN _person_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO nravlik_albums(person_id, album_id)
		VALUES (_person_id, _album_id);
END;
$$;


ALTER PROCEDURE public.new_nravlik_album(IN _album_id integer, IN _person_id integer) OWNER TO administrator;

--
-- Name: new_person(text, text, text); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.new_person(IN _lname text, IN _password text, IN _email text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		res			person;
	BEGIN
		INSERT INTO person(username, password, email, registration_date)
			VALUES(_lname, md5(_password), _email, now()) 
			RETURNING * INTO res;
				INSERT INTO role_person (person_id, role_id)
				VALUES (res.id, (SELECT p.id FROM role p WHERE p.name = 'Default'));
	END;
$$;


ALTER PROCEDURE public.new_person(IN _lname text, IN _password text, IN _email text) OWNER TO administrator;

--
-- Name: new_playlist(text, text, text, text, text); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.new_playlist(IN playlist_name text, IN playlist_description text, IN _image text, IN audios text, IN authors text)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.new_playlist(IN playlist_name text, IN playlist_description text, IN _image text, IN audios text, IN authors text) OWNER TO administrator;

--
-- Name: save_audio(integer, integer); Type: PROCEDURE; Schema: public; Owner: administrator
--

CREATE PROCEDURE public.save_audio(IN pers_id integer, IN aud_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO save_audio (person_id, audio_id) 
	VALUES (pers_id, aud_id);
END;
$$;


ALTER PROCEDURE public.save_audio(IN pers_id integer, IN aud_id integer) OWNER TO administrator;

--
-- Name: album; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.album (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    creation_date date NOT NULL,
    image text,
    description character varying(1000)
);

ALTER TABLE ONLY public.album REPLICA IDENTITY FULL;


ALTER TABLE public.album OWNER TO administrator;

--
-- Name: album_audio; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.album_audio (
    audio_id integer NOT NULL,
    album_id integer NOT NULL
);

ALTER TABLE ONLY public.album_audio REPLICA IDENTITY FULL;


ALTER TABLE public.album_audio OWNER TO administrator;

--
-- Name: album_author; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.album_author (
    author_id integer NOT NULL,
    album_id integer NOT NULL
);

ALTER TABLE ONLY public.album_author REPLICA IDENTITY FULL;


ALTER TABLE public.album_author OWNER TO administrator;

--
-- Name: album_id_seq; Type: SEQUENCE; Schema: public; Owner: administrator
--

CREATE SEQUENCE public.album_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.album_id_seq OWNER TO administrator;

--
-- Name: album_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: administrator
--

ALTER SEQUENCE public.album_id_seq OWNED BY public.album.id;


--
-- Name: audio_id_seq; Type: SEQUENCE; Schema: public; Owner: administrator
--

CREATE SEQUENCE public.audio_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audio_id_seq OWNER TO administrator;

--
-- Name: audio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: administrator
--

ALTER SEQUENCE public.audio_id_seq OWNED BY public.audio.id;


--
-- Name: author_audio; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.author_audio (
    author_id integer NOT NULL,
    audio_id integer NOT NULL
);


ALTER TABLE public.author_audio OWNER TO administrator;

--
-- Name: follows; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.follows (
    author_id integer NOT NULL,
    person_id integer NOT NULL
);


ALTER TABLE public.follows OWNER TO administrator;

--
-- Name: genre; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.genre (
    id integer NOT NULL,
    genre_name character varying(32) NOT NULL
);


ALTER TABLE public.genre OWNER TO administrator;

--
-- Name: genre_audio; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.genre_audio (
    genre_id integer NOT NULL,
    audio_id integer NOT NULL
);


ALTER TABLE public.genre_audio OWNER TO administrator;

--
-- Name: genre_id_seq; Type: SEQUENCE; Schema: public; Owner: administrator
--

CREATE SEQUENCE public.genre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.genre_id_seq OWNER TO administrator;

--
-- Name: genre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: administrator
--

ALTER SEQUENCE public.genre_id_seq OWNED BY public.genre.id;


--
-- Name: json_buffer; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.json_buffer (
    id numeric NOT NULL,
    name character varying(32) NOT NULL,
    text character varying(1000),
    image text,
    genre_name character varying(32) NOT NULL,
    username character varying(32) NOT NULL,
    upload_date timestamp without time zone NOT NULL
);


ALTER TABLE public.json_buffer OWNER TO administrator;

--
-- Name: nravlik; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.nravlik (
    person_id integer NOT NULL,
    audio_id integer NOT NULL
);


ALTER TABLE public.nravlik OWNER TO administrator;

--
-- Name: nravlik_albums; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.nravlik_albums (
    album_id integer NOT NULL,
    person_id integer NOT NULL
);


ALTER TABLE public.nravlik_albums OWNER TO administrator;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: administrator
--

CREATE SEQUENCE public.person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_id_seq OWNER TO administrator;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: administrator
--

ALTER SEQUENCE public.person_id_seq OWNED BY public.person.id;


--
-- Name: playlist_audio; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.playlist_audio (
    playlist_id integer NOT NULL,
    audio_id integer NOT NULL
);


ALTER TABLE public.playlist_audio OWNER TO administrator;

--
-- Name: playlist_author; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.playlist_author (
    playlist_id integer NOT NULL,
    author_id integer NOT NULL
);


ALTER TABLE public.playlist_author OWNER TO administrator;

--
-- Name: playlist_id_seq; Type: SEQUENCE; Schema: public; Owner: administrator
--

CREATE SEQUENCE public.playlist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.playlist_id_seq OWNER TO administrator;

--
-- Name: playlist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: administrator
--

ALTER SEQUENCE public.playlist_id_seq OWNED BY public.playlist.id;


--
-- Name: role; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.role (
    id integer NOT NULL,
    name character varying(32) NOT NULL
);


ALTER TABLE public.role OWNER TO administrator;

--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: administrator
--

CREATE SEQUENCE public.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_id_seq OWNER TO administrator;

--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: administrator
--

ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;


--
-- Name: role_person; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.role_person (
    person_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE public.role_person OWNER TO administrator;

--
-- Name: save_audio; Type: TABLE; Schema: public; Owner: administrator
--

CREATE TABLE public.save_audio (
    person_id integer NOT NULL,
    audio_id integer NOT NULL
);


ALTER TABLE public.save_audio OWNER TO administrator;

--
-- Name: album id; Type: DEFAULT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.album ALTER COLUMN id SET DEFAULT nextval('public.album_id_seq'::regclass);


--
-- Name: audio id; Type: DEFAULT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.audio ALTER COLUMN id SET DEFAULT nextval('public.audio_id_seq'::regclass);


--
-- Name: genre id; Type: DEFAULT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.genre ALTER COLUMN id SET DEFAULT nextval('public.genre_id_seq'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT nextval('public.person_id_seq'::regclass);


--
-- Name: playlist id; Type: DEFAULT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.playlist ALTER COLUMN id SET DEFAULT nextval('public.playlist_id_seq'::regclass);


--
-- Name: role id; Type: DEFAULT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);


--
-- Data for Name: album; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3523.dat

--
-- Data for Name: album_audio; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3524.dat

--
-- Data for Name: album_author; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3525.dat

--
-- Data for Name: audio; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3507.dat

--
-- Data for Name: author_audio; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3517.dat

--
-- Data for Name: follows; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3526.dat

--
-- Data for Name: genre; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3509.dat

--
-- Data for Name: genre_audio; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3519.dat

--
-- Data for Name: json_buffer; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3521.dat

--
-- Data for Name: nravlik; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3514.dat

--
-- Data for Name: nravlik_albums; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3527.dat

--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3505.dat

--
-- Data for Name: playlist; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3513.dat

--
-- Data for Name: playlist_audio; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3520.dat

--
-- Data for Name: playlist_author; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3516.dat

--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3511.dat

--
-- Data for Name: role_person; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3515.dat

--
-- Data for Name: save_audio; Type: TABLE DATA; Schema: public; Owner: administrator
--

\i $$PATH$$/3518.dat

--
-- Name: album_id_seq; Type: SEQUENCE SET; Schema: public; Owner: administrator
--

SELECT pg_catalog.setval('public.album_id_seq', 4, true);


--
-- Name: audio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: administrator
--

SELECT pg_catalog.setval('public.audio_id_seq', 63, true);


--
-- Name: genre_id_seq; Type: SEQUENCE SET; Schema: public; Owner: administrator
--

SELECT pg_catalog.setval('public.genre_id_seq', 27, true);


--
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: administrator
--

SELECT pg_catalog.setval('public.person_id_seq', 18, true);


--
-- Name: playlist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: administrator
--

SELECT pg_catalog.setval('public.playlist_id_seq', 32, true);


--
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: administrator
--

SELECT pg_catalog.setval('public.role_id_seq', 1, false);


--
-- Name: album_audio album_audio_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.album_audio
    ADD CONSTRAINT album_audio_pkey PRIMARY KEY (audio_id, album_id);


--
-- Name: album_author album_auth_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.album_author
    ADD CONSTRAINT album_auth_pkey PRIMARY KEY (author_id, album_id);


--
-- Name: album album_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.album
    ADD CONSTRAINT album_pkey PRIMARY KEY (id);


--
-- Name: audio audio_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.audio
    ADD CONSTRAINT audio_pkey PRIMARY KEY (id);


--
-- Name: author_audio author_audio_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.author_audio
    ADD CONSTRAINT author_audio_pkey PRIMARY KEY (author_id, audio_id);


--
-- Name: follows follows_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (author_id, person_id);


--
-- Name: genre_audio genre_audio_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.genre_audio
    ADD CONSTRAINT genre_audio_pkey PRIMARY KEY (genre_id, audio_id);


--
-- Name: genre genre_name_key; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_name_key UNIQUE (genre_name);


--
-- Name: genre genre_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_pkey PRIMARY KEY (id);


--
-- Name: json_buffer json_buffer_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.json_buffer
    ADD CONSTRAINT json_buffer_pkey PRIMARY KEY (id);


--
-- Name: nravlik_albums nravlik_albums_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.nravlik_albums
    ADD CONSTRAINT nravlik_albums_pkey PRIMARY KEY (album_id, person_id);


--
-- Name: nravlik nravlik_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.nravlik
    ADD CONSTRAINT nravlik_pkey PRIMARY KEY (person_id, audio_id);


--
-- Name: person person_email_key; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_email_key UNIQUE (email);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id);


--
-- Name: person person_username_key; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_username_key UNIQUE (username);


--
-- Name: playlist_audio playlist_audio_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.playlist_audio
    ADD CONSTRAINT playlist_audio_pkey PRIMARY KEY (playlist_id, audio_id);


--
-- Name: playlist_author playlist_author_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.playlist_author
    ADD CONSTRAINT playlist_author_pkey PRIMARY KEY (playlist_id, author_id);


--
-- Name: playlist playlist_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.playlist
    ADD CONSTRAINT playlist_pkey PRIMARY KEY (id);


--
-- Name: role role_name_key; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_name_key UNIQUE (name);


--
-- Name: role_person role_person_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.role_person
    ADD CONSTRAINT role_person_pkey PRIMARY KEY (person_id, role_id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: save_audio save_audio_pkey; Type: CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.save_audio
    ADD CONSTRAINT save_audio_pkey PRIMARY KEY (person_id, audio_id);


--
-- Name: audio_name_hash_idw; Type: INDEX; Schema: public; Owner: administrator
--

CREATE INDEX audio_name_hash_idw ON public.audio USING hash (name);


--
-- Name: id_btree_idx; Type: INDEX; Schema: public; Owner: administrator
--

CREATE INDEX id_btree_idx ON public.playlist USING btree (id);


--
-- Name: id_btree_index; Type: INDEX; Schema: public; Owner: administrator
--

CREATE INDEX id_btree_index ON public.album USING btree (id);


--
-- Name: name_hash_index; Type: INDEX; Schema: public; Owner: administrator
--

CREATE INDEX name_hash_index ON public.person USING hash (username);


--
-- Name: person_id_btree_index; Type: INDEX; Schema: public; Owner: administrator
--

CREATE INDEX person_id_btree_index ON public.person USING btree (id);


--
-- Name: playlist_name_hash_idx; Type: INDEX; Schema: public; Owner: administrator
--

CREATE INDEX playlist_name_hash_idx ON public.playlist USING hash (name);


--
-- Name: album_audio album_audio_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.album_audio
    ADD CONSTRAINT album_audio_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.album(id) ON DELETE CASCADE NOT VALID;


--
-- Name: album_audio album_audio_audio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.album_audio
    ADD CONSTRAINT album_audio_audio_id_fkey FOREIGN KEY (audio_id) REFERENCES public.audio(id) ON DELETE CASCADE NOT VALID;


--
-- Name: album_author album_author_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.album_author
    ADD CONSTRAINT album_author_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.album(id) NOT VALID;


--
-- Name: album_author album_author_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.album_author
    ADD CONSTRAINT album_author_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.person(id) NOT VALID;


--
-- Name: author_audio author_audio_audio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.author_audio
    ADD CONSTRAINT author_audio_audio_id_fkey FOREIGN KEY (audio_id) REFERENCES public.audio(id) ON DELETE CASCADE;


--
-- Name: author_audio author_audio_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.author_audio
    ADD CONSTRAINT author_audio_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.person(id) ON DELETE CASCADE;


--
-- Name: follows follows_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.person(id) NOT VALID;


--
-- Name: follows follows_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) NOT VALID;


--
-- Name: genre_audio genre_audio_audio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.genre_audio
    ADD CONSTRAINT genre_audio_audio_id_fkey FOREIGN KEY (audio_id) REFERENCES public.audio(id) ON DELETE CASCADE;


--
-- Name: genre_audio genre_audio_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.genre_audio
    ADD CONSTRAINT genre_audio_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genre(id) ON DELETE CASCADE;


--
-- Name: nravlik_albums nravlik_albums_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.nravlik_albums
    ADD CONSTRAINT nravlik_albums_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.album(id) NOT VALID;


--
-- Name: nravlik_albums nravlik_albums_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.nravlik_albums
    ADD CONSTRAINT nravlik_albums_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) NOT VALID;


--
-- Name: nravlik nravlik_audio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.nravlik
    ADD CONSTRAINT nravlik_audio_id_fkey FOREIGN KEY (audio_id) REFERENCES public.audio(id) ON DELETE CASCADE;


--
-- Name: nravlik nravlik_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.nravlik
    ADD CONSTRAINT nravlik_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON DELETE CASCADE;


--
-- Name: playlist_audio playlist_audio_audio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.playlist_audio
    ADD CONSTRAINT playlist_audio_audio_id_fkey FOREIGN KEY (audio_id) REFERENCES public.audio(id) ON DELETE CASCADE;


--
-- Name: playlist_audio playlist_audio_playlist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.playlist_audio
    ADD CONSTRAINT playlist_audio_playlist_id_fkey FOREIGN KEY (playlist_id) REFERENCES public.playlist(id) ON DELETE CASCADE;


--
-- Name: playlist_author playlist_author_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.playlist_author
    ADD CONSTRAINT playlist_author_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.person(id) ON DELETE CASCADE;


--
-- Name: playlist_author playlist_author_playlist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.playlist_author
    ADD CONSTRAINT playlist_author_playlist_id_fkey FOREIGN KEY (playlist_id) REFERENCES public.playlist(id) ON DELETE CASCADE;


--
-- Name: role_person role_person_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.role_person
    ADD CONSTRAINT role_person_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON DELETE CASCADE;


--
-- Name: role_person role_person_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.role_person
    ADD CONSTRAINT role_person_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(id) ON DELETE CASCADE;


--
-- Name: save_audio save_audio_audio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.save_audio
    ADD CONSTRAINT save_audio_audio_id_fkey FOREIGN KEY (audio_id) REFERENCES public.audio(id) ON DELETE CASCADE;


--
-- Name: save_audio save_audio_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: administrator
--

ALTER TABLE ONLY public.save_audio
    ADD CONSTRAINT save_audio_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON DELETE CASCADE;


--
-- Name: music_publication; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION music_publication FOR ALL TABLES WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION music_publication OWNER TO postgres;

--
-- Name: TABLE audio; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audio TO author;
GRANT SELECT ON TABLE public.audio TO listener;
GRANT ALL ON TABLE public.audio TO replica_user;


--
-- Name: TABLE person; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.person TO author;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.person TO listener;
GRANT ALL ON TABLE public.person TO replica_user;


--
-- Name: TABLE playlist; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.playlist TO author;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.playlist TO listener;
GRANT ALL ON TABLE public.playlist TO replica_user;


--
-- Name: TABLE album; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.album TO author;
GRANT SELECT ON TABLE public.album TO listener;
GRANT ALL ON TABLE public.album TO replica_user;


--
-- Name: TABLE album_audio; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.album_audio TO author;
GRANT SELECT ON TABLE public.album_audio TO listener;
GRANT ALL ON TABLE public.album_audio TO replica_user;


--
-- Name: TABLE album_author; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.album_author TO author;
GRANT SELECT ON TABLE public.album_author TO listener;
GRANT ALL ON TABLE public.album_author TO replica_user;


--
-- Name: SEQUENCE album_id_seq; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT ON SEQUENCE public.album_id_seq TO listener;
GRANT SELECT,USAGE ON SEQUENCE public.album_id_seq TO author;


--
-- Name: SEQUENCE audio_id_seq; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,USAGE ON SEQUENCE public.audio_id_seq TO author;
GRANT SELECT,USAGE ON SEQUENCE public.audio_id_seq TO listener;


--
-- Name: TABLE author_audio; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.author_audio TO author;
GRANT SELECT ON TABLE public.author_audio TO listener;
GRANT ALL ON TABLE public.author_audio TO replica_user;


--
-- Name: TABLE follows; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.follows TO author;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.follows TO listener;
GRANT ALL ON TABLE public.follows TO replica_user;


--
-- Name: TABLE genre; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT ON TABLE public.genre TO listener;
GRANT ALL ON TABLE public.genre TO replica_user;
GRANT SELECT ON TABLE public.genre TO author;


--
-- Name: TABLE genre_audio; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT ON TABLE public.genre_audio TO listener;
GRANT ALL ON TABLE public.genre_audio TO replica_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.genre_audio TO author;


--
-- Name: SEQUENCE genre_id_seq; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT ON SEQUENCE public.genre_id_seq TO author;
GRANT SELECT,USAGE ON SEQUENCE public.genre_id_seq TO listener;


--
-- Name: TABLE json_buffer; Type: ACL; Schema: public; Owner: administrator
--

GRANT ALL ON TABLE public.json_buffer TO replica_user;


--
-- Name: TABLE nravlik; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.nravlik TO author;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.nravlik TO listener;
GRANT ALL ON TABLE public.nravlik TO replica_user;


--
-- Name: TABLE nravlik_albums; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.nravlik_albums TO author;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.nravlik_albums TO listener;
GRANT ALL ON TABLE public.nravlik_albums TO replica_user;


--
-- Name: SEQUENCE person_id_seq; Type: ACL; Schema: public; Owner: administrator
--

GRANT ALL ON SEQUENCE public.person_id_seq TO author;
GRANT SELECT,USAGE ON SEQUENCE public.person_id_seq TO listener;


--
-- Name: TABLE playlist_audio; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.playlist_audio TO author;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.playlist_audio TO listener;
GRANT ALL ON TABLE public.playlist_audio TO replica_user;


--
-- Name: TABLE playlist_author; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.playlist_author TO author;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.playlist_author TO listener;
GRANT ALL ON TABLE public.playlist_author TO replica_user;


--
-- Name: SEQUENCE playlist_id_seq; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,USAGE ON SEQUENCE public.playlist_id_seq TO author;
GRANT SELECT,USAGE ON SEQUENCE public.playlist_id_seq TO listener;


--
-- Name: TABLE role; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.role TO author;
GRANT SELECT ON TABLE public.role TO listener;
GRANT ALL ON TABLE public.role TO replica_user;


--
-- Name: SEQUENCE role_id_seq; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,USAGE ON SEQUENCE public.role_id_seq TO listener;
GRANT SELECT ON SEQUENCE public.role_id_seq TO author;


--
-- Name: TABLE role_person; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.role_person TO author;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.role_person TO listener;
GRANT ALL ON TABLE public.role_person TO replica_user;


--
-- Name: TABLE save_audio; Type: ACL; Schema: public; Owner: administrator
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.save_audio TO author;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.save_audio TO listener;
GRANT ALL ON TABLE public.save_audio TO replica_user;


--
-- PostgreSQL database dump complete
--

