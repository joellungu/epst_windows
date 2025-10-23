import 'package:epst_windows_app/pages/formation_distante/inspecteur_cours.dart';
import 'package:flutter/foundation.dart';
import 'inspecteur_cours_service.dart';

class InspecteurCoursProvider with ChangeNotifier {
  List<InspecteurCours> _inspecteurCoursList = [];
  bool _isLoading = false;
  String _error = '';

  List<InspecteurCours> get inspecteurCoursList => _inspecteurCoursList;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Charger tous les inspecteur cours
  Future<void> loadAllInspecteurCours({
    int pageIndex = 0,
    int pageSize = 20,
    String? sortBy,
    int? idInspecteur,
    bool sortAsc = true,
  }) async {
    _setLoading(true);
    try {
      final response = await InspecteurCoursService.getAll(
          pageIndex: pageIndex,
          pageSize: pageSize,
          sortBy: sortBy,
          sortAsc: sortAsc,
          idInspecteur: idInspecteur);
      _inspecteurCoursList = response.data;
      _error = '';
    } catch (e) {
      _error = e.toString();
      _inspecteurCoursList = [];
    } finally {
      _setLoading(false);
    }
  }

  // Créer un nouvel inspecteur cours
  Future<bool> createInspecteurCours(InspecteurCours inspecteurCours) async {
    _setLoading(true);
    try {
      final created = await InspecteurCoursService.create(inspecteurCours);
      _inspecteurCoursList.add(created);
      notifyListeners();
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour un inspecteur cours
  Future<bool> updateInspecteurCours(
      int id, InspecteurCours inspecteurCours) async {
    _setLoading(true);
    try {
      final updated = await InspecteurCoursService.update(id, inspecteurCours);
      final index = _inspecteurCoursList.indexWhere((item) => item.id == id);
      if (index != -1) {
        _inspecteurCoursList[index] = updated;
        notifyListeners();
      }
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer un inspecteur cours
  Future<bool> deleteInspecteurCours(int id) async {
    _setLoading(true);
    try {
      await InspecteurCoursService.delete(id);
      _inspecteurCoursList.removeWhere((item) => item.id == id);
      notifyListeners();
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Rechercher
  Future<void> searchInspecteurCours({
    int? idInspecteur,
    int? coursId,
    int? classeId,
  }) async {
    _setLoading(true);
    try {
      final results = await InspecteurCoursService.search(
        idInspecteur: idInspecteur,
        coursId: coursId,
        classeId: classeId,
      );
      _inspecteurCoursList = results;
      _error = '';
    } catch (e) {
      _error = e.toString();
      _inspecteurCoursList = [];
    } finally {
      _setLoading(false);
    }
  }

  // Charger par ID inspecteur
  Future<void> loadByInspecteurId(int idInspecteur) async {
    _setLoading(true);
    try {
      final results =
          await InspecteurCoursService.getByInspecteurId(idInspecteur);
      _inspecteurCoursList = results;
      _error = '';
    } catch (e) {
      _error = e.toString();
      _inspecteurCoursList = [];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
