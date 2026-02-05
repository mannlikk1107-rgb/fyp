import 'package:flutter/material.dart';
import '../../services/ivs_service.dart';
import 'viewer_page.dart';

class ChannelListPage extends StatefulWidget {
  const ChannelListPage({super.key});

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  List<Channel> _channels = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final channels = await IVSApiService.fetchChannels();
      setState(() {
        _channels = channels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('選擇頻道', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChannels,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('載入頻道中...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('載入失敗',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300])),
              const SizedBox(height: 8),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadChannels,
                icon: const Icon(Icons.refresh),
                label: const Text('重試'),
              ),
              const SizedBox(height: 32),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              Text('或使用預設頻道', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 16),
              _buildDefaultChannelCard(),
            ],
          ),
        ),
      );
    }

    if (_channels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tv_off, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text('沒有找到頻道',
                style: TextStyle(fontSize: 18, color: Colors.grey[400])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadChannels,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新'),
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white24, indent: 48, endIndent: 48),
            const SizedBox(height: 16),
            _buildDefaultChannelCard(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChannels,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _channels.length,
        itemBuilder: (context, index) => _buildChannelCard(_channels[index]),
      ),
    );
  }

  Widget _buildDefaultChannelCard() {
    final defaultChannel = Channel(
      id: 'default',
      name: '預設頻道',
      playbackUrl:
          'https://ac97f1edccd9.ap-northeast-1.playback.live-video.net/api/video/v1/ap-northeast-1.043573420974.channel.EbF4UKrDoQOF.m3u8',
      isLive: false,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildChannelCard(defaultChannel),
    );
  }

  Widget _buildChannelCard(Channel channel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewerPage(channel: channel)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: channel.isLive
                        ? [Colors.red.shade700, Colors.red.shade900]
                        : [Colors.grey.shade700, Colors.grey.shade800],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  channel.isLive ? Icons.live_tv : Icons.tv,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(channel.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (channel.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle,
                                    size: 6, color: Colors.white),
                                SizedBox(width: 4),
                                Text('LIVE',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('ID: ${channel.id}',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (channel.latencyMode != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.speed, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            channel.latencyMode == 'LOW' ? '低延遲' : '標準',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}