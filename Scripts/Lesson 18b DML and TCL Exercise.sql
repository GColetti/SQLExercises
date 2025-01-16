--Practice Data Manupulation Language and Transaction Control Language

-- 1) Run the create table statement below to create the my_employee table:

     CREATE TABLE my_employee
      (
        id NUMBER(3) CONSTRAINT my_employee_id_pk primary key,
        last_name   VARCHAR2(15)  NOT NULL,
        first_name  VARCHAR2(15) NOT NULL,
        userid      VARCHAR2(8)      NOT NULL,
        salary      NUMBER(7,2) CONSTRAINT my_employee_salary_ck 
                      CHECK(salary > 0)
      );  
	  
  
-- 2) Describe the structure of the my_employee table.

     
	 
      
/* 3) Write an insert statement to add the FIRST ROW of data in the my_employee
      table from the following grid. Do not list the columns in the INSERT
      statement.
     ---------------------------------------------------------------------
     | ID  |  LAST_NAME    |   FIRST_NAME   |    USERID    |    SALARY   |
     ---------------------------------------------------------------------
     | 1   |  de Champlain |     Samuel     |    sdechamp  |     1608    |
     | 2   |  Ross         |     Betsy      |    bross     |     960     |
     | 3   |  Alexander    |     Mackenzie  |    amackenz  |     1793    |
     | 4   |  Madison      |     Dolly      |    dmadison  |     1817    |
     | 5   |  Lincoln      |     Abraham    |    alincoln  |     1865    |
     ---------------------------------------------------------------------
 */
      
	  
         
         
/* 4) Populate the my_employee table with the second row of the sample data.
        This time, list the columns explicitly in the INSERT. */  
      
       
      
	  
-- 5) Confirm your additions to the table.
      
    
	
      
 /* 6) Write a dynamic, reusable INSERT to load data into the 
      my_employee table. The script should prompt the user for a value for each 
      of the five columns: id, last_name, first_name, userid, salary. Populate 
      the my_employee table with the next TWO rows of data using the 
      reusable INSERT. */   
      
     
	 
      
-- 7) Confirm your additions to the table.

      
	  

-- 8) Make the additions permanent.

           
		   

-- 9) Change the last name of employee 3 to Owens. Change the userid accordingly.



      
-- 10) Change the salary to $1000 for all employees earning less than $1000.

     
	 
 
-- 11) Verify your changes are correct.

      
	  
      
-- 12) Delete Samuel de Champlain from the my_employee table.
       
      

	  
-- 13) Verify your change.

      
	  
      
-- 14) Make all pending changes permanent.


     
      
/* 15) Populate my_employee with the last row of sample data using the reusable 
      insert you created in step 6.  
	   ---------------------------------------------------------        
       |  ID  | last_name    |  first_name    |    userid    |  salary  |
       ---------------------------------------------------------
	   |  5   |  Lincoln     |     Abraham    |    alincoln  |   1865   |    */

      
	  
      
-- 16) Confirm your addition to the table.

     
	 
        
-- 17) Create an intermediate point in your transaction.

      
	  
           
-- 18) Delete all rows in the my_employee table.

        
		
                  
-- 19) Confirm the table is empty.

      
	  
      
-- 20) Discard the recent delete operation without discarding the insert before it.
  
  
      
            
-- 21) Confirm the rows are in the table.


      
-- 22) Make the data changes permanent.
  
      
        
		
/* 23) Modify the reusable insert created in step 6, so the userid value is 
        automatically generated by concatenating the first letter of the first 
        name and the first seven letters of the last name. The userid must be 
        in lower case, and the user should not be prompted to provide a userid. */
        
      I
	  
        
/* 24) Run the reusable insert to add the following row:
        ---------------------------------------------------------        
        |  ID  | last_name  |  first_name  | userid  |  salary  |
        ---------------------------------------------------------
        |  6   | Washington |  George      | gwashing|   1789   |
        ---------------------------------------------------------
*/
        
		
      
        
-- 25) Verify the new row was added.
      
            
			
             
-- 26) Make the addition permanent.

     
	 
           