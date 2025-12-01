import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

const dbConfig = {
  host: process.env.DB_HOST || "localhost",
  port: parseInt(process.env.DB_PORT || "3306"),
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "music_app",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: "utf8mb4",
};

// Tạo connection pool
const pool = mysql.createPool(dbConfig);

// Test connection
pool
  .getConnection()
  .then((connection: any) => {
    console.log("Database connected successfully");
    connection.release();
  })
  .catch((error: any) => {
    console.error("Database connection error:", error);
  });

export default pool;
