import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PinataService {
  static const String pinataApiKey = "c3d4fe29a74cc99b7f3e";
  static const String pinataSecretApiKey = "9157a9e23a9cb12d22a29ef9091f974a59c2d6e42b150310d13f898617e93a59";
  static const String url = "https://api.pinata.cloud/pinning/pinFileToIPFS";

  Future<String?> uploadFile(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      request.headers.addAll({
        "pinata_api_key": pinataApiKey,
        "pinata_secret_api_key": pinataSecretApiKey,
      });

      var response = await request.send();
      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();
        var jsonRes = json.decode(body);
        return "https://gateway.pinata.cloud/ipfs/${jsonRes['IpfsHash']}";
      } else {
        print("Upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }
}
