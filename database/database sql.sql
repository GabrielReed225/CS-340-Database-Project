-- phpMyAdmin SQL Dump
-- version 5.2.2-1.el9.remi
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 26, 2025 at 08:55 PM
-- Server version: 10.11.14-MariaDB-log
-- PHP Version: 8.4.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cs340_reedgab`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_create_address` (IN `p_street` VARCHAR(45), IN `p_state` VARCHAR(45), IN `p_city` VARCHAR(45), IN `p_zipCode` VARCHAR(45), OUT `p_id` INT)   BEGIN
    INSERT INTO Addresses (
    street, state, city, zipCode
) VALUES (
    p_street, p_state, p_city, p_zipCode
);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted address.
    SELECT LAST_INSERT_ID() AS 'new_id';
    -- Example of how to get the ID of the newly created address:
        -- CALL sp_create_address('Pike Street', 'Washington', Seattle, 98133, 
        -- @new_id);
        -- SELECT @new_id AS 'New Address ID';
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_create_customer` (IN `p_addressID` INT(11), IN `p_firstName` VARCHAR(45), IN `p_lastName` VARCHAR(45), IN `p_phoneNumber` VARCHAR(45), IN `p_email` VARCHAR(45), OUT `p_id` INT)   BEGIN
    INSERT INTO Customers (
addressID, firstName, lastName, phoneNumber, email
) VALUES (
    p_addressID, p_firstName, p_lastName, p_phoneNumber, p_email
);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted customer.
    SELECT LAST_INSERT_ID() AS 'new_id';
    -- Example of how to get the ID of the newly created address:
        -- CALL sp_create_customer(2, 'Christopher', 'Robin', '555-706-3410', 
        -- 'hundredacre@hello.com', @new_id);
        -- SELECT @new_id AS 'New Customer ID';
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_create_employee` (IN `p_locationID` INT(11), IN `p_addressID` INT(11), IN `p_firstName` VARCHAR(45), IN `p_lastName` VARCHAR(45), IN `p_phoneNumber` VARCHAR(45), IN `p_email` VARCHAR(45), OUT `p_id` INT)   BEGIN
    INSERT INTO Employees (
locationID, addressID, firstName, lastName, phoneNumber, email
) VALUES (
    p_locationID, p_addressID, p_firstName, p_lastName, p_phoneNumber, p_email
);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted employee.
    SELECT LAST_INSERT_ID() AS 'new_id';
    -- Example of how to get the ID of the newly created address:
        -- CALL sp_create_employee(2,3,5,'Kevin','Eleven','555-111-0493',
        -- 'IamEleven@hello.com', @new_id);
        -- SELECT @new_id AS 'New Employee ID';
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_create_location` (IN `p_addressID` INT(11), OUT `p_id` INT)   BEGIN
    INSERT INTO Locations (addressID)
    VALUES (p_addressID);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted location.
    SELECT LAST_INSERT_ID() AS 'new_id';
    -- Example of how to get the ID of the newly created location:
        -- CALL sp_create_location(2, @new_id);
        -- SELECT @new_id AS 'New Location ID';
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_create_location_vehicle` (IN `p_vehicleID` INT(11), IN `p_locationID` INT(11), IN `p_quantity` INT(11))   BEGIN
    INSERT INTO LocationVehicles (vehicleID, locationID, quantity) VALUES (
    p_vehicleID,
    p_locationID,
    p_quantity
);
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_create_order` (IN `p_customerID` INT(11), IN `p_locationID` INT(11), IN `p_employeeID` INT(11), IN `p_dateTime` DATETIME, OUT `p_id` INT)   BEGIN
    INSERT INTO Orders (customerID, locationID, employeeID, dateTime) 
    VALUES (
    p_customerID, p_locationID, p_employeeID, p_dateTime
);



    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted order.
    SELECT LAST_INSERT_ID() AS 'new_id';
    -- Example of how to get the ID of the newly created vehicle
        -- CALL sp_create_order(2,3,2,'2025-11-05 00:11:43', @new_id);
        -- SELECT @new_id AS 'New Order ID';
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_create_order_vehicle` (IN `p_orderID` INT(11), IN `p_vehicleID` INT(11), IN `p_saleAmount` DECIMAL(10,2), IN `p_quantity` INT(11))   BEGIN  
    DECLARE error_message VARCHAR(255); 
    DECLARE v_orderVehicleID INT(11); -- Declared as local variable
    DECLARE v_locationVehicleID INT(11);
    DECLARE v_current_quantity INT(11);
    DECLARE v_order_quantity INT(11);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO OrderVehicles (orderID, vehicleID, saleAmount, quantity) VALUES (
        p_orderID,
        p_vehicleID,
        p_saleAmount,
        p_quantity
    );

    -- Store the ID of the last inserted row into our local variable
    SET v_orderVehicleID = LAST_INSERT_ID();

    -- Use base tables to find the relevant location vehicle entry and quantity
    -- We assume an order is tied to a location (from Orders table)
    SELECT LV.locationVehicleID, LV.quantity INTO v_locationVehicleID, v_current_quantity
    FROM LocationVehicles LV
    JOIN Orders O ON LV.locationID = O.locationID
    WHERE O.orderID = p_orderID AND LV.vehicleID = p_vehicleID;

    SET v_order_quantity = p_quantity; -- Use the input parameter directly

    -- If the order quantity is greater than what is there, then error
    IF v_current_quantity < v_order_quantity OR v_current_quantity IS NULL THEN 
        SET error_message = CONCAT('Not enough inventory to fulfill order! Current stock: ', IFNULL(v_current_quantity, 0));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    ELSE 
        -- Update quantity in LocationVehicles
        UPDATE LocationVehicles 
        SET quantity = (v_current_quantity - v_order_quantity)
        WHERE locationVehicleID = v_locationVehicleID;
    END IF;
    
    COMMIT;
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_create_vehicle` (IN `p_model` VARCHAR(45), IN `p_year` INT(11), IN `p_type` VARCHAR(45), IN `p_vehiclePrice` DECIMAL(9,2), OUT `p_id` INT)   BEGIN
    INSERT INTO Vehicles (model, year, type, vehiclePrice) VALUES (
    p_model, p_year, p_type, p_vehiclePrice
);


    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted vehicle.
    SELECT LAST_INSERT_ID() AS 'new_id';
    -- Example of how to get the ID of the newly created vehicle
        -- CALL sp_create_vehicle(Toyota Corolla',2016,'Sedan',20000.00, 
        -- @new_id);
        -- SELECT @new_id AS 'New Vehicle ID';
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_delete_address` (IN `p_addressID` INT)   BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;
    START TRANSACTION;
        -- Start the transaction
        DELETE FROM Addresses
            WHERE addressID = p_addressID;


        -- ROW_COUNT() returns the number of rows affected by the preceding 
        -- statement. If no, matching rows, then error.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Addresses',
            ' for vehicleID: ', p_addressID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        SELECT 'Address deleted!' AS Result;

    COMMIT;

