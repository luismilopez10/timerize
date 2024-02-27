import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/screens.dart';
import 'providers/providers.dart';
import 'share_preferences/preferences.dart';

import 'package:timerize/models/models.dart';
import 'package:timerize/database/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(isDarkmode: Preferences.isDarkmode),
      ),
      ChangeNotifierProvider(
        create: (_) => ShowerSectionProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => NewSectionFormProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showerSectionProvider =
        Provider.of<ShowerSectionProvider>(context, listen: false);
    _loadShowerSectionsFromDatabase(showerSectionProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timerize',
      initialRoute: HomeScreen.routerName,
      routes: {
        HomeScreen.routerName: (_) => const HomeScreen(),
        TimerScreen.routerName: (_) => const TimerScreen(),
        NewSectionFormScreen.routerName: (_) => NewSectionFormScreen(),
      },
      theme: Provider.of<ThemeProvider>(context).currentTheme,
    );
  }

  Future<void> _loadShowerSectionsFromDatabase(
      ShowerSectionProvider showerSectionProvider) async {
    final databaseProvider = DatabaseProvider();

    List<ShowerSection> databaseShowerSection =
        await databaseProvider.getShowerSections();

    databaseShowerSection
        .sort((a, b) => a.orderIndex!.compareTo(b.orderIndex!));

    showerSectionProvider.showerSectionList = databaseShowerSection;
  }
}
