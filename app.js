// ########################################
// ########## SETUP

// Express
const express = require('express');
const app = express();
const session = require('express-session'); 
const flash = require('connect-flash');
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const PORT = 5018;

// Database
const db = require('./database/db-connector');

// Handlebars
const { engine } = require('express-handlebars'); // Import express-handlebars engine
app.engine('.hbs', engine({ extname: '.hbs' })); // Create instance of handlebars
app.set('view engine', '.hbs'); // Use handlebars engine for *.hbs files.
app.use(express.static('public'));
app.use(session({
    secret: 'LqI4zK2mYpB9hUvC6oF1eD7sJ5gR0tW3aX8nMpOqRsTuVwXyZcDfGhJkLmNoPqRsTuVwX',
    resave: false,
    saveUninitialized: false
}));

// Configure connect-flash middleware
app.use(flash())

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES

app.get('/check-schema', async function(req, res) {
    try {
        const [rows] = await db.query('DESCRIBE LocationVehicles;');
        res.json(rows);
    } catch (error) {
        res.status(500).send('Error fetching schema: ' + error.message);
    }
});

app.get('/Locations/:locationID/inventory', async function (req, res) {
    const locationID = req.params.locationID;
    try {
        // Query to provide Location Name
        const query1 = `SELECT Locations.addressID, CONCAT(Addresses.city, " Dealership") AS locationName FROM Locations \
            JOIN Addresses ON Locations.addressID = Addresses.addressID \
            WHERE locationID = ?;`;

        // Query to provide Inventory for Location
        const query2 = `SELECT LocationVehicles.locationVehicleID AS entryID, Vehicles.model, Vehicles.year, Vehicles.type, \ 
            LocationVehicles.quantity AS quantity FROM LocationVehicles \
            JOIN Vehicles ON LocationVehicles.vehicleID = Vehicles.vehicleID \ 
            WHERE LocationVehicles.locationID = ?;`;

        // Execute Queries
        const [locationResult] = await db.query(query1, [locationID]);
        const locationName = locationResult[0].locationName;
        const addressID = locationResult[0].addressID;
        const [inventory] = await db.query(query2, [locationID]);;

        // Render the page
        res.render('project-locations-inventory', {addressID: addressID, inventory: inventory, locationName: locationName});
    } catch (error) {
        console.error('Error executing inventory:', error);
        res.status(500).send('An error occurred while fetching inventory data.');
    }
});

app.get('/Orders/:orderID/vehicles', async function (req, res) {
    const orderID = req.params.orderID;
    try {
        // Query to provide a list of Vehicles and their quantity in an Order
        const query1 = `SELECT OrderVehicles.ordervehicleID AS entryID, Vehicles.year, Vehicles.model, OrderVehicles.quantity AS quantity FROM OrderVehicles \
        JOIN Vehicles ON OrderVehicles.vehicleID = Vehicles.vehicleID \
            WHERE orderID = ? \
            GROUP BY Vehicles.year, Vehicles.model;`;

        const [vehicles] = await db.query(query1, [orderID]);
        
        // Render the page
        res.render('project-order-vehicles', {vehicles: vehicles, orderID: orderID});
    } catch (error) {
        console.error('Error executing inventory:', error);
        res.status(500).send('An error occurred while fetching inventory data.');
    }
});


// Route to render the homepage
app.get('/', function(req, res) {
    // Get the flash messages stored under the 'success' key
    const successMessage = req.flash('success');

    res.render('home', { 
        // Pass the message to the template only if one exists
        successMessage: successMessage.length ? successMessage[0] : null 
    });
});



