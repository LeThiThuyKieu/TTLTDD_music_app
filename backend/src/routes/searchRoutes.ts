import { Router } from "express";
import { optionalAuth } from "../middleware/auth";
import { SearchController } from '../controllers/searchController';

const router = Router();

// GET /api/search?q=abc
router.get("/", optionalAuth, SearchController.search);

export default router;
