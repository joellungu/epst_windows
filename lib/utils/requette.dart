import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'connexion.dart';

class Requette extends GetConnect {
  Future<Response> getEs(String path) async {
    print(":: ${Connexion.lien}$path");
    return get(
      "${Connexion.lien}$path",
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );
  }

  //
  Future<Response> postEs(String path, var data) async {
    return post(
      "${Connexion.lien}$path",
      data,
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );
  }

//
  Future<Response> putEs(String path, var data) async {
    return put(
      "${Connexion.lien}$path",
      data,
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );
  }

//
  Future<Response> deleteEs(String path) async {
    return delete(
      "${Connexion.lien}$path",
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );
  }
//
  Future<Response> uploadFile(String path, File file) async {
    final filename = file.path.split(Platform.pathSeparator).last;
    final form = FormData({
      'file': MultipartFile(file, filename: filename),
    });
    return post(
      "${Connexion.lien}$path",
      form,
      headers: {
        "Accept": "*/*",
        "Content-Type": "multipart/form-data",
      },
    );
  }

  Future<Response> sendMultipartWithProgress(
    String method,
    String path, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    void Function(int sent, int total)? onProgress,
  }) async {
    final uri = Uri.parse("${Connexion.lien}$path");
    final request = http.MultipartRequest(method, uri);
    request.fields.addAll(fields);
    request.files.addAll(files);

    int total = 0;
    for (final f in files) {
      total += f.length;
    }

    int sent = 0;
    for (int i = 0; i < request.files.length; i++) {
      final f = request.files[i];
      final stream = f.finalize().transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: (data, sink) {
            sent += data.length;
            if (onProgress != null) {
              onProgress(sent, total);
            }
            sink.add(data);
          },
        ),
      );
      request.files[i] = http.MultipartFile(
        f.field,
        stream,
        f.length,
        filename: f.filename,
        contentType: f.contentType,
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return Response(
      statusCode: response.statusCode,
      bodyString: response.body,
    );
  }

  Future<http.MultipartFile> filePart(String name, File file) async {
    final filename = file.path.split(Platform.pathSeparator).last;
    final length = await file.length();
    final stream = http.ByteStream(file.openRead());
    return http.MultipartFile(name, stream, length, filename: filename);
  }

  http.MultipartFile textPart(String name, String value) {
    return http.MultipartFile.fromString(
      name,
      value,
      contentType: MediaType("text", "plain"),
    );
  }

  http.MultipartFile jsonPart(String name, String value) {
    return http.MultipartFile.fromString(
      name,
      value,
      contentType: MediaType("application", "json"),
    );
  }
}
