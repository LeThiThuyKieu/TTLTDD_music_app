import { Router } from "express";
import { GenreController } from "../controllers/genreController";
import { authenticate, optionalAuth } from "../middleware/auth";
import { validate, validateGenre } from "../utils/validation";

const router = Router();

// Public - list all genres
router.get("/", optionalAuth, GenreController.getAll);

// Public - get single genre
router.get("/:id", optionalAuth, GenreController.getById);

// Protected - create genre
router.post("/", authenticate, validate(validateGenre), GenreController.create);

// Protected - update genre
router.put(
  "/:id",
  authenticate,
  validate(validateGenre),
  GenreController.update
);

// Protected - delete genre
router.delete("/:id", authenticate, GenreController.delete);

export default router;
