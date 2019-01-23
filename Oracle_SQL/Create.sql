CREATE TABLE users (
    user_id INT NOT NULL,
    email VARCHAR2(255) NOT NULL UNIQUE,
    pass VARCHAR2(255) NOT NULL,
    constraint PK_USER_ID primary key (user_id)
);

CREATE TABLE lists (
    list_id INT NOT NULL,
    list_name VARCHAR2(255) NOT NULL,
    user_id INT NOT NULL,
    deleted INT DEFAULT 0,
    constraint PK_LIST_ID primary key (list_id)
);

CREATE TABLE tasks (
    task_id INT NOT NULL,
    list_id INT NOT NULL,
    task_name VARCHAR2(255) NOT NULL,
    description VARCHAR2(255),
    created_date DATE DEFAULT sysdate NOT NULL, 
    due_date DATE DEFAULT NULL,
    checked INT DEFAULT 0,
    deleted INT DEFAULT 0,
    constraint PK_TASK_ID primary key (task_id)
)  ;

-- Foreign keys
alter table lists
   add constraint FK_USER_ID foreign key (user_id)
      references users(user_id);

alter table tasks
   add constraint FK_LIST_ID foreign key (list_id)
      references lists(list_id);


-- Check costraints

alter table users
    add constraint user_email_content check (Regexp_like(email, '[a-z0-9.@]'));
    
alter table tasks
    add constraint right_dates check (due_date >= created_date);
    
alter table tasks
    add constraint right_checked check (Regexp_like(checked, '[0-1]'));

alter table tasks
    add constraint right_deleted_task check (Regexp_like(deleted, '[0-1]'));

alter table tasks
    add constraint task_name_check check (length(task_name) > 0);

alter table lists
    add constraint list_name_check check (length(list_name) > 0);

alter table lists
    add constraint right_deleted_list check (Regexp_like(deleted, '[0-1]'));

-- autoincrement for IDs

CREATE SEQUENCE user_seq START WITH 1 increment by 1;

CREATE OR REPLACE TRIGGER users_id 
BEFORE INSERT ON users 
FOR EACH ROW

BEGIN
  SELECT user_seq.NEXTVAL
  INTO   :new.user_id
  FROM   dual;
END;
/

CREATE SEQUENCE list_seq START WITH 1 increment by 1;

CREATE OR REPLACE TRIGGER lists_id 
BEFORE INSERT ON lists 
FOR EACH ROW

BEGIN
  SELECT list_seq.NEXTVAL
  INTO   :new.list_id
  FROM   dual;
END;
/

CREATE SEQUENCE task_seq START WITH 1 increment by 1;

CREATE OR REPLACE TRIGGER tasks_id 
BEFORE INSERT ON tasks 
FOR EACH ROW

BEGIN
  SELECT list_seq.NEXTVAL
  INTO   :new.task_id
  FROM   dual;
END;
/