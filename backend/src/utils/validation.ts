import { body, validationResult, ValidationChain } from "express-validator";
import { Request, Response, NextFunction } from "express";

export const validate = (validations: ValidationChain[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    // Run all validations
    await Promise.all(validations.map((validation) => validation.run(req)));

    const errors = validationResult(req);
    if (errors.isEmpty()) {
      return next();
    }

    res.status(400).json({
      success: false,
      errors: errors.array(),
    });
  };
};

// Validation rules
export const validateUser = [
  body("name").trim().notEmpty().withMessage("Name is required"),
  body("email").isEmail().withMessage("Valid email is required"),
];

export const validateSong = [
  body("title").trim().notEmpty().withMessage("Title is required"),
  body("file_url").notEmpty().withMessage("File URL is required"),
];

export const validatePlaylist = [
  body("name").trim().notEmpty().withMessage("Playlist name is required"),
];

export const validateGenre = [
  body("name").trim().notEmpty().withMessage("Genre name is required"),
];
