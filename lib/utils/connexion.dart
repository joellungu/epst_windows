import 'package:http/http.dart' as http;

class Connexion {
  //
  static var lien = 'http://localhost:9090/';
  //
  static Future<String> enregistrement(Map<String, dynamic> utilisateur) async {
    //
    var url = Uri.parse(lien + "agent");
    //
    var response = await http.post(url, body: utilisateur);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return "${response.body}";
  }
}
