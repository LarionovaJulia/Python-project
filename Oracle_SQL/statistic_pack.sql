CREATE OR REPLACE PACKAGE statistic_pack is
  TYPE row_check_task IS RECORD(
  in_user_id users.user_id%TYPE,
  count_task NUMBER(6),
  checked_tasks tasks.checked%TYPE
  );

  TYPE tbl_count_task IS TABLE OF row_check_task;

  FUNCTION check_tasks
    RETURN tbl_count_task
    PIPELINED;
    
    
  TYPE row_count_lists IS RECORD(
  in_user_id users.user_id%TYPE,
  count_lists NUMBER(6)
  );

  TYPE tbl_count_lists IS TABLE OF row_count_lists;

  FUNCTION count_lists
    RETURN tbl_count_lists
    PIPELINED;  
END statistic_pack;
/

CREATE OR REPLACE PACKAGE BODY statistic_pack IS
    FUNCTION check_tasks 
      RETURN tbl_count_task
      PIPELINED
      IS
        CURSOR my_cur IS
          select lists.user_id, count(tasks.task_id), tasks.checked from lists
          join tasks on lists.list_id = tasks.list_id
          group by lists.user_id, tasks.checked;
          BEGIN
            FOR curr IN my_cur
            LOOP
              PIPE ROW (curr);
            END LOOP;
        END check_tasks;

    FUNCTION count_lists 
      RETURN tbl_count_lists
      PIPELINED
      IS
        CURSOR my_cur IS
          select users.user_id, count(list_id) from lists
          right join users on users.user_id = lists.user_id
          group by users.user_id;
          BEGIN
            FOR curr IN my_cur
            LOOP
              PIPE ROW (curr);
            END LOOP;
        END count_lists;
END statistic_pack;
/