END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_delete_customer` (IN `p_customerID` INT)   BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;
    START TRANSACTION;
        -- Start the transaction
        DELETE FROM Customers
            WHERE customerID = p_customerID;


        -- ROW_COUNT() returns the number of rows affected by the preceding 
        -- statement. If no, matching rows, then error.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Customers',
            ' for customerID: ', p_customerID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        SELECT 'Customer deleted!' AS Result;

    COMMIT;

END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_delete_employee` (IN `p_employeeID` INT)   BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;
    START TRANSACTION;
        -- Start the transaction
        DELETE FROM Employees
            WHERE employeeID = p_employeeID;


        -- ROW_COUNT() returns the number of rows affected by the preceding 
        -- statement. If no, matching rows, then error.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Employees',
            ' for employeeID: ', p_employeeID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        SELECT 'Employee deleted!' AS Result;

    COMMIT;

END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_delete_location` (IN `p_locationID` INT)   BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;
    START TRANSACTION;
        -- Start the transaction
        DELETE FROM Locations
            WHERE locationID = p_locationID;


        -- ROW_COUNT() returns the number of rows affected by the preceding 
        -- statement. If no, matching rows, then error.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Locations',
            ' for locationID: ', p_locationID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        SELECT 'Location deleted!' AS Result;

    COMMIT;

END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_delete_order` (IN `p_orderID` INT)   BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;
    START TRANSACTION;
        -- Start the transaction
        DELETE FROM Orders
            WHERE orderID = p_orderID;


        -- ROW_COUNT() returns the number of rows affected by the preceding 
        -- statement. If no, matching rows, then error.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Orders',
            ' for orderID: ', p_orderID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        SELECT 'Order deleted!' AS Result;

    COMMIT;

