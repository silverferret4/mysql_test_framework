#
# SQL Export
# Created by Querious (957)
# Created: March 9, 2015 at 6:22:44 PM CDT
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




DROP PROCEDURE IF EXISTS `mtf_template_testsuite`;
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtf_template_testsuite`()
    DETERMINISTIC
    COMMENT 'This procedure is meant as a template to be used as the basis for all testsuites that are written.'
BEGIN

	-- Begin by deleteing results of previous tests.
	DELETE FROM mtf_result;
	
	
	
	-- Now execute the following tests.
	
	CALL test_1;
	CALL test_2;
	CALL test_3;
	
	
	
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


