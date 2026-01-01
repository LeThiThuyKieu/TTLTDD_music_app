import { body, validationResult, ValidationChain } from "express-validator";
import { Request, Response, NextFunction } from "express";

export const validate = (validations: ValidationChain[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    // Chạy tất cả các validation
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
  body("name").trim().notEmpty().withMessage("Tên không được để trống"),
  body("email").isEmail().withMessage("Email không hợp lệ"),
];

export const validateRegister = [
  body("name").trim().notEmpty().withMessage("Tên không được để trống"),
  body("email").isEmail().withMessage("Email không hợp lệ"),
  body("password")
    .isLength({ min: 6 })
    .withMessage("Mật khẩu phải có ít nhất 6 ký tự"),
];

export const validateLogin = [
  body("email").isEmail().withMessage("Email không hợp lệ"),
  body("password").notEmpty().withMessage("Mật khẩu không được để trống"),
];

export const validateSong = [
  body("title")
    .trim()
    .notEmpty()
    .withMessage("Tiêu đề bài hát không được để trống"),
  body("file_url")
    .notEmpty()
    .withMessage("Đường dẫn file nhạc không được để trống"),
];

export const validatePlaylist = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("Tên playlist không được để trống"),
];

export const validateGenre = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("Tên thể loại không được để trống"),
];

export const validateForgotPassword = [
  body("email").isEmail().withMessage("Email không hợp lệ"),
];

export const validateVerifyOTP = [
  body("email").isEmail().withMessage("Email không hợp lệ"),
  body("otp")
    .isLength({ min: 4, max: 4 })
    .withMessage("OTP phải có 4 số")
    .isNumeric()
    .withMessage("OTP phải là số"),
];

export const validateResetPassword = [
  body("email").isEmail().withMessage("Email không hợp lệ"),
  body("otp")
    .isLength({ min: 4, max: 4 })
    .withMessage("OTP phải có 4 số")
    .isNumeric()
    .withMessage("OTP phải là số"),
  body("new_password")
    .isLength({ min: 6 })
    .withMessage("Mật khẩu phải có ít nhất 6 ký tự"),
];
