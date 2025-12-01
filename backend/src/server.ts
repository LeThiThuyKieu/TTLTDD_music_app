import app from "./app";
import "./config/database"; // Initialize database connection
import "./config/firebase"; // Initialize Firebase

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || "development"}`);
  console.log(`API URL: http://localhost:${PORT}/api`);
});


