SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE lists_pack IS
    PROCEDURE add_list(
        list_name     IN  lists.list_name%TYPE, 
        in_user_id    IN  lists.user_id%TYPE
        --message OUT STRING
        );
    
    PROCEDURE delete_list(
        l_id  IN  lists.list_id%TYPE
        --  message OUT STRING 
        );
END lists_pack;
/

CREATE OR REPLACE PACKAGE BODY lists_pack IS 
    PROCEDURE add_list ( 
        list_name  IN  lists.list_name%TYPE, 
        in_user_id    IN  lists.user_id%TYPE
      --  message OUT STRING 
        ) AS 
    BEGIN
        INSERT INTO lists(list_name, user_id) 
        VALUES(list_name, in_user_id); 
       -- message := 'List created';
        COMMIT; 
    END add_list;

    PROCEDURE delete_list ( 
        l_id  IN  lists.list_id%TYPE
        --  message OUT STRING 
        ) AS
    BEGIN  
        UPDATE lists
        SET lists.deleted = 1
        WHERE lists.list_id = l_id;
        --message := 'List deleted'; 
        COMMIT; 
    END delete_list;
END lists_pack;
/

