DROP table employees cascade constraints;
DROP table departments cascade constraints;
DROP TABLE consultants cascade constraints;
DROP table locations;
DROP table countries;
DROP table regions;
DROP table job_history;
DROP table jobs;
DROP table sal_grades;

-- ********************************************************************
-- Create the REGIONS table to hold region information for locations
-- HR.LOCATIONS table has a foreign key to this table.
   
CREATE TABLE regions
   ( 
    region_id NUMBER(3) CONSTRAINT reg_id_pk  PRIMARY KEY,
    region_name VARCHAR2(25) 
   );


-- ********************************************************************
-- Create the COUNTRIES table to hold country information for customers
-- and company locations. 
-- OE.CUSTOMERS table and HR.LOCATIONS have a foreign key to this table.
       

CREATE TABLE countries 
   ( country_id CHAR(2)    CONSTRAINT country_id_pk   PRIMARY KEY
   , country_name VARCHAR2(40) 
   , region_id NUMBER (3) CONSTRAINT country_reg_id_fk 
                            REFERENCES regions(region_id)
   ) 
   ORGANIZATION INDEX; 

-- ********************************************************************
-- Create the LOCATIONS table to hold address information for company departments.
-- HR.DEPARTMENTS has a foreign key to this table.
       

CREATE TABLE locations
   ( location_id NUMBER(4) CONSTRAINT loc_id_pk   PRIMARY KEY 
   , street_address VARCHAR2(40)
   , postal_code VARCHAR2(12)
   , city VARCHAR2(30)  CONSTRAINT loc_city_nn NOT NULL
   , state_province VARCHAR2(25)
   , country_id CHAR(2) CONSTRAINT loc_country_id_fk
                            REFERENCES countries(country_id) 
   ) ;



-- Useful for any subsequent addition of rows to locations table
-- Starts with 3300

-- ********************************************************************
-- Create the DEPARTMENTS table to hold company department information.
-- HR.EMPLOYEES and HR.JOB_HISTORY and HR.CONSULTANTS have a foreign key to this table.
       

CREATE TABLE departments
   ( department_id NUMBER(4) CONSTRAINT dept_id_pk PRIMARY KEY 
   , department_name VARCHAR2(30) NOT NULL
   , manager_id NUMBER(6) 
   , location_id NUMBER(4) CONSTRAINT dept_loc_id_fk
                              REFERENCES locations (location_id)
   ) ;

-- Useful for any subsequent addition of rows to departments table
-- Starts with 280 

-- ********************************************************************
-- Create the JOBS table to hold the different names of job roles within the company.
-- HR.EMPLOYEES and HR.CONSULTANTS have a foreign key to this table.
       

CREATE TABLE jobs
   ( job_id VARCHAR2(10) CONSTRAINT job_id_pk  PRIMARY KEY
   , job_title VARCHAR2(35) NOT NULL
   , min_salary NUMBER(6) NOT NULL
   , max_salary NUMBER(6) NOT NULL
   ) ;

-- ********************************************************************
-- Create the EMPLOYEES table to hold the employee personnel 
-- information for the company.
-- HR.EMPLOYEES has a self referencing foreign key to this table.
-- HR.CONSULTANTS has a foreign key to this table.
       

CREATE TABLE employees
   ( employee_id NUMBER(6) CONSTRAINT emp_emp_id_pk PRIMARY KEY 
   , first_name VARCHAR2(20) NOT NULL
   , last_name VARCHAR2(25) NOT NULL
   , email VARCHAR2(25) NOT NULL CONSTRAINT emp_email_uk UNIQUE
   , phone_number VARCHAR2(20)
   , hire_date DATE NOT NULL
   , job_id VARCHAR2(10)NOT NULL CONSTRAINT emp_job_fk REFERENCES jobs (job_id)
   , salary NUMBER(8,2) CONSTRAINT emp_salary_min CHECK (salary > 0)
   , commission_pct NUMBER(2,2)
   , manager_id NUMBER(6) CONSTRAINT emp_manager_fk REFERENCES employees
   , department_id NUMBER(4)CONSTRAINT emp_dept_fk REFERENCES departments
   ) ;

                   
-- Useful for any subsequent addition of rows to employees table
-- Starts with 207 
       
/*********************************************************************
    Create the CONSULTANTS table to hold the consultant personnel 
    information for the company. */
           

CREATE TABLE consultants
   ( consultant_id NUMBER(6) CONSTRAINT cons_cons_id_pk PRIMARY KEY 
   , first_name VARCHAR2(20) not null
   , last_name VARCHAR2(25) not null
   , email VARCHAR2(25) NOT NULL CONSTRAINT cons_email_uk UNIQUE
   , phone_number VARCHAR2(20)
   , hire_date DATE NOT NULL
   , job_id VARCHAR2(10)NOT NULL CONSTRAINT cons_job_fk REFERENCES jobs (job_id)
   , salary NUMBER(8,2) CONSTRAINT cons_salary_min CHECK (salary > 0)
   , commission_pct NUMBER(2,2)
   , manager_id NUMBER(6) CONSTRAINT cons_manager_fk REFERENCES employees
   , department_id NUMBER(4)CONSTRAINT cons_dept_fk REFERENCES departments
   ) ;

                            
-- ********************************************************************
-- Create the JOB_HISTORY table to hold the history of jobs that 
-- employees have held in the past.
-- HR.JOBS, HR_DEPARTMENTS, and HR.EMPLOYEES have a foreign key to this table.
       

CREATE TABLE job_history
   ( employee_id NUMBER(6) NOT NULL CONSTRAINT jhist_emp_fk REFERENCES employees
   , start_date DATE NOT NULL
   , end_date DATE NOT NULL
   , job_id VARCHAR2(10) NOT NULL CONSTRAINT jhist_job_fk REFERENCES jobs
   , department_id NUMBER(4) NOT NULL CONSTRAINT jhist_dept_fk REFERENCES departments
   , CONSTRAINT jhist_date_interval CHECK (end_date > start_date)
   , CONSTRAINT jhist_emp_id_st_date_pk PRIMARY KEY (employee_id, start_date)
   ) ;
   
-- ********************************************************************
-- Create the SAL_GRADES table to hold the grade for each salary range 
   
CREATE TABLE sal_grades
   ( grade_level CHAR(3) CONSTRAINT sgrade_grade_level_pk PRIMARY KEY
   , lowest_sal NUMBER(8,2) NOT NULL
   , highest_sal NUMBER(8,2) NOT NULL
   , CONSTRAINT sgrade_sal_ck CHECK (lowest_sal < highest_sal)
   ) ;

-- ********************************************************************
-- Create the EMP_DETAILS_VIEW that joins the employees, jobs, 
-- departments, jobs, countries, and locations table to provide details
-- about employees.
       

CREATE OR REPLACE VIEW emp_details_view
   (employee_id,job_id,manager_id,department_id,location_id, country_id,
    first_name,last_name,salary,commission_pct,department_name,job_title,
    city,state_province,country_name,region_name)
  AS SELECT  e.employee_id, e.job_id, e.manager_id, e.department_id,
      d.location_id, l.country_id, e.first_name, e.last_name, e.salary,
      e.commission_pct,d.department_name, j.job_title, l.city, l.state_province,
      c.country_name, r.region_name
     FROM   employees e,   departments d,   jobs j,   locations l,
            countries c,  regions r
     WHERE e.department_id = d.department_id
     AND d.location_id = l.location_id
     AND l.country_id = c.country_id
     AND c.region_id = r.region_id
     AND j.job_id = e.job_id 
    WITH READ ONLY;


ALTER SESSION SET NLS_LANGUAGE=American; 

-- ***************************insert data into the REGIONS table

INSERT INTO regions VALUES 
   ( 1
   , 'Europe' 
   );

INSERT INTO regions VALUES 
   ( 2
   , 'Americas' 
   );

INSERT INTO regions VALUES 
   ( 3
   , 'Asia' 
   );

INSERT INTO regions VALUES 
   ( 4
   , 'Middle East and Africa' 
   );

-- ***************************insert data into the COUNTRIES table

INSERT INTO countries VALUES 
   ( 'IT'
   , 'Italy'
   , 1 
   );

INSERT INTO countries VALUES 
   ( 'JP'
   , 'Japan'
   , 3 
   );

INSERT INTO countries VALUES 
   ( 'US'
   , 'United States of America'
   , 2 
   );

INSERT INTO countries VALUES 
   ( 'CA'
   , 'Canada'
   , 2 
   );

INSERT INTO countries VALUES 
   ( 'CN'
   , 'China'
   , 3 
   );

INSERT INTO countries VALUES 
   ( 'IN'
   , 'India'
   , 3 
   );

INSERT INTO countries VALUES 
   ( 'AU'
   , 'Australia'
   , 3 
   );

INSERT INTO countries VALUES 
   ( 'ZW'
   , 'Zimbabwe'
   , 4 
   );

INSERT INTO countries VALUES 
   ( 'SG'
   , 'Singapore'
   , 3 
   );

INSERT INTO countries VALUES 
   ( 'UK'
   , 'United Kingdom'
   , 1 
   );

INSERT INTO countries VALUES 
   ( 'FR'
   , 'France'
   , 1 
   );

INSERT INTO countries VALUES 
   ( 'DE'
   , 'Germany'
   , 1 
   );

INSERT INTO countries VALUES 
   ( 'ZM'
   , 'Zambia'
   , 4 
   );

INSERT INTO countries VALUES 
   ( 'EG'
   , 'Egypt'
   , 4 
   );

INSERT INTO countries VALUES 
   ( 'BR'
   , 'Brazil'
   , 2 
   );

INSERT INTO countries VALUES 
   ( 'CH'
   , 'Switzerland'
   , 1 
   );

INSERT INTO countries VALUES 
   ( 'NL'
   , 'Netherlands'
   , 1 
   );

INSERT INTO countries VALUES 
   ( 'MX'
   , 'Mexico'
   , 2 
   );

INSERT INTO countries VALUES 
   ( 'KW'
   , 'Kuwait'
   , 4 
   );

INSERT INTO countries VALUES 
   ( 'IL'
   , 'Israel'
   , 4 
   );

INSERT INTO countries VALUES 
   ( 'DK'
   , 'Denmark'
   , 1 
   );

