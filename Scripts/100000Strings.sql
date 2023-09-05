CREATE OR REPLACE PROCEDURE insertCycleProcedure() AS $$
	BEGIN
	FOR counter IN 1..100000
		LOOP
			INSERT INTO playlist(id, name, description, creation_date) 
				VALUES (counter, 'stringType', 'Description', '2023-04-04');
		END LOOP;
			INSERT INTO playlist(id, name, description, creation_date) 
				VALUES
					(658324, 'Jazz', 'Jazz playlis', '2023-05-04'),
					(836853, 'Hip-Hop', 'Hip-Hop playlist', '2023-05-05'),
					(386392, 'Pop', 'Pop playlist', '2023-05-07'),
					(547283, 'Classic', 'Classic playlist', '2023-05-06'),
					(174392, 'Dub', 'Dub playlist', '2023-05-08');
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE deleteCycleProcedure() AS $$
	BEGIN
		DELETE FROM playlist;
	END;
$$ LANGUAGE plpgsql;

call insertCycleProcedure();
call deleteCycleProcedure();

SELECT create_new_audio()
SELECT * FROM playlist WHERE playlist.id > 100000;

