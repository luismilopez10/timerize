import 'package:flutter/material.dart';
import 'package:timerize/database/database_provider.dart';

import 'package:timerize/models/models.dart';

class ShowerSectionProvider extends ChangeNotifier {
  List<ShowerSection> _showerSectionList = [];
  List<ShowerSection> get showerSectionList => _showerSectionList;
  set showerSectionList(List<ShowerSection> value) {
    _showerSectionList = value;
    notifyListeners();
  }

  Future<void> deleteSection(String showerSectionId) async {
    final databaseProvider = DatabaseProvider();

    _updateListInProvider(showerSectionId);

    await databaseProvider.deleteShowerSection(showerSectionId);
  }

  void _updateListInProvider(String showerSectionId) {
    var tempShowerSectionList = showerSectionList;

    int modifiedIndex = showerSectionList.indexWhere(
      (showerSection) => showerSection.id == showerSectionId,
    );
    tempShowerSectionList.removeAt(modifiedIndex);

    showerSectionList = tempShowerSectionList;
  }
}
