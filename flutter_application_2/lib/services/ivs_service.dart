import 'dart:convert';
import 'package:http/http.dart' as http;

// 頻道模型
class Channel {
  final String id;
  final String name;
  final String playbackUrl;
  final String? arn;
  final String? ingestEndpoint;
  final bool isLive;
  final String? latencyMode;

  Channel({
    required this.id,
    required this.name,
    required this.playbackUrl,
    this.arn,
    this.ingestEndpoint,
    this.isLive = false,
    this.latencyMode,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] ?? '',
      name: json['name'] ?? '未命名頻道',
      playbackUrl: json['playbackUrl'] ?? '',
      arn: json['arn'],
      ingestEndpoint: json['ingestEndpoint'],
      isLive: json['isLive'] ?? false,
      latencyMode: json['latencyMode'],
    );
  }
}

// IVS API 服務
class IVSApiService {
  static const String apiUrl =
      'https://xrgoia7scd.execute-api.ap-northeast-1.amazonaws.com/default/getIVSChannels';

  static Future<List<Channel>> fetchChannels() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> channelList = data['channels'] ?? [];
          return channelList.map((json) => Channel.fromJson(json)).toList();
        }
        throw Exception(data['error'] ?? '獲取頻道失敗');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('無法連接到伺服器: $e');
    }
  }
}