app.get('/Addresses', async function (req, res) {
    try {
        // Query to provide a list of all Addresses
        const query1 = `SELECT * FROM Addresses;`;
        const [addresses] = await db.query(query1);;

        // Render the page
        res.render('project-addresses', { addresses: addresses});
    } catch (error) {
        console.error('Error executing queries:', error);
    
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/Customers', async function (req, res) {
    try {
        // Query to provide a list of all Customers with their Addresses
        const query1 = `SELECT Customers.customerID, CONCAT(Addresses.street, ', ', Addresses.city, ', ', Addresses.state, ', ', Addresses.zipCode) AS Address, Customers.firstName, \
        Customers.lastName, Customers.phoneNumber, Customers.email FROM Customers \
        LEFT JOIN Addresses ON Customers.addressID = Addresses.addressID \
        ORDER BY Customers.customerID ASC;`;

        // Query to provide a list of all Addresses
        const query2 = `SELECT * FROM Addresses;`;

        const [customers] = await db.query(query1);;
        const [addresses] = await db.query(query2);;

        // Render the page
        res.render('project-customers', { customers: customers, addresses: addresses});
    } catch (error) {
        console.error('Error executing queries:', error);
    
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/Employees', async function (req, res) {
    try {
        // Query to provide a list of all Employees with their Addresses and Locations
        const query1 = `SELECT Employees.employeeID,  CONCAT(LocationAddresses.city, ' Dealership') AS location, \
        CONCAT(EmployeeAddresses.street, ', ', EmployeeAddresses.city, ', ', EmployeeAddresses.state, ', ', EmployeeAddresses.zipCode) AS Address, \
        Employees.firstName, Employees.lastName, Employees.phoneNumber, Employees.email  FROM Employees \
        LEFT JOIN Locations ON Employees.locationID = Locations.locationID \
        LEFT JOIN Addresses AS EmployeeAddresses ON Employees.addressID = EmployeeAddresses.addressID \
        LEFT JOIN Addresses AS LocationAddresses ON Locations.addressID = LocationAddresses.addressID \
        ORDER BY Employees.employeeID ASC;`;

        // Query to provide a list of all Addresses
        const query2 = `SELECT * FROM Addresses;`;
        
        // Query to provide a list of all Locations
        const query3 = `SELECT Locations.locationID, CONCAT(Addresses.city, ' Dealership') AS locationName FROM Locations
        JOIN Addresses ON Locations.addressID = Addresses.addressID;`;
        
        const [employees] = await db.query(query1);;
        const [addresses] = await db.query(query2);;
        const [locations] = await db.query(query3);;

        // Render the page
        res.render('project-employees', { employees: employees, locations: locations, addresses: addresses});
    } catch (error) {
        console.error('Error executing queries:', error);
    
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});



app.get('/Locations', async function (req, res) {
    try {
        // Query to provide a list of all Locations with their Addresses
        const query1 = `SELECT Locations.locationID, CONCAT(Addresses.street, ', ', Addresses.city, ', ', Addresses.state, ', ', Addresses.zipCode) AS Address, \
       CONCAT(Addresses.city, ' Dealership') AS locationName FROM Locations \
        JOIN Addresses ON Locations.addressID = Addresses.addressID \
        ORDER BY Locations.locationID ASC;`;
        const query2 = `SELECT * FROM Addresses;`;
        const query3 = `SELECT * FROM Vehicles;`;
        const query4 = `SELECT LocationVehicles.locationVehicleID AS entryID, Vehicles.model AS vehicleModel, CONCAT(Addresses.city, ' Dealership') AS locationName
        FROM LocationVehicles
        JOIN Vehicles ON LocationVehicles.vehicleID = Vehicles.vehicleID
        JOIN Locations ON LocationVehicles.locationID = Locations.locationID
        JOIN Addresses ON Locations.addressID = Addresses.addressID;`;
        const [locations] = await db.query(query1);;
        const [addresses] = await db.query(query2);;
        const [vehicles] = await db.query(query3);;
        const [locationVehicles] = await db.query(query4);;

        // Render the page
        res.render('project-locations', { locations: locations, addresses: addresses, vehicles: vehicles, locationVehicles: locationVehicles});
    } catch (error) {
        console.error('Error executing queries:', error);
    
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/Vehicles', async function (req, res) {
    try {
        // Query to provide a list of all Vehicles
        const query1 = `SELECT * FROM Vehicles ORDER BY vehicleID ASC;`;
        const [vehicles] = await db.query(query1);;

        // Render the page
        res.render('project-vehicles', { vehicles: vehicles});
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/Orders', async function (req, res) {
    try {
        // Query to provide a list of all Orders with relevant information
        const query1 = `SELECT Orders.orderID, CONCAT(Customers.firstName, ' ', Customers.lastName) AS customer, \
        CONCAT(Employees.firstName, ' ', Employees.lastName) AS employee, CONCAT(Addresses.city, ' Dealership') AS locationName, \
        Orders.dateTime, SUM(OrderVehicles.quantity) AS vehiclesSold, SUM(OrderVehicles.saleAmount * OrderVehicles.quantity) AS transactionTotal,  \
         SUM((OrderVehicles.saleAmount * OrderVehicles.quantity) - (Vehicles.vehiclePrice * OrderVehicles.quantity)) AS profit FROM Orders \
        INNER JOIN Customers ON Orders.customerID = Customers.customerID \  
        INNER JOIN Employees ON Orders.employeeID = Employees.employeeID \
        INNER JOIN Locations ON Orders.locationID = Locations.locationID \
        INNER JOIN Addresses ON Locations.addressID = Addresses.addressID \
        LEFT JOIN OrderVehicles ON Orders.orderID = OrderVehicles.orderID \
        LEFT JOIN Vehicles ON OrderVehicles.vehicleID = Vehicles.vehicleID \
        GROUP BY Orders.orderID;`;

        // Additional queries to provide data for dropdowns when adding a new Order
        const query2 = `SELECT customerID, firstName, lastName FROM Customers;`;
        const query3 = `SELECT employeeID, firstName, lastName FROM Employees;`;
        const query4 = `SELECT Locations.locationID, CONCAT(Addresses.city, ' Dealership') AS locationName FROM Locations \
        JOIN Addresses ON Locations.addressID = Addresses.addressID;`;
        const query5 = `SELECT OrderVehicles.ordervehicleID AS entryID, Vehicles.model AS vehicleModel, Orders.orderID FROM OrderVehicles
        JOIN Vehicles ON OrderVehicles.vehicleID = Vehicles.vehicleID
        JOIN Orders ON OrderVehicles.orderID = Orders.orderID;`;
        const query6 = `SELECT * FROM Vehicles;`;

        // Execute Queries
        const [orders] = await db.query(query1);;
        const [customers] = await db.query(query2);;
        const [employees] = await db.query(query3);;
        const [locations] = await db.query(query4);;
        const [ordervehicles] = await db.query(query5);;
        const [vehicles] = await db.query(query6);;

        // Render the page
        res.render('project-orders', { orders: orders, customers: customers, employees: employees, locations: locations, ordervehicles: ordervehicles, vehicles: vehicles});
    } catch (error) {
        console.error('Error executing queries:', error);
    
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});


// CREATE ROUTES //
app.post('/Addresses/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const street = data.street;
        const city = data.city;
        const state = data.state;
        const zipCode = data.zip_code;

        await db.query('SET @new_address_id = NULL;');

        // 2. Call the stored procedure, passing the variable name as the 5th argument
        // Note: We use string interpolation here instead of '?' for the @variable name itself,
        // but still use '?' for the user inputs to prevent SQL injection.
        const query1 = `CALL sp_create_address(?, ?, ?, ?, @new_address_id);`;
        const queryArgs = [street, city, state, zipCode];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Addresses');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the address.'
        );
    }
});

app.post('/Customers/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const addressID = data.address_ID;
        const firstName = data.first_name;
        const lastName = data.last_name;
        const phoneNumber = data.phone_number;
        const email = data.email;

        await db.query('SET @new_customer_id = NULL;');

        // 2. Call the stored procedure, passing the variable name as the 6th argument
        const query1 = `CALL sp_create_customer(?, ?, ?, ?, ?, @new_customer_id);`;
        const queryArgs = [addressID, firstName, lastName, phoneNumber, email];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Customers');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the customer.'
        );
    }
});

