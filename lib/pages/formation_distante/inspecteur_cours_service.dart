import 'dart:convert';
import 'package:epst_windows_app/pages/formation_distante/api_response.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:http/http.dart' as http;

import 'inspecteur_cours.dart';

class InspecteurCoursService {
  static String baseUrl = '${Connexion.lien}api/inspecteur-cours';

  static final http.Client _client = http.Client();

  // Headers communs
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Gestion des erreurs
  static void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Erreur serveur');
    }
  }

  // GET ALL avec pagination et tri
  static Future<ApiResponse<InspecteurCours>> getAll({
    int pageIndex = 0,
    int pageSize = 20,
    String? sortBy,
    int? idInspecteur,
    bool sortAsc = true,
  }) async {
    final params = {
      if (idInspecteur != null) 'idInspecteur': idInspecteur.toString(),
      'pageIndex': pageIndex.toString(),
      'pageSize': pageSize.toString(),
      if (sortBy != null) 'sortBy': sortBy,
      'sortAsc': sortAsc.toString(),
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await _client.get(uri, headers: _headers);

    _handleError(response);

    final jsonResponse = json.decode(response.body);
    return ApiResponse<InspecteurCours>.fromJson(
      jsonResponse,
      (item) => InspecteurCours.fromJson(item),
    );
  }

  // GET BY ID
  static Future<InspecteurCours> getById(int id) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/$id'),
      headers: _headers,
    );

    _handleError(response);
    return InspecteurCours.fromJson(json.decode(response.body));
  }

  // CREATE
  static Future<InspecteurCours> create(InspecteurCours inspecteurCours) async {
    final response = await _client.post(
      Uri.parse(baseUrl),
      headers: _headers,
      body: json.encode(inspecteurCours.toJson()),
    );

    _handleError(response);
    return InspecteurCours.fromJson(json.decode(response.body));
  }

  // UPDATE
  static Future<InspecteurCours> update(
      int id, InspecteurCours inspecteurCours) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/$id'),
      headers: _headers,
      body: json.encode(inspecteurCours.toJson()),
    );

    _handleError(response);
    return InspecteurCours.fromJson(json.decode(response.body));
  }

  // DELETE
  static Future<void> delete(int id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/$id'),
      headers: _headers,
    );

    _handleError(response);
  }

  // GET BY INSPECTEUR ID
  static Future<List<InspecteurCours>> getByInspecteurId(
      int idInspecteur) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/inspecteur/$idInspecteur'),
      headers: _headers,
    );

    _handleError(response);
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((item) => InspecteurCours.fromJson(item)).toList();
  }

  // ADD COURS
  static Future<InspecteurCours> addCours(int id, int coursId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/$id/cours?coursId=$coursId'),
      headers: _headers,
    );

    _handleError(response);
    return InspecteurCours.fromJson(json.decode(response.body));
  }

  // REMOVE COURS
  static Future<InspecteurCours> removeCours(int id, int coursId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/$id/cours/$coursId'),
      headers: _headers,
    );

    _handleError(response);
    return InspecteurCours.fromJson(json.decode(response.body));
  }

  // ADD CLASSE
  static Future<InspecteurCours> addClasse(int id, int classeId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/$id/classe?classeId=$classeId'),
      headers: _headers,
    );

    _handleError(response);
    return InspecteurCours.fromJson(json.decode(response.body));
  }

  // REMOVE CLASSE
  static Future<InspecteurCours> removeClasse(int id, int classeId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/$id/classe/$classeId'),
      headers: _headers,
    );

    _handleError(response);
    return InspecteurCours.fromJson(json.decode(response.body));
  }

  // SEARCH
  static Future<List<InspecteurCours>> search({
    int? idInspecteur,
    int? coursId,
    int? classeId,
  }) async {
    final params = {
      if (idInspecteur != null) 'idInspecteur': idInspecteur.toString(),
      if (coursId != null) 'coursId': coursId.toString(),
      if (classeId != null) 'classeId': classeId.toString(),
    };

    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: params);
    final response = await _client.get(uri, headers: _headers);

    _handleError(response);
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((item) => InspecteurCours.fromJson(item)).toList();
  }

  // COUNT
  static Future<int> count() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/count'),
      headers: _headers,
    );

    _handleError(response);
    final jsonResponse = json.decode(response.body);
    return jsonResponse['count'];
  }
}
