/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: SELECT 
    product_id,
    product_name,
    list_price
FROM 
    production.products
WHERE 
    list_price = (
        SELECT 
            MAX(list_price )
        FROM
            production.products);

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT *
FROM `Facilities`
WHERE `membercost` !=0
LIMIT 0 , 50


/* Q2: How many facilities do not charge a fee to members? */  --> Answer 4
SELECT COUNT( `facid` ) AS num_nochange_facilities
FROM `Facilities`
WHERE `membercost` = 0.0
LIMIT 0 , 30

/*Q2 below just listing the facilities that do not charge a fee to members*/

SELECT *
FROM `Facilities`
WHERE `membercost` = 0.0
LIMIT 0 , 30

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT *
FROM `Facilities`
WHERE `membercost` < ( 0.20 * `monthlymaintenance` )
LIMIT 0 , 30


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT *
FROM `Facilities`
WHERE `facid`
IN ( 1, 5 )
LIMIT 0 , 30


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT 	`name`,
		`monthlymaintenance`,
		CASE WHEN `monthlymaintenance` > 100 THEN 'expensive'
		     ELSE 'cheap' END AS labelled
FROM `Facilities`


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT `firstname`, 
		`surname`
FROM `Members` 
WHERE `joindate`= (
		SELECT 
			MAX(`joindate`)
			FROM `Members`)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/*/
/* My QUESTION to BLAKE- Not sure Distins is helping me to avoid duplicates, because the same 
member should be able to reserve the the same facility but at two different time slots. 
Is the above case scenario consider a duplicate???) In my mind that should not be a duplicate, 
but I can only separate these two scenarios if I check starttime/slot*/
	
SELECT DISTINCT
	CONCAT( Members.surname, Members.firstname ) AS member, 
	Facilities.name AS facility
FROM Bookings
	JOIN Facilities ON Facilities.facid = Bookings.facid
	JOIN Members ON Members.memid = Bookings.memid
	ORDER BY member
LIMIT 0 , 30

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT
	CONCAT( Members.surname, Members.firstname ) AS member, 
	Facilities.name AS facility,
	CASE WHEN Members.memid = 0 THEN (Facilities.guestcost*slots)
		     ELSE (Facilities.membercost*slots) END AS totalcost
FROM Bookings
	JOIN Facilities ON Facilities.facid = Bookings.facid
	JOIN Members ON Members.memid = Bookings.memid
WHERE starttime LIKE '2012-09-14%' 
HAVING totalcost > 30
	ORDER BY totalcost DESC 
LIMIT 0 , 30



/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT
	CONCAT( Members.surname, Members.firstname ) AS member, 
	Facilities.name AS facility, 
	CASE WHEN Members.memid = 0 THEN (Facilities.guestcost*sub.slots)
		     ELSE (Facilities.membercost*sub.slots) END AS totalcost
FROM (SELECT facid,
			 memid, 
			 slots
	  FROM Bookings 
	  WHERE starttime LIKE '2012-09-14%' ) sub
	JOIN Facilities ON Facilities.facid = sub.facid
	JOIN Members ON Members.memid = sub.memid
HAVING totalcost > 30
	ORDER BY totalcost DESC 
LIMIT 0 , 30


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/* Explanation - I need to substract the monthly maintenance to get the exact revenue number*/
/* The data is captured across two months (x2)*/

SELECT 
	Facilities.name AS facility,
	SUM(CASE WHEN Members.memid = 0 THEN (Facilities.guestcost*slots)
		     ELSE (Facilities.membercost*slots) END) - (Facilities.monthlymaintenance*2) AS totalrevenue
	
FROM Bookings
	JOIN Facilities ON Facilities.facid = Bookings.facid
	JOIN Members ON Members.memid = Bookings.memid
GROUP BY Facilities.facid
HAVING totalrevenue < 1000
	ORDER BY totalrevenue DESC 
LIMIT 0 , 30