app.post('/Employees/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const locationID = data.location_ID;
        const addressID = data.address_ID;
        const firstName = data.first_name;
        const lastName = data.last_name;
        const phoneNumber = data.phone_number;
        const email = data.email;

        await db.query('SET @new_employee_id = NULL;');

        // 2. Call the stored procedure, passing the variable name as the 7th argument
        const query1 = `CALL sp_create_employee(?, ?, ?, ?, ?, ?, @new_employee_id);`;
        const queryArgs = [locationID, addressID, firstName, lastName, phoneNumber, email];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Employees');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the employee.'
        );
    }
});

app.post('/Locations/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const addressID = data.address_ID;

        await db.query('SET @new_location_id = NULL;');

        // 2. Call the stored procedure, passing the variable name as the 2nd argument
        const query1 = `CALL sp_create_location(?, @new_location_id);`;
        const queryArgs = [addressID];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Locations');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the location.'
        );
    }
});

app.post('/Locations/inventory/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const locationID = data.location_ID;
        const vehicleID = data.vehicle_ID;
        const quantity = data.quantity;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_create_location_vehicle(?, ?, ?);`;
        const queryArgs = [locationID, vehicleID, quantity];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Locations');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for adding vehicle to location.'
        );
    }
});

app.post('/Vehicles/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const model = data.model;
        const year = data.year;
        const type = data.type;
        const vehiclePrice = data.vehicle_price;

        await db.query('SET @new_vehicle_id = NULL;');

        // 2. Call the stored procedure, passing the variable name as the 5th argument
        const query1 = `CALL sp_create_vehicle(?, ?, ?, ?, @new_vehicle_id);`;
        const queryArgs = [model, year, type, vehiclePrice];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Vehicles');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the vehicle.'
        );
    }
});

app.post('/Orders/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const customerID = data.customer_ID;
        const employeeID = data.employee_ID;
        const locationID = data.location_ID;
        const dateTime = data.date_time;

        await db.query('SET @new_order_id = NULL;');

        // 2. Call the stored procedure, passing the variable name as the 5th argument
        const query1 = `CALL sp_create_order(?, ?, ?, ?, @new_order_id);`;
        const queryArgs = [customerID, employeeID, locationID, dateTime];
        await db.query(query1, queryArgs);
        console.log('Order created with args:', queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Orders');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the order.'
        );
    }
});

app.post('/Orders/vehicles/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const orderID = data.order_ID;
        const vehicleID = data.vehicle_ID;
        const quantity = data.quantity;
        const saleAmount = data.sale_amount;

        // Create and execute our query
        const query1 = `CALL sp_create_order_vehicle(?, ?, ?, ?);`;
        const queryArgs = [orderID, vehicleID, saleAmount, quantity];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Orders');
    } catch (error) {
        console.error('Error executing queries:', error);
        // The catch block will receive the SQLSTATE '45000' custom error message
        res.status(500).send(
            'An error occurred: ' + error.sqlMessage // Display the specific SQL error message to the user
        );
    }
});   

// // UPDATE ROUTES //
app.post('/Addresses/update', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const addressID = data.update_address_ID;
        const street = data.street;
        const city = data.city;
        const state = data.state;
        const zipCode = data.zip_code;

        if (!addressID || isNaN(parseInt(addressID))) {
            console.error(`Invalid or missing ID for address update: ${addressID}`);
            return res.status(400).send('Error: Invalid or missing Address ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_update_address(?, ?, ?, ?, ?);`;
        const queryArgs = [addressID, street, state, city, zipCode];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Addresses');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the address.'
        );
    }
});

