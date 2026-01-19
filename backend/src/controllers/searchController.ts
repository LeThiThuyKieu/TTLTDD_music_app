import { Response } from "express";
import { AuthenticatedRequest } from "../models";
import { SearchService } from "../services/SearchService";

export class SearchController {
    static async search(
        req: AuthenticatedRequest,
            res: Response
        ): Promise<void> {
    try {
          const query = (req.query.q as string)?.trim();
          if (!query) {
            res.json({ success: true,
              data: {
                songs: [],
                artists: [],
                albums: [],
                genres: [],
              },
            });
            return;
          }

          const limit = parseInt(req.query.limit as string) || 20;

          const result = await SearchService.searchAll(query, limit);

          res.json({
            success: true,
            data: result,
            query,
          });
        } catch (error: any) {
          console.error("Search error:", error);
          res.status(500).json({
            success: false,
            error: error.message || "Internal server error",
          });
        }
      }
    }