CREATE OR REPLACE PACKAGE show_tasks is
  TYPE row_show_tasks IS RECORD(
  task_id     tasks.task_id%TYPE,
  task_name   tasks.task_name%TYPE,
  checked     tasks.checked%TYPE,
  description tasks.description%TYPE,
  due_date    tasks.due_date%TYPE
  );

TYPE tbl_show_tasks IS TABLE OF row_show_tasks;

FUNCTION user_tasks (li_id in lists.list_id%TYPE)
  RETURN tbl_show_tasks
  PIPELINED;
END show_tasks;
/


CREATE OR REPLACE PACKAGE BODY show_tasks is
    FUNCTION user_tasks (li_id in lists.list_id%TYPE)
      RETURN tbl_show_tasks
      PIPELINED
      IS
        CURSOR my_cur IS
          select tasks.task_id, tasks.task_name, tasks.checked, tasks.description, tasks.due_date
          from tasks
          where tasks.list_id = li_id
          and tasks.deleted = 0;
          BEGIN
            FOR curr IN my_cur
            LOOP
              PIPE ROW (curr);
            END LOOP;
        END user_tasks;
END show_tasks;
/