END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_delete_vehicle` (IN `p_vehicleID` INT)   BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;
    START TRANSACTION;
        -- Start the transaction
        DELETE FROM Vehicles
            WHERE vehicleID = p_vehicleID;


        -- ROW_COUNT() returns the number of rows affected by the preceding 
        -- statement. If no, matching rows, then error.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Vehicles',
            ' for vehicleID: ', p_vehicleID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        SELECT 'Vehicle deleted!' AS Result;

    COMMIT;

END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_load_db` ()   BEGIN
    SET FOREIGN_KEY_CHECKS = 0;

    --
    -- Table structure for table `Addresses`
    --

    DROP TABLE IF EXISTS `Addresses`;
    CREATE TABLE `Addresses` (
    `addressID` int(11) NOT NULL AUTO_INCREMENT,
    `street` varchar(45) NOT NULL,
    `state` varchar(45) NOT NULL,
    `city` varchar(45) NOT NULL,
    `zipCode` varchar(45) NOT NULL,
    PRIMARY KEY (`addressID`)
    ) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

    --
    -- Dumping data for table `Addresses`
    --

    INSERT INTO `Addresses` VALUES (1,'Sesame Street','California',
    'San Francisco','94102'),
    (2,'Pike Street','Washington','Seattle','98133'),
    (3,'Alligator Boulevard','Florida','Orlando','45103'),
    (4,'Wallingford Avenue','Washington','Seattle','98133'),
    (5,'Tropical Street','Florida','Orlando','45103');

    --
    -- Table structure for table `Customers`
    --

    DROP TABLE IF EXISTS `Customers`;
    CREATE TABLE `Customers` (
    `customerID` int(11) NOT NULL AUTO_INCREMENT,
    `addressID` int(11),
    `firstName` varchar(45) NOT NULL,
    `lastName` varchar(45) NOT NULL,
    `phoneNumber` varchar(45) NOT NULL,
    `email` varchar(45) NOT NULL,
    PRIMARY KEY (`customerID`),
    UNIQUE KEY `customerID_UNIQUE` (`customerID`),
    UNIQUE KEY `email_UNIQUE` (`email`),
    UNIQUE KEY `phoneNumber_UNIQUE` (`phoneNumber`),
    KEY `fk_Customers_Addresses1_idx` (`addressID`),
    CONSTRAINT `fk_Customers_Addresses1` FOREIGN KEY (`addressID`) REFERENCES `Addresses` (`addressID`) 
    ON DELETE SET NULL ON UPDATE NO ACTION
    ) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

    --
    -- Dumping data for table `Customers`
    --
    INSERT INTO `Customers` VALUES (1,2,'Christopher','Robin','555-706-3410','hundredacre@hello.com'),
    (2,3,'Benito','Vasquez','555-345-2341','veranocaliente@hello.com'),
    (3,1,'Elmo','Redd','555-595-0020','iluvmygoldfish@hello.com');
    
    --
    -- Table structure for table `Employees`
    --

    DROP TABLE IF EXISTS `Employees`;
    CREATE TABLE `Employees` (
    `employeeID` int(11) NOT NULL AUTO_INCREMENT,
    `locationID` int(11),
    `addressID` int(11),
    `firstName` varchar(45) NOT NULL,
    `lastName` varchar(45) NOT NULL,
    `phoneNumber` varchar(45) NOT NULL,
    `email` varchar(45) NOT NULL,
    PRIMARY KEY (`employeeID`),
    UNIQUE KEY `employeeID_UNIQUE` (`employeeID`),
    UNIQUE KEY `email_UNIQUE` (`email`),
    UNIQUE KEY `phoneNumber_UNIQUE` (`phoneNumber`),
    KEY `fk_Employees_locations1_idx` (`locationID`),
    KEY `fk_Employees_Addresses1_idx` (`addressID`),
    CONSTRAINT `fk_Employees_Addresses1` FOREIGN KEY (`addressID`) 
    REFERENCES `Addresses` (`addressID`) ON DELETE SET NULL 
    ON UPDATE CASCADE,
    CONSTRAINT `fk_Employees_locations1` FOREIGN KEY (`locationID`) 
    REFERENCES `Locations` (`locationID`) ON DELETE SET NULL 
    ON UPDATE CASCADE
    ) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 
    COLLATE=utf8mb4_general_ci;

    --
    -- Dumping data for table `Employees`
    --
    INSERT INTO `Employees` VALUES (1,2,1,'Michael','Smith','555-212-4403',
    'mrsmith@hello.com'),
    (2,3,5,'Kevin','Eleven','555-111-0493','IamEleven@hello.com'),
    (3,1,4,'Sarah ','Sweet','555-555-5055','2sweet4U@hello.com');


    --
    -- Table structure for table `LocationVehicles`
    --

	DROP TABLE IF EXISTS `LocationVehicles`;
	CREATE TABLE `LocationVehicles` (
    `locationVehicleID` INT(11) NOT NULL AUTO_INCREMENT,
    `vehicleID` INT(11) NOT NULL,
    `locationID` INT(11) NOT NULL,
    `quantity` INT(11) NOT NULL,
    PRIMARY KEY (`locationVehicleID`),
    UNIQUE KEY `unique_location_vehicle` (`vehicleID`, `locationID`), -- Optional unique constraint
    KEY `fk_Vehicles_has_Locations_Locations1_idx` (`locationID`),
    KEY `fk_Vehicles_has_Locations_Vehicles1_idx` (`vehicleID`),
    CONSTRAINT `fk_Vehicles_has_Locations_Locations1` FOREIGN KEY (`locationID`)
        REFERENCES `Locations` (`locationID`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fk_Vehicles_has_Locations_Vehicles1` FOREIGN KEY (`vehicleID`)
        REFERENCES `Vehicles` (`vehicleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci; 

    --
    -- Dumping data for table `LocationVehicles`
    --


    INSERT INTO `LocationVehicles` VALUES (1,1,3,10),(2,2,2,10),(3,3,1,8);

    --
    -- Table structure for table `Locations`
    --

    DROP TABLE IF EXISTS `Locations`;
    CREATE TABLE `Locations` (
    `locationID` int(11) NOT NULL AUTO_INCREMENT,
    `addressID` int(11),
    PRIMARY KEY (`locationID`),
    UNIQUE KEY `locationID_UNIQUE` (`locationID`),
    KEY `fk_Locations_Addresses1_idx` (`addressID`),
    CONSTRAINT `fk_Locations_Addresses1` FOREIGN KEY (`addressID`) 
    REFERENCES `Addresses` (`addressID`) ON DELETE SET NULL 
    ON UPDATE CASCADE
    ) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 
    COLLATE=utf8mb4_general_ci;

    --
    -- Dumping data for table `Locations`
    --


    INSERT INTO `Locations` VALUES (2,1),(1,2),(3,3);

    --
    -- Table structure for table `OrderVehicles`
    --

	DROP TABLE IF EXISTS `OrderVehicles`;
	CREATE TABLE `OrderVehicles` (
    `ordervehicleID` INT(11) NOT NULL AUTO_INCREMENT,
    `orderID` INT(11) NOT NULL,
    `vehicleID` INT(11) NOT NULL,
    `saleAmount` DECIMAL(9,2) NOT NULL,
    `quantity` INT(11) NOT NULL,
    PRIMARY KEY (`ordervehicleID`),
    UNIQUE KEY `unique_order_vehicle` (`orderID`, `vehicleID`), -- Optional: ensures a vehicle isn't listed twice per order
    KEY `fk_Orders_has_Vehicles_Vehicles1_idx` (`vehicleID`),
    KEY `fk_Orders_has_Vehicles_Orders1_idx` (`orderID`),
    CONSTRAINT `fk_Orders_has_Vehicles_Orders1` FOREIGN KEY (`orderID`) 
        REFERENCES `Orders` (`orderID`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fk_Orders_has_Vehicles_Vehicles1` FOREIGN KEY (`vehicleID`)
        REFERENCES `Vehicles` (`vehicleID`) ON DELETE CASCADE 
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


    --
    -- Dumping data for table `OrderVehicles`
    --

    INSERT INTO `OrderVehicles` VALUES (1,1,2,45000.00,1),
    (2,1,3,35000.00,1),
    (3,2,1,20000.00,1),
    (4,3,3,70000.00,2);

    --
    -- Table structure for table `Orders`
    --

    DROP TABLE IF EXISTS `Orders`;
    CREATE TABLE `Orders` (
    `orderID` int(11) NOT NULL AUTO_INCREMENT,
    `customerID` int(11),
    `locationID` int(11),
    `employeeID` int(11),
    `dateTime` datetime NOT NULL,
    PRIMARY KEY (`orderID`),
    UNIQUE KEY `orderID_UNIQUE` (`orderID`),
    KEY `fk_Orders_Customers1_idx` (`customerID`),
    KEY `fk_Orders_Employees1_idx` (`employeeID`),
    KEY `fk_Orders_locations1_idx` (`locationID`),
    CONSTRAINT `fk_Orders_Customers1` FOREIGN KEY (`customerID`)
    REFERENCES `Customers` (`customerID`) ON DELETE SET NULL 
    ON UPDATE NO ACTION,
    CONSTRAINT `fk_Orders_Employees1` FOREIGN KEY (`employeeID`) 
    REFERENCES `Employees` (`employeeID`) ON DELETE SET NULL 
    ON UPDATE NO ACTION,
    CONSTRAINT `fk_Orders_locations1` FOREIGN KEY (`locationID`) 
    REFERENCES `Locations` (`locationID`) ON DELETE SET NULL 
    ON UPDATE NO ACTION
    ) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 
    COLLATE=utf8mb4_general_ci;

    --
    -- Dumping data for table `Orders`
    --

    INSERT INTO `Orders` VALUES (1,1,1,3,'2025-11-05 00:11:43'),
    (2,2,3,2,'2025-11-05 00:11:43'),
    (3,3,2,1,'2025-11-05 00:11:43');

    --
    -- Table structure for table `Vehicles`
    --

    DROP TABLE IF EXISTS `Vehicles`;
    CREATE TABLE `Vehicles` (
    `vehicleID` int(11) NOT NULL AUTO_INCREMENT,
    `model` varchar(45) NOT NULL,
    `year` int(11) unsigned NOT NULL,
    `type` varchar(45) NOT NULL,
    `vehiclePrice` decimal(9,2) NOT NULL,
    PRIMARY KEY (`vehicleID`),
    UNIQUE KEY `vehiclesID_UNIQUE` (`vehicleID`)
    ) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 
    COLLATE=utf8mb4_general_ci;

    --
    -- Dumping data for table `Vehicles`
    --

    INSERT INTO `Vehicles` VALUES 
    (1,'Toyota Corolla',2016,'Sedan',20000.00),
    (2,'Ford F-150',2020,'Truck',45000.00),
    (3,'Jeep Wrangler',2022,'SUV',35000.00);

    SET FOREIGN_KEY_CHECKS = 1;

END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_update_address` (IN `p_addressID` INT(11), IN `p_street` VARCHAR(45), IN `p_state` VARCHAR(45), IN `p_city` VARCHAR(45), IN `p_zipCode` VARCHAR(45))   BEGIN
    UPDATE Addresses SET 
    street = p_street, state = p_state, city = p_city, zipCode = p_zipCode
    WHERE addressID = p_addressID;
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_update_customer` (IN `p_customerID` INT(11), IN `p_addressID` INT(11), IN `p_firstName` VARCHAR(45), IN `p_lastName` VARCHAR(45), IN `p_phoneNumber` VARCHAR(45), IN `p_email` VARCHAR(45))   BEGIN
UPDATE Customers SET 
    customerID = p_customerID,
    addressID = p_addressID, 
    firstName = p_firstName,
    lastName = p_lastName,
    phoneNumber = p_phoneNumber,
    email = p_email
    WHERE customerID = p_customerID;
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_update_employee` (IN `p_employeeID` INT(11), IN `p_locationID` INT(11), IN `p_addressID` INT(11), IN `p_firstName` VARCHAR(45), IN `p_lastName` VARCHAR(45), IN `p_phoneNumber` VARCHAR(45), IN `p_email` VARCHAR(45))   BEGIN
UPDATE Employees SET 
    addressID = p_addressID,
    locationID = p_locationID,
    firstName = p_firstName,
    lastName = p_lastName,
    phoneNumber = p_phoneNumber, 
    email = p_email
    WHERE employeeID = p_employeeID;
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_update_location` (IN `p_locationID` INT(11), IN `p_addressID` INT(11))   BEGIN
UPDATE Locations SET addressID = p_addressID
    WHERE locationID = p_locationID;
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_update_location_vehicle` (IN `p_locationVehicleID` INT(11), IN `p_vehicleID` INT(11), IN `p_quantity` INT(11))   BEGIN
UPDATE LocationVehicles SET vehicleID = p_vehicleID,
    quantity = p_quantity
    WHERE locationVehicleID = p_locationVehicleID;
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_update_order_vehicle` (IN `p_orderVehicleID` INT(11), IN `p_vehicleID` INT(11), IN `p_saleAmount` DECIMAL(9,2), IN `p_quantity` INT(11))   BEGIN

    DECLARE error_message VARCHAR(255); 
    DECLARE current_quantity INT(11);
    DECLARE prev_quantity INT(11);
    DECLARE v_locationVehicleID_to_update INT(11); 

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
        -- 1. Get the previous quantity from the order detail
        SELECT quantity INTO prev_quantity FROM OrderVehicles
            WHERE orderVehicleID = p_orderVehicleID;

        -- 2. Update the order detail record with new vehicle, amount, and quantity
        UPDATE OrderVehicles SET 
            vehicleID = p_vehicleID,
            saleAmount = p_saleAmount,
            quantity = p_quantity
            WHERE orderVehicleID = p_orderVehicleID;

    -- 3. Determine the correct LocationVehicle record to update
    -- 👇👇 FIX: Join tables correctly to find the associated locationVehicleID 👇👇
    SELECT LV.locationVehicleID INTO v_locationVehicleID_to_update
    FROM LocationVehicles LV
    JOIN Orders O ON LV.locationID = O.locationID
    JOIN OrderVehicles OV ON O.orderID = OV.orderID AND LV.vehicleID = OV.vehicleID
    WHERE OV.orderVehicleID = p_orderVehicleID;


        -- If the updated quantity is less than the previous, add the difference back to inventory
        IF p_quantity < prev_quantity THEN 
            -- Fetch the current stock level immediately before update
            SELECT quantity INTO current_quantity FROM LocationVehicles WHERE locationVehicleID = v_locationVehicleID_to_update;

            UPDATE LocationVehicles SET quantity = (current_quantity + (prev_quantity - p_quantity))
            WHERE locationVehicleID = v_locationVehicleID_to_update;

        -- If the updated quantity is more than the previous, subtract the difference from the inventory
        ELSEIF p_quantity > prev_quantity THEN
             -- Fetch the current stock level immediately before update
            SELECT quantity INTO current_quantity FROM LocationVehicles WHERE locationVehicleID = v_locationVehicleID_to_update;

            -- Check if there is enough inventory to subtract
            IF current_quantity < (p_quantity - prev_quantity) THEN
                SET error_message = CONCAT('Not enough inventory to fulfill update in order! Current stock: ', current_quantity);
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;

            ELSE 
                UPDATE LocationVehicles SET quantity = (current_quantity - (p_quantity - prev_quantity))
                WHERE locationVehicleID = v_locationVehicleID_to_update;
            END IF;
        END IF;
    COMMIT;
END$$

CREATE DEFINER=`cs340_reedgab`@`%` PROCEDURE `sp_update_vehicle` (IN `p_vehicleID` INT(11), IN `p_model` VARCHAR(45), IN `p_year` INT(11), IN `p_type` VARCHAR(45), IN `p_vehiclePrice` DECIMAL(9,2))   BEGIN
UPDATE Vehicles SET 
    model = p_model,
    year = p_year, 
    type = p_type, 
    vehiclePrice = p_vehiclePrice
    WHERE vehicleID = p_vehicleID;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Addresses`
--

CREATE TABLE `Addresses` (
  `addressID` int(11) NOT NULL,
  `street` varchar(45) NOT NULL,
  `state` varchar(45) NOT NULL,
  `city` varchar(45) NOT NULL,
  `zipCode` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Addresses`
--

INSERT INTO `Addresses` (`addressID`, `street`, `state`, `city`, `zipCode`) VALUES
(1, 'Sesame Street', 'California', 'San Francisco', '94102'),
(2, 'Pike Street', 'Washington', 'Seattle', '98133'),
(3, 'Alligator Boulevard', 'Florida', 'Orlando', '45103'),
(4, 'Wallingford Avenue', 'Washington', 'Seattle', '98133'),
(5, 'Tropical Street', 'Florida', 'Orlando', '45103');

-- --------------------------------------------------------

--
-- Table structure for table `Customers`
--

CREATE TABLE `Customers` (
  `customerID` int(11) NOT NULL,
  `addressID` int(11) DEFAULT NULL,
  `firstName` varchar(45) NOT NULL,
  `lastName` varchar(45) NOT NULL,
  `phoneNumber` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Customers`
--

INSERT INTO `Customers` (`customerID`, `addressID`, `firstName`, `lastName`, `phoneNumber`, `email`) VALUES
(1, 2, 'Christopher', 'Robin', '555-706-3410', 'hundredacre@hello.com'),
(2, 3, 'Benito', 'Vasquez', '555-345-2341', 'veranocaliente@hello.com'),
(3, 1, 'Elmo', 'Redd', '555-595-0020', 'iluvmygoldfish@hello.com');

-- --------------------------------------------------------

--
-- Table structure for table `Employees`
--

CREATE TABLE `Employees` (
  `employeeID` int(11) NOT NULL,
  `locationID` int(11) DEFAULT NULL,
  `addressID` int(11) DEFAULT NULL,
  `firstName` varchar(45) NOT NULL,
  `lastName` varchar(45) NOT NULL,
  `phoneNumber` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Employees`
--

INSERT INTO `Employees` (`employeeID`, `locationID`, `addressID`, `firstName`, `lastName`, `phoneNumber`, `email`) VALUES
(1, 2, 1, 'Michael', 'Smith', '555-212-4403', 'mrsmith@hello.com'),
(2, 3, 5, 'Kevin', 'Eleven', '555-111-0493', 'IamEleven@hello.com'),
(3, 1, 4, 'Sarah ', 'Sweet', '555-555-5055', '2sweet4U@hello.com');

-- --------------------------------------------------------

--
-- Table structure for table `Locations`
--

CREATE TABLE `Locations` (
  `locationID` int(11) NOT NULL,
  `addressID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Locations`
--

INSERT INTO `Locations` (`locationID`, `addressID`) VALUES
(2, 1),
(1, 2),
(3, 3);

-- --------------------------------------------------------

--
-- Table structure for table `LocationVehicles`
--

CREATE TABLE `LocationVehicles` (
  `locationVehicleID` int(11) NOT NULL,
  `vehicleID` int(11) NOT NULL,
  `locationID` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `LocationVehicles`
--

INSERT INTO `LocationVehicles` (`locationVehicleID`, `vehicleID`, `locationID`, `quantity`) VALUES
(1, 1, 3, 10),
(2, 2, 2, 3),
(3, 3, 1, 8);

-- --------------------------------------------------------

--
-- Table structure for table `Orders`
--

CREATE TABLE `Orders` (
  `orderID` int(11) NOT NULL,
  `customerID` int(11) DEFAULT NULL,
  `locationID` int(11) DEFAULT NULL,
  `employeeID` int(11) DEFAULT NULL,
  `dateTime` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Orders`
--

INSERT INTO `Orders` (`orderID`, `customerID`, `locationID`, `employeeID`, `dateTime`) VALUES
(1, 1, 1, 3, '2025-11-05 00:11:43'),
(2, 2, 3, 2, '2025-11-05 00:11:43'),
(3, 3, 2, 1, '2025-11-05 00:11:43');

-- --------------------------------------------------------

--
-- Table structure for table `OrderVehicles`
--

CREATE TABLE `OrderVehicles` (
  `ordervehicleID` int(11) NOT NULL,
  `orderID` int(11) NOT NULL,
  `vehicleID` int(11) NOT NULL,
  `saleAmount` decimal(9,2) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `OrderVehicles`
--

INSERT INTO `OrderVehicles` (`ordervehicleID`, `orderID`, `vehicleID`, `saleAmount`, `quantity`) VALUES
(1, 1, 2, 45000.00, 1),
(2, 1, 3, 35000.00, 1),
(3, 2, 1, 20000.00, 1),
(4, 3, 3, 70000.00, 2);

-- --------------------------------------------------------

--
-- Table structure for table `Vehicles`
--

CREATE TABLE `Vehicles` (
  `vehicleID` int(11) NOT NULL,
  `model` varchar(45) NOT NULL,
  `year` int(11) UNSIGNED NOT NULL,
  `type` varchar(45) NOT NULL,
  `vehiclePrice` decimal(9,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Vehicles`
--

INSERT INTO `Vehicles` (`vehicleID`, `model`, `year`, `type`, `vehiclePrice`) VALUES
(1, 'Toyota Corolla', 2016, 'Sedan', 20000.00),
(2, 'Ford F-150', 2020, 'Truck', 45000.00),
(3, 'Jeep Wrangler', 2022, 'SUV', 35000.00);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Addresses`
--
ALTER TABLE `Addresses`
  ADD PRIMARY KEY (`addressID`);

--
-- Indexes for table `Customers`
--
ALTER TABLE `Customers`
  ADD PRIMARY KEY (`customerID`),
  ADD UNIQUE KEY `customerID_UNIQUE` (`customerID`),
  ADD UNIQUE KEY `email_UNIQUE` (`email`),
  ADD UNIQUE KEY `phoneNumber_UNIQUE` (`phoneNumber`),
  ADD KEY `fk_Customers_Addresses1_idx` (`addressID`);

--
-- Indexes for table `Employees`
--
ALTER TABLE `Employees`
  ADD PRIMARY KEY (`employeeID`),
  ADD UNIQUE KEY `employeeID_UNIQUE` (`employeeID`),
  ADD UNIQUE KEY `email_UNIQUE` (`email`),
  ADD UNIQUE KEY `phoneNumber_UNIQUE` (`phoneNumber`),
  ADD KEY `fk_Employees_locations1_idx` (`locationID`),
  ADD KEY `fk_Employees_Addresses1_idx` (`addressID`);

--
-- Indexes for table `Locations`
--
ALTER TABLE `Locations`
  ADD PRIMARY KEY (`locationID`),
  ADD UNIQUE KEY `locationID_UNIQUE` (`locationID`),
  ADD KEY `fk_Locations_Addresses1_idx` (`addressID`);

--
-- Indexes for table `LocationVehicles`
--
ALTER TABLE `LocationVehicles`
  ADD PRIMARY KEY (`locationVehicleID`),
  ADD UNIQUE KEY `unique_location_vehicle` (`vehicleID`,`locationID`),
  ADD KEY `fk_Vehicles_has_Locations_Locations1_idx` (`locationID`),
  ADD KEY `fk_Vehicles_has_Locations_Vehicles1_idx` (`vehicleID`);

--
-- Indexes for table `Orders`
--
ALTER TABLE `Orders`
  ADD PRIMARY KEY (`orderID`),
  ADD UNIQUE KEY `orderID_UNIQUE` (`orderID`),
  ADD KEY `fk_Orders_Customers1_idx` (`customerID`),
  ADD KEY `fk_Orders_Employees1_idx` (`employeeID`),
  ADD KEY `fk_Orders_locations1_idx` (`locationID`);

--
-- Indexes for table `OrderVehicles`
--
ALTER TABLE `OrderVehicles`
  ADD PRIMARY KEY (`ordervehicleID`),
  ADD UNIQUE KEY `unique_order_vehicle` (`orderID`,`vehicleID`),
  ADD KEY `fk_Orders_has_Vehicles_Vehicles1_idx` (`vehicleID`),
  ADD KEY `fk_Orders_has_Vehicles_Orders1_idx` (`orderID`);

--
-- Indexes for table `Vehicles`
--
ALTER TABLE `Vehicles`
  ADD PRIMARY KEY (`vehicleID`),
  ADD UNIQUE KEY `vehiclesID_UNIQUE` (`vehicleID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Addresses`
--
ALTER TABLE `Addresses`
  MODIFY `addressID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `Customers`
--
ALTER TABLE `Customers`
  MODIFY `customerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Employees`
--
ALTER TABLE `Employees`
  MODIFY `employeeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Locations`
--
ALTER TABLE `Locations`
  MODIFY `locationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `LocationVehicles`
--
ALTER TABLE `LocationVehicles`
  MODIFY `locationVehicleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Orders`
--
ALTER TABLE `Orders`
  MODIFY `orderID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `OrderVehicles`
--
ALTER TABLE `OrderVehicles`
  MODIFY `ordervehicleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `Vehicles`
--
ALTER TABLE `Vehicles`
  MODIFY `vehicleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Customers`
--
ALTER TABLE `Customers`
  ADD CONSTRAINT `fk_Customers_Addresses1` FOREIGN KEY (`addressID`) REFERENCES `Addresses` (`addressID`) ON DELETE SET NULL ON UPDATE NO ACTION;

--
-- Constraints for table `Employees`
--
ALTER TABLE `Employees`
  ADD CONSTRAINT `fk_Employees_Addresses1` FOREIGN KEY (`addressID`) REFERENCES `Addresses` (`addressID`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_Employees_locations1` FOREIGN KEY (`locationID`) REFERENCES `Locations` (`locationID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `Locations`
--
ALTER TABLE `Locations`
  ADD CONSTRAINT `fk_Locations_Addresses1` FOREIGN KEY (`addressID`) REFERENCES `Addresses` (`addressID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `LocationVehicles`
--
ALTER TABLE `LocationVehicles`
  ADD CONSTRAINT `fk_Vehicles_has_Locations_Locations1` FOREIGN KEY (`locationID`) REFERENCES `Locations` (`locationID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Vehicles_has_Locations_Vehicles1` FOREIGN KEY (`vehicleID`) REFERENCES `Vehicles` (`vehicleID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `Orders`
--
ALTER TABLE `Orders`
  ADD CONSTRAINT `fk_Orders_Customers1` FOREIGN KEY (`customerID`) REFERENCES `Customers` (`customerID`) ON DELETE SET NULL ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Orders_Employees1` FOREIGN KEY (`employeeID`) REFERENCES `Employees` (`employeeID`) ON DELETE SET NULL ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Orders_locations1` FOREIGN KEY (`locationID`) REFERENCES `Locations` (`locationID`) ON DELETE SET NULL ON UPDATE NO ACTION;

--
-- Constraints for table `OrderVehicles`
--
ALTER TABLE `OrderVehicles`
  ADD CONSTRAINT `fk_Orders_has_Vehicles_Orders1` FOREIGN KEY (`orderID`) REFERENCES `Orders` (`orderID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Orders_has_Vehicles_Vehicles1` FOREIGN KEY (`vehicleID`) REFERENCES `Vehicles` (`vehicleID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
