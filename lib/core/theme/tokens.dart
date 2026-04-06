import 'palette.dart';
import 'package:flutter/material.dart';

class AppTokens {
  AppTokens._();

  // ── App shell ─────────────────────────────────────────────
  static const appBarBg          = Palette.blue700;
  static const appBarTitle       = Palette.white;
  static const appBarIcon        = Palette.white;
  static const navBarBg          = Palette.blue700;
  static const navBarFg          = Palette.white;
  static const bodyBg            = Palette.white;
  static const splashBg          = Palette.blue700;
  static const splashSpinner     = Palette.textDark;

  // ── Brand ─────────────────────────────────────────────────
  static const brandPrimary      = Palette.blue600;
  static const brandDark         = Palette.blue800;
  static const brandDeep         = Palette.blue900;
  static const brandLight        = Palette.blue50;
  static const brandMid          = Palette.blueAccentFg;
  static const brandGlow         = Palette.brandGlow;
  static const brandGradientStart= Palette.blueDeep;
  static const brandGradientEnd  = Palette.blueMid;
  static const brandGradientStartLight = Palette.blueDeep;  // ← add this
  static const brandGradientStartDark  = Palette.blue800;
  // ── Text ──────────────────────────────────────────────────
  static const textPrimary       = Palette.textDark;
  static const textSecondary     = Palette.grey500;
  static const textMuted         = Palette.textMuted;
  static const textDim           = Palette.textDim;
  static const textOnDark        = Palette.white;
  static const textField         = Palette.grey600;
  static const textNavy          = Palette.textNavy;

  // ── Surface / layout ──────────────────────────────────────
  static const surfacePage       = Palette.grey50;
  static const surfaceCard       = Palette.white;
  static const surfaceDetail     = Palette.grey200p;
  static const surfaceChip       = Palette.chipBg;
  static const surfaceBorder     = Palette.grey200;
  static const surfaceCardBorder = Palette.cardBorder;

  // ── Product card ──────────────────────────────────────────
  static const productName       = Palette.white;
  static const productMrp        = Palette.grey400;
  static const productSalePrice  = Palette.blue600;
  static const productSpecialPrice= Palette.blue600;
  static const productPriceBg    = Palette.grey400;
  static const productAddBtn     = Palette.blue600;
  static const outOfStock        = Palette.blue600;
  static const noItemFound       = Palette.grey400;
  static const comingSoon        = Palette.grey400;

  // ── Cart ──────────────────────────────────────────────────
  static const cartCount         = Palette.textDark;
  static const cartButtonBg      = Palette.grey400;
  static const cartButtonText    = Palette.textDark;
  static const buyNowBg          = Palette.blue600;
  static const buyNowText        = Palette.textDark;

  // ── Product details ───────────────────────────────────────
  static const wishListEnabled   = Palette.blue600;
  static const wishListDisabled  = Palette.grey400;
  static const productSpinner    = Palette.grey400;
  static const hoverButton       = Palette.blue600;

  // ── Category ──────────────────────────────────────────────
  static const catTamil          = Palette.textDark;
  static const catEnglish        = Palette.blue600;

  // ── Login ─────────────────────────────────────────────────
  static const loginTab          = Palette.blue600;
  static const loginBg           = Palette.grey50;
  static const loginSurface      = Palette.grey50;
  static const loginBorder       = Palette.grey200;
  static const loginText         = Palette.textDark;
  static const loginSubText      = Palette.grey500;
  static const loginFieldText    = Palette.grey600;

  // ── Buttons ───────────────────────────────────────────────
  static const buttonPrimary     = Palette.blue600;
  static const buttonFg          = Palette.white;
  static const buttonDisabled    = Color(0x61959595);

  // ── Status ────────────────────────────────────────────────
  static const statusSuccess     = Palette.green;
  static const statusDanger      = Palette.rose;
  static const statusWarning     = Palette.amber;
  static const statusGold        = Palette.amberGold;
  static const statusRed         = Palette.red;
  static const statusYellow      = Palette.amberWarn;

  // ── Invoice / header gradients ────────────────────────────
  static const invoiceHeaderStart= Palette.blue700;
  static const invoiceHeaderEnd  = Palette.blue400;
  static const invoiceCardBg     = Palette.white;
  static const invoicePageBg     = Palette.grey100;
  static const invoicePillBg     = Palette.pillBg;

  // ── Planning ──────────────────────────────────────────────
  static const planSurface       = Palette.grey300;
  static const planGold          = Palette.amberGold;
  static const planCobalt        = Palette.blueCobalt;
  static const planSuccess       = Palette.greenEco;
  static const planDanger        = Palette.redDanger;
  static const planTextMuted     = Palette.textMuted;
  static const planTextDim       = Palette.textDim;

  // ── Maintenance ───────────────────────────────────────────
  static const maintCardBorder   = Palette.cardBorder;
  static const maintTextDark     = Palette.textDark2;
  static const maintTextMid      = Palette.textMid;
  static const maintDetailBg     = Palette.grey200p;
  static const maintChipBg       = Palette.chipBg;
  static const maintAccentRed    = Palette.redAccent;

  // ── Sale order ────────────────────────────────────────────
  static const soBrand           = Palette.blue600;
  static const soBrandDark       = Palette.blue800;
  static const soBrandDeep       = Palette.blue900;
  static const soBrandLight      = Palette.blue50;
  static const soBrandGlow       = Palette.brandGlow;
  static const soSurface         = Palette.grey150;
  static const soTextMain        = Palette.textBlue;
  static const soTextSub         = Palette.grey700;
  static const soBorder          = Palette.brandBorder;
  static const soRed             = Palette.red;
  static const soYellow          = Palette.amberWarn;
  static const soGreen           = Palette.greenSuccess;


  // ── Transport ─────────────────────────────────────────────
  static const transBlueDark     = Palette.blue800;
  static const transBlueLight    = Palette.blue400;
  static const transBlueBg       = Palette.blue50;

  // ── Spinners / misc ───────────────────────────────────────
  static const spinKit           = Palette.spinKit;
  static const highlight         = Palette.highlight;
  static const accentGold        = Palette.gold2;

  static const kExpiredRed      = Color(0xFFD32F2F);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Palette.blueDeep, Palette.blueMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Palette.blue700, Palette.blue400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
