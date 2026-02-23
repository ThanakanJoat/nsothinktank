import 'package:flutter/material.dart';
import 'package:nsothinktank/pages/main_page.dart';
import 'package:nsothinktank/pages/feedback_page.dart';
import 'package:nsothinktank/pages/local_data/province_data.dart';
import 'package:nsothinktank/pages/local_data/province_info.dart';
import 'package:nsothinktank/pages/info_graphic.dart';
import 'package:nsothinktank/pages/release_calendar.dart';
import 'package:nsothinktank/pages/app_manual.dart';
import 'package:nsothinktank/pages/contact_us.dart';
import 'package:nsothinktank/pages/contact_us_web.dart';
import 'package:nsothinktank/pages/key_data/catalog.dart';
import 'package:nsothinktank/pages/key_data/catalog_list.dart';
import 'package:nsothinktank/pages/key_data/branch_table_list.dart';
import 'package:nsothinktank/pages/key_data/pages/chart_page.dart';  
import 'package:nsothinktank/pages/key_data/pages/data_table.dart';
import 'package:nsothinktank/pages/key_data/pages/line_chart.dart';
import 'package:nsothinktank/pages/key_data/pages/pie_chart.dart';
import 'package:nsothinktank/pages/key_data/pages/meta_data.dart';

import 'package:nsothinktank/pages/bookmark_page.dart';
import 'package:nsothinktank/pages/splash_page.dart';
import 'package:nsothinktank/pages/madee_chat_page.dart';

Map<String, WidgetBuilder> routes = {
  "/home": (BuildContext context) => MainPage(),
  "/catalog": (BuildContext context) => CatalogPage(),
  "/cataloglist": (BuildContext context) => CatalogListPage(),
  "/branch_tables": (BuildContext context) => const BranchTableListPage(),
  "/province": (BuildContext context) => const ProvincePage(),
  "/provinceinfo": (BuildContext context) => const ProvinceInfoPage(),
  "/infographic": (BuildContext context) => InfoGraphicPage(),
  "/calendar": (BuildContext context) => const CalendarPage(),
  "/manual": (BuildContext context) => ManualPage(),
  "/contact": (BuildContext context) => ContactUsPage(),
  "/contactweb": (BuildContext context) => const ContactUsWebPage(),
  "/linechart": (BuildContext context) => LineChartPage(),
  "/piechart": (BuildContext context) => const PieChartPage(),
  "/datatable": (BuildContext context) => DataTablePage(),
  "/metadata": (BuildContext context) => MetaDataPage(),
  "/checkbarchart": (BuildContext context) => ChartPage(), // Backward compatibility
  "/barchart1": (BuildContext context) => ChartPage(), // Backward compatibility
  "/chart_page": (BuildContext context) => ChartPage(), // New standard route
  // 2-10 Removed
  "/bookmark": (BuildContext context) => const BookmarkPage(),
  "/feedback": (BuildContext context) => const FeedbackPage(),
  "/splash": (BuildContext context) => const SplashPage(),
  "/madeechat": (BuildContext context) => const MadeeChatPage(),
};
