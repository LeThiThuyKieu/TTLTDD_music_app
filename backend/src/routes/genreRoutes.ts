import { Router } from "express";
import { GenreController } from "../controllers/genreController";
import { authenticateFirebase, optionalAuth } from "../middleware/auth";
import { validate, validateGenre } from "../utils/validation";

const router = Router();

// Public - list all genres
router.get("/", optionalAuth, GenreController.getAll);

// Public - get single genre
router.get("/:id", optionalAuth, GenreController.getById);

// Protected - create genre
router.post(
  "/",
  authenticateFirebase,
  validate(validateGenre),
  GenreController.create
);

// Protected - update genre
router.put(
  "/:id",
  authenticateFirebase,
  validate(validateGenre),
  GenreController.update
);

// Protected - delete genre
router.delete("/:id", authenticateFirebase, GenreController.delete);

export default router;


