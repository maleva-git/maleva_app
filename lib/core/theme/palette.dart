import 'package:flutter/material.dart';

class Palette {
  Palette._();

  // ── Blues ─────────────────────────────────────────────────
  static const blue50   = Color(0xFFE8EEFF);   // kAccent, kBlueBg, brandLight, accentBg.blue
  static const blue200  = Color(0xFFB5D4F4);
  static const blue400  = Color(0xFF4A6FD4);   // kHeaderGradEnd, kBlueL, kPrimaryLight, cBlueLight, brandMid
  static const blue500  = Color(0xFF3A7BFF);   // kPrimaryL, cBlueLight
  static const blue600  = Color(0xFF1555F3);   // cBlue, brand, accentFg.blue
  static const blue700  = Color(0xFF1A3A8F);   // kPrimary, kHeaderGradStart, AppColors.appBarColor, commonColor
  static const blue800  = Color(0xFF0D3DB5);   // kPrimaryDark, kBlueDark, cBlueDark, brandDark
  static const blue900  = Color(0xFF0A2D8A);   // brandDeep
  static const blue950  = Color(0xFF0D2A99);   // kPrimaryD, cBlueDark (dark variant)
  static const blueNavy = Color(0xFF1A2E5A);   // kNavy
  static const blueDeep = Color(0xFF1E3A8A);   // AppColors.primaryGradient start
  static const blueLight= Color(0xFF5B9BD5);   // kBlue, commonColorLight
  static const blueMid  = Color(0xFF2563EB);   // AppColors.primaryGradient end
  static const blueBar  = Color(0xFF3563E9);   // kBarBlue
  static const blueCobalt= Color(0xFF3B82F6);  // kCobalt
  static const blueAccent= Color(0xFF2F80ED);  // kBlueAccent
  static const blueAccentFg= Color(0xFF4B7BF5);// brandMid

  // ── Brand glow / translucent ──────────────────────────────
  static const brandGlow  = Color(0x1F1555F3); // brandGlow
  static const brandBorder= Color(0x261555F3); // border (saleorder)
  static const pillBg     = Color(0x33FFFFFF);  // kPillBg
  static const rwhite     = Color(0x54E1E1E1);  // RWhite

  // ── Surfaces / Neutrals ───────────────────────────────────
  static const white      = Color(0xFFFFFFFF);
  static const grey50     = Color(0xFFF5F6FA);  // cSurface, kSurface, kBg, surfacePage
  static const grey100    = Color(0xFFF4F6FB);  // kPageBg, surface (saleorder)
  static const grey150    = Color(0xFFF4F7FF);  // surface (saleorder variant)
  static const grey200    = Color(0xFFECEEF5);  // cBorder, kBorder
  static const grey300    = Color(0xFFF1F5F9);  // kSurface2
  static const grey400    = Color(0xFF607D8B);  // mrpTextColor, wishListDisableColor, noItemFound, comingSoon
  static const grey500    = Color(0xFFB0B4C8);  // cSub, kSubText
  static const grey600    = Color(0xFF6B7094);  // kFieldText
  static const grey700    = Color(0xFF5A6A9A);  // textSub
  static const grey200p   = Color(0xFFF0F4FF);  // kDetailBg
  static const grey200q   = Color(0xFFEEF2FF);  // kChipBg, accentBg.blue

  // ── Text ──────────────────────────────────────────────────
  static const textDark   = Color(0xFF1A1D2E);  // cText, kText, textMain
  static const textNavy   = Color(0xFF022b50);  // blackText
  static const textMuted  = Color(0xFF475569);  // kTextMuted
  static const textDim    = Color(0xFF94A3B8);  // kTextDim
  static const textDark2  = Color(0xFF1E2D5E);  // kTextDark
  static const textMid    = Color(0xFF4A5A8A);  // kTextMid
  static const textBlue   = Color(0xFF0D1B4B);  // textMain (saleorder)

  // ── Status ────────────────────────────────────────────────
  static const green      = Color(0xFF27AE60);  // kGreen
  static const greenSuccess= Color(0xFF2E7D32); // green (saleorder)
  static const greenEco   = Color(0xFF059669);  // kSuccess
  static const amber      = Color(0xFFE67E22);  // kOrange
  static const amberGold  = Color(0xFFD97706);  // kGold
  static const amberWarn  = Color(0xFFF9A825);  // yellow (saleorder)
  static const red        = Color(0xFFE53935);  // red (saleorder)
  static const redDanger  = Color(0xFFDC2626);  // kDanger
  static const redAccent  = Color(0xFFB33040);  // kAccentRed
  static const redError   = Color(0xFFb30c0c);  // commonColorred
  static const rose       = Color(0xFFE11D48);  // cRose, kDanger-ish, accentFg.rose

  // ── Legacy / misc ────────────────────────────────────────
  static const spinKit    = Color(0xFF0e387a);  // spinKitColor
  static const highlight  = Color(0xE2BF0F0F);  // commonColorhighlight
  static const gold2      = Color(0xFFFFBC29);  // whiteText / commonColor2
  static const cardBorder = Color(0xFFC5D0EE);  // kCardBorder
  static const chipBg     = Color(0xFFEEF2FF);  // kChipBg
  static const kWhite = Colors.white;

}
