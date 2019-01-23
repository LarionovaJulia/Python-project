select * from users;

select lists.list_name
          from lists, users
          where lists.user_id = users.user_id
          and lists.deleted = 0;
          
select count(tasks.task_id)
from tasks
where tasks.list_id = list_id
and checked = 0;

select users.user_id, count(list_id) from lists
right join users on users.user_id = lists.user_id
group by users.user_id;

select lists.user_id, count(tasks.task_id), tasks.checked from lists
join tasks on lists.list_id = tasks.list_id
group by lists.user_id, tasks.checked;

select list_id, list_name
          from lists
          where lists.user_id = 1
          and lists.deleted = 0;

UPDATE lists
SET deleted = 0
WHERE lists.list_id in (1,2,3,4,5);

select * from lists;

select * from lists
join tasks on lists.list_id = tasks.list_id;

select tasks.created_date, count(distinct lists.user_id) from lists
join tasks on lists.list_id = tasks.list_id
group by tasks.created_date;

select tasks.created_date from tasks
group by tasks.created_date;


BEGIN
  lists_pack.delete_list(4);
END;


BEGIN
  update_age.new_age(1,5);
END;

