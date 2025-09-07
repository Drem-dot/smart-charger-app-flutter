import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // --- BẢNG MÀU CHÍNH ---
  // Màu xanh lá cây chủ đạo của thương hiệu (RGB: 20, 168, 0)
  static const Color primaryColor = Color(0xFF14A800);
  
  // Màu nền chính của ứng dụng (vùng bên ngoài các Card/Sheet)
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // Màu cho các bề mặt như Card, BottomSheet, Drawer, AppBar... (TRẮNG TINH)
  static const Color surfaceColor = Colors.white;

  // Màu chữ chính, xám đen, dễ đọc và hiện đại
  static const Color textColor = Color(0xFF333333);

  /// Getter tĩnh để lấy ThemeData chung của ứng dụng.
  static ThemeData get theme {
    // Bắt đầu với theme sáng mặc định của Flutter
    final baseTheme = ThemeData.light();

    return baseTheme.copyWith(
      // --- CẤU HÌNH MÀU SẮC CHUNG ---
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: primaryColor, // accentColor bây giờ dùng chung màu
        surface: surfaceColor,
        error: Colors.red,
        onPrimary: Colors.white,   // Chữ trên nền màu chính (xanh lá)
        onSecondary: Colors.white,  // Chữ trên nền màu nhấn (cũng là xanh lá)
        onSurface: textColor,   // Chữ trên các bề mặt trắng (Card, Sheet, AppBar)
        brightness: Brightness.light,
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,

      // --- CẤU HÌNH FONT CHỮ ---
      textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),

      // --- CẤU HÌNH CHO CÁC WIDGET CỤ THỂ ---

      // AppBar nền trắng, chữ đen
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 1.0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        iconTheme: const IconThemeData(
          color: textColor,
        ),
      ),
      
      // Nút FilledButton vẫn giữ màu xanh lá
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
      
      // FloatingActionButton cũng có màu xanh lá cây
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4.0,
      ),
      
      // Drawer (thanh nav) có nền trắng
      drawerTheme: const DrawerThemeData(
        backgroundColor: surfaceColor,
      ),

      // Ô nhập liệu có nền trắng
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
      ),

      // Card có nền trắng
      cardTheme: CardThemeData(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: surfaceColor,
      ),

      // BottomSheet có nền trắng
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}