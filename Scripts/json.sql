CALL export_to_json_tracks();
CALL delete_audio(2);
CALL delete_audio(3);
CALL delete_audio(4);
CALL delete_audio(8);
CALL import_from_json_tracks('C:\Program Files\PostgreSQL\15\data\ee\tracksS.json');