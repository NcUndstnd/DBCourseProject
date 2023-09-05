CREATE INDEX IF NOT EXISTS audio_name_hash_idw
    ON public.audio USING hash
    (name COLLATE pg_catalog."default")
    TABLESPACE musicservicedefault;
	
CREATE INDEX IF NOT EXISTS id_btree_idx
    ON public.playlist USING btree
    (id ASC NULLS LAST)
    TABLESPACE musicservicedefault;

CREATE INDEX IF NOT EXISTS playlist_name_hash_idx
    ON public.playlist USING hash
    (name COLLATE pg_catalog."default")
    TABLESPACE musicservicedefault;
	
CREATE INDEX IF NOT EXISTS id_btree_index
    ON public.album USING btree
    (id ASC NULLS LAST)
    TABLESPACE musicservicedefault;
	
CREATE INDEX IF NOT EXISTS name_hash_index
    ON public.person USING hash
    (username COLLATE pg_catalog."default")
    TABLESPACE musicservicedefault;

CREATE INDEX IF NOT EXISTS person_id_btree_index
    ON public.person USING btree
    (id ASC NULLS LAST)
    TABLESPACE musicservicedefault;