INSERT INTO countries VALUES 
   ( 'HK'
   , 'HongKong'
   , 3 
   );

INSERT INTO countries VALUES 
   ( 'NG'
   , 'Nigeria'
   , 4 
   );

INSERT INTO countries VALUES 
   ( 'AR'
   , 'Argentina'
   , 2 
   );

INSERT INTO countries VALUES 
   ( 'BE'
   , 'Belgium'
   , 1 
   );
       

-- ***************************insert data into the LOCATIONS table       

INSERT INTO locations VALUES 
   ( 1000 
   , '1297 Via Cola di Rie'
   , '00989'
   , 'Rome'
   , NULL
   , 'IT'
   );

INSERT INTO locations VALUES 
   ( 1100 
   , '93091 Calle della Testa'
   , '10934'
   , 'Venice'
   , NULL
   , 'IT'
   );

INSERT INTO locations VALUES 
   ( 1200 
   , '2017 Shinjuku-ku'
   , '1689'
   , 'Tokyo'
   , 'Tokyo Prefecture'
   , 'JP'
   );

INSERT INTO locations VALUES 
   ( 1300 
   , '9450 Kamiya-cho'
   , '6823'
   , 'Hiroshima'
   , NULL
   , 'JP'
   );

INSERT INTO locations VALUES 
   ( 1400 
   , '2014 Jabberwocky Rd'
   , '26192'
   , 'Southlake'
   , 'Texas'
   , 'US'
   );

INSERT INTO locations VALUES 
   ( 1500 
   , '2011 Interiors Blvd'
   , '99236'
   , 'South San Francisco'
   , 'California'
   , 'US'
   );

INSERT INTO locations VALUES 
   ( 1600 
   , '2007 Zagora St'
   , '50090'
   , 'South Brunswick'
   , 'New Jersey'
   , 'US'
   );

INSERT INTO locations VALUES 
   ( 1700 
   , '2004 Charade Rd'
   , '98199'
   , 'Seattle'
   , 'Washington'
   , 'US'
   );

INSERT INTO locations VALUES 
   ( 1800 
   , '147 Spadina Ave'
   , 'M5V 2L7'
   , 'Toronto'
   , 'Ontario'
   , 'CA'
   );

INSERT INTO locations VALUES 
   ( 1900 
   , '6092 Boxwood St'
   , 'YSW 9T2'
   , 'Whitehorse'
   , 'Yukon'
   , 'CA'
   );

INSERT INTO locations VALUES 
   ( 2000 
   , '40-5-12 Laogianggen'
   , '190518'
   , 'Beijing'
   , NULL
   , 'CN'
   );

INSERT INTO locations VALUES 
   ( 2100 
   , '1298 Vileparle (E)'
   , '490231'
   , 'Bombay'
   , 'Maharashtra'
   , 'IN'
   );

INSERT INTO locations VALUES 
   ( 2200 
   , '12-98 Victoria Street'
   , '2901'
   , 'Sydney'
   , 'New South Wales'
   , 'AU'
   );

INSERT INTO locations VALUES 
   ( 2300 
   , '198 Clementi North'
   , '540198'
   , 'Singapore'
   , NULL
   , 'SG'
   );

INSERT INTO locations VALUES 
   ( 2400 
   , '8204 Arthur St'
   , NULL
   , 'London'
   , NULL
   , 'UK'
   );

INSERT INTO locations VALUES 
   ( 2500 
   , 'Magdalen Centre, The Oxford Science Park'
   , 'OX9 9ZB'
   , 'Oxford'
   , 'Oxford'
   , 'UK'
   );

INSERT INTO locations VALUES 
   ( 2600 
   , '9702 Chester Road'
   , '09629850293'
   , 'Stretford'
   , 'Manchester'
   , 'UK'
   );

INSERT INTO locations VALUES 
   ( 2700 
   , 'Schwanthalerstr. 7031'
   , '80925'
   , 'Munich'
   , 'Bavaria'
   , 'DE'
   );

INSERT INTO locations VALUES 
   ( 2800 
   , 'Rua Frei Caneca 1360 '
   , '01307-002'
   , 'Sao Paulo'
   , 'Sao Paulo'
   , 'BR'
   );

INSERT INTO locations VALUES 
   ( 2900 
   , '20 Rue des Corps-Saints'
   , '1730'
   , 'Geneva'
   , 'Geneve'
   , 'CH'
   );

INSERT INTO locations VALUES 
   ( 3000 
   , 'Murtenstrasse 921'
   , '3095'
   , 'Bern'
   , 'BE'
   , 'CH'
   );

INSERT INTO locations VALUES 
   ( 3100 
   , 'Pieter Breughelstraat 837'
   , '3029SK'
   , 'Utrecht'
   , 'Utrecht'
   , 'NL'
   );

INSERT INTO locations VALUES 
   ( 3200 
   , 'Mariano Escobedo 9991'
   , '11932'
   , 'Mexico City'
   , 'Distrito Federal'
   , 'MX'
   );
       

-- ****************************insert data into the DEPARTMENTS table


INSERT INTO departments VALUES 
   ( 10
   , 'Administration'
   , 200
   , 1700
   );

INSERT INTO departments VALUES 
   ( 20
   , 'Marketing'
   , 201
   , 1800
   );
   
   INSERT INTO departments VALUES 
   ( 30
   , 'Purchasing'
   , 114
   , 1700
   );
   
   INSERT INTO departments VALUES 
   ( 40
   , 'Human Resources'
   , 203
   , 2400
   );

INSERT INTO departments VALUES 
   ( 50
   , 'Shipping'
   , 121
   , 1500
   );
   
   INSERT INTO departments VALUES 
   ( 60 
   , 'IT'
   , 103
   , 1400
   );
   
   INSERT INTO departments VALUES 
   ( 70 
   , 'Public Relations'
   , 204
   , 2700
   );
   
   INSERT INTO departments VALUES 
   ( 80 
   , 'Sales'
   , 145
   , 2500
   );
   
   INSERT INTO departments VALUES 
   ( 90 
   , 'Executive'
   , 100
   , 1700
   );

INSERT INTO departments VALUES 
   ( 100 
   , 'Finance'
   , 108
   , 1700
   );
   
   INSERT INTO departments VALUES 
   ( 110 
   , 'Accounting'
   , 205
   , 1800
   );

INSERT INTO departments VALUES 
   ( 120 
   , 'Treasury'
   , NULL
   , 1700
   );

INSERT INTO departments VALUES 
   ( 130 
   , 'Corporate Tax'
   , NULL
   , 1800
   );

INSERT INTO departments VALUES 
   ( 140 
   , 'Control And Credit'
   , NULL
   , 1700
   );

INSERT INTO departments VALUES 
   ( 150 
   , 'Shareholder Services'
   , NULL
   , 1900
   );

INSERT INTO departments VALUES 
   ( 160 
   , 'Benefits'
   , NULL
   , 2000
   );

INSERT INTO departments VALUES 
   ( 170 
   , 'Manufacturing'
   , NULL
   , 2000
   );

INSERT INTO departments VALUES 
   ( 180 
   , 'Construction'
   , NULL
   , 2100
   );

INSERT INTO departments VALUES 
   ( 190 
   , 'Contracting'
   , NULL
   , 2200
   );

INSERT INTO departments VALUES 
   ( 200 
   , 'Operations'
   , NULL
   , 2300
   );

INSERT INTO departments VALUES 
   ( 210 
   , 'IT Support'
   , NULL
   , 2400
   );

INSERT INTO departments VALUES 
   ( 220 
   , 'NOC'
   , NULL
   , 2500
   );

INSERT INTO departments VALUES 
   ( 230 
   , 'IT Helpdesk'
   , NULL
   , 2500
   );

INSERT INTO departments VALUES 
   ( 240 
   , 'Government Sales'
   , NULL
   , 1700
   );

INSERT INTO departments VALUES 
   ( 250 
   , 'Retail Sales'
   , NULL
   , 2700
   );

INSERT INTO departments VALUES 
   ( 260 
   , 'Recruiting'
   , NULL
   , 2800
   );

INSERT INTO departments VALUES 
   ( 270 
   , 'Payroll'
   , NULL
   , 2900
   );
       

-- ***************************insert data into the JOBS table

INSERT INTO jobs VALUES 
   ( 'AD_PRES'
   , 'President'
   , 20000
   , 40000
   );
   INSERT INTO jobs VALUES 
   ( 'AD_VP'
   , 'Administration Vice President'
   , 15000
   , 30000
   );

INSERT INTO jobs VALUES 
   ( 'AD_ASST'
   , 'Administration Assistant'
   , 3000
   , 6000
   );

INSERT INTO jobs VALUES 
   ( 'FI_MGR'
   , 'Finance Manager'
   , 8200
   , 16000
   );

INSERT INTO jobs VALUES 
   ( 'FI_ACCOUNT'
   , 'Accountant'
   , 4200
   , 9000
   );

INSERT INTO jobs VALUES 
   ( 'AC_MGR'
   , 'Accounting Manager'
   , 8200
   , 16000
   );

INSERT INTO jobs VALUES 
   ( 'AC_ACCOUNT'
   , 'Public Accountant'
   , 4200
   , 9000
   );
   INSERT INTO jobs VALUES 
   ( 'SA_MAN'
   , 'Sales Manager'
   , 10000
   , 20000
   );

INSERT INTO jobs VALUES 
   ( 'SA_REP'
   , 'Sales Representative'
   , 6000
   , 12000
   );

INSERT INTO jobs VALUES 
   ( 'PU_MAN'
   , 'Purchasing Manager'
   , 8000
   , 15000
   );

INSERT INTO jobs VALUES 
   ( 'PU_CLERK'
   , 'Purchasing Clerk'
   , 2500
   , 5500
   );

INSERT INTO jobs VALUES 
   ( 'ST_MAN'
   , 'Stock Manager'
   , 5500
   , 8500
   );
   INSERT INTO jobs VALUES 
   ( 'ST_CLERK'
   , 'Stock Clerk'
   , 2000
   , 5000
   );

INSERT INTO jobs VALUES 
   ( 'SH_CLERK'
   , 'Shipping Clerk'
   , 2500
   , 5500
   );

