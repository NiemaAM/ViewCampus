const express = require("express");
const app = express();
const cors = require("cors");
const pool = require("./db");

app.use(cors());
app.use(express.json());

// User Signup
app.post("/signup", async (req, res) => {
    try {
        const { profil_id, first_name, last_name, email, password, profil_type } = req.body;
        const newUser = await pool.query(
            "INSERT INTO profil (profil_id, first_name, last_name, email, password, profil_type) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *",
            [profil_id, first_name, last_name, email, password, profil_type]
        );
        res.json(newUser.rows[0]);
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ error: error.message });
    }
});

// User Login
app.post("/login", async (req, res) => {
    try {
        const { identifier, password } = req.body;
        
        const user = await pool.query("SELECT * FROM profil WHERE email = $1 AND password = $2", [identifier, password]);

        if (user.rows.length === 0) {
            return res.status(404).json({ message: "Invalid email or password" });
        }

        res.json({ message: "Login successful", user: user.rows[0] });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ error: error.message });
    }
});


// Get All Events
app.get("/events", async (req, res) => {
    try {
        const allEvents = await pool.query("SELECT * FROM event");
        res.json(allEvents.rows);
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ error: error.message });
    }
});

// Get User's Events
app.get("/user/events", async (req, res) => {
    try {
        const { profil_id } = req.body;
        const userEvents = await pool.query("SELECT * FROM event WHERE profil_id = $1", [profil_id]);
        res.json(userEvents.rows);
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ error: error.message });
    }
});

// Create Event
app.post("/event", async (req, res) => {
    try {
        const { profil_id, name, description, start_date_time, end_date_time, event_type, room_number, building_number } = req.body;
        const newEvent = await pool.query(
            "INSERT INTO event (profil_id, name, description, start_date_time, end_date_time, event_type, room_number, building_number) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *",
            [profil_id, name, description, start_date_time, end_date_time, event_type, room_number, building_number]
        );
        res.json(newEvent.rows[0]);
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ error: error.message });
    }
});

// Update Event
app.put("/events/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { profil_id, name, description, start_date_time, end_date_time, event_type, room_number, building_number } = req.body;
        const updateEvent = await pool.query(
            "UPDATE event SET name = $1, description = $2, start_date_time = $3, end_date_time = $4, event_type = $5, room_number = $6, building_number = $7 WHERE event_id = $8 AND profil_id = $9",
            [name, description, start_date_time, end_date_time, event_type, room_number, building_number, id, profil_id]
        );
        res.json({ message: "Event updated!" });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ error: error.message });
    }
});

// Delete Event
app.delete("/events/:id", async (req, res) => {
    try {
        const { id } = req.params;
        //const { profil_id } = req.body;
        const deleteEvent = await pool.query("DELETE FROM event WHERE event_id = $1", [id]);
        res.json({ message: "Event deleted!" });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ error: error.message });
    }
});

app.listen(5000, () => {
    console.log("server has started on port 5000");
});
