
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/modal/form_model.dart';
import '../../../core/repository/form_repository.dart';

/// 1) FormModel loader
final formModelProvider = AsyncNotifierProvider<FormModelNotifier, FormModel?>(
  FormModelNotifier.new,
);

class FormModelNotifier extends AsyncNotifier<FormModel?> {
  final repo = FormRepository();

  @override
  Future<FormModel?> build() async {
    final model = await repo.loadFormModel();
    return model;
  }

  // helper to save model (writing back whole JSON)
  Future<void> saveModel(Map<String, dynamic> json) async {
    await repo.writeLocalJson(json);
    state = AsyncValue.data(FormModel.fromJson(json));
  }
}

final formValuesNotifierProvider = StateNotifierProvider<FormValuesNotifier, Map<String,dynamic>>((ref){
  return FormValuesNotifier();
});

/// **************************************************************************
class FormValuesNotifier extends StateNotifier<Map<String,dynamic>> {
  FormValuesNotifier(): super({});

  void setValue(String key, dynamic value){
    state = {...state, key: value};
  }

  dynamic getValue(String key){
    return state[key];
  }

  void removeKey(String key){
    final copy = {...state};
    copy.remove(key);
    state = copy;
  }

  void clearAll() => state = {};
}


/// ************************************************************************************