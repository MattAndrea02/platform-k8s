CREATE TABLE healthcheck (id SERIAL PRIMARY KEY, status VARCHAR(64));
INSERT INTO healthcheck(id, status) VALUES (1, 'ready');