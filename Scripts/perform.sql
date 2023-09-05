CALL new_playlist('IVOXYG', 'track by IVOXYGEN', 'link to image', '43,44,45', 'IVOXYGEN');
CALL change_playlist(31, 'IVOXYGen', 'track by IVOXYGEN', 'link to image', '43,44,45');
CALL delete_playlist(31);

CALL new_audio('Young Kid', 'track by IVOXYGEN', 'link to image', 'IVOXYGEN', 'Hip-Hop');
CALL new_audio('room', 'track by IVOXYGEN', 'link to image', 'IVOXYGEN', 'Hip-Hop');
CALL new_audio('SAVAGE for a dream', 'track by IVOXYGEN', 'link to image', 'IVOXYGEN', 'Hip-Hop');
CALL new_audio('TEEN', 'track by IVOXYGEN', 'link to image', 'IVOXYGEN', 'Hip-Hop');
CALL new_audio('requiem for a dream', 'track by IVOXYGEN', 'link to image', 'IVOXYGEN', 'Hip-Hop');
CALL new_audio('1998', 'track by IVOXYGEN', 'link to image', 'IVOXYGEN', 'Hip-Hop');

--audio
CALL new_audio('SAMPLE', 'track by IVOXYGEN', 'link to image', 'IVOXYGEN', 'Jazz');
CALL change_audio(55, 'METAMORPHOSIS 3', 'track by IVOXYGEN', 'link to image', 'IVOXYGEN', 'Hip-Hop,Rap', '2023-05-11 18:59:24.700141+03');
CALL delete_audio(62);

--album
CALL new_album(
	'Spaced Out', 
	'Album Description', 
	'C:\Users\Ignat\OneDrive\Изображения\1200x1200bf-60.jpg', 
	'43,44,45,46,48,49', 
	'IVOXYGEN'
);

CALL change_album(
	4, 
	'Teen Dreams', 
	'Album Description', 
	'C:\Users\Ignat\OneDrive\Изображения\1200x1200bf-60.jpg',
	'43,44,45,46,48,49,55', 
	'IVOXYGEN', 
	'2023-05-11 18:59:24.700141+03'
);

CALL delete_album(3);

--genre
CALL new_genre('Funk');
CALL change_genre(27, 'Phonk');
CALL delete_genre('Phonk');

--person
CALL new_person('INTERWORLD', 'eijok8328', 'tduiQWEye@gmaail.com');
CALL change_person('INTERWORLD', 'k832br348', 'tduiQWEye@gmaail.com', 3);
CALL delete_person('INTERWORLD');

--playlist
CALL new_playlist(
	'Playlist', 
	'Playlist Description', 
	'C:\Users\Ignat\OneDrive\Изображения\1200x1200bf-60.jpg', 
	'43,44,45,46', 
	'IVOXYGEN'
);

CALL change_playlist(
	32, 
	'Teen Dreams', 
	'Playlist Description', 
	'C:\Users\Ignat\OneDrive\Изображения\1200x1200bf-60.jpg',
	'43,44,48,49,54,55'
);

CALL new_nravlik(55,5);

CALL delete_playlist(4);
-------------------------------------------------------------------------------------
--процедуры
SELECT pg_get_functiondef(p.oid) AS procedure_definition
FROM pg_proc p
INNER JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'

--тест производительности
--VALUES (counter, 'stringType', 'Description', '2023-04-04');
CALL public.insertcycleprocedure(450000)
CALL public.deletecycleprocedure()

EXPLAIN ANALYZE SELECT id FROM playlist WHERE id > 75000;

DROP INDEX IF EXISTS public.id_btree_idx;
CREATE INDEX IF NOT EXISTS id_btree_idx
    ON public.playlist USING btree
    (id ASC NULLS LAST)
    TABLESPACE musicservicedefault;
