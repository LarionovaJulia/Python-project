CREATE OR REPLACE PACKAGE show_lists is
  TYPE row_show_lists IS RECORD(
  list_id lists.list_id%TYPE,
  list_name lists.list_name%TYPE
  );

TYPE tbl_show_lists IS TABLE OF row_show_lists;

FUNCTION user_lists (in_user_id in users.user_id%TYPE)
  RETURN tbl_show_lists
  PIPELINED;
END show_lists;
/


CREATE OR REPLACE PACKAGE BODY show_lists IS
    FUNCTION user_lists (in_user_id in users.user_id%TYPE)
      RETURN tbl_show_lists
      PIPELINED
      IS
        CURSOR my_cur IS
          select list_id, list_name
          from lists
          where lists.user_id = in_user_id
          and lists.deleted = 0;
          BEGIN
            FOR curr IN my_cur
            LOOP
              PIPE ROW (curr);
            END LOOP;
        END user_lists;
END show_lists;
/