INSERT INTO jobs VALUES 
   ( 'IT_PROG'
   , 'Programmer'
   , 4000
   , 10000
   );

INSERT INTO jobs VALUES 
   ( 'MK_MAN'
   , 'Marketing Manager'
   , 9000
   , 15000
   );

INSERT INTO jobs VALUES 
   ( 'MK_REP'
   , 'Marketing Representative'
   , 4000
   , 9000
   );

INSERT INTO jobs VALUES 
   ( 'HR_REP'
   , 'Human Resources Representative'
   , 4000
   , 9000
   );

INSERT INTO jobs VALUES 
   ( 'PR_REP'
   , 'Public Relations Representative'
   , 4500
   , 10500
   );
       

-- ***************************insert data into the EMPLOYEES table

  INSERT INTO employees VALUES 
   ( 100
   , 'Steven'
   , 'King'
   , 'SKING'
   , '515.123.4567'
   , TO_DATE('17-JUN-07', 'DD-MON-RR')
   , 'AD_PRES'
   , 24000
   , NULL
   , NULL
   , 90
   );

INSERT INTO employees VALUES 
   ( 101
   , 'Neena'
   , 'Kochhar'
   , 'NKOCHHAR'
   , '515.123.4568'
   , TO_DATE('28-OCT-03', 'DD-MON-RR')
   , 'AD_VP'
   , 17000
   , NULL
   , 100
   , 90
   );

INSERT INTO employees VALUES 
   ( 102
   , 'Lex'
   , 'De Haan'
   , 'LDEHAAN'
   , '515.123.4569'
   , TO_DATE('13-JAN-03', 'DD-MON-RR')
   , 'AD_VP'
   , 17000
   , NULL
   , 100
   , 90
   );

INSERT INTO employees VALUES 
   ( 103
   , 'Alexander'
   , 'Hunold'
   , 'AHUNOLD'
   , '590.423.4567'
   , TO_DATE('03-JAN-10', 'DD-MON-RR')
   , 'IT_PROG'
   , 9000
   , NULL
   , 102
   , 60
   );

INSERT INTO employees VALUES 
   ( 104
   , 'Bruce'
   , 'Ernst'
   , 'BERNST'
   , '590.423.4568'
   , TO_DATE('21-MAY-01', 'DD-MON-RR')
   , 'IT_PROG'
   , 6000
   , NULL
   , 103
   , 60
   );

INSERT INTO employees VALUES 
   ( 105
   , 'David'
   , 'Austin'
   , 'DAUSTIN'
   , '590.423.4569'
   , TO_DATE('25-JUN-13', 'DD-MON-RR')
   , 'IT_PROG'
   , 4800
   , NULL
   , 103
   , 60
   );

INSERT INTO employees VALUES 
   ( 106
   , 'Valli'
   , 'Pataballa'
   , 'VPATABAL'
   , '590.423.4560'
   , TO_DATE('05-FEB-08', 'DD-MON-RR')
   , 'IT_PROG'
   , 4800
   , NULL
   , 103
   , 60
   );

INSERT INTO employees VALUES 
   ( 107
   , 'Diana'
   , 'Lorentz'
   , 'DLORENTZ'
   , '590.423.5567'
   , TO_DATE('07-FEB-09', 'DD-MON-RR')
   , 'IT_PROG'
   , 4200
   , NULL
   , 103
   , 60
   );

INSERT INTO employees VALUES 
   ( 108
   , 'Nancy'
   , 'Greenberg'
   , 'NGREENBE'
   , '515.421.4569'
   , TO_DATE('17-AUG-04', 'DD-MON-RR')
   , 'FI_MGR'
   , 12000
   , NULL
   , 101
   , 100
   );

INSERT INTO employees VALUES 
   ( 109
   , 'Daniel'
   , 'Faviet'
   , 'DFAVIET'
   , '515.421.4169'
   , TO_DATE('16-AUG-04', 'DD-MON-RR')
   , 'FI_ACCOUNT'
   , 9000
   , NULL
   , 108
   , 100
   );

INSERT INTO employees VALUES 
   ( 110
   , 'John'
   , 'Chen'
   , 'JCHEN'
   , '515.421.4269'
   , TO_DATE('28-SEP-07', 'DD-MON-RR')
   , 'FI_ACCOUNT'
   , 8200
   , NULL
   , 108
   , 100
   );

INSERT INTO employees VALUES 
   ( 111
   , 'Ismael'
   , 'Sciarra'
   , 'ISCIARRA'
   , '515.124.4369'
   , TO_DATE('30-SEP-07', 'DD-MON-RR')
   , 'FI_ACCOUNT'
   , 7700
   , NULL
   , 108
   , 100
   );

INSERT INTO employees VALUES 
   ( 112
   , 'Jose Manuel'
   , 'Urman'
   , 'JMURMAN'
   , '515.124.4469'
   , TO_DATE('07-MAR-08', 'DD-MON-RR')
   , 'FI_ACCOUNT'
   , 7800
   , NULL
   , 108
   , 100
   );

INSERT INTO employees VALUES 
   ( 113
   , 'Luis'
   , 'Popp'
   , 'LPOPP'
   , '515.124.4567'
   , TO_DATE('07-DEC-09', 'DD-MON-RR')
   , 'FI_ACCOUNT'
   , 6900
   , NULL
   , 108
   , 100
   );

INSERT INTO employees VALUES 
   ( 114
   , 'Den'
   , 'Raphaely'
   , 'DRAPHEAL'
   , '515.127.4561'
   , TO_DATE('24-MAR-08', 'DD-MON-RR')
   , 'PU_MAN'
   , 11000
   , NULL
   , 100
   , 30
   );

INSERT INTO employees VALUES 
   ( 115
   , 'Alexander'
   , 'Khoo'
   , 'AKHOO'
   , '515.127.4562'
   , TO_DATE('18-MAY-05', 'DD-MON-RR')
   , 'PU_CLERK'
   , 3100
   , NULL
   , 114
   , 30
   );

INSERT INTO employees VALUES 
   ( 116
   , 'Shelli'
   , 'Baida'
   , 'SBAIDA'
   , '515.127.4563'
   , TO_DATE('24-DEC-14', 'DD-MON-RR')
   , 'PU_CLERK'
   , 2900
   , NULL
   , 114
   , 30
   );

INSERT INTO employees VALUES 
   ( 117
   , 'Sigal'
   , 'Tobias'
   , 'STOBIAS'
   , '515.127.4564'
   , TO_DATE('24-JUL-07', 'DD-MON-RR')
   , 'PU_CLERK'
   , 2800
   , NULL
   , 114
   , 30
   );

INSERT INTO employees VALUES 
   ( 118
   , 'Guy'
   , 'Himuro'
   , 'GHIMURO'
   , '515.127.4565'
   , TO_DATE('15-NOV-08', 'DD-MON-RR')
   , 'PU_CLERK'
   , 2600
   , NULL
   , 114
   , 30
   );

INSERT INTO employees VALUES 
   ( 119
   , 'Karen'
   , 'Colmenares'
   , 'KCOLMENA'
   , '515.127.4566'
   , TO_DATE('10-AUG-09', 'DD-MON-RR')
   , 'PU_CLERK'
   , 2500
   , NULL
   , 114
   , 30
   );

INSERT INTO employees VALUES 
   ( 120
   , 'Matthew'
   , 'Weiss'
   , 'MWEISS'
   , '650.123.1234'
   , TO_DATE('18-JUL-12', 'DD-MON-RR')
   , 'ST_MAN'
   , 8000
   , NULL
   , 100
   , 50
   );

INSERT INTO employees VALUES 
   ( 121
   , 'Adam'
   , 'Fripp'
   , 'AFRIPP'
   , '650.123.2234'
   , TO_DATE('10-APR-07', 'DD-MON-RR')
   , 'ST_MAN'
   , 8200
   , NULL
   , 100
   , 50
   );

INSERT INTO employees VALUES 
   ( 122
   , 'Payam'
   , 'Kaufling'
   , 'PKAUFLIN'
   , '650.123.3234'
   , TO_DATE('01-JAN-09', 'DD-MON-RR')
   , 'ST_MAN'
   , 7900
   , NULL
   , 100
   , 50
   );

INSERT INTO employees VALUES 
   ( 123
   , 'Shanta'
   , 'Vollman'
   , 'SVOLLMAN'
   , '650.123.4234'
   , TO_DATE('10-OCT-14', 'DD-MON-RR')
   , 'ST_MAN'
   , 6500
   , NULL
   , 100
   , 50
   );

INSERT INTO employees VALUES 
   ( 124
   , 'Kevin'
   , 'Mourgos'
   , 'KMOURGOS'
   , '650.123.5234'
   , TO_DATE('16-NOV-19', 'DD-MON-RR')
   , 'ST_MAN'
   , 5800
   , NULL
   , 100
   , 50
   );

INSERT INTO employees VALUES 
   ( 125
   , 'Julia'
   , 'Nayer'
   , 'JNAYER'
   , '650.124.1214'
   , TO_DATE('16-JUL-07', 'DD-MON-RR')
   , 'ST_CLERK'
   , 3200
   , NULL
   , 120
   , 50
   );

