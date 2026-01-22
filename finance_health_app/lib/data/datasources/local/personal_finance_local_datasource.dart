import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/personal_finance.dart';
import '../../models/personal_finance_model.dart';

/// Key lưu trữ trong SharedPreferences
const String _personalFinanceKey = 'personal_finance_data';
const String _formDraftKey = 'finance_form_draft';

/// Local data source để lưu trữ thông tin tài chính cá nhân
abstract class PersonalFinanceLocalDataSource {
  /// Lưu thông tin tài chính cá nhân
  Future<void> savePersonalFinance(PersonalFinance data);

  /// Lấy thông tin tài chính cá nhân đã lưu
  Future<PersonalFinance?> getPersonalFinance();

  /// Xóa thông tin tài chính cá nhân
  Future<void> clearPersonalFinance();

  /// Lưu bản nháp form
  Future<void> saveFormDraft(Map<String, dynamic> draft);

  /// Lấy bản nháp form
  Future<Map<String, dynamic>?> getFormDraft();

  /// Xóa bản nháp form
  Future<void> clearFormDraft();

  /// Kiểm tra có dữ liệu đã lưu không
  Future<bool> hasData();
}

/// Implementation sử dụng SharedPreferences
class PersonalFinanceLocalDataSourceImpl
    implements PersonalFinanceLocalDataSource {
  final SharedPreferences _prefs;

  PersonalFinanceLocalDataSourceImpl({required SharedPreferences prefs})
    : _prefs = prefs;

  @override
  Future<void> savePersonalFinance(PersonalFinance data) async {
    final model = PersonalFinanceModel.fromEntity(data);
    final jsonString = jsonEncode(model.toJson());
    await _prefs.setString(_personalFinanceKey, jsonString);
  }

  @override
  Future<PersonalFinance?> getPersonalFinance() async {
    final jsonString = _prefs.getString(_personalFinanceKey);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PersonalFinanceModel.fromJson(json).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearPersonalFinance() async {
    await _prefs.remove(_personalFinanceKey);
  }

  @override
  Future<void> saveFormDraft(Map<String, dynamic> draft) async {
    final jsonString = jsonEncode(draft);
    await _prefs.setString(_formDraftKey, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getFormDraft() async {
    final jsonString = _prefs.getString(_formDraftKey);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearFormDraft() async {
    await _prefs.remove(_formDraftKey);
  }

  @override
  Future<bool> hasData() async {
    return _prefs.containsKey(_personalFinanceKey);
  }
}
