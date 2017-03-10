#!/bin/bash
# 2017-03-10
# mysql employees database example
# insert new data

MYSQL_C="mysql -h127.0.0.1 -uemployee -pemployee" #mysql login
i=1
lastid=499999 #employees last id default:499999
insert_count=160000 # insert rows 

start=$(date +%s)
echo "start-time: $start"

employees_sql="insert into employees.employees(emp_no, birth_date, first_name, last_name, gender, hire_date) values"
titles_sql="insert into employees.titles(emp_no, title, from_date, to_date) values"
dept_emp_sql="insert into employees.dept_emp(emp_no, dept_no, form_date, to_date) values"
salary_sql="insert into employees.salaries(emp_no, salary, from_date, to_date) values"

while true
do
        let "lastid++"
        if [[ ${lastid}%2 -eq 0 ]]; then gender='F'; else gender='M'; fi
        employees_sql=$employees_sql"("$lastid", '1980-10-22', 'FirstName', 'LastName', '"$gender"', '2002-12-31'),"
        titles_sql=$titles_sql"("$lastid", 'PHP', '2002-12-31', '9999-12-01'),"
        dept_emp_sql=$dept_emp_sql"("$lastid", 'd009', '2002-12-31', '9999-12-01'),"

		salary_sql=$salary_sql"("$lastid", 70001, '2002-12-31', '2003-01-31'),"
		salary_sql=$salary_sql"("$lastid", 70502, '2003-01-31', '2003-04-31'),"
		salary_sql=$salary_sql"("$lastid", 71001, '2003-04-31', '2003-07-31'),"
		salary_sql=$salary_sql"("$lastid", 72001, '2003-07-31', '2003-12-31'),"
		salary_sql=$salary_sql"("$lastid", 73001, '2003-12-31', '2004-01-31'),"

        let "i++"
        if [[ $i -gt $insert_count ]]
	then 
		break 
	else
		employees_sql=$employees_sql","
		titles_sql=$titles_sql","
		dept_emp_sql=$dept_emp_sql","
		salary_sql=$salary_sql","
	fi
done

employees_time=$(date +%s)
echo "insert employees begin: $employees_time"
$MYSQL_C  -e "$employees_sql"
echo "insert employees end"

titles_time=$(date +%s)
echo "insert titles begin: $titles_time"
$MYSQL_C  -e "$titles_sql"
echo "insert titles end"

dept_emp_time=$(date +%s)
echo "insert dept-emp begin: $dept_emp_time"
$MYSQL_C  -e "$dept_emp_sql"
echo "insert dept-emp end"

salary_time=$(date +%s)
echo "insert salary begin: $salary_time"
$MYSQL_C  -e "$salary_sql"
echo "insert salary end"

echo $?

