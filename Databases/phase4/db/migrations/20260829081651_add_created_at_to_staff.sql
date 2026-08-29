-- migrate:up
    alter table staff
    add column created_at timestamp default current_timestamp;


-- migrate:down
    alter table staff
    drop column created_at;
