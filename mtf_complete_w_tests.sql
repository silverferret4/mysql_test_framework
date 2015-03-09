#
# SQL Export
# Created by Querious (957)
# Created: March 9, 2015 at 6:07:21 PM CDT
# Encoding: Unicode (UTF-8)
#


DROP TABLE IF EXISTS `mtf_version`;
DROP TABLE IF EXISTS `mtf_result`;
DROP TABLE IF EXISTS `mtf_info`;


CREATE TABLE `mtf_info` (
  `info_id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(128) DEFAULT NULL COMMENT 'Type of the object that data is being stored about.  This coud be table, procedure, function, or something custom.',
  `name` varchar(128) NOT NULL DEFAULT '' COMMENT 'Name of the object data is being stored about.',
  `attr` varchar(128) DEFAULT NULL COMMENT 'Attribute.  This describes what the value stored in this record represents.  Examples: record count, id, etc.',
  `str_val` varchar(128) DEFAULT NULL COMMENT 'Value (if a string) of this record is stored here.',
  `num_val` int(128) DEFAULT NULL COMMENT 'Value (if numeric) of this record is stored here.',
  `create_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modify_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`info_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `mtf_result` (
  `result_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL DEFAULT '' COMMENT 'Name of the test.',
  `description` varchar(128) DEFAULT NULL COMMENT 'Description of the test.',
  `status` char(4) NOT NULL DEFAULT '' COMMENT 'Status of the test.  Will either be PASS or FAIL.',
  `message` varchar(256) DEFAULT NULL COMMENT 'Comment field used for additional information that might be useful for debugging.',
  `create_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modify_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`result_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `mtf_version` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `major` int(128) NOT NULL DEFAULT '0',
  `minor` varchar(128) NOT NULL DEFAULT '',
  `comment` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;




DROP PROCEDURE IF EXISTS `mtf_test_suite_self`;
DROP PROCEDURE IF EXISTS `mtf_test_sp_str_not_equal`;
DROP PROCEDURE IF EXISTS `mtf_test_sp_str_equal`;
DROP PROCEDURE IF EXISTS `mtf_test_sp_num_not_equal`;
DROP PROCEDURE IF EXISTS `mtf_test_sp_num_equal`;
DROP PROCEDURE IF EXISTS `mtf_test_sp_get_info_str`;
DROP PROCEDURE IF EXISTS `mtf_test_sp_get_info_num`;
DROP PROCEDURE IF EXISTS `mtf_test_sp_create_result`;
DROP PROCEDURE IF EXISTS `mtf_test_sp_create_info`;
DROP PROCEDURE IF EXISTS `mtf_template_test`;
DROP PROCEDURE IF EXISTS `mtf_sp_str_not_equal`;
DROP PROCEDURE IF EXISTS `mtf_sp_str_equal`;
DROP PROCEDURE IF EXISTS `mtf_sp_reset`;
DROP PROCEDURE IF EXISTS `mtf_sp_num_not_equal`;
DROP PROCEDURE IF EXISTS `mtf_sp_num_equal`;
DROP PROCEDURE IF EXISTS `mtf_sp_get_info_str`;
DROP PROCEDURE IF EXISTS `mtf_sp_get_info_num`;
DROP PROCEDURE IF EXISTS `mtf_sp_create_result`;
DROP PROCEDURE IF EXISTS `mtf_sp_create_info`;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_sp_create_info`(IN p_type varchar(128), IN p_name varchar(128), IN p_attr varchar(128), IN p_str_val varchar(128), IN p_num_val int)
    DETERMINISTIC
    COMMENT 'Logging Procedure: Used to write information into the mtf_info table.'
BEGIN

	-- Insert a record.
	INSERT INTO	mtf_info (
		type,
		name,
		attr,
		str_val,
		num_val
	)
	VALUES (
		p_type,
		p_name,
		p_attr,
		p_str_val,
		p_num_val
	);
		
#	Currently no reason to return the ID on a created record.  And it is annoying
# to continually have to add a generic OUT parameter.
#
#	If this changes in the future, add this ", OUT p_info_id int" to the parameters
# and uncomment the following two lines:

#	-- Return the _id of the newly created record.
#	SET p_info_id = LAST_INSERT_ID();	

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_sp_create_result`(IN p_name varchar(128), IN p_description varchar(128), IN p_status char(4), IN p_message varchar(256))
    DETERMINISTIC
    COMMENT 'Logging Procedure: Used to write information into the mtf_result table.'
BEGIN

	-- Insert a record.
	INSERT INTO	mtf_result (
		name,
		description,
		status,
		message
	)
	VALUES (
		p_name,
		p_description,
		p_status,
		p_message
	);
		
#	Currently no reason to return the ID on a created record.  And it is annoying
# to continually have to add a generic OUT parameter.
#
#	If this changes in the future, add this ", OUT p_result_id int" to the parameters
# and uncomment the following two lines:

#	-- Return the _id of the newly created record.
#	SET p_result_id = LAST_INSERT_ID();	

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_sp_get_info_num`(IN p_type varchar(128), IN p_name varchar(128), IN p_attr varchar(128), OUT p_num_val varchar(128))
    DETERMINISTIC
    COMMENT 'Utility Procedure: Used to retrieve a number value that was stored in the mtf_info table.'
BEGIN

	-- Clearing variable before use because in testing this was holding value between calls.
	SET @num_val = null;
	
	-- Because type and attr can be null, we need to build up a where clause and 
	-- execute dynamically.
	SET @select_clause = 'SELECT num_val INTO @num_val FROM mtf_info ';
	
	IF ISNULL(p_type) THEN
		SET @type_clause = 'WHERE type IS NULL ';
	ELSE
		SET @type_clause = CONCAT('WHERE type = ', QUOTE(p_type),' ');
	END IF;
	
	SET @name_clause = CONCAT('AND name = ', QUOTE(p_name),' ');
	
	IF ISNULL(p_attr) THEN
		SET @attr_clause = 'AND attr IS NULL ';
	ELSE
		SET @attr_clause = CONCAT('AND attr = ', QUOTE(p_attr),' ');
	END IF;	
	
	SET @limit_clause = 'LIMIT 1;';
	
	
	-- Prepare the statement and then execute.
	SET @s = CONCAT(@select_clause, @type_clause, @name_clause, @attr_clause, @limit_clause);
	PREPARE stmt1 FROM @s;
	EXECUTE stmt1;


	-- Set the value of the OUT variable.
	SET p_num_val = @num_val;
	
	
	-- Deallocate the prepared statement.
	DEALLOCATE PREPARE stmt1;	

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_sp_get_info_str`(IN p_type varchar(128), IN p_name varchar(128), IN p_attr varchar(128), OUT p_str_val varchar(128))
    DETERMINISTIC
    COMMENT 'Utility Procedure: Used to retrieve a string value that was stored in the mtf_info table.'
BEGIN
	
	-- Clearing variable before use because in testing this was holding value between calls.
	SET @str_val = null;
	
	-- Because type and attr can be null, we need to build up a where clause and 
	-- execute dynamically.
	SET @select_clause = 'SELECT str_val INTO @str_val FROM mtf_info ';
	
	IF ISNULL(p_type) THEN
		SET @type_clause = 'WHERE type IS NULL ';
	ELSE
		SET @type_clause = CONCAT('WHERE type = ', QUOTE(p_type),' ');
	END IF;
	
	SET @name_clause = CONCAT('AND name = ', QUOTE(p_name),' ');
	
	IF ISNULL(p_attr) THEN
		SET @attr_clause = 'AND attr IS NULL ';
	ELSE
		SET @attr_clause = CONCAT('AND attr = ', QUOTE(p_attr),' ');
	END IF;	
	
	SET @limit_clause = 'LIMIT 1;';
	
	
	-- Prepare the statement and then execute.
	SET @s = CONCAT(@select_clause, @type_clause, @name_clause, @attr_clause, @limit_clause);
	PREPARE stmt1 FROM @s;
	EXECUTE stmt1;


	-- Set the value of the OUT variable.
	SET p_str_val = @str_val;
	
	
	-- Deallocate the prepared statement.
	DEALLOCATE PREPARE stmt1;	

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_sp_num_equal`(IN p_num_1 int, IN p_num_2 int, OUT p_status char(4))
    DETERMINISTIC
    COMMENT 'Comparison Procedure:  Returns PASS if numbers being compared are equal, else FAIL.'
BEGIN

	IF (IFNULL(p_num_1, 0) = IFNULL(p_num_2, 0)) THEN
		SET p_status = 'PASS';
	ELSE
		SET p_status = 'FAIL';
	END IF;

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_sp_num_not_equal`(IN p_num_1 int, IN p_num_2 int, OUT p_status char(4))
    DETERMINISTIC
    COMMENT 'Comparison Procedure:  Returns PASS if numbers being compared are not equal, else FAIL.'
BEGIN

	IF (IFNULL(p_num_1, 0) <> IFNULL(p_num_2, 0)) THEN
		SET p_status = 'PASS';
	ELSE
		SET p_status = 'FAIL';
	END IF;

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_sp_reset`()
    DETERMINISTIC
    COMMENT 'Procedure used to reset tables in mtf.  Note: Still preserves version information in mtf_version.'
BEGIN

	DELETE FROM mtf_info;
	DELETE FROM mtf_result;
	ALTER TABLE mtf_info AUTO_INCREMENT = 1;
	ALTER TABLE mtf_result AUTO_INCREMENT = 1;

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_sp_str_equal`(IN p_str_1 varchar(128), IN p_str_2 varchar(128), OUT p_status char(4))
    DETERMINISTIC
    COMMENT 'Comparison Procedure:  Returns PASS if strings being compared are equal, else FAIL.'
BEGIN

	IF (IFNULL(p_str_1,'') = IFNULL(p_str_2,'')) THEN
		SET p_status = 'PASS';
	ELSE
		SET p_status = 'FAIL';
	END IF;

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_sp_str_not_equal`(IN p_str_1 varchar(128), IN p_str_2 varchar(128), OUT p_status char(4))
    DETERMINISTIC
    COMMENT 'Comparison Procedure:  Returns PASS if strings being compared are not equal, else FAIL.'
BEGIN

	IF (IFNULL(p_str_1,'') <> IFNULL(p_str_2,'')) THEN
		SET p_status = 'PASS';
	ELSE
		SET p_status = 'FAIL';
	END IF;

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_template_test`()
    DETERMINISTIC
    COMMENT 'This procedure is meant as a template to be used as the basis for all tests that are written.'
BEGIN
	
	/**
	*	By using HANDLERs we are able to simply raise 'errors' in our tests to be able to log results.
	* This is particularly useful because it provides a consistent mechanism that we can use for custom
	* messages, as well as a 'catch-all' that will also handle any unexpected database errors that
	* occur (which would by definition result in a FAIL of the test).
	*
	* Documentation / Props:
	*		- MySQL HANDLER documentation:		http://dev.mysql.com/doc/refman/5.5/en/handler.html
	*		- MySQL SIGNAL documentation:			http://dev.mysql.com/doc/refman/5.5/en/signal.html
	*				Important: Setting SQL_ERR to start with '01' (Warning) otherwise SQLEXCEPTION handler is also triggered.
	*		- Example of HANDLER usage:				http://www.mysqltutorial.org/mysql-error-handling-in-stored-procedures/
	*   - Example of SIGNAL usage:				http://stackoverflow.com/questions/465727/how-to-raise-an-error-within-a-mysql-function
	*   - Buildup of @full_error:					https://mariadb.com/blog/improve-your-stored-procedure-error-handling-get-diagnostics
	*
	**/
	
	/**
	*	IMPORTANT NOTE:
	*	The test for this stored procedure is slightly different than others.  That is because this stored procedure is 
	* used in the HANDLERs for every other test.  However, if there is something wrong with this procedure, we cannot
	* use it to write information into the results table.  Instead, we need to use a SQL INSERT statement on any error.
	*
	*/


		
#----------------------------------------------
	-- HANDLERS
	
	DECLARE test_fail CONDITION FOR SQLSTATE '01990';
	DECLARE test_critical CONDITION FOR SQLSTATE '01991';
	DECLARE test_pass CONDITION FOR SQLSTATE '01992';
	
	/** 
	*	IMPORTANT NOTE:  Need to use the prefix '01' on each of the SQLSTATE codes because
	* MySQL classifies those as Warnings.  If I use a different value, and it interprets
	* the SQLSTATE as an exception, then our final 'catch-all' handler (which is an EXIT)
	* will also get called and prevent continued execution.
	*
	**/ 
		
	-- Catches custom FAIL messages but allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_fail
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom CRITICAL messages and stops processing.
	DECLARE CONTINUE HANDLER FOR test_critical
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		SET @message = CONCAT("CRITICAL: ", IFNULL(@text,'Unknown'));
		ROLLBACK;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom PASS messages.  Allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_pass
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN;
		CALL mtf_sp_create_result(@c_name, @description, @c_pass, '');
	END;

	-- Catches any other SQLEXCEPTION.  These will halt further testing.
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("DATABASE ERROR ", @errno, " (", @sqlstate, "): ", IFNULL(@text,'Unknown'));	
		ROLLBACK;
		CALL mtf_sp_create_result(@c_name, '', @c_fail, @full_error);
	END;


		
#----------------------------------------------	
	-- CONSTANT VARIABLES (prefix with @c_)
	SET @c_name = '';
	SET @c_fail = 'FAIL';
	SET @c_pass = 'PASS';
	
	
#----------------------------------------------	
	-- TEST DATA (prefix with @t_)
	
	-- Test 1
	SET @t_test_1_description = '...';
	SET @t_example_1 = '...';
	
	
	-- Test 2
	SET @t_test_2_description = '...';
	SET @t_example_2 = '...';
	
	
	
#----------------------------------------------
-- TESTS

	START TRANSACTION;  -- Only needed if you want to remove the test data.  Otherwise leave commented.



#----------------------------------------------	
	-- TEST 1
#	Perform test here...
	
# Perform validation that it worked here...

 
    
    
#----------------------------------------------	
	ROLLBACK;  -- Only needed if you wish to remove the tests data.  Otherwise leave commented.



#----------------------------------------------	
-- RESULTS

#	Write the results out here.
		
					
											
	/**
	*	EXAMPLE: Raise a custom error
	*
	*	SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_critical SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_description;
	*
	*/

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_test_sp_create_info`()
    DETERMINISTIC
    COMMENT 'Test for the stored procedure mtf_sp_create_info.'
BEGIN
	
	/**
	*	By using HANDLERs we are able to simply raise 'errors' in our tests to be able to log results.
	* This is particularly useful because it provides a consistent mechanism that we can use for custom
	* messages, as well as a 'catch-all' that will also handle any unexpected database errors that
	* occur (which would by definition result in a FAIL of the test).
	*
	* Documentation / Props:
	*		- MySQL HANDLER documentation:		http://dev.mysql.com/doc/refman/5.5/en/handler.html
	*		- MySQL SIGNAL documentation:			http://dev.mysql.com/doc/refman/5.5/en/signal.html
	*				Important: Setting SQL_ERR to start with '01' (Warning) otherwise SQLEXCEPTION handler is also triggered.
	*		- Example of HANDLER usage:				http://www.mysqltutorial.org/mysql-error-handling-in-stored-procedures/
	*   - Example of SIGNAL usage:				http://stackoverflow.com/questions/465727/how-to-raise-an-error-within-a-mysql-function
	*   - Buildup of @full_error:					https://mariadb.com/blog/improve-your-stored-procedure-error-handling-get-diagnostics
	*
	**/


		
#----------------------------------------------
	-- HANDLERS
	
	DECLARE test_fail CONDITION FOR SQLSTATE '01990';
	DECLARE test_critical CONDITION FOR SQLSTATE '01991';
	DECLARE test_pass CONDITION FOR SQLSTATE '01992';
	
	/** 
	*	IMPORTANT NOTE:  Need to use the prefix '01' on each of the SQLSTATE codes because
	* MySQL classifies those as Warnings.  If I use a different value, and it interprets
	* the SQLSTATE as an exception, then our final 'catch-all' handler (which is an EXIT)
	* will also get called and prevent continued execution.
	*
	**/ 
	
	-- Catches custom FAIL messages but allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_fail
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom CRITICAL messages and stops processing.
	DECLARE CONTINUE HANDLER FOR test_critical
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		SET @message = CONCAT("CRITICAL: ", IFNULL(@text,'Unknown'));
		ROLLBACK;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom PASS messages.  Allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_pass
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN;
		CALL mtf_sp_create_result(@c_name, @description, @c_pass, '');
	END;

	-- Catches any other SQLEXCEPTION.  These will halt further testing.
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("DATABASE ERROR ", @errno, " (", @sqlstate, "): ", IFNULL(@text,'Unknown'));	
		ROLLBACK;
		CALL mtf_sp_create_result(@c_name, '', @c_fail, @full_error);
	END;

	
	
#----------------------------------------------	
	-- CONSTANT VARIABLES (prefix with @c_)
	SET @c_name = 'mtf_sp_create_info';
	SET @c_fail = 'FAIL';
	SET @c_pass = 'PASS';
	
	
#----------------------------------------------	
	-- TEST DATA (prefix with @t_)
	
	-- Test 1
	SET @t_test_1_description = 'Insert with any nullable fields set to null.';
	SET @t_type_1 = null;
	SET @t_name_1 = 'mtf_sp_create_info';
	SET @t_attr_1 = null;
	SET @t_str_val_1 = null;
	SET @t_num_val_1 = null;
	
	-- Test 2
	SET @t_test_2_description = 'Insert with all fields set to a value.';
	SET @t_type_2 = 'procedure';
	SET @t_name_2 = 'mtf_sp_create_info';
	SET @t_attr_2 = 'attr';
	SET @t_str_val_2 = 'str_val';
	SET @t_num_val_2 = 'num_val';
	
	
	
#----------------------------------------------
-- TESTS

	START TRANSACTION;  -- Only needed if you want to remove the test data.  Otherwise leave commented.



#----------------------------------------------	
	-- TEST 1: Insert with any nullable fields set to null.
	CALL mtf_sp_create_info(@t_type_1, @t_name_1, @t_attr_1, @t_str_val_1, @t_num_val_1);
	
	-- Now validate that a record matching these values exist.
	SELECT	count(*)
	INTO		@test_1_count
	FROM		mtf_info
	WHERE		type IS NULL
	AND			name = @t_name_1
	AND			attr IS NULL
	AND			str_val IS NULL
	AND			num_val IS NULL;
	
#----------------------------------------------	
	-- Test 2: Insert with all fields set to a value.
	CALL mtf_sp_create_info(@t_type_2, @t_name_2, @t_attr_2, @t_str_val_2, @t_num_val_2);
	
	-- Now validate that a record matching these values exist.
	SELECT	count(*)
	INTO		@test_2_count
	FROM		mtf_info
	WHERE		type = @t_type_2
	AND			name = @t_name_2
	AND			attr = @t_attr_2
	AND			str_val = @t_str_val_2
	AND			num_val = @t_num_val_2;

 
    
    
#----------------------------------------------	
	ROLLBACK;  -- Only needed if you wish to remove the tests data.  Otherwise leave commented.



#----------------------------------------------	
-- RESULTS

	IF @test_1_count <> 1 THEN
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_1_description, MESSAGE_TEXT = 'Not all expected values match what was inserted.';
	ELSE
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_1_description;
	END IF;
	
	IF @test_2_count <> 1 THEN
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_1_description, MESSAGE_TEXT = 'Not all expected values match what was inserted.';
	ELSE
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_2_description;
	END IF;
		
					
											
	/**
	*	EXAMPLE: Raise a custom error
	*
	*	SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_critical SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_description;
	*
	*/

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_test_sp_create_result`()
    DETERMINISTIC
    COMMENT 'Test for the stored procedure mtf_sp_create_result.'
BEGIN
	
	/**
	*	By using HANDLERs we are able to simply raise 'errors' in our tests to be able to log results.
	* This is particularly useful because it provides a consistent mechanism that we can use for custom
	* messages, as well as a 'catch-all' that will also handle any unexpected database errors that
	* occur (which would by definition result in a FAIL of the test).
	*
	* Documentation / Props:
	*		- MySQL HANDLER documentation:		http://dev.mysql.com/doc/refman/5.5/en/handler.html
	*		- MySQL SIGNAL documentation:			http://dev.mysql.com/doc/refman/5.5/en/signal.html
	*				Important: Setting SQL_ERR to start with '01' (Warning) otherwise SQLEXCEPTION handler is also triggered.
	*		- Example of HANDLER usage:				http://www.mysqltutorial.org/mysql-error-handling-in-stored-procedures/
	*   - Example of SIGNAL usage:				http://stackoverflow.com/questions/465727/how-to-raise-an-error-within-a-mysql-function
	*   - Buildup of @full_error:					https://mariadb.com/blog/improve-your-stored-procedure-error-handling-get-diagnostics
	*
	**/
	
	/**
	*	IMPORTANT NOTE:
	*	The test for this stored procedure is slightly different than others.  That is because this stored procedure is 
	* used in the HANDLERs for every other test.  However, if there is something wrong with this procedure, we cannot
	* use it to write information into the results table.  Instead, we need to use a SQL INSERT statement on any error.
	*
	*/


		
#----------------------------------------------
	-- HANDLERS
	
	DECLARE test_fail CONDITION FOR SQLSTATE '01990';
	DECLARE test_critical CONDITION FOR SQLSTATE '01991';
	DECLARE test_pass CONDITION FOR SQLSTATE '01992';
		
	/** 
	*	IMPORTANT NOTE:  Need to use the prefix '01' on each of the SQLSTATE codes because
	* MySQL classifies those as Warnings.  If I use a different value, and it interprets
	* the SQLSTATE as an exception, then our final 'catch-all' handler (which is an EXIT)
	* will also get called and prevent continued execution.
	*
	**/ 
	
	-- Catches custom FAIL messages but allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_fail
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom CRITICAL messages and stops processing.
	DECLARE CONTINUE HANDLER FOR test_critical
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		SET @message = CONCAT("CRITICAL: ", IFNULL(@text,'Unknown'));
		ROLLBACK;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom PASS messages.  Allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_pass
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN;
		CALL mtf_sp_create_result(@c_name, @description, @c_pass, '');
	END;

	-- Catches any other SQLEXCEPTION.  These will halt further testing.
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("DATABASE ERROR ", @errno, " (", @sqlstate, "): ", IFNULL(@text,'Unknown'));	
		ROLLBACK;
		CALL mtf_sp_create_result(@c_name, '', @c_fail, @full_error);
	END;
	
	
#----------------------------------------------	
	-- CONSTANT VARIABLES (prefix with @c_)
	SET @c_name = 'mtf_sp_create_result';
	SET @c_fail = 'FAIL';
	SET @c_pass = 'PASS';
	
	
#----------------------------------------------	
	-- TEST DATA (prefix with @t_)
	
	-- Test 1: Insert with any nullable fields set to null.
	SET @t_test_1_description = 'Insert with any nullable fields set to null.';
	SET @t_name_1 = 'mtf_sp_create_result';
	SET @t_description_1 = null;
	SET @t_status_1 = 'FAIL';  -- Testing FAIL status here.
	SET @t_message_1 = null;

	-- Test 2: Insert with all fields set to a value.
	SET @t_test_2_description = 'Insert with all fields set to a value.';
	SET @t_name_2 = 'mtf_sp_create_result';
	SET @t_description_2 = 'description';
	SET @t_status_2 = 'PASS';  -- Testing PASS status here.
	SET @t_message_2 = 'message';
	
	
	
#----------------------------------------------
-- TESTS

	START TRANSACTION;  -- Only needed if you want to remove the test data.  Otherwise leave commented.



#----------------------------------------------	
	-- TEST 1: Insert with any nullable fields set to null.
	CALL mtf_sp_create_result(@t_name_1, @t_description_1, @t_status_1, @t_message_1);
	
	-- Now validate that a record matching these values exist.
	SELECT	count(*)
	INTO		@test_1_count
	FROM		mtf_result
	WHERE		name = @t_name_1
	AND			description IS NULL
	AND			status = @t_status_1
	AND			message IS NULL;

	
			
#----------------------------------------------	
	-- Test 2: Insert with all fields set to a value.
	CALL mtf_sp_create_result(@t_name_2, @t_description_2, @t_status_2, @t_message_2);
	
	-- Now validate that a record matching these values exist.
	SELECT	count(*)
	INTO		@test_2_count
	FROM		mtf_result
	WHERE		name = @t_name_2
	AND			description = @t_description_2
	AND			status = @t_status_2
	AND			message = @t_message_2;
 
    
    
#----------------------------------------------	
	ROLLBACK;  -- Only needed if you wish to remove the tests data.  Otherwise leave commented.



#----------------------------------------------	
-- RESULTS

	IF @test_1_count <> 1 THEN
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_1_description, MESSAGE_TEXT = 'Not all expected values match what was inserted.';
	ELSE
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_1_description;
	END IF;
	
	IF @test_2_count <> 1 THEN
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_1_description, MESSAGE_TEXT = 'Not all expected values match what was inserted.';
	ELSE
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_2_description;
	END IF;
		
					
											
	/**
	*	EXAMPLE: Raise a custom error
	*
	*	SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_critical SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_description;
	*
	*/

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_test_sp_get_info_num`()
    DETERMINISTIC
    COMMENT 'Test for the stored procedure mtf_sp_get_info_num.'
BEGIN
	
	/**
	*	By using HANDLERs we are able to simply raise 'errors' in our tests to be able to log results.
	* This is particularly useful because it provides a consistent mechanism that we can use for custom
	* messages, as well as a 'catch-all' that will also handle any unexpected database errors that
	* occur (which would by definition result in a FAIL of the test).
	*
	* Documentation / Props:
	*		- MySQL HANDLER documentation:		http://dev.mysql.com/doc/refman/5.5/en/handler.html
	*		- MySQL SIGNAL documentation:			http://dev.mysql.com/doc/refman/5.5/en/signal.html
	*				Important: Setting SQL_ERR to start with '01' (Warning) otherwise SQLEXCEPTION handler is also triggered.
	*		- Example of HANDLER usage:				http://www.mysqltutorial.org/mysql-error-handling-in-stored-procedures/
	*   - Example of SIGNAL usage:				http://stackoverflow.com/questions/465727/how-to-raise-an-error-within-a-mysql-function
	*   - Buildup of @full_error:					https://mariadb.com/blog/improve-your-stored-procedure-error-handling-get-diagnostics
	*
	**/


		
#----------------------------------------------
	-- HANDLERS
	
	DECLARE test_fail CONDITION FOR SQLSTATE '01990';
	DECLARE test_critical CONDITION FOR SQLSTATE '01991';
	DECLARE test_pass CONDITION FOR SQLSTATE '01992';
	
	/** 
	*	IMPORTANT NOTE:  Need to use the prefix '01' on each of the SQLSTATE codes because
	* MySQL classifies those as Warnings.  If I use a different value, and it interprets
	* the SQLSTATE as an exception, then our final 'catch-all' handler (which is an EXIT)
	* will also get called and prevent continued execution.
	*
	**/ 
	
	-- Catches custom FAIL messages but allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_fail
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom CRITICAL messages and stops processing.
	DECLARE CONTINUE HANDLER FOR test_critical
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		SET @message = CONCAT("CRITICAL: ", IFNULL(@text,'Unknown'));
		ROLLBACK;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom PASS messages.  Allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_pass
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN;
		CALL mtf_sp_create_result(@c_name, @description, @c_pass, '');
	END;

	-- Catches any other SQLEXCEPTION.  These will halt further testing.
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("DATABASE ERROR ", @errno, " (", @sqlstate, "): ", IFNULL(@text,'Unknown'));	
		ROLLBACK;
		CALL mtf_sp_create_result(@c_name, '', @c_fail, @full_error);
	END;

	
	
#----------------------------------------------	
	-- CONSTANT VARIABLES (prefix with @c_)
	SET @c_name = 'mtf_sp_get_info_num';
	SET @c_fail = 'FAIL';
	SET @c_pass = 'PASS';
	
	
#----------------------------------------------	
	-- TEST DATA (prefix with @t_)
	
	-- Test 1
	SET @t_test_1_description = 'Get value from record no nulls.';
	SET @t_type_1 = 'test 1';
	SET @t_name_1 = 'mtf_sp_get_info_num';
	SET @t_attr_1 = 'attr';
	SET @t_str_val_1 = null;
	SET @t_num_val_1 = 1001;
	
	-- Test 2
	SET @t_test_2_description = 'Get value from info with nulls.';
	SET @t_type_2 = null;
	SET @t_name_2 = 'mtf_sp_get_info_num';
	SET @t_attr_2 = null;
	SET @t_str_val_2 = null;
	SET @t_num_val_2 = 2001;
	
	-- Test 3
	SET @t_test_3_description = 'Get first value from multiple records.';
	SET @t_type_3 = 'test 3';
	SET @t_name_3 = 'mtf_sp_get_info_num';
	SET @t_attr_3  = null;
	SET @t_str_val_3 = null;
	SET @t_num_val_3_1 = 3001;
	SET @t_num_val_3_2 = 3002;
	SET @t_num_val_3_3 = 3003;
	
	-- Test 4
	SET @t_test_4_description = 'Attempt get from non-existent record.';
	SET @t_type_4 = 'test 4';
	SET @t_name_4 = 'mtf_sp_get_info_num';
	SET @t_attr_4  = null;
	SET @t_num_val_4 = 4001;
	
	
	
#----------------------------------------------
-- TESTS

	START TRANSACTION;  -- Only needed if you want to remove the test data.  Otherwise leave commented.



#----------------------------------------------	
	-- TEST 1: Get value from record no nulls.
	-- Insert test data, then immediately retrieve it using procedure we are testing.
	CALL mtf_sp_create_info(@t_type_1, @t_name_1, @t_attr_1, @t_str_val_1, @t_num_val_1);
	CALL mtf_sp_get_info_num(@t_type_1, @t_name_1, @t_attr_1, @test_1_num);
	
	
#----------------------------------------------	
	-- TEST 2: Get value from info with nulls.
	-- Insert test data, then immediately retrieve it using procedure we are testing.
	CALL mtf_sp_create_info(@t_type_2, @t_name_2, @t_attr_2, @t_str_val_2, @t_num_val_2);
	CALL mtf_sp_get_info_num(@t_type_2, @t_name_2, @t_attr_2, @test_2_num);
	
	
#----------------------------------------------	
	-- TEST 3: Get first value from multiple records.
	-- Insert test data, then immediately retrieve it using procedure we are testing.
	CALL mtf_sp_create_info(@t_type_3, @t_name_3, @t_attr_3, @t_str_val_3, @t_num_val_3_1);
	CALL mtf_sp_create_info(@t_type_3, @t_name_3, @t_attr_3, @t_str_val_3, @t_num_val_3_2);
	CALL mtf_sp_create_info(@t_type_3, @t_name_3, @t_attr_3, @t_str_val_3, @t_num_val_3_3);
	CALL mtf_sp_get_info_num(@t_type_3, @t_name_3, @t_attr_3, @test_3_num);
	
#----------------------------------------------	
	-- TEST 4: Attempt get from non-existent record.
	-- Do not insert test data for this.  Instead, simply try to retrieve from a non-existent record.
	CALL mtf_sp_get_info_num(@t_type_4, @t_name_4, @t_attr_4, @test_4_num);
	
	
    
#----------------------------------------------	
	ROLLBACK;  -- Only needed if you wish to remove the tests data.  Otherwise leave commented.



#----------------------------------------------	
-- RESULTS

	IF @test_1_num = @t_num_val_1 THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_1_description;
	ELSE
		SET @mt1 = CONCAT('Retrieved ', QUOTE(@test_1_num),' but expected ',QUOTE(@t_num_val_1));
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_1_description, MESSAGE_TEXT = @mt1;
	END IF;
	
	IF @test_2_num = @t_num_val_2 THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_2_description;
	ELSE
		SET @mt2 = CONCAT('Retrieved ', QUOTE(@test_2_num),' but expected ',QUOTE(@t_num_val_2));
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_2_description, MESSAGE_TEXT = @mt2;
	END IF;

	IF @test_3_num = @t_num_val_3_1 THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_3_description;
	ELSE
		SET @mt3 = CONCAT('Retrieved ', QUOTE(@test_3_num),' but expected ',QUOTE(@t_num_val_3_1));
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_3_description, MESSAGE_TEXT = @mt3;
	END IF;
	
	IF ISNULL(@test_4_num) THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_4_description;
	ELSE
		SET @mt4 = CONCAT('Retrieved ', QUOTE(@test_4_num),' but expected ',QUOTE(@t_num_val_4));
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_4_description, MESSAGE_TEXT = @mt4;
	END IF;		
					
											
	/**
	*	EXAMPLE: Raise a custom error
	*
	*	SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_critical SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_description;
	*
	*/

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_test_sp_get_info_str`()
    DETERMINISTIC
    COMMENT 'Test for the stored procedure mtf_sp_get_info_str.'
BEGIN
	
	/**
	*	By using HANDLERs we are able to simply raise 'errors' in our tests to be able to log results.
	* This is particularly useful because it provides a consistent mechanism that we can use for custom
	* messages, as well as a 'catch-all' that will also handle any unexpected database errors that
	* occur (which would by definition result in a FAIL of the test).
	*
	* Documentation / Props:
	*		- MySQL HANDLER documentation:		http://dev.mysql.com/doc/refman/5.5/en/handler.html
	*		- MySQL SIGNAL documentation:			http://dev.mysql.com/doc/refman/5.5/en/signal.html
	*				Important: Setting SQL_ERR to start with '01' (Warning) otherwise SQLEXCEPTION handler is also triggered.
	*		- Example of HANDLER usage:				http://www.mysqltutorial.org/mysql-error-handling-in-stored-procedures/
	*   - Example of SIGNAL usage:				http://stackoverflow.com/questions/465727/how-to-raise-an-error-within-a-mysql-function
	*   - Buildup of @full_error:					https://mariadb.com/blog/improve-your-stored-procedure-error-handling-get-diagnostics
	*
	**/


		
#----------------------------------------------
	-- HANDLERS
	
	DECLARE test_fail CONDITION FOR SQLSTATE '01990';
	DECLARE test_critical CONDITION FOR SQLSTATE '01991';
	DECLARE test_pass CONDITION FOR SQLSTATE '01992';
	
	/** 
	*	IMPORTANT NOTE:  Need to use the prefix '01' on each of the SQLSTATE codes because
	* MySQL classifies those as Warnings.  If I use a different value, and it interprets
	* the SQLSTATE as an exception, then our final 'catch-all' handler (which is an EXIT)
	* will also get called and prevent continued execution.
	*
	**/ 
	
	-- Catches custom FAIL messages but allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_fail
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom CRITICAL messages and stops processing.
	DECLARE CONTINUE HANDLER FOR test_critical
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		SET @message = CONCAT("CRITICAL: ", IFNULL(@text,'Unknown'));
		ROLLBACK;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom PASS messages.  Allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_pass
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN;
		CALL mtf_sp_create_result(@c_name, @description, @c_pass, '');
	END;

	-- Catches any other SQLEXCEPTION.  These will halt further testing.
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("DATABASE ERROR ", @errno, " (", @sqlstate, "): ", IFNULL(@text,'Unknown'));	
		ROLLBACK;
		CALL mtf_sp_create_result(@c_name, '', @c_fail, @full_error);
	END;

	
	
#----------------------------------------------	
	-- CONSTANT VARIABLES (prefix with @c_)
	SET @c_name = 'mtf_sp_get_info_str';
	SET @c_fail = 'FAIL';
	SET @c_pass = 'PASS';
	
	
#----------------------------------------------	
	-- TEST DATA (prefix with @t_)
	
	-- Test 1
	SET @t_test_1_description = 'Get value from record no nulls.';
	SET @t_type_1 = 'test 1';
	SET @t_name_1 = 'mtf_sp_get_info_str';
	SET @t_attr_1 = 'attr';
	SET @t_str_val_1 = 'test 1';
	SET @t_num_val_1 = null;
	
	-- Test 2
	SET @t_test_2_description = 'Get value from info with nulls.';
	SET @t_type_2 = null;
	SET @t_name_2 = 'mtf_sp_get_info_str';
	SET @t_attr_2 = null;
	SET @t_str_val_2 = 'test 2';
	SET @t_num_val_2 = null;
	
	-- Test 3
	SET @t_test_3_description = 'Get first value from multiple records.';
	SET @t_type_3 = 'test 3';
	SET @t_name_3 = 'mtf_sp_get_info_str';
	SET @t_attr_3  = null;
	SET @t_str_val_3_1 = 'first';
	SET @t_str_val_3_2 = 'second';
	SET @t_str_val_3_3 = 'third';
	SET @t_num_val_3 = null;
	
	-- Test 4
	SET @t_test_4_description = 'Attempt get from non-existent record.';
	SET @t_type_4 = 'test 4';
	SET @t_name_4 = 'mtf_sp_get_info_str';
	SET @t_attr_4  = null;
	SET @t_str_val_4 = null;
	
	
	
#----------------------------------------------
-- TESTS

	START TRANSACTION;  -- Only needed if you want to remove the test data.  Otherwise leave commented.



#----------------------------------------------	
	-- TEST 1: Get value from record no nulls.
	-- Insert test data, then immediately retrieve it using procedure we are testing.
	CALL mtf_sp_create_info(@t_type_1, @t_name_1, @t_attr_1, @t_str_val_1, @t_num_val_1);
	CALL mtf_sp_get_info_str(@t_type_1, @t_name_1, @t_attr_1, @test_1_str);
	
	
#----------------------------------------------	
	-- TEST 2: Get value from info with nulls.
	-- Insert test data, then immediately retrieve it using procedure we are testing.
	CALL mtf_sp_create_info(@t_type_2, @t_name_2, @t_attr_2, @t_str_val_2, @t_num_val_2);
	CALL mtf_sp_get_info_str(@t_type_2, @t_name_2, @t_attr_2, @test_2_str);
	
	
#----------------------------------------------	
	-- TEST 3: Get first value from multiple records.
	-- Insert test data, then immediately retrieve it using procedure we are testing.
	CALL mtf_sp_create_info(@t_type_3, @t_name_3, @t_attr_3, @t_str_val_3_1, @t_num_val_3);
	CALL mtf_sp_create_info(@t_type_3, @t_name_3, @t_attr_3, @t_str_val_3_2, @t_num_val_3);
	CALL mtf_sp_create_info(@t_type_3, @t_name_3, @t_attr_3, @t_str_val_3_3, @t_num_val_3);
	CALL mtf_sp_get_info_str(@t_type_3, @t_name_3, @t_attr_3, @test_3_str);
	
#----------------------------------------------	
	-- TEST 4: Attempt get from non-existent record.
	-- Do not insert test data for this.  Instead, simply try to retrieve from a non-existent record.
	CALL mtf_sp_get_info_str(@t_type_4, @t_name_4, @t_attr_4, @test_4_str);
	
	
    
#----------------------------------------------	
	ROLLBACK;  -- Only needed if you wish to remove the tests data.  Otherwise leave commented.



#----------------------------------------------	
-- RESULTS

	IF @test_1_str = @t_str_val_1 THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_1_description;
	ELSE
		SET @mt1 = CONCAT('Retrieved ', QUOTE(@test_1_str),' but expected ',QUOTE(@t_str_val_1));
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_1_description, MESSAGE_TEXT = @mt1;
	END IF;
	
	IF @test_2_str = @t_str_val_2 THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_2_description;
	ELSE
		SET @mt2 = CONCAT('Retrieved ', QUOTE(@test_2_str),' but expected ',QUOTE(@t_str_val_2));
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_2_description, MESSAGE_TEXT = @mt2;
	END IF;

	IF @test_3_str = @t_str_val_3_1 THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_3_description;
	ELSE
		SET @mt3 = CONCAT('Retrieved ', QUOTE(@test_3_str),' but expected ',QUOTE(@t_str_val_3_1));
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_3_description, MESSAGE_TEXT = @mt3;
	END IF;
	
	IF ISNULL(@test_4_str) THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_4_description;
	ELSE
		SET @mt4 = CONCAT('Retrieved ', QUOTE(@test_4_str),' but expected ',QUOTE(@t_str_val_4));
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_4_description, MESSAGE_TEXT = @mt4;
	END IF;		
					
											
	/**
	*	EXAMPLE: Raise a custom error
	*
	*	SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_critical SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_description;
	*
	*/

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_test_sp_num_equal`()
    DETERMINISTIC
    COMMENT 'Test for the stored procedure mtf_sp_num_equal.'
BEGIN
	
	/**
	*	By using HANDLERs we are able to simply raise 'errors' in our tests to be able to log results.
	* This is particularly useful because it provides a consistent mechanism that we can use for custom
	* messages, as well as a 'catch-all' that will also handle any unexpected database errors that
	* occur (which would by definition result in a FAIL of the test).
	*
	* Documentation / Props:
	*		- MySQL HANDLER documentation:		http://dev.mysql.com/doc/refman/5.5/en/handler.html
	*		- MySQL SIGNAL documentation:			http://dev.mysql.com/doc/refman/5.5/en/signal.html
	*				Important: Setting SQL_ERR to start with '01' (Warning) otherwise SQLEXCEPTION handler is also triggered.
	*		- Example of HANDLER usage:				http://www.mysqltutorial.org/mysql-error-handling-in-stored-procedures/
	*   - Example of SIGNAL usage:				http://stackoverflow.com/questions/465727/how-to-raise-an-error-within-a-mysql-function
	*   - Buildup of @full_error:					https://mariadb.com/blog/improve-your-stored-procedure-error-handling-get-diagnostics
	*
	**/
	
	/**
	*	IMPORTANT NOTE:
	*	The test for this stored procedure is slightly different than others.  That is because this stored procedure is 
	* used in the HANDLERs for every other test.  However, if there is something wrong with this procedure, we cannot
	* use it to write information into the results table.  Instead, we need to use a SQL INSERT statement on any error.
	*
	*/


		
#----------------------------------------------
	-- HANDLERS
	
	DECLARE test_fail CONDITION FOR SQLSTATE '01990';
	DECLARE test_critical CONDITION FOR SQLSTATE '01991';
	DECLARE test_pass CONDITION FOR SQLSTATE '01992';
	
	/** 
	*	IMPORTANT NOTE:  Need to use the prefix '01' on each of the SQLSTATE codes because
	* MySQL classifies those as Warnings.  If I use a different value, and it interprets
	* the SQLSTATE as an exception, then our final 'catch-all' handler (which is an EXIT)
	* will also get called and prevent continued execution.
	*
	**/ 
		
	-- Catches custom FAIL messages but allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_fail
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom CRITICAL messages and stops processing.
	DECLARE CONTINUE HANDLER FOR test_critical
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		SET @message = CONCAT("CRITICAL: ", IFNULL(@text,'Unknown'));
		ROLLBACK;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom PASS messages.  Allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_pass
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN;
		CALL mtf_sp_create_result(@c_name, @description, @c_pass, '');
	END;

	-- Catches any other SQLEXCEPTION.  These will halt further testing.
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("DATABASE ERROR ", @errno, " (", @sqlstate, "): ", IFNULL(@text,'Unknown'));	
		ROLLBACK;
		CALL mtf_sp_create_result(@c_name, '', @c_fail, @full_error);
	END;


		
#----------------------------------------------	
	-- CONSTANT VARIABLES (prefix with @c_)
	SET @c_name = 'mtf_sp_num_equal';
	SET @c_fail = 'FAIL';
	SET @c_pass = 'PASS';
	
	
#----------------------------------------------	
	-- TEST DATA (prefix with @t_)
	
	-- Test 1
	SET @t_test_1_description = 'Matching numbers.';
	SET @t_test_1_num_1 = 21345;
	SET @t_test_1_num_2 = 21345;
	
	
	-- Test 2
	SET @t_test_2_description = 'Mismatched numbers.';
	SET @t_test_2_num_1 = 43124;
	SET @t_test_2_num_2 = 453;
	

	-- Test 3
	SET @t_test_3_description = 'NULL numbers.';
	SET @t_test_3_num_1 = null;
	SET @t_test_3_num_2 = null;
	

	-- Test 4
	SET @t_test_4_description = 'Valid number and NULL.';
	SET @t_test_4_num_1 = 43214;
	SET @t_test_4_num_2 = null;
	
	
	-- Test 5
	SET @t_test_5_description = 'NULL and a valid number.';
	SET @t_test_5_num_1 = null;
	SET @t_test_5_num_2 = 99;
	
	
	
#----------------------------------------------
-- TESTS

#	START TRANSACTION;  -- Only needed if you want to remove the test data.  Otherwise leave commented.



#----------------------------------------------	

	CALL mtf_sp_num_equal(@t_test_1_num_1, @t_test_1_num_2, @test_1_result);
	CALL mtf_sp_num_equal(@t_test_2_num_1, @t_test_2_num_2, @test_2_result);
	CALL mtf_sp_num_equal(@t_test_3_num_1, @t_test_3_num_2, @test_3_result);
	CALL mtf_sp_num_equal(@t_test_4_num_1, @t_test_4_num_2, @test_4_result);
	CALL mtf_sp_num_equal(@t_test_5_num_1, @t_test_5_num_2, @test_5_result);

    
    
#----------------------------------------------	
#	ROLLBACK;  -- Only needed if you wish to remove the tests data.  Otherwise leave commented.



#----------------------------------------------	
-- RESULTS

	IF @test_1_result = 'PASS' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_1_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_1_description, MESSAGE_TEXT = 'Comparison of matching numbers is failing.';
	END IF;
	
	IF @test_2_result = 'FAIL' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_2_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_2_description, MESSAGE_TEXT = 'Comparison of mismatched numbers is failing.';
	END IF;
	
	IF @test_3_result = 'PASS' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_3_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_3_description, MESSAGE_TEXT = 'Comparison of null numbers is failing.';
	END IF;
	
	IF @test_4_result = 'FAIL' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_4_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_4_description, MESSAGE_TEXT = 'Comparison of a valid number against null is failing.';
	END IF;
		
	IF @test_5_result = 'FAIL' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_5_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_5_description, MESSAGE_TEXT = 'Comparison of null against a valid number is failing.';
	END IF;
						
											
	/**
	*	EXAMPLE: Raise a custom error
	*
	*	SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_critical SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_description;
	*
	*/

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_test_sp_num_not_equal`()
    DETERMINISTIC
    COMMENT 'Test for the stored procedure mtf_sp_num_not_equal.'
BEGIN
	
	/**
	*	By using HANDLERs we are able to simply raise 'errors' in our tests to be able to log results.
	* This is particularly useful because it provides a consistent mechanism that we can use for custom
	* messages, as well as a 'catch-all' that will also handle any unexpected database errors that
	* occur (which would by definition result in a FAIL of the test).
	*
	* Documentation / Props:
	*		- MySQL HANDLER documentation:		http://dev.mysql.com/doc/refman/5.5/en/handler.html
	*		- MySQL SIGNAL documentation:			http://dev.mysql.com/doc/refman/5.5/en/signal.html
	*				Important: Setting SQL_ERR to start with '01' (Warning) otherwise SQLEXCEPTION handler is also triggered.
	*		- Example of HANDLER usage:				http://www.mysqltutorial.org/mysql-error-handling-in-stored-procedures/
	*   - Example of SIGNAL usage:				http://stackoverflow.com/questions/465727/how-to-raise-an-error-within-a-mysql-function
	*   - Buildup of @full_error:					https://mariadb.com/blog/improve-your-stored-procedure-error-handling-get-diagnostics
	*
	**/
	
	/**
	*	IMPORTANT NOTE:
	*	The test for this stored procedure is slightly different than others.  That is because this stored procedure is 
	* used in the HANDLERs for every other test.  However, if there is something wrong with this procedure, we cannot
	* use it to write information into the results table.  Instead, we need to use a SQL INSERT statement on any error.
	*
	*/


		
#----------------------------------------------
	-- HANDLERS
	
	DECLARE test_fail CONDITION FOR SQLSTATE '01990';
	DECLARE test_critical CONDITION FOR SQLSTATE '01991';
	DECLARE test_pass CONDITION FOR SQLSTATE '01992';
	
	/** 
	*	IMPORTANT NOTE:  Need to use the prefix '01' on each of the SQLSTATE codes because
	* MySQL classifies those as Warnings.  If I use a different value, and it interprets
	* the SQLSTATE as an exception, then our final 'catch-all' handler (which is an EXIT)
	* will also get called and prevent continued execution.
	*
	**/ 
		
	-- Catches custom FAIL messages but allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_fail
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom CRITICAL messages and stops processing.
	DECLARE CONTINUE HANDLER FOR test_critical
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		SET @message = CONCAT("CRITICAL: ", IFNULL(@text,'Unknown'));
		ROLLBACK;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom PASS messages.  Allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_pass
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN;
		CALL mtf_sp_create_result(@c_name, @description, @c_pass, '');
	END;

	-- Catches any other SQLEXCEPTION.  These will halt further testing.
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("DATABASE ERROR ", @errno, " (", @sqlstate, "): ", IFNULL(@text,'Unknown'));	
		ROLLBACK;
		CALL mtf_sp_create_result(@c_name, '', @c_fail, @full_error);
	END;


		
#----------------------------------------------	
	-- CONSTANT VARIABLES (prefix with @c_)
	SET @c_name = 'mtf_sp_num_equal';
	SET @c_fail = 'FAIL';
	SET @c_pass = 'PASS';
	
	
#----------------------------------------------	
	-- TEST DATA (prefix with @t_)
	
	-- Test 1
	SET @t_test_1_description = 'Matching numbers.';
	SET @t_test_1_num_1 = 21345;
	SET @t_test_1_num_2 = 21345;
	
	
	-- Test 2
	SET @t_test_2_description = 'Mismatched numbers.';
	SET @t_test_2_num_1 = 43124;
	SET @t_test_2_num_2 = 453;
	

	-- Test 3
	SET @t_test_3_description = 'NULL numbers.';
	SET @t_test_3_num_1 = null;
	SET @t_test_3_num_2 = null;
	

	-- Test 4
	SET @t_test_4_description = 'Valid number and NULL.';
	SET @t_test_4_num_1 = 43214;
	SET @t_test_4_num_2 = null;
	
	
	-- Test 5
	SET @t_test_5_description = 'NULL and a valid number.';
	SET @t_test_5_num_1 = null;
	SET @t_test_5_num_2 = 99;
	
	
	
#----------------------------------------------
-- TESTS

#	START TRANSACTION;  -- Only needed if you want to remove the test data.  Otherwise leave commented.



#----------------------------------------------	

	CALL mtf_sp_num_not_equal(@t_test_1_num_1, @t_test_1_num_2, @test_1_result);
	CALL mtf_sp_num_not_equal(@t_test_2_num_1, @t_test_2_num_2, @test_2_result);
	CALL mtf_sp_num_not_equal(@t_test_3_num_1, @t_test_3_num_2, @test_3_result);
	CALL mtf_sp_num_not_equal(@t_test_4_num_1, @t_test_4_num_2, @test_4_result);
	CALL mtf_sp_num_not_equal(@t_test_5_num_1, @t_test_5_num_2, @test_5_result);

    
    
#----------------------------------------------	
#	ROLLBACK;  -- Only needed if you wish to remove the tests data.  Otherwise leave commented.



#----------------------------------------------	
-- RESULTS

	IF @test_1_result = 'FAIL' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_1_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_1_description, MESSAGE_TEXT = 'Comparison of matching numbers is failing.';
	END IF;
	
	IF @test_2_result = 'PASS' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_2_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_2_description, MESSAGE_TEXT = 'Comparison of mismatched numbers is failing.';
	END IF;
	
	IF @test_3_result = 'FAIL' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_3_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_3_description, MESSAGE_TEXT = 'Comparison of null numbers is failing.';
	END IF;
	
	IF @test_4_result = 'PASS' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_4_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_4_description, MESSAGE_TEXT = 'Comparison of a valid number against null is failing.';
	END IF;
		
	IF @test_5_result = 'PASS' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_5_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_5_description, MESSAGE_TEXT = 'Comparison of null against a valid number is failing.';
	END IF;
						
											
	/**
	*	EXAMPLE: Raise a custom error
	*
	*	SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_critical SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_description;
	*
	*/

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_test_sp_str_equal`()
    DETERMINISTIC
    COMMENT 'Test for the stored procedure mtf_sp_str_equal.'
BEGIN
	
	/**
	*	By using HANDLERs we are able to simply raise 'errors' in our tests to be able to log results.
	* This is particularly useful because it provides a consistent mechanism that we can use for custom
	* messages, as well as a 'catch-all' that will also handle any unexpected database errors that
	* occur (which would by definition result in a FAIL of the test).
	*
	* Documentation / Props:
	*		- MySQL HANDLER documentation:		http://dev.mysql.com/doc/refman/5.5/en/handler.html
	*		- MySQL SIGNAL documentation:			http://dev.mysql.com/doc/refman/5.5/en/signal.html
	*				Important: Setting SQL_ERR to start with '01' (Warning) otherwise SQLEXCEPTION handler is also triggered.
	*		- Example of HANDLER usage:				http://www.mysqltutorial.org/mysql-error-handling-in-stored-procedures/
	*   - Example of SIGNAL usage:				http://stackoverflow.com/questions/465727/how-to-raise-an-error-within-a-mysql-function
	*   - Buildup of @full_error:					https://mariadb.com/blog/improve-your-stored-procedure-error-handling-get-diagnostics
	*
	**/
	
	/**
	*	IMPORTANT NOTE:
	*	The test for this stored procedure is slightly different than others.  That is because this stored procedure is 
	* used in the HANDLERs for every other test.  However, if there is something wrong with this procedure, we cannot
	* use it to write information into the results table.  Instead, we need to use a SQL INSERT statement on any error.
	*
	*/


		
#----------------------------------------------
	-- HANDLERS
	
	DECLARE test_fail CONDITION FOR SQLSTATE '01990';
	DECLARE test_critical CONDITION FOR SQLSTATE '01991';
	DECLARE test_pass CONDITION FOR SQLSTATE '01992';
	
	/** 
	*	IMPORTANT NOTE:  Need to use the prefix '01' on each of the SQLSTATE codes because
	* MySQL classifies those as Warnings.  If I use a different value, and it interprets
	* the SQLSTATE as an exception, then our final 'catch-all' handler (which is an EXIT)
	* will also get called and prevent continued execution.
	*
	**/ 
		
	-- Catches custom FAIL messages but allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_fail
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom CRITICAL messages and stops processing.
	DECLARE CONTINUE HANDLER FOR test_critical
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		SET @message = CONCAT("CRITICAL: ", IFNULL(@text,'Unknown'));
		ROLLBACK;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom PASS messages.  Allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_pass
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN;
		CALL mtf_sp_create_result(@c_name, @description, @c_pass, '');
	END;

	-- Catches any other SQLEXCEPTION.  These will halt further testing.
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("DATABASE ERROR ", @errno, " (", @sqlstate, "): ", IFNULL(@text,'Unknown'));	
		ROLLBACK;
		CALL mtf_sp_create_result(@c_name, '', @c_fail, @full_error);
	END;


		
#----------------------------------------------	
	-- CONSTANT VARIABLES (prefix with @c_)
	SET @c_name = 'mtf_sp_str_equal';
	SET @c_fail = 'FAIL';
	SET @c_pass = 'PASS';
	
	
#----------------------------------------------	
	-- TEST DATA (prefix with @t_)
	
	-- Test 1
	SET @t_test_1_description = 'Matching strings.';
	SET @t_test_1_str_1 = 'string';
	SET @t_test_1_str_2 = 'string';
	
	
	-- Test 2
	SET @t_test_2_description = 'Mismatched strings.';
	SET @t_test_2_str_1 = 'string';
	SET @t_test_2_str_2 = 'abcdef';
	

	-- Test 3
	SET @t_test_3_description = 'NULL strings.';
	SET @t_test_3_str_1 = null;
	SET @t_test_3_str_2 = null;
	

	-- Test 4
	SET @t_test_4_description = 'Valid string and NULL.';
	SET @t_test_4_str_1 = 'string';
	SET @t_test_4_str_2 = null;
	
	
	-- Test 5
	SET @t_test_5_description = 'NULL and a valid string.';
	SET @t_test_5_str_1 = null;
	SET @t_test_5_str_2 = 'string';
	
	
	
#----------------------------------------------
-- TESTS

#	START TRANSACTION;  -- Only needed if you want to remove the test data.  Otherwise leave commented.



#----------------------------------------------	

	CALL mtf_sp_str_equal(@t_test_1_str_1, @t_test_1_str_2, @test_1_result);
	CALL mtf_sp_str_equal(@t_test_2_str_1, @t_test_2_str_2, @test_2_result);
	CALL mtf_sp_str_equal(@t_test_3_str_1, @t_test_3_str_2, @test_3_result);
	CALL mtf_sp_str_equal(@t_test_4_str_1, @t_test_4_str_2, @test_4_result);
	CALL mtf_sp_str_equal(@t_test_5_str_1, @t_test_5_str_2, @test_5_result);

    
    
#----------------------------------------------	
#	ROLLBACK;  -- Only needed if you wish to remove the tests data.  Otherwise leave commented.



#----------------------------------------------	
-- RESULTS

	IF @test_1_result = 'PASS' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_1_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_1_description, MESSAGE_TEXT = 'Comparison of matching strings is failing.';
	END IF;
	
	IF @test_2_result = 'FAIL' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_2_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_2_description, MESSAGE_TEXT = 'Comparison of mismatched strings is failing.';
	END IF;
	
	IF @test_3_result = 'PASS' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_3_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_3_description, MESSAGE_TEXT = 'Comparison of null strings is failing.';
	END IF;
	
	IF @test_4_result = 'FAIL' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_4_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_4_description, MESSAGE_TEXT = 'Comparison of a valid string against null is failing.';
	END IF;
		
	IF @test_5_result = 'FAIL' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_5_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_5_description, MESSAGE_TEXT = 'Comparison of null against a valid string is failing.';
	END IF;
						
											
	/**
	*	EXAMPLE: Raise a custom error
	*
	*	SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_critical SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_description;
	*
	*/

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_test_sp_str_not_equal`()
    DETERMINISTIC
    COMMENT 'Test for the stored procedure mtf_sp_str_not_equal.'
BEGIN
	
	/**
	*	By using HANDLERs we are able to simply raise 'errors' in our tests to be able to log results.
	* This is particularly useful because it provides a consistent mechanism that we can use for custom
	* messages, as well as a 'catch-all' that will also handle any unexpected database errors that
	* occur (which would by definition result in a FAIL of the test).
	*
	* Documentation / Props:
	*		- MySQL HANDLER documentation:		http://dev.mysql.com/doc/refman/5.5/en/handler.html
	*		- MySQL SIGNAL documentation:			http://dev.mysql.com/doc/refman/5.5/en/signal.html
	*				Important: Setting SQL_ERR to start with '01' (Warning) otherwise SQLEXCEPTION handler is also triggered.
	*		- Example of HANDLER usage:				http://www.mysqltutorial.org/mysql-error-handling-in-stored-procedures/
	*   - Example of SIGNAL usage:				http://stackoverflow.com/questions/465727/how-to-raise-an-error-within-a-mysql-function
	*   - Buildup of @full_error:					https://mariadb.com/blog/improve-your-stored-procedure-error-handling-get-diagnostics
	*
	**/
	
	/**
	*	IMPORTANT NOTE:
	*	The test for this stored procedure is slightly different than others.  That is because this stored procedure is 
	* used in the HANDLERs for every other test.  However, if there is something wrong with this procedure, we cannot
	* use it to write information into the results table.  Instead, we need to use a SQL INSERT statement on any error.
	*
	*/


		
#----------------------------------------------
	-- HANDLERS
	
	DECLARE test_fail CONDITION FOR SQLSTATE '01990';
	DECLARE test_critical CONDITION FOR SQLSTATE '01991';
	DECLARE test_pass CONDITION FOR SQLSTATE '01992';
	
	/** 
	*	IMPORTANT NOTE:  Need to use the prefix '01' on each of the SQLSTATE codes because
	* MySQL classifies those as Warnings.  If I use a different value, and it interprets
	* the SQLSTATE as an exception, then our final 'catch-all' handler (which is an EXIT)
	* will also get called and prevent continued execution.
	*
	**/ 
		
	-- Catches custom FAIL messages but allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_fail
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom CRITICAL messages and stops processing.
	DECLARE CONTINUE HANDLER FOR test_critical
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN, @message = MESSAGE_TEXT;
		SET @message = CONCAT("CRITICAL: ", IFNULL(@text,'Unknown'));
		ROLLBACK;
		INSERT INTO mtf_result (name, description, status, message)
			VALUES (@c_name, @description, @c_fail, @message);
	END;
	
	-- Catches custom PASS messages.  Allows processing to continue.
	DECLARE CONTINUE HANDLER FOR test_pass
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @description = SUBCLASS_ORIGIN;
		CALL mtf_sp_create_result(@c_name, @description, @c_pass, '');
	END;

	-- Catches any other SQLEXCEPTION.  These will halt further testing.
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("DATABASE ERROR ", @errno, " (", @sqlstate, "): ", IFNULL(@text,'Unknown'));	
		ROLLBACK;
		CALL mtf_sp_create_result(@c_name, '', @c_fail, @full_error);
	END;


		
#----------------------------------------------	
	-- CONSTANT VARIABLES (prefix with @c_)
	SET @c_name = 'mtf_sp_str_not_equal';
	SET @c_fail = 'FAIL';
	SET @c_pass = 'PASS';
	
	
#----------------------------------------------	
	-- TEST DATA (prefix with @t_)
	
	-- Test 1
	SET @t_test_1_description = 'Matching strings.';
	SET @t_test_1_str_1 = 'string';
	SET @t_test_1_str_2 = 'string';
	
	
	-- Test 2
	SET @t_test_2_description = 'Mismatched strings.';
	SET @t_test_2_str_1 = 'string';
	SET @t_test_2_str_2 = 'abcdef';
	

	-- Test 3
	SET @t_test_3_description = 'NULL strings.';
	SET @t_test_3_str_1 = null;
	SET @t_test_3_str_2 = null;
	

	-- Test 4
	SET @t_test_4_description = 'Valid string and NULL.';
	SET @t_test_4_str_1 = 'string';
	SET @t_test_4_str_2 = null;
	
	
	-- Test 5
	SET @t_test_5_description = 'NULL and a valid string.';
	SET @t_test_5_str_1 = null;
	SET @t_test_5_str_2 = 'string';
	
	
	
#----------------------------------------------
-- TESTS

#	START TRANSACTION;  -- Only needed if you want to remove the test data.  Otherwise leave commented.



#----------------------------------------------	

	CALL mtf_sp_str_not_equal(@t_test_1_str_1, @t_test_1_str_2, @test_1_result);
	CALL mtf_sp_str_not_equal(@t_test_2_str_1, @t_test_2_str_2, @test_2_result);
	CALL mtf_sp_str_not_equal(@t_test_3_str_1, @t_test_3_str_2, @test_3_result);
	CALL mtf_sp_str_not_equal(@t_test_4_str_1, @t_test_4_str_2, @test_4_result);
	CALL mtf_sp_str_not_equal(@t_test_5_str_1, @t_test_5_str_2, @test_5_result);

    
    
#----------------------------------------------	
#	ROLLBACK;  -- Only needed if you wish to remove the tests data.  Otherwise leave commented.



#----------------------------------------------	
-- RESULTS

	IF @test_1_result = 'FAIL' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_1_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_1_description, MESSAGE_TEXT = 'Comparison of matching strings is failing.';
	END IF;
	
	IF @test_2_result = 'PASS' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_2_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_2_description, MESSAGE_TEXT = 'Comparison of mismatched strings is failing.';
	END IF;
	
	IF @test_3_result = 'FAIL' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_3_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_3_description, MESSAGE_TEXT = 'Comparison of null strings is failing.';
	END IF;
	
	IF @test_4_result = 'PASS' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_4_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_4_description, MESSAGE_TEXT = 'Comparison of a valid string against null is failing.';
	END IF;
		
	IF @test_5_result = 'PASS' THEN
		SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_5_description;
	ELSE
		SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_5_description, MESSAGE_TEXT = 'Comparison of null against a valid string is failing.';
	END IF;
						
											
	/**
	*	EXAMPLE: Raise a custom error
	*
	*	SIGNAL test_fail SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_critical SET SUBCLASS_ORIGIN = @t_test_description, MESSAGE_TEXT = 'Custom message here.';
	* SIGNAL test_pass SET SUBCLASS_ORIGIN = @t_test_description;
	*
	*/

END;
//
DELIMITER ;


DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_test_suite_self`()
    DETERMINISTIC
    COMMENT 'Test Suite that tests the complete testing framwork.'
BEGIN

	-- Begin by deleteing results of previous tests.
	DELETE FROM mtf_result;
	
	
	
	-- Now execute the following tests.
	
	-- LOGGING PROCEDURES
	CALL mtf_test_sp_create_result;
	CALL mtf_test_sp_create_info;
	
	-- COMPARISON PROCEDURES
	CALL mtf_test_sp_str_equal;
	CALL mtf_test_sp_str_not_equal;
	CALL mtf_test_sp_num_equal;
	CALL mtf_test_sp_num_not_equal;
	
	-- UTILITY PROCEDURES
	CALL mtf_test_sp_get_info_str;
	CALL mtf_test_sp_get_info_num;
	
	
	
	-- Finally, output a manifest of the test results.
	SELECT	*
	FROM		mtf_result;

END;
//
DELIMITER ;




SET @PREVIOUS_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;


LOCK TABLES `mtf_info` WRITE;
ALTER TABLE `mtf_info` DISABLE KEYS;
ALTER TABLE `mtf_info` ENABLE KEYS;
UNLOCK TABLES;


LOCK TABLES `mtf_result` WRITE;
ALTER TABLE `mtf_result` DISABLE KEYS;
ALTER TABLE `mtf_result` ENABLE KEYS;
UNLOCK TABLES;


LOCK TABLES `mtf_version` WRITE;
ALTER TABLE `mtf_version` DISABLE KEYS;
INSERT INTO `mtf_version` (`id`, `major`, `minor`, `comment`) VALUES 
	(1,0,'1','Initial release.  Very probable that there are much better ways of doing things, but this is at least a start.');
ALTER TABLE `mtf_version` ENABLE KEYS;
UNLOCK TABLES;




SET FOREIGN_KEY_CHECKS = @PREVIOUS_FOREIGN_KEY_CHECKS;


