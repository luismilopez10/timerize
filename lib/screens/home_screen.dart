import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:timerize/providers/providers.dart';
import 'package:timerize/screens/screens.dart';
import 'package:timerize/share_preferences/preferences.dart';
import 'package:timerize/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  static const String routerName = 'Home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ShowerSectionProvider showerSectionProvider =
        Provider.of<ShowerSectionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Preferences.isDarkmode
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined),
          onPressed: () {
            Preferences.isDarkmode = !Preferences.isDarkmode;
            Preferences.isDarkmode
                ? themeProvider.setDarkmode()
                : themeProvider.setLightmode();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewSectionFormScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          //* Título de Nueva sección
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'Mis secciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (showerSectionProvider.showerSectionList.isNotEmpty)
            const Expanded(child: ShowerSectionItem())
          else
            const _NoSectionsYet(),
        ],
      ),
      floatingActionButton: showerSectionProvider.showerSectionList.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimerScreen(
                        showerSectionProvider: showerSectionProvider),
                  ),
                ),
                child: const Icon(Icons.play_arrow),
              ),
            )
          : null,
    );
  }
}

class _NoSectionsYet extends StatelessWidget {
  const _NoSectionsYet();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 100.0),
        width: double.infinity,
        child: const Text(
          'Aún no tienes secciones',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
