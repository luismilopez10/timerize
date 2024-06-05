import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timerize/database/database_provider.dart';

import 'package:timerize/models/models.dart';
import 'package:timerize/providers/providers.dart';
import 'package:timerize/screens/screens.dart';

class ShowerSectionItem extends StatefulWidget {
  const ShowerSectionItem({
    super.key,
  });

  @override
  State<ShowerSectionItem> createState() => _ShowerSectionItemState();
}

class _ShowerSectionItemState extends State<ShowerSectionItem> {
  @override
  Widget build(BuildContext context) {
    final ShowerSectionProvider showerSectionProvider =
        Provider.of<ShowerSectionProvider>(context);
    final NewSectionFormProvider newSectionFormProvider =
        Provider.of<NewSectionFormProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    final Color draggableItemColor = colorScheme.primary;

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(0, 6, animValue)!;
          return Material(
            elevation: elevation,
            // color: draggableItemColor,
            shadowColor: draggableItemColor,
            child: child,
          );
        },
        child: child,
      );
    }

    return ReorderableListView.builder(
      itemCount: showerSectionProvider.showerSectionList.length,
      proxyDecorator: proxyDecorator,
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        final ShowerSection movedItem =
            showerSectionProvider.showerSectionList.removeAt(oldIndex);
        showerSectionProvider.showerSectionList.insert(newIndex, movedItem);

        _updateShowerSectionsOrderInDB(showerSectionProvider);
      },
      itemBuilder: (BuildContext context, int index) {
        final showerSection = showerSectionProvider.showerSectionList[index];

        final String formattedSeconds =
            showerSection.seconds.toString().padLeft(2, '0');

        final String formattedMinutes =
            showerSection.formattedMinutes.toString().padLeft(2, '0');

        final String formattedHours =
            showerSection.hours.toString().padLeft(2, '0');

        return ListTile(
            key: Key(showerSection.id! + index.toString()),
            tileColor: index.isOdd ? oddItemColor : evenItemColor,
            title: Text(showerSection.sectionName!),
            subtitle: Text(
                'Duración: $formattedHours:$formattedMinutes:$formattedSeconds'),
            trailing: SizedBox(
              width: 100.0,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      newSectionFormProvider.sectionNameController.text =
                          showerSection.sectionName!;
                      newSectionFormProvider.minutesController.text =
                          showerSection.formattedMinutes.toString();
                      newSectionFormProvider.secondsController.text =
                          showerSection.seconds!.toString();

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewSectionFormScreen(
                                showerSection: showerSection),
                          ));
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 20.0,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Eliminar sección'),
                            content: Text(
                                '¿Estás seguro que deseas eliminar "${showerSection.sectionName}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  showerSectionProvider
                                      .deleteSection(showerSection.id!);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.delete,
                      size: 20.0,
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  Future<void> _updateShowerSectionsOrderInDB(
      ShowerSectionProvider showerSectionProvider) async {
    final databaseProvider = DatabaseProvider();

    final List<ShowerSection> reorderedSections =
        showerSectionProvider.showerSectionList;

    for (int i = 0; i < reorderedSections.length; i++) {
      final section = reorderedSections[i];
      section.orderIndex = i;
      await databaseProvider.saveShowerSection(section);
    }
  }
}
