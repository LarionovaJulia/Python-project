CREATE OR REPLACE PACKAGE tasks_pack IS
    PROCEDURE add_task(
        list_id      IN  tasks.list_id%TYPE, 
        task_name    IN  tasks.task_name%TYPE,
        description  IN  tasks.description%TYPE,
        due_date     IN  tasks.due_date%TYPE
        -- message OUT STRING
        );
    
    PROCEDURE delete_task(
        t_id       IN  tasks.task_id%TYPE
        -- deleted    IN  tasks.deleted%TYPE
        -- message OUT STRING
        );
        
    PROCEDURE check_task(
        tk_id       IN  tasks.task_id%TYPE
    );
    
END tasks_pack;
/

CREATE OR REPLACE PACKAGE BODY tasks_pack IS 
    PROCEDURE add_task ( 
        list_id      IN  tasks.list_id%TYPE, 
        task_name    IN  tasks.task_name%TYPE,
        description  IN  tasks.description%TYPE,
        due_date     IN  tasks.due_date%TYPE
        -- message OUT STRING
        ) IS
        PRAGMA autonomous_transaction; 
    BEGIN 
        INSERT INTO tasks(list_id, task_name, description, due_date) 
            VALUES(list_id, task_name, description, due_date); 
        -- message := 'Task created'; 
        COMMIT; 
    END add_task;

    PROCEDURE delete_task ( 
        t_id    IN  tasks.task_id%TYPE
        -- deleted    IN  tasks.deleted%TYPE
        -- message OUT STRING 
        ) IS
        PRAGMA autonomous_transaction; 
    BEGIN 
        UPDATE tasks
        SET deleted = 1
        WHERE tasks.task_id = t_id; 
        -- message := 'Task deleted'; 
        COMMIT; 
    END delete_task;
    
    PROCEDURE check_task ( 
        tk_id    IN  tasks.task_id%TYPE
        ) AS 
    BEGIN 
        UPDATE tasks
        SET checked = 1
        WHERE tasks.task_id = tk_id; 
        -- message := 'Task deleted'; 
        COMMIT; 
    END check_task;
END tasks_pack;
/