app.post('/Customers/update', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const customerID = data.update_customer_ID;
        const addressID = data.address_ID;
        const firstName = data.first_name;
        const lastName = data.last_name;
        const phoneNumber = data.phone_number;
        const email = data.email;

        if (!customerID || isNaN(parseInt(customerID))) {
            console.error(`Invalid or missing ID for customer update: ${customerID}`);
            return res.status(400).send('Error: Invalid or missing Customer ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_update_customer(?, ?, ?, ?, ?, ?);`;
        const queryArgs = [customerID, addressID, firstName, lastName, phoneNumber, email];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Customers');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the customer.'
        );
    }
});

app.post('/Employees/update', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const employeeID = data.update_employee_ID;
        const locationID = data.location_ID;
        const addressID = data.address_ID;
        const firstName = data.first_name;
        const lastName = data.last_name;
        const phoneNumber = data.phone_number;
        const email = data.email;

        if (!employeeID || isNaN(parseInt(employeeID))) {
            console.error(`Invalid or missing ID for employee update: ${employeeID}`);
            return res.status(400).send('Error: Invalid or missing Employee ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_update_employee(?, ?, ?, ?, ?, ?, ?);`;
        const queryArgs = [employeeID, locationID, addressID, firstName, lastName, phoneNumber, email];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Employees');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the employee.'
        );
    }
});

app.post('/Locations/update', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const locationID = data.update_location_ID;
        const addressID = data.address_ID;

        if (!locationID || isNaN(parseInt(locationID))) {
            console.error(`Invalid or missing ID for location update: ${locationID}`);
            return res.status(400).send('Error: Invalid or missing Location ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_update_location(?, ?);`;
        const queryArgs = [locationID, addressID];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Locations');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the location.'
        );
    }
});

app.post('/Locations/inventory/update', async function (req, res) {
    console.log('Received req.body:', req.body);
    try {
        // Parse frontend form information
        let data = req.body;
        const entryID = data.update_location_vehicle_ID;
        const vehicleID = data.vehicle_ID;
        const quantity = data.quantity;
        if (!entryID || isNaN(parseInt(entryID))) {
            console.error(`Invalid or missing ID for location vehicle update: ${entryID}`);
            return res.status(400).send('Error: Invalid or missing Location Vehicle Entry ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_update_location_vehicle(?, ?, ?);`;
        const queryArgs = [entryID, vehicleID, quantity];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Locations');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for updating vehicle quantity at location.'
        );
    }
});

app.post('/Vehicles/update', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const vehicleID = data.update_vehicle_ID;
        const model = data.model;
        const year = data.year;
        const type = data.type;
        const vehiclePrice = data.vehicle_price;

        if (!vehicleID || isNaN(parseInt(vehicleID))) {
            console.error(`Invalid or missing ID for vehicle update: ${vehicleID}`);
            return res.status(400).send('Error: Invalid or missing Vehicle ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_update_vehicle(?, ?, ?, ?, ?);`;
        const queryArgs = [vehicleID, model, year, type, vehiclePrice];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Vehicles');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the vehicle.'
        );
    }
});

