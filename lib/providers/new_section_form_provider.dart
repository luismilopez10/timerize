import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timerize/database/database_provider.dart';
import 'package:timerize/models/models.dart';
import 'package:timerize/providers/providers.dart';
import 'package:uuid/uuid.dart';

class NewSectionFormProvider extends ChangeNotifier {
  GlobalKey<FormState> newSectionFormKey = GlobalKey<FormState>();

  TextEditingController _sectionNameController = TextEditingController();
  TextEditingController get sectionNameController => _sectionNameController;
  set sectionNameController(TextEditingController value) {
    _sectionNameController = value;
    notifyListeners();
  }

  TextEditingController _minutesController = TextEditingController();
  TextEditingController get minutesController => _minutesController;
  set minutesController(TextEditingController value) {
    _minutesController = value;
    notifyListeners();
  }

  TextEditingController _secondsController = TextEditingController();
  TextEditingController get secondsController => _secondsController;
  set secondsController(TextEditingController value) {
    _secondsController = value;
    notifyListeners();
  }

  void resetValues() {
    _sectionNameController.clear();
    _minutesController.clear();
    _secondsController.clear();
  }

  bool isValidForm() {
    return newSectionFormKey.currentState?.validate() ?? false;
  }

  String? validate(String value, String key) => value.isEmpty ? key : null;

  void saveShowerSection(
      BuildContext context, ShowerSection? showerSection) async {
    final showerSectionProvider =
        Provider.of<ShowerSectionProvider>(context, listen: false);
    final NewSectionFormProvider newSectionFormProvider =
        Provider.of<NewSectionFormProvider>(context, listen: false);

    final newShowerSection = ShowerSection(
      id: showerSection != null ? showerSection.id : const Uuid().v4(),
      sectionName: newSectionFormProvider.sectionNameController.text,
      orderIndex: showerSectionProvider.showerSectionList.length,
      seconds: int.parse(newSectionFormProvider.secondsController.text),
      minutes: int.parse(newSectionFormProvider.minutesController.text),
    );

    final databaseProvider = DatabaseProvider();

    _updateListInProvider(
        showerSectionProvider, newShowerSection, showerSection);

    await databaseProvider.saveShowerSection(newShowerSection);
  }

  void _updateListInProvider(ShowerSectionProvider showerSectionProvider,
      ShowerSection newShowerSection, ShowerSection? showerSection) {
    var tempShowerSectionList = showerSectionProvider.showerSectionList;

    if (showerSection != null) {
      int modifiedIndex = showerSectionProvider.showerSectionList.indexWhere(
        (showerSection) => showerSection.id == newShowerSection.id,
      );
      tempShowerSectionList[modifiedIndex] = newShowerSection;
    } else {
      tempShowerSectionList.add(newShowerSection);
    }
    showerSectionProvider.showerSectionList = tempShowerSectionList;
  }
}
