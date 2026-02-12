-- Création des tables référentielles (Catalogue)
CREATE TABLE IF NOT EXISTS artists (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS songs (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT,
    language VARCHAR(10),
    artist_id INT REFERENCES artists(id)
);

-- Index pour la performance 
CREATE INDEX IF NOT EXISTS idx_artist_name ON artists(name);
CREATE INDEX IF NOT EXISTS idx_song_title ON songs(title);

-- Gestion Utilisateurs & Favoris
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'USER'
);

CREATE TABLE IF NOT EXISTS favorites (
    user_id INT REFERENCES users(id),
    song_id BIGINT REFERENCES songs(id),
    PRIMARY KEY (user_id, song_id)
);

-- Donnée de test
INSERT INTO users (username, password, role) VALUES ('admin', 'admin', 'ADMIN') ON CONFLICT DO NOTHING;
