-- migrate:up
    alter table staff 
    add column age integer;


-- migrate:down
    alter table staff 
    drop column age;
