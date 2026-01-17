import { Router } from "express";
import { authenticate } from "../../middleware/auth";
import { AdminDashboardController } from "../../controllers/admin/dashboardController";
import { requireAdmin } from "../../middleware/admin";

const router = Router();

//1. ( GET /api/admin/dashboard/overview )
router.get("/overview", authenticate, requireAdmin, AdminDashboardController.getOverview);

//2. ( GET /api/admin/dashboard/weekly )
router.get("/weekly", authenticate, requireAdmin, AdminDashboardController.getWeekly);

// 3. ( GET /api/admin/dashboard/highlights )
router.get("/highlights", authenticate, requireAdmin, AdminDashboardController.getHighlights);

//4. ( GET /api/admin/dashboard/topsongs )
router.get("/topsongs", authenticate, requireAdmin, AdminDashboardController.getTopSongs);

//5. ( GET /api/admin/dashboard/genredistribution )
router.get("/genredistribution", authenticate, requireAdmin, AdminDashboardController.getGenreDistribution);

export default router;
