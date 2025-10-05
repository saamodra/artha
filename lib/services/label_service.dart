import 'package:flutter/foundation.dart';
import '../models/label.dart';
import '../repositories/label_repository.dart';

class LabelService extends ChangeNotifier {
  static final LabelService _instance = LabelService._internal();
  factory LabelService() => _instance;
  LabelService._internal() {
    _repository = LabelRepository();
  }

  final List<Label> _labels = [];
  late final LabelRepository _repository;

  List<Label> get labels => List.unmodifiable(_labels);

  /// Load all labels from the repository
  Future<void> loadLabels() async {
    try {
      _labels.clear();
      _labels.addAll(await _repository.getLabels());
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load labels: $e');
    }
  }

  /// Add a new label
  Future<Label> addLabel(Label label) async {
    try {
      // Check if label name already exists
      final nameExists = await _repository.isLabelNameExists(label.name);
      if (nameExists) {
        throw Exception('Label name already exists');
      }

      final newLabel = await _repository.createLabel(label);
      _labels.add(newLabel);
      _labels.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return newLabel;
    } catch (e) {
      throw Exception('Failed to add label: $e');
    }
  }

  /// Update an existing label
  Future<Label> updateLabel(Label label) async {
    try {
      // Check if label name already exists (excluding current label)
      final nameExists = await _repository.isLabelNameExists(
        label.name,
        excludeId: label.id,
      );
      if (nameExists) {
        throw Exception('Label name already exists');
      }

      final updatedLabel = await _repository.updateLabel(label);
      final index = _labels.indexWhere((l) => l.id == label.id);
      if (index != -1) {
        _labels[index] = updatedLabel;
        _labels.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      }
      return updatedLabel;
    } catch (e) {
      throw Exception('Failed to update label: $e');
    }
  }

  /// Delete a label
  Future<void> deleteLabel(String id) async {
    try {
      await _repository.deleteLabel(id);
      _labels.removeWhere((l) => l.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete label: $e');
    }
  }

  /// Get a label by ID
  Label? getLabelById(String id) {
    try {
      return _labels.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get labels by name (case-insensitive search)
  List<Label> searchLabels(String query) {
    if (query.isEmpty) return _labels;

    return _labels
        .where(
          (label) => label.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Get labels for a specific wallet record
  Future<List<Label>> getLabelsForWalletRecord(String walletRecordId) async {
    try {
      return await _repository.getLabelsForWalletRecord(walletRecordId);
    } catch (e) {
      throw Exception('Failed to get labels for wallet record: $e');
    }
  }

  /// Add labels to a wallet record
  Future<void> addLabelsToWalletRecord(
    String walletRecordId,
    List<String> labelIds,
  ) async {
    try {
      await _repository.addLabelsToWalletRecord(walletRecordId, labelIds);
    } catch (e) {
      throw Exception('Failed to add labels to wallet record: $e');
    }
  }

  /// Remove labels from a wallet record
  Future<void> removeLabelsFromWalletRecord(
    String walletRecordId,
    List<String> labelIds,
  ) async {
    try {
      await _repository.removeLabelsFromWalletRecord(walletRecordId, labelIds);
    } catch (e) {
      throw Exception('Failed to remove labels from wallet record: $e');
    }
  }

  /// Update labels for a wallet record (replace all existing labels)
  Future<void> updateLabelsForWalletRecord(
    String walletRecordId,
    List<String> labelIds,
  ) async {
    try {
      await _repository.updateLabelsForWalletRecord(walletRecordId, labelIds);
    } catch (e) {
      throw Exception('Failed to update labels for wallet record: $e');
    }
  }

  /// Get labels that are not yet assigned to a wallet record
  List<Label> getUnassignedLabels(List<String> assignedLabelIds) {
    return _labels
        .where((label) => !assignedLabelIds.contains(label.id))
        .toList();
  }

  /// Get most used labels (for suggestions)
  List<Label> getMostUsedLabels({int limit = 5}) {
    // This would require additional database queries to count usage
    // For now, return the first few labels
    return _labels.take(limit).toList();
  }

  /// Check if a label name is available
  Future<bool> isLabelNameAvailable(String name, {String? excludeId}) async {
    try {
      return !await _repository.isLabelNameExists(name, excludeId: excludeId);
    } catch (e) {
      return false;
    }
  }
}