app.post('/Orders/vehicles/update', async function (req, res) {
    console.log('Received req.body:', req.body);
    try {
        // Parse frontend form information
        let data = req.body;
        const entryID = data.update_order_vehicle_ID;
        const vehicleID = data.vehicle_ID;
        const quantity = data.quantity;
        const saleAmount = data.sale_amount;

        if (!entryID || isNaN(parseInt(entryID))) {
            console.error(`Invalid or missing ID for order vehicle update: ${entryID}`);
            return res.status(400).send('Error: Invalid or missing Order Vehicle Entry ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_update_order_vehicle(?, ?, ?, ?);`;
        const queryArgs = [entryID, vehicleID, saleAmount, quantity];
        await db.query(query1, queryArgs);

        // Redirect the user to the updated webpage data
        res.redirect('/Orders');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for updating vehicle in order.<br>Specific Error: ' + error.sqlMessage
        );
    }
});


// DELETE ROUTES // 
app.post('/Addresses/delete', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const addressId = data.delete_address_id;

        if (!addressId || isNaN(parseInt(addressId))) {
            console.error(`Invalid or missing ID for address deletion: ${addressId}`);
            return res.status(400).send('Error: Invalid or missing Address ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_delete_address(?);`;
        await db.query(query1, [addressId]);

        // Redirect the user to the updated webpage data
        res.redirect('/Addresses');
    } catch (error) {
        console.error('Error executing queries:', error);

        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the address.'
        );
    }
});

app.post('/Customers/delete', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const customerId = data.delete_customer_id;

        if (!customerId || isNaN(parseInt(customerId))) {
            console.error(`Invalid or missing ID for customer deletion: ${customerId}`);
            return res.status(400).send('Error: Invalid or missing Customer ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_delete_customer(?);`;
        await db.query(query1, [customerId]);

        // Redirect the user to the updated webpage data
        res.redirect('/Customers');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the customer.'
        );
    }
});

app.post('/Employees/delete', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const employeeId = data.delete_employee_id;

        if (!employeeId || isNaN(parseInt(employeeId))) {
            console.error(`Invalid or missing ID for employee deletion: ${employeeId}`);
            return res.status(400).send('Error: Invalid or missing Employee ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_delete_employee(?);`;
        await db.query(query1, [employeeId]);

        // Redirect the user to the updated webpage data
        res.redirect('/Employees');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the employee.'
        );
    }
});

app.post('/Locations/delete', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const locationId = data.delete_location_id;

        if (!locationId || isNaN(parseInt(locationId))) {
            console.error(`Invalid or missing ID for location deletion: ${locationId}`);
            return res.status(400).send('Error: Invalid or missing Location ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_delete_location(?);`;
        await db.query(query1, [locationId]);


        // Redirect the user to the updated webpage data
        res.redirect('/Locations');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the location.'
        );
    }
});

app.post('/Vehicles/delete', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const vehicleId = data.delete_vehicle_id;

        if (!vehicleId || isNaN(parseInt(vehicleId))) {
            console.error(`Invalid or missing ID for vehicle deletion: ${vehicleId}`);
            return res.status(400).send('Error: Invalid or missing Vehicle ID provided.');
        }

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        // Corrected SP name assumption: 'sp_delete_vehicle'
        const query1 = `CALL sp_delete_vehicle(?);`; 
        await db.query(query1, [vehicleId]);

        // Redirect the user to the updated webpage data
        res.redirect('/Vehicles');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the vehicle.'
        );
    }
});

app.post('/Orders/delete', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;
        const orderId = data.delete_order_id;

        if (!orderId || isNaN(parseInt(orderId))) {
            console.error(`Invalid or missing ID for order deletion: ${orderId}`);
            return res.status(400).send('Error: Invalid or missing Order ID provided.');
        }

        const query1 = `CALL sp_delete_order(?);`; 
        await db.query(query1, [orderId]);

        // Redirect the user to the updated webpage data
        res.redirect('/Orders');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries for the order.'
        );
    }
});

app.post('/reset', async function (req, res) {
    try {
        const query1 = `CALL sp_load_db();`;
        await db.query(query1);

        req.flash('success', 'Database Successfully Reset!');
        res.redirect('/'); 

    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});





// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});