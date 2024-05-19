const Pool = require("pg").Pool;

const pool = new Pool({
    user: "admin",
    password: "admin",
    howt: "localhost",
    port: 5432,
    database: "viewcampus"
});

module.exports = pool;