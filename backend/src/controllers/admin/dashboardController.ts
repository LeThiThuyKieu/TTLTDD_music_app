import { Response } from "express";
import { AuthenticatedRequest } from "../../models";
import { AdminDashboardService } from "../../services/admin/dashboardService";

export class AdminDashboardController {
// 1. API (GET /api/admin/dashboard/overview)
static async getOverview(req: AuthenticatedRequest, res: Response) {
    try {
      const data = await AdminDashboardService.getOverview();

      return res.status(200).json({
        success: true,
        data,
      });
    } catch (error) {
      console.error("Dashboard overview error:", error);
      return res.status(500).json({
        success: false,
        message: "Failed to load dashboard overview",
      });
    }
  }
    //2. API(GET /api/admin/dashboard/weekly)
   static async getWeekly(req: AuthenticatedRequest, res: Response) {
  try {
    const data = await AdminDashboardService.getWeekly();

    return res.json({
      success: true,
      data,
    });
  } catch (error) {
    console.error("Weekly dashboard error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to load weekly chart",
    });
  }
}


    // 3. API (Get api/admin/dashboard/highlights)
  static async getHighlights(req: AuthenticatedRequest, res: Response) {
    try {
      const data = await AdminDashboardService.getHighlights();

      return res.status(200).json({
        success: true,
        data,
      });
    } catch (error) {
      console.error("Dashboard highlight error:", error);
      return res.status(500).json({
        success: false,
        message: "Failed to load dashboard highlights",
      });
    }
  }

  //4. API (Get api/admin/dashboard/topsongs)
 static async getTopSongs(req: AuthenticatedRequest, res: Response) {
    try {
      const limit = Number(req.query?.limit) || 10;

      const data = await AdminDashboardService.getTopSongs(limit);

      return res.status(200).json({
        success: true,
        data,
      });
    } catch (error) {
      console.error("Top songs error:", error);
      return res.status(500).json({
        success: false,
        message: "Failed to load top songs",
      });
    }
  }
  // 5. API (GET /api/admin/dashboard/genredistribution)
static async getGenreDistribution(
  req: AuthenticatedRequest,
  res: Response
) {
  try {
    const data = await AdminDashboardService.getGenreDistribution();

    return res.status(200).json({
      success: true,
      data,
    });
  } catch (error) {
    console.error("Genre distribution error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to load genre distribution",
    });
  }
}

}