INSERT INTO employees VALUES 
   ( 126
   , 'Irene'
   , 'Mikkilineni'
   , 'IMIKKILI'
   , '650.124.1224'
   , TO_DATE('28-SEP-08', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2700
   , NULL
   , 120
   , 50
   );

INSERT INTO employees VALUES 
   ( 127
   , 'James'
   , 'Landry'
   , 'JLANDRY'
   , '650.124.1334'
   , TO_DATE('14-JAN-19', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2400
   , NULL
   , 120
   , 50
   );

INSERT INTO employees VALUES 
   ( 128
   , 'Steven'
   , 'Markle'
   , 'SMARKLE'
   , '650.124.1434'
   , TO_DATE('08-MAR-00', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2200
   , NULL
   , 120
   , 50
   );

INSERT INTO employees VALUES 
   ( 129
   , 'Laura'
   , 'Bissot'
   , 'LBISSOT'
   , '650.124.5234'
   , TO_DATE('20-AUG-07', 'DD-MON-RR')
   , 'ST_CLERK'
   , 3300
   , NULL
   , 121
   , 50
   );

INSERT INTO employees VALUES 
   ( 130
   , 'Mozhe'
   , 'Atkinson'
   , 'MATKINSO'
   , '650.124.6234'
   , TO_DATE('30-OCT-07', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2800
   , NULL
   , 121
   , 50
   );

INSERT INTO employees VALUES 
   ( 131
   , 'James'
   , 'Marlow'
   , 'JAMRLOW'
   , '650.124.7234'
   , TO_DATE('16-FEB-15', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2500
   , NULL
   , 121
   , 50
   );

INSERT INTO employees VALUES 
   ( 132
   , 'TJ'
   , 'Olson'
   , 'TJOLSON'
   , '650.124.8234'
   , TO_DATE('10-APR-09', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2100
   , NULL
   , 121
   , 50
   );

INSERT INTO employees VALUES 
   ( 133
   , 'Jason'
   , 'Mallin'
   , 'JMALLIN'
   , '650.127.1934'
   , TO_DATE('14-JUN-06', 'DD-MON-RR')
   , 'ST_CLERK'
   , 3300
   , NULL
   , 122
   , 50
   );

INSERT INTO employees VALUES 
   ( 134
   , 'Michael'
   , 'Rogers'
   , 'MROGERS'
   , '650.127.1834'
   , TO_DATE('26-AUG-08', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2900
   , NULL
   , 122
   , 50
   );

INSERT INTO employees VALUES 
   ( 135
   , 'Ki'
   , 'Gee'
   , 'KGEE'
   , '650.127.1734'
   , TO_DATE('12-DEC-09', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2400
   , NULL
   , 122
   , 50
   );

INSERT INTO employees VALUES 
   ( 136
   , 'Hazel'
   , 'Philtanker'
   , 'HPHILTAN'
   , '650.127.1634'
   , TO_DATE('06-FEB-00', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2200
   , NULL
   , 122
   , 50
   );

INSERT INTO employees VALUES 
   ( 137
   , 'Renske'
   , 'Ladwig'
   , 'RLADWIG'
   , '650.121.1234'
   , TO_DATE('14-JUL-05', 'DD-MON-RR')
   , 'ST_CLERK'
   , 3600
   , NULL
   , 123
   , 50
   );

INSERT INTO employees VALUES 
   ( 138
   , 'Stephen'
   , 'Stiles'
   , 'SSTILES'
   , '650.121.2034'
   , TO_DATE('26-OCT-07', 'DD-MON-RR')
   , 'ST_CLERK'
   , 3200
   , NULL
   , 123
   , 50
   );

INSERT INTO employees VALUES 
   ( 139
   , 'John'
   , 'Seo'
   , 'JSEO'
   , '650.121.2019'
   , TO_DATE('12-FEB-08', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2700
   , NULL
   , 123
   , 50
   );

INSERT INTO employees VALUES 
   ( 140
   , 'Joshua'
   , 'Patel'
   , 'JPATEL'
   , '650.121.1834'
   , TO_DATE('06-APR-15', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2500
   , NULL
   , 123
   , 50
   );

INSERT INTO employees VALUES 
   ( 141
   , 'Trenna'
   , 'Rajs'
   , 'TRAJS'
   , '650.121.8009'
   , TO_DATE('17-OCT-05', 'DD-MON-RR')
   , 'ST_CLERK'
   , 3500
   , NULL
   , 124
   , 50
   );

INSERT INTO employees VALUES 
   ( 142
   , 'Curtis'
   , 'Davies'
   , 'CDAVIES'
   , '650.121.2994'
   , TO_DATE('29-JAN-07', 'DD-MON-RR')
   , 'ST_CLERK'
   , 3100
   , NULL
   , 124
   , 50
   );

INSERT INTO employees VALUES 
   ( 143
   , 'Randall'
   , 'Matos'
   , 'RMATOS'
   , '650.121.2874'
   , TO_DATE('15-MAR-08', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2600
   , NULL
   , 124
   , 50
   );

INSERT INTO employees VALUES 
   ( 144
   , 'Peter'
   , 'Vargas'
   , 'PVARGAS'
   , '650.121.2004'
   , TO_DATE('09-JUL-18', 'DD-MON-RR')
   , 'ST_CLERK'
   , 2500
   , NULL
   , 124
   , 50
   );

INSERT INTO employees VALUES 
   ( 145
   , 'John'
   , 'Russell'
   , 'JRUSSEL'
   , '011.44.1344.429268'
   , TO_DATE('01-OCT-06', 'DD-MON-RR')
   , 'SA_MAN'
   , 14000
   , .4
   , 100
   , 80
   );

INSERT INTO employees VALUES 
   ( 146
   , 'Karen'
   , 'Partners'
   , 'KPARTNER'
   , '011.44.1344.467268'
   , TO_DATE('05-JAN-07', 'DD-MON-RR')
   , 'SA_MAN'
   , 13500
   , .3
   , 100
   , 80
   );

INSERT INTO employees VALUES 
   ( 147
   , 'Alberto'
   , 'Errazuriz'
   , 'AERRAZUR'
   , '011.44.1344.429278'
   , TO_DATE('10-MAR-16', 'DD-MON-RR')
   , 'SA_MAN'
   , 12000
   , .3
   , 100
   , 80
   );

INSERT INTO employees VALUES 
   ( 148
   , 'Gerald'
   , 'Cambrault'
   , 'GCAMBRAU'
   , '011.44.1344.619268'
   , TO_DATE('15-OCT-09', 'DD-MON-RR')
   , 'SA_MAN'
   , 11000
   , .3
   , 100
   , 80
   );

INSERT INTO employees VALUES 
   ( 149
   , 'Eleni'
   , 'Zlotkey'
   , 'EZLOTKEY'
   , '011.44.1344.429018'
   , TO_DATE('29-JAN-10', 'DD-MON-RR')
   , 'SA_MAN'
   , 10500
   , .2
   , 100
   , 80
   );

INSERT INTO employees VALUES 
   ( 150
   , 'Peter'
   , 'Tucker'
   , 'PTUCKER'
   , '011.44.1344.129268'
   , TO_DATE('30-JAN-07', 'DD-MON-RR')
   , 'SA_REP'
   , 10000
   , .3
   , 145
   , 80
   );

INSERT INTO employees VALUES 
   ( 151
   , 'David'
   , 'Bernstein'
   , 'DBERNSTE'
   , '011.44.1344.345268'
   , TO_DATE('24-MAR-07', 'DD-MON-RR')
   , 'SA_REP'
   , 9500
   , .25
   , 145
   , 80
   );

INSERT INTO employees VALUES 
   ( 152
   , 'Peter'
   , 'Hall'
   , 'PHALL'
   , '011.44.1344.478968'
   , TO_DATE('20-AUG-16', 'DD-MON-RR')
   , 'SA_REP'
   , 9000
   , .25
   , 145
   , 80
   );

INSERT INTO employees VALUES 
   ( 153
   , 'Christopher'
   , 'Olsen'
   , 'COLSEN'
   , '011.44.1344.498718'
   , TO_DATE('30-MAR-08', 'DD-MON-RR')
   , 'SA_REP'
   , 8000
   , .2
   , 145
   , 80
   );

INSERT INTO employees VALUES 
   ( 154
   , 'Nanette'
   , 'Cambrault'
   , 'NCAMBRAU'
   , '011.44.1344.987668'
   , TO_DATE('09-DEC-18', 'DD-MON-RR')
   , 'SA_REP'
   , 7500
   , .2
   , 145
   , 80
   );

INSERT INTO employees VALUES 
   ( 155
   , 'Oliver'
   , 'Tuvault'
   , 'OTUVAULT'
   , '011.44.1344.486508'
   , TO_DATE('23-NOV-09', 'DD-MON-RR')
   , 'SA_REP'
   , 7000
   , .15
   , 145
   , 80
   );

INSERT INTO employees VALUES 
   ( 156
   , 'Janette'
   , 'King'
   , 'JKING'
   , '011.44.1345.429268'
   , TO_DATE('30-JAN-12', 'DD-MON-RR')
   , 'SA_REP'
   , 10000
   , .35
   , 146
   , 80
   );

INSERT INTO employees VALUES 
   ( 157
   , 'Patrick'
   , 'Sully'
   , 'PSULLY'
   , '011.44.1345.929268'
   , TO_DATE('04-MAR-06', 'DD-MON-RR')
   , 'SA_REP'
   , 9500
   , .35
   , 146
   , 80
   );

INSERT INTO employees VALUES 
   ( 158
   , 'Allan'
   , 'McEwen'
   , 'AMCEWEN'
   , '011.44.1345.829268'
   , TO_DATE('01-AUG-13', 'DD-MON-RR')
   , 'SA_REP'
   , 9000
   , .35
   , 146
   , 80
   );

INSERT INTO employees VALUES 
   ( 159
   , 'Lindsey'
   , 'Smith'
   , 'LSMITH'
   , '011.44.1345.729268'
   , TO_DATE('10-MAR-07', 'DD-MON-RR')
   , 'SA_REP'
   , 8000
   , .3
   , 146
   , 80
   );

INSERT INTO employees VALUES 
   ( 160
   , 'Louise'
   , 'Doran'
   , 'LDORAN'
   , '011.44.1345.629268'
   , TO_DATE('15-DEC-07', 'DD-MON-RR')
   , 'SA_REP'
   , 7500
   , .3
   , 146
   , 80
   );

INSERT INTO employees VALUES 
   ( 161
   , 'Sarath'
   , 'Sewall'
   , 'SSEWALL'
   , '011.44.1345.529268'
   , TO_DATE('03-NOV-18', 'DD-MON-RR')
   , 'SA_REP'
   , 7000
   , .25
   , 146
   , 80
   );

INSERT INTO employees VALUES 
   ( 162
   , 'Clara'
   , 'Vishney'
   , 'CVISHNEY'
   , '011.44.1346.129268'
   , TO_DATE('11-NOV-07', 'DD-MON-RR')
   , 'SA_REP'
   , 10500
   , .25
   , 147
   , 80
   );

INSERT INTO employees VALUES 
   ( 163
   , 'Danielle'
   , 'Greene'
   , 'DGREENE'
   , '011.44.1346.229268'
   , TO_DATE('19-MAR-19', 'DD-MON-RR')
   , 'SA_REP'
   , 9500
   , .15
   , 147
   , 80
   );

INSERT INTO employees VALUES 
   ( 164
   , 'Mattea'
   , 'Marvins'
   , 'MMARVINS'
   , '011.44.1346.329268'
   , TO_DATE('24-JAN-00', 'DD-MON-RR')
   , 'SA_REP'
   , 7200
   , .10
   , 147
   , 80
   );

INSERT INTO employees VALUES 
   ( 165
   , 'David'
   , 'Lee'
   , 'DLEE'
   , '011.44.1346.529268'
   , TO_DATE('23-FEB-00', 'DD-MON-RR')
   , 'SA_REP'
   , 6800
   , .1
   , 147
   , 80
   );

INSERT INTO employees VALUES 
   ( 166
   , 'Sundar'
   , 'Ande'
   , 'SANDE'
   , '011.44.1346.629268'
   , TO_DATE('24-MAR-00', 'DD-MON-RR')
   , 'SA_REP'
   , 6400
   , .10
   , 147
   , 80
   );

INSERT INTO employees VALUES 
   ( 167
   , 'Amit'
   , 'Banda'
   , 'ABANDA'
   , '011.44.1346.729268'
   , TO_DATE('21-APR-10', 'DD-MON-RR')
   , 'SA_REP'
   , 6200
   , .10
   , 147
   , 80
   );

INSERT INTO employees VALUES 
   ( 168
   , 'Lisa'
   , 'Ozer'
   , 'LOZER'
   , '011.44.1343.929268'
   , TO_DATE('11-MAR-07', 'DD-MON-RR')
   , 'SA_REP'
   , 11500
   , .25
   , 148
   , 80
   );

INSERT INTO employees VALUES 
   ( 169 
   , 'Harrison'
   , 'Bloom'
   , 'HBLOOM'
   , '011.44.1343.829268'
   , TO_DATE('23-MAR-08', 'DD-MON-RR')
   , 'SA_REP'
   , 10000
   , .20
   , 148
   , 80
   );

INSERT INTO employees VALUES 
   ( 170
   , 'Tayler'
   , 'Fox'
   , 'TFOX'
   , '011.44.1343.729268'
   , TO_DATE('24-JAN-15', 'DD-MON-RR')
   , 'SA_REP'
   , 9600
   , .20
   , 148
   , 80
   );

INSERT INTO employees VALUES 
   ( 171
   , 'William'
   , 'Smith'
   , 'WSMITH'
   , '011.44.1343.629268'
   , TO_DATE('23-FEB-09', 'DD-MON-RR')
   , 'SA_REP'
   , 7400
   , .15
   , 148
   , 80
   );

INSERT INTO employees VALUES 
   ( 172
   , 'Elizabeth'
   , 'Bates'
   , 'EBATES'
   , '011.44.1343.529268'
   , TO_DATE('24-MAR-09', 'DD-MON-RR')
   , 'SA_REP'
   , 7300
   , .15
   , 148
   , 80
   );

INSERT INTO employees VALUES 
   ( 173
   , 'Sundita'
   , 'Kumar'
   , 'SKUMAR'
   , '011.44.1343.329268'
   , TO_DATE('21-APR-00', 'DD-MON-RR')
   , 'SA_REP'
   , 6100
   , .10
   , 148
   , 80
   );

INSERT INTO employees VALUES 
   ( 174
   , 'Ellen'
   , 'Abel'
   , 'EABEL'
   , '011.44.1644.429267'
   , TO_DATE('11-MAY-06', 'DD-MON-RR')
   , 'SA_REP'
   , 11000
   , .30
   , 149
   , 80
   );

INSERT INTO employees VALUES 
   ( 175
   , 'Alyssa'
   , 'Hutton'
   , 'AHUTTON'
   , '011.44.1644.429266'
   , TO_DATE('19-MAR-07', 'DD-MON-RR')
   , 'SA_REP'
   , 8800
   , .25
   , 149
   , 80
   );

INSERT INTO employees VALUES 
   ( 176
   , 'Jonathon'
   , 'Taylor'
   , 'JTAYLOR'
   , '011.44.1644.429265'
   , TO_DATE('24-MAR-08', 'DD-MON-RR')
   , 'SA_REP'
   , 8600
   , .20
   , 149
   , 80
   );

INSERT INTO employees VALUES 
   ( 177
   , 'Jack'
   , 'Livingston'
   , 'JLIVINGS'
   , '011.44.1644.429264'
   , TO_DATE('23-APR-08', 'DD-MON-RR')
   , 'SA_REP'
   , 8400
   , .20
   , 149
   , 80
   );

INSERT INTO employees VALUES 
   ( 178
   , 'Kimberely'
   , 'Grant'
   , 'KGRANT'
   , '011.44.1644.429263'
   , TO_DATE('24-MAY-19', 'DD-MON-RR')
   , 'SA_REP'
   , 7000
   , .15
   , 149
   , NULL
   );

INSERT INTO employees VALUES 
   ( 179
   , 'Charles'
   , 'Johnson'
   , 'CJOHNSON'
   , '011.44.1644.429262'
   , TO_DATE('04-JAN-00', 'DD-MON-RR')
   , 'SA_REP'
   , 6200
   , .10
   , 149
   , 80
   );

INSERT INTO employees VALUES 
   ( 180
   , 'Winston'
   , 'Taylor'
   , 'WTAYLOR'
   , '650.507.9876'
   , TO_DATE('24-JAN-95', 'DD-MON-RR')
   , 'SH_CLERK'
   , 3200
   , NULL
   , 120
   , 50
   );

INSERT INTO employees VALUES 
   ( 181
   , 'Jean'
   , 'Fleaur'
   , 'JFLEAUR'
   , '650.507.9877'
   , TO_DATE('23-FEB-98', 'DD-MON-RR')
   , 'SH_CLERK'
   , 3100
   , NULL
   , 120
   , 50
   );

INSERT INTO employees VALUES 
   ( 182
   , 'Martha'
   , 'Sullivan'
   , 'MSULLIVA'
   , '650.507.9878'
   , TO_DATE('21-JUN-99', 'DD-MON-RR')
   , 'SH_CLERK'
   , 2500
   , NULL
   , 120
   , 50
   );

INSERT INTO employees VALUES 
   ( 183
   , 'Girard'
   , 'Geoni'
   , 'GGEONI'
   , '650.507.9879'
   , TO_DATE('03-FEB-10', 'DD-MON-RR')
   , 'SH_CLERK'
   , 2800
   , NULL
   , 120
   , 50
   );

INSERT INTO employees VALUES 
   ( 184
   , 'Nandita'
   , 'Sarchand'
   , 'NSARCHAN'
   , '650.509.1876'
   , TO_DATE('27-JAN-96', 'DD-MON-RR')
   , 'SH_CLERK'
   , 4200
   , NULL
   , 121
   , 50
   );

INSERT INTO employees VALUES 
   ( 185
   , 'Alexis'
   , 'Bull'
   , 'ABULL'
   , '650.509.2876'
   , TO_DATE('20-FEB-97', 'DD-MON-RR')
   , 'SH_CLERK'
   , 4100
   , NULL
   , 121
   , 50
   );

INSERT INTO employees VALUES 
   ( 186
   , 'Julia'
   , 'Dellinger'
   , 'JDELLING'
   , '650.509.3876'
   , TO_DATE('24-JUN-08', 'DD-MON-RR')
   , 'SH_CLERK'
   , 3400
   , NULL
   , 121
   , 50
   );

INSERT INTO employees VALUES 
   ( 187
   , 'Anthony'
   , 'Cabrio'
   , 'ACABRIO'
   , '650.509.4876'
   , TO_DATE('07-FEB-09', 'DD-MON-RR')
   , 'SH_CLERK'
   , 3000
   , NULL
   , 121
   , 50
   );

INSERT INTO employees VALUES 
   ( 188
   , 'Kelly'
   , 'Chung'
   , 'KCHUNG'
   , '650.505.1876'
   , TO_DATE('14-JUN-07', 'DD-MON-RR')
   , 'SH_CLERK'
   , 3800
   , NULL
   , 122
   , 50
   );

INSERT INTO employees VALUES 
   ( 189
   , 'Jennifer'
   , 'Dilly'
   , 'JDILLY'
   , '650.505.2876'
   , TO_DATE('13-AUG-07', 'DD-MON-RR')
   , 'SH_CLERK'
   , 3600
   , NULL
   , 122
   , 50
   );

INSERT INTO employees VALUES 
   ( 190
   , 'Timothy'
   , 'Gates'
   , 'TGATES'
   , '650.505.3876'
   , TO_DATE('11-JUL-08', 'DD-MON-RR')
   , 'SH_CLERK'
   , 2900
   , NULL
   , 122
   , 50
   );

INSERT INTO employees VALUES 
   ( 191
   , 'Randall'
   , 'Perkins'
   , 'RPERKINS'
   , '650.505.4876'
   , TO_DATE('19-DEC-09', 'DD-MON-RR')
   , 'SH_CLERK'
   , 2500
   , NULL
   , 122
   , 50
   );

INSERT INTO employees VALUES 
   ( 192
   , 'Sarah'
   , 'Bell'
   , 'SBELL'
   , '650.501.1876'
   , TO_DATE('04-FEB-06', 'DD-MON-RR')
   , 'SH_CLERK'
   , 4000
   , NULL
   , 123
   , 50
   );

INSERT INTO employees VALUES 
   ( 193
   , 'Britney'
   , 'Everett'
   , 'BEVERETT'
   , '650.501.2876'
   , TO_DATE('03-MAR-07', 'DD-MON-RR')
   , 'SH_CLERK'
   , 3900
   , NULL
   , 123
   , 50
   );

INSERT INTO employees VALUES 
   ( 194
   , 'Samuel'
   , 'McCain'
   , 'SMCCAIN'
   , '650.501.3876'
   , TO_DATE('01-JUL-08', 'DD-MON-RR')
   , 'SH_CLERK'
   , 3200
   , NULL
   , 123
   , 50
   );

INSERT INTO employees VALUES 
   ( 195
   , 'Vance'
   , 'Jones'
   , 'VJONES'
   , '650.501.4876'
   , TO_DATE('17-MAR-19', 'DD-MON-RR')
   , 'SH_CLERK'
   , 2800
   , NULL
   , 123
   , 50
   );

INSERT INTO employees VALUES 
   ( 196
   , 'Alana'
   , 'Walsh'
   , 'AWALSH'
   , '650.507.9811'
   , TO_DATE('24-APR-08', 'DD-MON-RR')
   , 'SH_CLERK'
   , 3100
   , NULL
   , 124
   , 50
   );

INSERT INTO employees VALUES 
   ( 197
   , 'Kevin'
   , 'Feeney'
   , 'KFEENEY'
   , '650.507.9822'
   , TO_DATE('23-MAY-08', 'DD-MON-RR')
   , 'SH_CLERK'
   , 3000
   , NULL
   , 124
   , 50
   );

INSERT INTO employees VALUES 
   ( 198
   , 'Donald'
   , 'O''Connell'
   , 'DOCONNEL'
   , '650.507.9833'
   , TO_DATE('21-JUN-09', 'DD-MON-RR')
   , 'SH_CLERK'
   , 2600
   , NULL
   , 124
   , 50
   );

INSERT INTO employees VALUES 
   ( 199
   , 'Douglas'
   , 'Grant'
   , 'DGRANT'
   , '650.507.9844'
   , TO_DATE('13-JAN-00', 'DD-MON-RR')
   , 'SH_CLERK'
   , 2600
   , NULL
   , 124
   , 50
   );

INSERT INTO employees VALUES 
   ( 200
   , 'Jennifer'
   , 'Whalen'
   , 'JWHALEN'
   , '515.123.4444'
   , TO_DATE('01-JUL-04', 'DD-MON-RR')
   , 'AD_ASST'
   , 4400
   , NULL
   , 101
   , 10
   );

INSERT INTO employees VALUES 
   ( 201
   , 'Michael'
   , 'Hartstein'
   , 'MHARTSTE'
   , '515.123.5555'
   , TO_DATE('17-FEB-14', 'DD-MON-RR')
   , 'MK_MAN'
   , 13000
   , NULL
   , 100
   , 20
   );

INSERT INTO employees VALUES 
   ( 202
   , 'Pat'
   , 'Fay'
   , 'PFAY'
   , '603.123.6666'
   , TO_DATE('17-AUG-07', 'DD-MON-RR')
   , 'MK_REP'
   , 6000
   , NULL
   , 201
   , 20
   );

INSERT INTO employees VALUES 
   ( 203
   , 'Susan'
   , 'Mavris'
   , 'SMAVRIS'
   , '515.123.7777'
   , TO_DATE('07-JUN-11', 'DD-MON-RR')
   , 'HR_REP'
   , 6500
   , NULL
   , 101
   , 40
   );

INSERT INTO employees VALUES 
   ( 204
   , 'Hermann'
   , 'Baer'
   , 'HBAER'
   , '515.123.8888'
   , TO_DATE('07-JUN-04', 'DD-MON-RR')
   , 'PR_REP'
   , 10000
   , NULL
   , 101
   , 70
   );

INSERT INTO employees VALUES 
   ( 205
   , 'Shelley'
   , 'Higgins'
   , 'SHIGGINS'
   , '515.123.8080'
   , TO_DATE('07-JUN-12', 'DD-MON-RR')
   , 'AC_MGR'
   , 12000
   , NULL
   , 101
   , 110
   );

INSERT INTO employees VALUES 
   ( 206
   , 'William'
   , 'Gietz'
   , 'WGIETZ'
   , '515.123.8181'
   , TO_DATE('07-JUN-04', 'DD-MON-RR')
   , 'AC_ACCOUNT'
   , 8300
   , NULL
   , 205
   , 110
   );

 --***************************************************************  
  ALTER table departments ADD CONSTRAINT dept_mgr_fk 
    FOREIGN KEY (manager_id) REFERENCES employees (employee_id);
   
-- ********* insert data into the CONSULTANT table

INSERT INTO consultants VALUES 
   ( 1
   , 'Ron'
   , 'Soltani'
   , 'RSOLTANI'
   , '515.321.1234'
   , TO_DATE('17-MAR-16', 'DD-MON-RR')
   , 'SA_REP'
   , 8300
   , .35
   , 149
   , 80
   );
  
  INSERT INTO consultants VALUES 
   ( 2
   , 'Eric'
   , 'Siglin'
   , 'ESIGLIN'
   , '515.321.2345'
   , TO_DATE('11-JUL-16', 'DD-MON-RR')
   , 'SA_REP'
   , 8300
   , .30
   , 149
   , 80
   ); 
   
   INSERT INTO consultants VALUES
   ( 3
   , 'Joe'
   , 'Roch'
   , 'JROCH'
   , '515.321.3456'
   , TO_DATE('10-AUG-16', 'DD-MON-RR')
   , 'SA_REP'
   , 8300
   , .30
   , 149
   , 80
   );
  
  INSERT INTO consultants VALUES 
   ( 4
   , 'Sean'
   , 'Kim'
   , 'SKIM'
   , '515.321.4567'
   , TO_DATE('11-AUG-16', 'DD-MON-RR')
   , 'SA_REP'
   , 8300
   , .30
   , 149
   , 80
   ); 
   
   INSERT INTO consultants VALUES 
   ( 5
   , 'Tim'
   , 'LeBlanc'
   , 'TLEBLANC'
   , '515.321.5678'
   , TO_DATE('07-AUG-17', 'DD-MON-RR')
   , 'SA_REP'
   , 8300
   , .25
   , 148
   , 80
   );
  
  INSERT INTO consultants VALUES 
   ( 6
   , 'Tammy'
   , 'McCullough'
   , 'TMCCULLOUGH'
   , '515.321.6789'
   , TO_DATE('07-AUG-17', 'DD-MON-RR')
   , 'SA_REP'
   , 8300
   , .25
   , 148
   , 80
   ); 
   
   INSERT INTO consultants VALUES
   ( 7
   , 'Nancy'
   , 'Greenberg'
   , 'NGREENBE'
   , '515.321.7890'
   , TO_DATE('07-AUG-17', 'DD-MON-RR')
   , 'SA_REP'
   , 8300
   , .25
   , 147
   , 80
   );
  
  INSERT INTO consultants VALUES 
   ( 8
   , 'Gerry'
   , 'Jurrens'
   , 'JGURRENS'
   , '515.321.8901'
   , TO_DATE('11-AUG-17', 'DD-MON-RR')
   , 'SA_REP'
   , 9000
   , .40
   , 146
   , 80
   ); 
   
   INSERT INTO consultants VALUES 
   ( 9
   , 'Steve'
   , 'Jones'
   , 'SJONES'
   , '515.321.9012'
   , TO_DATE('15-SEP-17', 'DD-MON-RR')
   , 'SA_REP'
   , 9000
   , .40
   , 146
   , 80
   );
  
  INSERT INTO consultants VALUES 
   ( 10
   , 'Wayne'
   , 'Abbott'
   , 'WABBOTT'
   , '515.321.0123'
   , TO_DATE('15-SEP-17', 'DD-MON-RR')
   , 'SA_REP'
   , 9000
   , .40
   , 146
   , 80
   ); 
   
  INSERT INTO consultants VALUES
   ( 11
   , 'Vance'
   , 'Jones'
   , 'VJONES'
   , '515.421.1234'
   , TO_DATE('04-APR-18', 'DD-MON-RR')
   , 'SA_REP'
   , 9500
   , .45
   , 145
   , 80
   );
  
  INSERT INTO consultants VALUES 
   ( 12
   , 'Bill'
   , 'Mayers'
   , 'BMAYERS'
   , '515.421.2345'
   , TO_DATE('02-MAY-18', 'DD-MON-RR')
   , 'SA_REP'
   , 8300
   , .25
   , 149
   , 80
   ); 
   
   INSERT INTO consultants VALUES 
   ( 13
   , 'Bob'
   , 'Witty'
   , 'BWITTY'
   , '515.421.3456'
   , TO_DATE('01-JUN-18', 'DD-MON-RR')
   , 'SA_REP'
   , 8300
   , .25
   , 148
   , 80
   );
  
  INSERT INTO consultants VALUES 
   ( 14
   , 'Michael'
   , 'Thum'
   , 'MTHUM'
   , '515.421.4567'
   , TO_DATE('07-AUG-17', 'DD-MON-RR')
   , 'SA_REP'
   , 8300
   , .25
   , 147
   , 80
   ); 
  
  INSERT INTO consultants VALUES 
   ( 15
   , 'James'
   , 'Little'
   , 'JLITTLE'
   , '515.421.5678'
   , TO_DATE('07-AUG-17', 'DD-MON-RR')
   , 'SA_REP'
   , 8500
   , .30
   , 146
   , 80
   );
  
  INSERT INTO consultants VALUES 
   ( 16
   , 'Angie'
   , 'Seydel'
   , 'ASEYDEL'
   , '515.421.6789'
   , TO_DATE('11-AUG-17', 'DD-MON-RR')
   , 'SA_REP'
   , 8500
   , .25
   , 146
   , 80
   );
-- ********* insert data into the JOB_HISTORY table
       

INSERT INTO job_history
         VALUES (102
   , TO_DATE('13-JAN-03', 'DD-MON-RR')
   , TO_DATE('24-JUL-08', 'DD-MON-RR')
   , 'IT_PROG'
   , 60);

INSERT INTO job_history
         VALUES (101
   , TO_DATE('28-OCT-03', 'DD-MON-RR')
   , TO_DATE('27-SEP-04', 'DD-MON-RR')
   , 'AC_ACCOUNT'
   , 110);

INSERT INTO job_history
         VALUES (101
   , TO_DATE('28-SEP-04', 'DD-MON-RR')
   , TO_DATE('15-MAR-07', 'DD-MON-RR')
   , 'AC_MGR'
   , 110);

INSERT INTO job_history
         VALUES (201
   , TO_DATE('17-FEB-14', 'DD-MON-RR')
   , TO_DATE('19-DEC-19', 'DD-MON-RR')
   , 'MK_REP'
   , 20);

INSERT INTO job_history
         VALUES (114
   , TO_DATE('24-MAR-08', 'DD-MON-RR')
   , TO_DATE('31-DEC-09', 'DD-MON-RR')
   , 'ST_CLERK'
   , 50
   );

INSERT INTO job_history
         VALUES (122
   , TO_DATE('01-JAN-09', 'DD-MON-RR')
   , TO_DATE('31-DEC-09', 'DD-MON-RR')
   , 'ST_CLERK'
   , 50
   );

INSERT INTO job_history
         VALUES (200
   , TO_DATE('01-JUL-04', 'DD-MON-RR')
   , TO_DATE('31-DEC-08', 'DD-MON-RR')
   , 'AD_ASST'
   , 90
   );

INSERT INTO job_history
         VALUES (176
   , TO_DATE('24-MAR-08', 'DD-MON-RR')
   , TO_DATE('31-DEC-08', 'DD-MON-RR')
   , 'SA_REP'
   , 80
   );

INSERT INTO job_history
         VALUES (176
   , TO_DATE('01-JAN-09', 'DD-MON-RR')
   , TO_DATE('31-DEC-09', 'DD-MON-RR')
   , 'SA_MAN'
   , 80
   );

INSERT INTO job_history
         VALUES (200
   , TO_DATE('01-JAN-09', 'DD-MON-RR')
   , TO_DATE('20-JUL-15', 'DD-MON-RR')
   , 'AC_ACCOUNT'
   , 90
   );
   
-- ********* insert data into the SAL_GRADES table
       

INSERT INTO sal_grades
         VALUES ('A'
   , 1000
   , 2999);
   
INSERT INTO sal_grades
         VALUES ('B'
   , 3000
   , 5999);
   
INSERT INTO sal_grades
         VALUES ('C'
   , 6000
   , 9999);
   
INSERT INTO sal_grades
         VALUES ('D'
   , 10000
   , 14999);
   
INSERT INTO sal_grades
         VALUES ('E'
   , 15000
   , 24999);
   
INSERT INTO sal_grades
         VALUES ('F'
   , 25000
   , 40000);

-- enable integrity constraint to DEPARTMENTS

ALTER TABLE departments 
   ENABLE CONSTRAINT dept_mgr_fk;

COMMIT;

CREATE INDEX emp_department_ix
   ON employees (department_id);

CREATE INDEX emp_job_ix
   ON employees (job_id);

CREATE INDEX emp_manager_ix
   ON employees (manager_id);

CREATE INDEX emp_name_ix
   ON employees (last_name, first_name);

CREATE INDEX dept_location_ix
   ON departments (location_id);

CREATE INDEX jhist_job_ix
   ON job_history (job_id);

CREATE INDEX jhist_employee_ix
   ON job_history (employee_id);

CREATE INDEX jhist_department_ix
   ON job_history (department_id);

CREATE INDEX loc_city_ix
   ON locations (city);

CREATE INDEX loc_state_province_ix 
   ON locations (state_province);

CREATE INDEX loc_country_ix
   ON locations (country_id);

COMMIT;
/*
-- procedure and statement trigger to allow dmls during business hours:
         CREATE OR REPLACE PROCEDURE secure_dml
         IS
         BEGIN
   IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
   OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
   RAISE_APPLICATION_ERROR (-20205, 
   'You may only make changes during normal office hours');
   END IF;
   END secure_dml;
   /

CREATE OR REPLACE TRIGGER secure_employees
   BEFORE INSERT OR UPDATE OR DELETE ON employees
   BEGIN
   secure_dml;
   END secure_employees;
   /

ALTER TRIGGER secure_employees DISABLE;
*/
-- **************************************************************************
-- procedure to add a row to the JOB_HISTORY table and row trigger 
-- to call the procedure when data is updated in the job_id or 
-- department_id columns in the EMPLOYEES table:
/*
CREATE OR REPLACE PROCEDURE add_job_history
   ( p_emp_id job_history.employee_id%type
   , p_start_date job_history.start_date%type
   , p_end_date job_history.end_date%type
   , p_job_id job_history.job_id%type
   , p_department_id job_history.department_id%type 
   )
   IS
   BEGIN
   INSERT INTO job_history (employee_id, start_date, end_date, 
   job_id, department_id)
   VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
   END add_job_history;
   /

CREATE OR REPLACE TRIGGER update_job_history
   AFTER UPDATE OF job_id, department_id ON employees
   FOR EACH ROW
   BEGIN
   add_job_history(:old.employee_id, :old.hire_date, sysdate, 
   :old.job_id, :old.department_id);
   END;
   /
*/
COMMIT;

COMMENT ON TABLE regions 
         IS 'Regions table that contains region numbers and names. Contains 4 rows; references with the Countries table.';

COMMENT ON COLUMN regions.region_id
         IS 'Primary key of regions table.';

COMMENT ON COLUMN regions.region_name
         IS 'Names of regions. Locations are in the countries of these regions.';

COMMENT ON TABLE locations
         IS 'Locations table that contains specific address of a specific office,
         warehouse, and/or production site of a company. Does not store addresses /
         locations of customers. Contains 23 rows; references with the
         departments and countries tables. ';

COMMENT ON COLUMN locations.location_id
         IS 'Primary key of locations table';

COMMENT ON COLUMN locations.street_address
         IS 'Street address of an office, warehouse, or production site of a company.
         Contains building number and street name';

COMMENT ON COLUMN locations.postal_code
         IS 'Postal code of the location of an office, warehouse, or production site 
         of a company. ';

COMMENT ON COLUMN locations.city
         IS 'A not null column that shows city where an office, warehouse, or 
         production site of a company is located. ';

COMMENT ON COLUMN locations.state_province
         IS 'State or Province where an office, warehouse, or production site of a 
         company is located.';

COMMENT ON COLUMN locations.country_id
         IS 'Country where an office, warehouse, or production site of a company is
         located. Foreign key to country_id column of the countries table.';
       

-- *********************************************

COMMENT ON TABLE departments
         IS 'Departments table that shows details of departments where employees 
         work. Contains 27 rows; references with locations, employees, and job_history tables.';

COMMENT ON COLUMN departments.department_id
         IS 'Primary key column of departments table.';

COMMENT ON COLUMN departments.department_name
         IS 'A not null column that shows name of a department. Administration, 
         Marketing, Purchasing, Human Resources, Shipping, IT, Executive, Public 
         Relations, Sales, Finance, and Accounting. ';

COMMENT ON COLUMN departments.manager_id
         IS 'Manager_id of a department. Foreign key to employee_id column of employees table. The manager_id column of the employee table references this column.';

COMMENT ON COLUMN departments.location_id
         IS 'Location id where a department is located. Foreign key to location_id column of locations table.';
       

-- *********************************************

COMMENT ON TABLE job_history
         IS 'Table that stores job history of the employees. If an employee 
         changes departments within the job or changes jobs within the department, 
         new rows get inserted into this table with old job information of the 
         employee. Contains a complex primary key: employee_id+start_date.
         Contains 25 rows. References with jobs, employees, and departments tables.';

COMMENT ON COLUMN job_history.employee_id
         IS 'A not null column in the complex primary key employee_id+start_date.
         Foreign key to employee_id column of the employee table';

COMMENT ON COLUMN job_history.start_date
         IS 'A not null column in the complex primary key employee_id+start_date. 
         Must be less than the end_date of the job_history table. (enforced by 
         constraint jhist_date_interval)';

COMMENT ON COLUMN job_history.end_date
         IS 'Last day of the employee in this job role. A not null column. Must be 
         greater than the start_date of the job_history table. 
         (enforced by constraint jhist_date_interval)';

COMMENT ON COLUMN job_history.job_id
         IS 'Job role in which the employee worked in the past; foreign key to 
         job_id column in the jobs table. A not null column.';

COMMENT ON COLUMN job_history.department_id
         IS 'Department id in which the employee worked in the past; foreign key to deparment_id column in the departments table';
       

-- *********************************************

COMMENT ON TABLE countries
         IS 'country table. Contains 25 rows. References with locations table.';

COMMENT ON COLUMN countries.country_id
         IS 'Primary key of countries table.';

COMMENT ON COLUMN countries.country_name
         IS 'Country name';

COMMENT ON COLUMN countries.region_id
         IS 'Region ID for the country. Foreign key to region_id column in the departments table.';

-- *********************************************

COMMENT ON TABLE jobs
         IS 'jobs table with job titles and salary ranges. Contains 19 rows.
         References with employees and job_history table.';

COMMENT ON COLUMN jobs.job_id
         IS 'Primary key of jobs table.';

COMMENT ON COLUMN jobs.job_title
         IS 'A not null column that shows job title, e.g. AD_VP, FI_ACCOUNTANT';

COMMENT ON COLUMN jobs.min_salary
         IS 'Minimum salary for a job title.';

COMMENT ON COLUMN jobs.max_salary
         IS 'Maximum salary for a job title';

-- *********************************************

COMMENT ON TABLE employees
         IS 'employees table. Contains 107 rows. References with departments, 
         jobs, job_history tables. Contains a self reference.';

COMMENT ON COLUMN employees.employee_id
         IS 'Primary key of employees table.';

COMMENT ON COLUMN employees.first_name
         IS 'First name of the employee. A not null column.';

COMMENT ON COLUMN employees.last_name
         IS 'Last name of the employee. A not null column.';

COMMENT ON COLUMN employees.email
         IS 'Email id of the employee';

COMMENT ON COLUMN employees.phone_number
         IS 'Phone number of the employee; includes country code and area code';

COMMENT ON COLUMN employees.hire_date
         IS 'Date when the employee started on this job. A not null column.';

COMMENT ON COLUMN employees.job_id
         IS 'Current job of the employee; foreign key to job_id column of the 
         jobs table. A not null column.';

COMMENT ON COLUMN employees.salary
         IS 'Monthly salary of the employee. Must be greater 
         than zero (enforced by constraint emp_salary_min)';

COMMENT ON COLUMN employees.commission_pct
         IS 'Commission percentage of the employee; Only employees in sales 
         department elgible for commission percentage';

COMMENT ON COLUMN employees.manager_id
         IS 'Manager id of the employee; has same domain as manager_id in 
         departments table. Foreign key to employee_id column of employees table.
         (useful for reflexive joins and CONNECT BY query)';

COMMENT ON COLUMN employees.department_id
         IS 'Department id where employee works; foreign key to department_id 
         column of the departments table';

-- *********************************************

COMMENT ON TABLE consultants
         IS 'consultants table. Contains 16 rows. References with departments, 
         jobs, employees tables.';

COMMENT ON COLUMN consultants.consultant_id
         IS 'Primary key of consultants table.';

COMMENT ON COLUMN consultants.first_name
         IS 'First name of the consultant. A not null column.';

COMMENT ON COLUMN consultants.last_name
         IS 'Last name of the consultant. A not null column.';

COMMENT ON COLUMN consultants.email
         IS 'Email id of the consultant';

COMMENT ON COLUMN consultants.phone_number
         IS 'Phone number of the consultant; includes country code and area code';

COMMENT ON COLUMN consultants.hire_date
         IS 'Date when the consultant started this job. A not null column.';

COMMENT ON COLUMN consultants.job_id
         IS 'Current job of the consultant; foreign key to job_id column of the 
         jobs table. A not null column.';

COMMENT ON COLUMN consultants.salary
         IS 'Monthly salary of the consultant. Must be greater 
         than zero (enforced by constraint cons_salary_min)';

COMMENT ON COLUMN consultants.commission_pct
         IS 'Commission percentage of the consultant; Only employees in sales 
         department elgible for commission percentage';

COMMENT ON COLUMN consultants.manager_id
         IS 'Manager id of the consultant; has same domain as manager_id in 
         departments table. Foreign key to employee_id column of employees table.';

COMMENT ON COLUMN consultants.department_id
         IS 'Department id where consultant works; foreign key to department_id 
         column of the departments table';


-- *********************************************

COMMENT ON TABLE sal_grades
         IS 'sal_grades table. Contains 6 rows. Does not reference any other
                tables.';

COMMENT ON COLUMN sal_grades.grade_level
         IS 'Primary key of sal_grades table.';

COMMENT ON COLUMN sal_grades.lowest_sal
         IS 'Lowest salary in the grade range. A not null column.';

COMMENT ON COLUMN sal_grades.highest_sal
         IS 'Highest salary in the grade range. A not null column.';

-------------------------------------------------------------------------------------------
-- ************** CUSTOMERS AND SALES TABLES ***********************
--The following tables provide transactional data:

DROP TABLE sales PURGE;
DROP TABLE customers PURGE;

CREATE TABLE customers
 (
 cust_id    NUMBER(6) GENERATED AS IDENTITY (START WITH 2 INCREMENT BY 2)
                CONSTRAINT cust_id_pk PRIMARY KEY,
 cust_email       VARCHAR2(30) NOT NULL CONSTRAINT cust_email_uk UNIQUE,
 cust_fname       VARCHAR2(20) NOT NULL,
 cust_lname       VARCHAR2(20) NOT NULL,
 cust_address     VARCHAR2(50) NOT NULL,
 cust_city        VARCHAR2(50) NOT NULL,
 cust_state_province CHAR(2),
 cust_postal_code VARCHAR2(20)        ,
 cust_country     VARCHAR2(20) NOT NULL,
 cust_phone       VARCHAR2(20) NOT NULL ,
 cust_credit_limit  NUMBER(11,2) DEFAULT 1000
               CONSTRAINT cust_credit_limit_ck  CHECK(cust_credit_limit > 0)
  );
 
CREATE Table sales
(
 sales_id       	NUMBER(12) GENERATED AS IDENTITY 
						CONSTRAINT sales_id_pk PRIMARY KEY,
 sales_timestamp    TIMESTAMP NOT NULL,
 sales_amt    		NUMBER(8,2),
 sales_cust_id  	NUMBER(6) CONSTRAINT sales_cust_id_fk REFERENCES customers(cust_id),
 sales_rep_id   	NUMBER(6) CONSTRAINT sales_rep_id_fk REFERENCES employees(employee_id)
 );
 
--------------------------------------------------------------------------------       
 
 INSERT INTO CUSTOMERS(cust_email, cust_fname, cust_lname, cust_address, cust_city,
    cust_state_province, cust_postal_code, cust_country, cust_phone, cust_credit_limit)
  VALUES('bjayne@shu.edu', 'Bill', 'Jayne', '52 Main St.', 'Madison', 'NJ', '07940',
          'US', '+1 973 555 1212', 2000.99);
 INSERT INTO CUSTOMERS(cust_email, cust_fname, cust_lname, cust_address, cust_city,
    cust_state_province, cust_postal_code, cust_country, cust_phone, cust_credit_limit)
  VALUES('aoconnell@aol.com', 'Audrey', 'O''Connell', '15 W. Park St.', 'Butte', 'MT', '57911',
          'US', '+1 406 555 1212', 2200); 
 INSERT INTO CUSTOMERS(cust_email, cust_fname, cust_lname, cust_address, cust_city,
     cust_postal_code, cust_country, cust_phone, cust_credit_limit)
  VALUES('efrey@vodafone.net', 'Evelyn', 'Frey', '17 Brooksby St.', 'London', 'N1 1HE',
          'GB', '+44 020 755 1212', 1800.50);
 INSERT INTO CUSTOMERS(cust_email, cust_fname, cust_lname, cust_address, cust_city,
    cust_state_province, cust_postal_code, cust_country, cust_phone, cust_credit_limit)
  VALUES('dtone@abc.com', 'Deborah', 'Tone', '234 Beverley St.', 'Winnipeg', 'MB', 'R3G 1T6',
          'CA', '+1 204 555 1212', 2000); 
 INSERT INTO CUSTOMERS(cust_email, cust_fname, cust_lname, cust_address, cust_city,
    cust_state_province, cust_postal_code, cust_country, cust_phone, cust_credit_limit)
  VALUES('fterziotti@alitalia.com', 'Fabio', 'Terziotti', '72 Via Belviglieri', 'Verona', 'VR', '37131',
          'IT', '+39 045 555 1212', 5000);
 INSERT INTO CUSTOMERS(cust_email, cust_fname, cust_lname, cust_address, cust_city,
    cust_postal_code, cust_country, cust_phone, cust_credit_limit)
  VALUES('eikeloa@bluebird.net', 'Emanuel', 'Ikeloa', '745 Agbe Rd.', 'Lagos', '100212',
          'NG', '+234 1 555 1212', 2300); 
 INSERT INTO CUSTOMERS(cust_email, cust_fname, cust_lname, cust_address, cust_city,
      cust_country, cust_phone, cust_credit_limit)
  VALUES('chenliu@bochk.com', 'Chen', 'Liu', '39 Dai Shing St.', 'Wan Chai',
          'HK', '+852 2555 1212', 2300);
 INSERT INTO CUSTOMERS(cust_email, cust_fname, cust_lname, cust_address, cust_city,
    cust_state_province, cust_postal_code, cust_country, cust_phone, cust_credit_limit)
  VALUES('alotero@caracol.co', 'Andres', 'Lotero', '405 Carrera 93', 'Bogota', 'DC', '110721',
          'CO', '+57 300 794 5529', 3600); 
 INSERT INTO CUSTOMERS(cust_email, cust_fname, cust_lname, cust_address, cust_city,
    cust_postal_code, cust_country, cust_phone, cust_credit_limit)
  VALUES('gong.li@uobgroup.com', 'Gong', 'Li', '42 Cambridge Rd.', 'Cambridge', '219687',
          'SG', '+65 973 555 1212', 3500);
 INSERT INTO CUSTOMERS(cust_email, cust_fname, cust_lname, cust_address, cust_city,
    cust_state_province, cust_postal_code, cust_country, cust_phone, cust_credit_limit)
  VALUES('sganesan@abanoffshore.com', 'Shivaji', 'Ganesan', '15 Adithanar Rd.', 'Chennai', 'TN', '600 018',
          'IN', '+91 406 555 1212', 2800); 


-------------------------------------------------------------------------------------------  		  
-- Insert data into the sales table:		  
              
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '936' hour, 483.92, 2, 176);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '865' hour, 123.45, 8, 150); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '71' hour, 9374.61, 12, 163);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '746' hour, 492.58, 10, 176);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '39' hour, 104.93, 18, 164); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '840' hour, 808.73, 16, 174);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '583' hour, 938.65, 14, 170);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '291' hour, 274.98, 16, 176);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '82' hour, 2483.76, 10, 152); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '49' hour, 3781.39, 16, 174); 
    
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '485' hour, 33.13, 10, 168);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '36' hour, 789.34, 18, 156); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '19' hour, 4958.36, 12, 170);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '26' hour, 6028.38, 16, 153);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '623' hour, 9024.30, 8, 178); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '698' hour, 430.73, 10, 159);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '294' hour, 329.65, 14, 163);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '409' hour, 215.98, 4, 158);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '51' hour, 293.76, 2, 174); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '39' hour, 4381.39, 16, 170); 


 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '45' hour, 343.13, 16, 160);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '376' hour, 8279.16, 8, 162); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '194' hour, 5829.47, 12, 151);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '260' hour, 9375.27, 2, 154);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '23' hour, 914.30, 4, 168); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '98' hour, 573.82, 18, 166);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '29' hour, 319.65, 10, 169);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '49' hour, 695.89, 16, 164);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '534' hour, 259.76, 10, 157); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '389' hour, 2367.82, 18, 170); 


  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '295' hour, 463.31, 16, 152);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '626' hour, 7589.34, 2, 165); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '54' hour, 3052.42, 16, 151);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '22' hour, 6828.38, 10, 154);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '271' hour, 739.51, 14, 171); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '918' hour, 590.73, 8, 177);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '38' hour, 639.27, 10, 175);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '41' hour, 965.98, 4, 152);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '92' hour, 769.52, 8, 172); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '47' hour, 4211.39, 2, 177); 

INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '72' hour, 5293.46, 16, 150);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '825' hour, 4385.97, 8, 175); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '92' hour, 2937.28, 10, 152);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '17' hour, 3948.88, 10, 159);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '647' hour, 992.45, 14, 160); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '175' hour, 917.38, 16, 157);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '28' hour, 723.85, 4, 159);  
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '73' hour, 826.42, 16, 156);
 INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '412' hour, 259.34, 8, 172); 
  INSERT INTO sales(sales_timestamp, sales_amt, sales_cust_id, sales_rep_id)
    VALUES(LOCALTIMESTAMP - interval '463' hour, 611.31, 12, 158); 
  
  COMMIT;