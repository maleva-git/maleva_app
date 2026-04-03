import 'package:flutter/material.dart';

const topAppBarBgColor = Colors.blue;
const topAppBarTitleColor = Colors.black;
const bottomNavigationBarBgColor = Colors.blue;
const bottomNavigationBarFgColor = Colors.white;
const commonHeadingColor = Colors.white;
const productNameColor = Colors.white;
const specialPriceTextColor = Colors.blue;
const mrpTextColor = Color(0xFF607D8B);
const salePriceTextColor = Colors.blue;
final priceTagBgColor = Colors.grey[200];
const menuIconColor = Colors.white;
const bodyBgColor = Colors.white;

const splashScreenBgColor = Colors.blue;
const splashScreenSpinKitColor = Colors.black;
const commonButtonColor = Colors.blue;
const commonPrimaryTextColor = Colors.black;
const blackText = Color(0xff022b50);
const whiteText = Color(0xffffbc29);
const outOfStockTextColor = Colors.blue;
const noItemFoundColor = Color(0xFF607D8B);
const comingSoonColor = Color(0xFF607D8B);
const loginTabColor = Colors.blue;
const cartCountColor = Colors.black;
const catTamilColor = Colors.black;
const catEnglishColor = Colors.blue;
const prodAddBtnColor = Colors.blue;

//Product Details
const wishListEnableColor = Colors.blue;
const wishListDisableColor = Color(0xFF607D8B);
const productDetailsSpinnerColor = Color(0xFF607D8B);
const cartButtonTextColor = Colors.black;
const cartButtonBgColor = Color(0xFF607D8B);
const buyNowButtonTextColor = Colors.black;
const buyNowButtonBgColor = Colors.blue;
const hoverButtonColor = Colors.blue;
const commonColor2 = Color(0xffffbc29);

const commonColorhighlight = Color(0xe2bf0f0f);
const commonColor = Color(0xff1a4d9e);
const commonColorDisabled = Color(0x61959595);
const topAppBarColor = Colors.white;
const ButtonForeColor = Colors.white;
const commonColorLight = Color(0xFF5B9BD5);
const commonColorred = Color(0xffb30c0c);
const spinKitColor = Color(0xff0e387a);

const Color kPrimary = Color(0xFF1A3A8F);
const Color kPrimaryDark = Color(0xFF0D3DB5);
const Color kPrimaryLight = Color(0xFF4D7EF7);
const Color kAccent = Color(0xFFE8EEFF);
const Color kWhite = Colors.white;
const cBlue      = Color(0xFF1555F3);
const RWhite      = Color(0x54E1E1E1);
const cBlueDark  = Color(0xFF0D2A99);
const cBlueLight = Color(0xFF3A7BFF);
const cWhite     = Color(0xFFFFFFFF);
const cSurface   = Color(0xFFF5F6FA);
const cBorder    = Color(0xFFECEEF5);
const cText      = Color(0xFF1A1D2E);
const cSub       = Color(0xFFB0B4C8);
const cRose      = Color(0xFFE11D48);

// ── Screenshot color palette ────────────────────────────── Invoice color
const kHeaderGradStart = Color(0xFF1A3A8F); // deep blue
const kHeaderGradEnd   = Color(0xFF4A6FD4); // lighter blue
const kCardBg          = Colors.white;
const kPageBg          = Color(0xFFF4F6FB);
const kPillBg          = Color(0x33FFFFFF); // translucent white pill
const kGreen           = Color(0xFF27AE60);
const kBlueAccent      = Color(0xFF2F80ED);
const kBarBlue         = Color(0xFF3563E9);


const kShadow = Color(0x0D000000);
const kNavy   = Color(0xFF1A2E5A);
const kBlue   = Color(0xFF5B9BD5);
const kOrange = Color(0xFFE67E22);


//Transport

const kBlueDark = Color(0xFF0D3DB5);
const kBlueL    = Color(0xFF4D7EF7);
const kBlueBg   = Color(0xFFE8EEFF);


enum Accent { blue, green, amber, purple, teal, rose }

const accentBg = {
  Accent.blue:   Color(0xFFEEF2FF),
  Accent.green:  Color(0xFFEDFAF4),
  Accent.amber:  Color(0xFFFFF8EC),
  Accent.purple: Color(0xFFF5F0FF),
  Accent.teal:   Color(0xFFEAFBF8),
  Accent.rose:   Color(0xFFFFF1F2),
};
const accentFg = {
  Accent.blue:   Color(0xFF1555F3),
  Accent.green:  Color(0xFF16A85A),
  Accent.amber:  Color(0xFFE07A20),
  Accent.purple: Color(0xFF7B52D3),
  Accent.teal:   Color(0xFF0FA58E),
  Accent.rose:   Color(0xFFE11D48),
};

class AppColors {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF1E3A8A),
      Color(0xFF2563EB),

    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color appBarColor = Color(0xFF1A3A8F);
  static const Color whitecolor = Color(0xFFFFFFFF);
}

//Login
const kPrimaryD  = Color(0xFF0D2A99);
const kPrimaryL  = Color(0xFF3A7BFF);
const kBg        = Color(0xFFECEEF4);
const kSurface   = Color(0xFFF5F6FA);
const kBorder    = Color(0xFFECEEF5);
const kText      = Color(0xFF1A1D2E);
const kSubText   = Color(0xFFB0B4C8);
const kFieldText = Color(0xFF6B7094);


//Planning
const Color kSurface2  = Color(0xFFF1F5F9);
const Color kGold      = Color(0xFFD97706);
const Color kCobalt    = Color(0xFF3B82F6);
const Color kSuccess   = Color(0xFF059669);
const Color kDanger    = Color(0xFFDC2626);
const Color kTextMuted = Color(0xFF475569);
const Color kTextDim   = Color(0xFF94A3B8);


//maintenance


const kCardBorder      = Color(0xFFC5D0EE);
const kTextDark        = Color(0xFF1E2D5E);
const kTextMid         = Color(0xFF4A5A8A);
const kDetailBg        = Color(0xFFF0F4FF);
const kChipBg          = Color(0xFFEEF2FF);
const kAccentRed       = Color(0xFFB33040);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;


//saleorder view
// ── Brand palette ─────────────────────────────────────────
const brand      = Color(0xFF1555F3);
const brandDark  = Color(0xFF0D3DB8);
const brandDeep  = Color(0xFF0A2D8A);
const brandLight = Color(0xFFE8EFFE);
const brandMid   = Color(0xFF4B7BF5);
const brandGlow  = Color(0x1F1555F3);
const surface    = Color(0xFFF4F7FF);
const textMain   = Color(0xFF0D1B4B);
const textSub    = Color(0xFF5A6A9A);
const border     = Color(0x261555F3);
const red        = Color(0xFFE53935);
const yellow     = Color(0xFFF9A825);
const green      = Color(0xFF2E7D32);



