import 'package:flutter/material.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/locator.dart';

// Bold Styles
TextStyle style60Bold() {
  return TextStyle(
    fontFamily: !locator<AppLanguage>().isRtl() ? 'Almarai-Bold' : 'Almarai-Bold',
    color: grey33,
    fontSize: 60,
  );
}

TextStyle style48Bold() {
  return TextStyle(
    fontFamily: !locator<AppLanguage>().isRtl() ? 'Almarai-Bold' : 'Almarai-Bold',
    color: grey33,
    fontSize: 50,
  );
}

TextStyle style36Bold() => style48Bold().copyWith(fontSize: 36);
TextStyle style32Bold() => style48Bold().copyWith(fontSize: 32);
TextStyle style28Bold() => style48Bold().copyWith(fontSize: 28);
TextStyle style24Bold() => style48Bold().copyWith(fontSize: 24);
TextStyle style22Bold() => style48Bold().copyWith(fontSize: 22);
TextStyle style20Bold() => style48Bold().copyWith(fontSize: 20);
TextStyle style18Bold() => style48Bold().copyWith(fontSize: 18);
TextStyle style16Bold() => style48Bold().copyWith(fontSize: 16);
TextStyle style14Bold() => style48Bold().copyWith(fontSize: 14);
TextStyle style12Bold() => style48Bold().copyWith(fontSize: 12);
TextStyle style10Bold() => style48Bold().copyWith(fontSize: 10);

// Regular Styles
TextStyle style60Regular() {
  return TextStyle(
    fontFamily: !locator<AppLanguage>().isRtl() ? 'Almarai-Regular' : 'Almarai-Regular',
    color: grey33,
    fontSize: 60,
  );
}

TextStyle style48Regular() {
  return TextStyle(
    fontFamily: !locator<AppLanguage>().isRtl() ? 'Almarai-Regular' : 'Almarai-Regular',
    color: grey33,
    fontSize: 50,
  );
}

TextStyle style36Regular() => style48Regular().copyWith(fontSize: 36);
TextStyle style32Regular() => style48Regular().copyWith(fontSize: 32);
TextStyle style28Regular() => style48Regular().copyWith(fontSize: 28);
TextStyle style24Regular() => style48Regular().copyWith(fontSize: 24);
TextStyle style22Regular() => style48Regular().copyWith(fontSize: 22);
TextStyle style20Regular() => style48Regular().copyWith(fontSize: 20);
TextStyle style18Regular() => style48Regular().copyWith(fontSize: 18);
TextStyle style16Regular() => style48Regular().copyWith(fontSize: 16);
TextStyle style14Regular() => style48Regular().copyWith(fontSize: 14);
TextStyle style12Regular() => style48Regular().copyWith(fontSize: 12);
TextStyle style10Regular() => style48Regular().copyWith(fontSize: 10);
TextStyle style8Regular() => style48Regular().copyWith(fontSize: 8);
