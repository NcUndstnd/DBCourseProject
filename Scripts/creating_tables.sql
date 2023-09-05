CREATE TABLE IF NOT EXISTS person
(
    id                SERIAL PRIMARY KEY,
    username          VARCHAR(32) UNIQUE  NOT NULL,
    password          VARCHAR(60)         NOT NULL,
    email             VARCHAR(256) UNIQUE NOT NULL,
    registration_date TIMESTAMP           NOT NULL,
);

CREATE TABLE IF NOT EXISTS audio
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(32) NOT NULL,
    text        VARCHAR(10000),
    upload_date TIMESTAMP   NOT NULL
);

CREATE TABLE IF NOT EXISTS genre
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(32) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS role
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(32) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS achievement
(
    id                      SERIAL PRIMARY KEY,
    name                    VARCHAR(32) UNIQUE  NOT NULL,
    description             VARCHAR(256) UNIQUE NOT NULL,
    required_count_activity INTEGER             NOT NULL DEFAULT 0,
    reward                  INTEGER             NOT NULL,
    CHECK (reward >= 0),
    CHECK (required_count_activity > 0)
);

CREATE TABLE IF NOT EXISTS emotion
(
    id          SERIAL PRIMARY KEY,
    description VARCHAR(32) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS playlist
(
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(128) NOT NULL,
    description   VARCHAR(5000),
    creation_date DATE                NOT NULL
);

-- Отношения со связями

CREATE TABLE IF NOT EXISTS profile
(
    person_id   INTEGER NOT NULL,
    status      VARCHAR(512),
    description VARCHAR(10000),
    PRIMARY KEY (person_id),
    FOREIGN KEY (person_id) REFERENCES person (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS post
(
    id               SERIAL PRIMARY KEY,
    profile_id       INTEGER   NOT NULL REFERENCES profile (person_id) ON DELETE CASCADE,
    playlist_id      INTEGER REFERENCES playlist (id) ON DELETE CASCADE,
    audio_id         INTEGER REFERENCES audio (id) ON DELETE CASCADE,
    description      VARCHAR(5000),
    publication_date TIMESTAMP NOT NULL,
    CHECK ( ((playlist_id is NULL) AND (audio_id is NOT NULL)) OR ((playlist_id is NOT NULL) AND (audio_id is NULL)) )
);

CREATE TABLE IF NOT EXISTS comment
(
    id               BIGSERIAL PRIMARY KEY,
    person_id        INTEGER       NOT NULL REFERENCES person (id) ON DELETE CASCADE,
    post_id          INTEGER       NOT NULL REFERENCES post (id) ON DELETE CASCADE,
    text             VARCHAR(2048) NOT NULL,
    publication_date TIMESTAMP     NOT NULL
);

CREATE TABLE IF NOT EXISTS nravlik
(
    person_id INTEGER NOT NULL,
    audio_id  INTEGER NOT NULL,
    PRIMARY KEY (person_id, audio_id),
    FOREIGN KEY (person_id) REFERENCES person (id) ON DELETE CASCADE,
    FOREIGN KEY (audio_id) REFERENCES audio (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS person_emotion_audio
(
    person_id  INTEGER NOT NULL,
    audio_id   INTEGER NOT NULL,
    emotion_id INTEGER NOT NULL,
    PRIMARY KEY (person_id, audio_id),
    FOREIGN KEY (person_id) REFERENCES person (id) ON DELETE CASCADE,
    FOREIGN KEY (audio_id) REFERENCES audio (id) ON DELETE CASCADE,
    FOREIGN KEY (emotion_id) REFERENCES emotion (id) ON DELETE CASCADE
);


-- many-to-many relations

-- many-to-many with user
CREATE TABLE IF NOT EXISTS role_person
(
    person_id INTEGER NOT NULL,
    role_id   INTEGER NOT NULL,
    PRIMARY KEY (person_id, role_id),
    FOREIGN KEY (person_id) REFERENCES person (id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS achievement_person
(
    achievement_id  INTEGER NOT NULL,
    person_id       INTEGER NOT NULL,
    completed_count INTEGER NOT NULL,
    is_access       BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (completed_count > 0),
    PRIMARY KEY (achievement_id, person_id),
    FOREIGN KEY (achievement_id) REFERENCES achievement (id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES person (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS person_follow
(
    follower_person_id  INTEGER NOT NULL,
    follow_to_person_id INTEGER NOT NULL,
    PRIMARY KEY (follower_person_id, follow_to_person_id),
    FOREIGN KEY (follower_person_id) REFERENCES person (id) ON DELETE CASCADE,
    FOREIGN KEY (follow_to_person_id) REFERENCES person (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS playlist_author
(
    playlist_id INTEGER NOT NULL,
    author_id   INTEGER NOT NULL,
    PRIMARY KEY (playlist_id, author_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist (id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES person (id) ON DELETE CASCADE
);

-- many-to-many with audio

CREATE TABLE IF NOT EXISTS author_audio
(
    author_id INTEGER NOT NULL,
    audio_id  INTEGER NOT NULL,
    PRIMARY KEY (author_id, audio_id),
    FOREIGN KEY (author_id) REFERENCES person (id) ON DELETE CASCADE,
    FOREIGN KEY (audio_id) REFERENCES audio (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS save_audio
(
    person_id INTEGER NOT NULL,
    audio_id  INTEGER NOT NULL,
    PRIMARY KEY (person_id, audio_id),
    FOREIGN KEY (person_id) REFERENCES person (id) ON DELETE CASCADE,
    FOREIGN KEY (audio_id) REFERENCES audio (id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS genre_audio
(
    genre_id INTEGER NOT NULL,
    audio_id INTEGER NOT NULL,
    PRIMARY KEY (genre_id, audio_id),
    FOREIGN KEY (genre_id) REFERENCES genre (id) ON DELETE CASCADE,
    FOREIGN KEY (audio_id) REFERENCES audio (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS playlist_audio
(
    playlist_id INTEGER NOT NULL,
    audio_id    INTEGER NOT NULL,
    PRIMARY KEY (playlist_id, audio_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist (id) ON DELETE CASCADE,
    FOREIGN KEY (audio_id) REFERENCES audio (id) ON DELETE CASCADE
);