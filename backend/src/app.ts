import express, { Application } from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import dotenv from "dotenv";
import path from "path";

// Import routes
import authRoutes from "./routes/authRoutes";
import userRoutes from "./routes/userRoutes";
import songRoutes from "./routes/songRoutes";
import playlistRoutes from "./routes/playlistRoutes";
import favoriteRoutes from "./routes/favoriteRoutes";
import historyRoutes from "./routes/historyRoutes";
import genreRoutes from "./routes/genreRoutes";
import searchRoutes from "./routes/searchRoutes"
import adminSongRoutes from "./routes/admin/adminSongRoutes"
import adminArtistRoutes from "./routes/admin/adminArtistRoutes";
import adminAlbumRoutes from "./routes/admin/adminAlbumRoutes";
import adminUserRoutes from "./routes/admin/adminUserRoutes";
import adminGenreRoutes from "./routes/admin/adminGenreRoutes";

// Import middleware
import { errorHandler, notFoundHandler } from "./middleware/errorHandler";

// Load environment variables
dotenv.config();

const app: Application = express();

// Middleware
app.use(helmet()); // Security header
app.use(cors()); // Enable CORS
app.use(morgan("dev")); // Logging
app.use(express.json()); // Parse JSON body
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded body

// Health check
app.get("/health", (_req, res) => {
  res.json({
    success: true,
    message: "Server is running",
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/uploads", express.static(path.join(__dirname, "../uploads")));
app.use("/api/songs", songRoutes);
app.use("/api/playlists", playlistRoutes);
app.use("/api/favorites", favoriteRoutes);
app.use("/api/history", historyRoutes);
app.use("/api/genres", genreRoutes);
app.use('/api/search', searchRoutes);
app.use('/api/admin/songs', adminSongRoutes);
app.use('/api/admin/artists', adminArtistRoutes);
app.use('/api/admin/albums', adminAlbumRoutes);
app.use('/api/admin/users', adminUserRoutes);
app.use('/api/admin/genres', adminGenreRoutes);
// Error handling middleware (phải đặt cuối cùng)
app.use(notFoundHandler);
app.use(errorHandler);

export default app;
