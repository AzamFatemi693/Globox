

1. Can a user show up more than once in the activity table? Yes or no, and why?(139 users)
```
select uid, count(uid)
from activity
group by uid
having count(uid)>1
```

```
select uid, 
case when count(uid) > 1 then 'Yes'
else 'No' 
end 
from activity
group by uid
having count(uid)>1
```

2. What type of join should we use to join the users table to the activity table?
```
select *
from users u
join activity a
on u.id= a.uid
order by uid
```

3. What SQL function can we use to fill in NULL values? "Coalesce"
```
select *,
coalesce(device, 'Unknown') as device
from activity
```

4. What are the start and end dates of the experiment?
```
select min(join_dt) as min_date, max(join_dt) as max_date
from groups
```

5. How many total users were in the experiment?
```
select count(distinct id)
from users
```

6. How many users were in the control and treatment groups?
```
select count(g.uid), g.group
from groups g
group by g.group
```

7. What was the conversion rate of all users?
```
with user_activity as
(
    select distinct u.id as id, a.uid 
    from users u
    full outer join activity a
    on u.id=a.uid
    
)
select round(((count(uid)*1.0)/count(id))*100,2) as rate
from user_activity
```

8. What is the user conversion rate for the control and treatment groups?
```
with user_activity as
(
    select distinct u.id as id, a.uid as uid
    from users u
    full outer join activity a
    on u.id=a.uid
    
)
select round(((count(ua.uid)*1.0)/count(id))*100,2) as rate, g.group
from user_activity ua
left join groups g
	on ua.id = g.uid
group by g.group
```

9. What is the average amount spent per user for the control and treatment groups, including users who did not convert?
```
with user_activity as
(
    select distinct u.id as id, a.uid as uid, coalesce(a.spent, 0) as spent
    from users u
    full outer join activity a
    on u.id=a.uid
    
)
select avg(spent) as avg_spent, g.group
from user_activity ua
left join groups g
	on ua.id = g.uid
group by g.group
```



1. Write a SQL query that returns: the user ID, the user’s country, the user’s gender, the user’s device type, the user’s test group, whether or not they converted (spent > $0), and how much they spent in total ($0+).
```
select u.id, u.country, u.gender, g.device, g.group,
case when spent>0 then 1 else 0 end as purchased,
sum(coalesce(a.spent,0)) as total_spent
from users u
join groups g
on u.id = g.uid
left join activity a
on a.uid=u.id
group by u.id, u.country, u.gender, g.device, g.group, purchased
```
