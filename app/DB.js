// Connect to the database
const { Client } = require('pg');
const client = new Client({
    user: "admin",
    password: "admin",
    host: "localhost",
    port: 5432,
    database: "viewcampus"
});

// Function to perform SELECT operation
async function selectFromTable(tableName) {
    try {
        const result = await client.query(`SELECT * FROM ${tableName}`);
        console.table(result.rows);
    } catch (error) {
        console.error('Error executing SELECT query:', error);
    }
}

// Function to perform INSERT operation
async function insertIntoTable(tableName, values) {
    try {
        const query = `INSERT INTO ${tableName} VALUES (${values})`;
        await client.query(query);
        console.log('Data inserted successfully.');
    } catch (error) {
        console.error('Error executing INSERT query:', error);
    }
}

// Function to perform DELETE operation
async function deleteFromTable(tableName, condition) {
    try {
        const query = `DELETE FROM ${tableName} WHERE ${condition}`;
        await client.query(query);
        console.log('Data deleted successfully.');
    } catch (error) {
        console.error('Error executing DELETE query:', error);
    }
}

// Function to perform UPDATE operation
async function updateTable(tableName, columnValues, condition) {
    try {
        let setValues = '';
        for (const key in columnValues) {
            setValues += `${key} = ${columnValues[key]}, `;
        }
        setValues = setValues.slice(0, -2); // Remove the trailing comma and space
        const query = `UPDATE ${tableName} SET ${setValues} WHERE ${condition}`;
        await client.query(query);
        console.log('Data updated successfully.');
    } catch (error) {
        console.error('Error executing UPDATE query:', error);
    }
}

// Connect to the database and execute operations
async function main() {
    try {
        await client.connect(); // Connect to the database
        await selectFromTable('profil');
        await selectFromTable('club');
        // Perform other operations as needed
    } catch (error) {
        console.error('Error:', error);
    } finally {
        await client.end(); // Close the connection
    }
}

main();
