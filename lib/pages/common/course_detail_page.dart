// lib/pages/common/course_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:open_filex/open_filex.dart';
import '../../models/course_model.dart';
import '../../services/api_service.dart';
import '../../services/file_service.dart';
import '../../providers/user_provider.dart';
import '../student/top_up_page.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FileService _fileService = FileService();

  bool _isEnrolling = false;
  bool _isEnrolled = false;
  
  bool _isLessonsLoading = true;
  bool _isMaterialsLoading = true;
  
  List<dynamic> _lessons = [];
  List<Map<String, dynamic>> _materials = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCourseData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // [關鍵修正]：加入了完整的 try-catch-finally 防錯機制
  Future<void> _loadCourseData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? mId = userProvider.mId.isNotEmpty ? userProvider.mId : null;

    setState(() {
      _isLessonsLoading = true;
      _isMaterialsLoading = true;
    });

    try {
      debugPrint("正在載入課程資料... Course ID: ${widget.course.id}");

      final lessonFuture = ApiService.getCourseContent(widget.course.id, mId ?? '');
      final materialFuture = _fileService.getFiles(courseId: widget.course.id);
      
      // 平行等待兩個 API 請求完成
      final results = await Future.wait([lessonFuture, materialFuture]);

      final lessonData = results[0] as Map<String, dynamic>;
      final fileResult = results[1] as Map<String, dynamic>;
      
      // 印出 API 回傳的原始資料，方便除錯
      debugPrint("API Response [Lessons]: $lessonData");
      debugPrint("API Response [Materials]: $fileResult");

      if (mounted) {
        setState(() {
          // 處理課程內容
          if (lessonData['success'] == true) {
            _isEnrolled = lessonData['isEnrolled'] == true;
            _lessons = lessonData['lessons'] ?? [];
          } else {
            debugPrint("載入 Lessons 失敗: ${lessonData['message']}");
          }

          // 處理教材檔案
          if (fileResult['success'] == true) {
            _materials = List<Map<String, dynamic>>.from(fileResult['files'] ?? []);
          } else {
            debugPrint("載入 Materials 失敗: ${fileResult['message']}");
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint("--- 載入資料時發生嚴重錯誤 ---");
      debugPrint("錯誤類型: ${e.runtimeType}");
      debugPrint("錯誤訊息: $e");
      debugPrint("堆疊追蹤: $stackTrace");
      debugPrint("---------------------------");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("載入資料失敗，請稍後再試: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      // [關鍵]：無論成功或失敗，最後都必須停止轉圈圈
      if (mounted) {
        setState(() {
          _isLessonsLoading = false;
          _isMaterialsLoading = false;
        });
      }
    }
  }

  // --- Actions ---

  Future<void> _handleEnroll() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.mId.isEmpty) return;
    
    setState(() => _isEnrolling = true);
    
    if (userProvider.balance < widget.course.price) {
      if(!mounted) return;
      _showInsufficientFundsDialog(userProvider.balance);
      setState(() => _isEnrolling = false);
      return;
    }

    final result = await ApiService.enrollCourse(
      memberId: userProvider.mId, 
      courseId: widget.course.id, 
      price: widget.course.price
    );
    
    if (mounted) {
      if (result['success'] == true) {
        await userProvider.refreshBalance();
        _showDialog("Success", "You are now enrolled!");
        _loadCourseData(); // 重新載入以解鎖內容
      } else {
        _showDialog("Failed", result['message'] ?? "Unknown error", isError: true);
      }
      setState(() => _isEnrolling = false);
    }
  }

  Future<void> _downloadAndOpenMaterial(String fileUrl, String fileName) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(SnackBar(content: Text('Downloading $fileName...')));
      
      final result = await _fileService.downloadToPrivateDirectory(fileUrl, fileName);
      
      messenger.hideCurrentSnackBar();
      if (result['success']) {
        final openResult = await OpenFilex.open(result['path']);
        if (openResult.type != ResultType.done) {
           messenger.showSnackBar(SnackBar(content: Text("No application found to open this file: ${openResult.message}")));
        }
      } else {
        messenger.showSnackBar(SnackBar(content: Text("Download failed: ${result['error']}")));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Error opening file: $e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _openLesson(String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) {
       _showDialog("Info", "This lesson has no video.");
       return;
    }
    try {
      if(!await launchUrl(Uri.parse(videoUrl), mode: LaunchMode.externalApplication)) {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if(mounted) _showDialog("Error", "Could not play video.");
    }
  }
  
  // --- UI Dialogs ---

  void _showInsufficientFundsDialog(double balance) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Insufficient Funds"),
        content: Text("You need ${widget.course.price.toStringAsFixed(0)} ACoin but you only have ${balance.toStringAsFixed(0)}."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TopUpPage()));
          }, child: const Text("Top Up"))
        ],
      ),
    );
  }

  void _showDialog(String title, String content, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: isError ? Colors.red : Colors.green),
          const SizedBox(width: 10),
          Text(title)
        ]),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.course.coverImage != null && widget.course.coverImage!.isNotEmpty
                ? Image.network(widget.course.coverImage!, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildPlaceholderImage())
                : _buildPlaceholderImage(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(label: Text(widget.course.category), backgroundColor: Colors.indigo.withAlpha(25)),
                      Text("${widget.course.price.toStringAsFixed(0)} ACoin", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.course.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("By ${widget.course.teacherName}", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  Text(widget.course.description, style: const TextStyle(color: Colors.grey, height: 1.5)),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.indigo,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.indigo,
                tabs: const [Tab(text: "Lessons"), Tab(text: "Materials")],
              ),
            ),
            pinned: true,
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _isLessonsLoading ? const Center(child: CircularProgressIndicator()) : _buildLessonsList(),
            _isMaterialsLoading ? const Center(child: CircularProgressIndicator()) : _buildMaterialsList(),
          ],
        ),
      ),
      bottomSheet: !_isEnrolled ? _buildEnrollButton() : null,
    );
  }

  // --- UI Builder Methods ---

  Widget _buildPlaceholderImage() {
    return Container(color: Colors.indigo.shade50, child: const Icon(Icons.school_rounded, size: 80, color: Colors.indigo));
  }
  
  Widget _buildEnrollButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isEnrolling ? null : _handleEnroll,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
          child: _isEnrolling 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Enroll Now • ${widget.course.price.toStringAsFixed(0)} ACoin", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
  
  Widget _buildLessonsList() {
    if (!_isEnrolled) return _buildLockedContent("Enroll to watch lessons");
    if (_lessons.isEmpty) return _buildEmptyContent("No video lessons have been added yet.");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lessons.length,
      itemBuilder: (context, index) {
        final lesson = _lessons[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.play_circle_fill, color: Colors.blue),
            title: Text(lesson['lName'] ?? "Lesson ${index + 1}"),
            subtitle: Text("${lesson['duration']} min"),
            onTap: () => _openLesson(lesson['video']),
          ),
        );
      },
    );
  }

  Widget _buildMaterialsList() {
    if (!_isEnrolled) return _buildLockedContent("Enroll to access course materials");
    if (_materials.isEmpty) return _buildEmptyContent("No materials have been uploaded for this course.");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _materials.length,
      itemBuilder: (context, index) {
        final file = _materials[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.description, color: Colors.orange),
            title: Text(file['original_name'] ?? "File"),
            subtitle: Text(_fileService.formatFileSize(file['file_size'])),
            trailing: const Icon(Icons.download_rounded, color: Colors.blue),
            onTap: () => _downloadAndOpenMaterial(file['file_url'], file['original_name']),
          ),
        );
      },
    );
  }

  Widget _buildLockedContent(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildEmptyContent(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(message, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
