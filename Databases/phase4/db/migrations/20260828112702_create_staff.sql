-- migrate:up

CREATE TABLE staff (
    id serial PRIMARY KEY,
    name text,
    email text UNIQUE
);


-- migrate:down

DROP TABLE staff;