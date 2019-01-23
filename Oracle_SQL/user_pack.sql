CREATE OR REPLACE PACKAGE user_auth IS
    FUNCTION registration(
        email   IN  users.email%TYPE, 
        pass    IN  users.pass%TYPE
        )
        RETURN STRING;
        
    TYPE row_user IS RECORD (
        email users.email%TYPE,
        pass users.pass%TYPE
        );
        
    TYPE user_table IS TABLE OF row_user;
    
    FUNCTION log_in(
        in_email  IN  users.email%TYPE, 
        in_pass   IN  users.pass%TYPE
       -- message out STRING
       )
    RETURN user_table
    PIPELINED;
END user_auth;
/

CREATE OR REPLACE PACKAGE BODY user_auth IS 
    FUNCTION registration ( 
        email   IN  users.email%TYPE,  
        pass    IN  users.pass%TYPE
        ) 
        RETURN STRING
        IS 
    BEGIN 
        INSERT INTO users(email, pass) 
            VALUES(email, pass); 
        RETURN 'Operation successful'; 
        COMMIT; 
    END registration;

    FUNCTION log_in(
        in_email  IN  users.email%TYPE, 
        in_pass   IN  users.pass%TYPE
        ) 
    RETURN user_table 
    PIPELINED 
    IS
        CURSOR MY_CUR IS
            SELECT users.email, users.pass
            FROM users
            WHERE users.email = in_email 
            AND users.pass = in_pass;
            BEGIN
              FOR curr IN MY_CUR
              LOOP
                PIPE ROW (curr);
              END LOOP;           
        END log_in;
END user_auth;
/