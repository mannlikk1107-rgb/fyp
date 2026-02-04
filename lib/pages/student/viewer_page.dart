import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/ivs_service.dart';

class ViewerPage extends StatefulWidget {
  final Channel channel;

  const ViewerPage({super.key, required this.channel});

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _isLive = false;
  String? _errorMessage;

  // 聊天室相關
  final TextEditingController _messageController = TextEditingController();
  final String _username =
      'User${DateTime.now().millisecondsSinceEpoch % 1000}';
  bool _showChat = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _videoController?.dispose();
      _chewieController?.dispose();

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.playbackUrl),
      );
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showOptions: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
      );

      setState(() {
        _isLoading = false;
        _isLive = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLive = false;
        _errorMessage = '主播未開播';
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    FirebaseFirestore.instance.collection('messages_default').add({
      'text': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'username': _username,
    });

    _messageController.clear();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            if (_isLive) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.white),
                    SizedBox(width: 4),
                    Text('LIVE',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(widget.channel.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showChat ? Icons.chat : Icons.chat_bubble_outline,
                color: Colors.white),
            onPressed: () => setState(() => _showChat = !_showChat),
            tooltip: _showChat ? '隱藏聊天室' : '顯示聊天室',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _initPlayer,
          ),
        ],
      ),
      body: Column(
        children: [
          // 播放器
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildPlayer(),
          ),
          // 聊天室或主播信息
          Expanded(
            child: _showChat ? _buildChatRoom() : _buildStreamerInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text('載入中...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || !_isLive) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tv_off, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? '主播未開播',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initPlayer,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重試'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }

  Widget _buildChatRoom() {
    return Container(
      color: const Color(0xFF1a1a2e),
      child: Column(
        children: [
          // 聊天標題
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              border: const Border(
                  bottom: BorderSide(color: Colors.white12, width: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.chat_bubble, size: 16, color: Colors.white54),
                SizedBox(width: 8),
                Text('聊天室',
                    style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),

          // 聊天消息列表
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages_default')
                  .orderBy('timestamp', descending: false)
                  .limitToLast(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('聊天室載入失敗',
                        style: TextStyle(color: Colors.grey[500])),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('還沒有消息，說點什麼吧！',
                        style: TextStyle(color: Colors.grey[600])),
                  );
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: false,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data =
                        messages[index].data() as Map<String, dynamic>;
                    final text = data['text'] ?? '';
                    final username = data['username'] ?? 'Unknown';
                    final isMe = username == _username;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$username: ',
                            style: TextStyle(
                              color: isMe
                                  ? Colors.amber
                                  : Colors.deepPurple[200],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              text,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 輸入框
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: const Border(
                  top: BorderSide(color: Colors.white12, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '說點什麼...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[900],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamerInfo() {
    return Container(
      color: const Color(0xFF1a1a2e),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.deepPurple,
                child: Text(
                  widget.channel.name.isNotEmpty
                      ? widget.channel.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.channel.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(
                      _isLive ? '直播中' : '未開播',
                      style: TextStyle(
                          color: _isLive ? Colors.green : Colors.grey[500],
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('頻道 ID: ${widget.channel.id}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          if (widget.channel.latencyMode != null) ...[
            const SizedBox(height: 4),
            Text(
                '延遲模式: ${widget.channel.latencyMode == "LOW" ? "低延遲" : "標準"}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ],
      ),
    );
  }
}