import 'package:flutter/material.dart';

class NewsTemplateDesigns {
  // ==========================================
  // 9:16 FORMAT TEMPLATES (Vertical / Reel)
  // ==========================================

  /// ১. Split Comparison Template (৯:১৬)
  static Widget buildSplitComparisonTemplate(BuildContext context, Map<String, dynamic> data) {
    return Container(
      color: const Color(0xFF101010),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              data['mainHeader'] ?? 'BREAKING NEWS',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey.shade900,
                    child: data['person1Url'] != null
                        ? Image.network(data['person1Url'], fit: BoxFit.cover)
                        : const Icon(Icons.person, color: Colors.white54, size: 48),
                  ),
                ),
                const VerticalDivider(width: 2, color: Colors.white24),
                Expanded(
                  child: Container(
                    color: Colors.grey.shade900,
                    child: data['person2Url'] != null
                        ? Image.network(data['person2Url'], fit: BoxFit.cover)
                        : const Icon(Icons.person, color: Colors.white54, size: 48),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.all(12),
            child: Text(
              data['footerText'] ?? 'Latest updates regarding the ongoing event...',
              style: const TextStyle(color: Colors.yellowAccent, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// ২. Cyberpunk Reel Template (৯:১৬) - নতুন ডিজাইন
  static Widget buildCyberpunkReelTemplate(BuildContext context, Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyanAccent, width: 2),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: data['imageUrl'] != null
                ? Image.network(data['imageUrl'], fit: BoxFit.cover)
                : Container(color: Colors.grey.shade900, child: const Icon(Icons.image, color: Colors.white38, size: 64)),
          ),
          Positioned(
            bottom: 16,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.bolt, color: Colors.cyanAccent, size: 18),
                      SizedBox(width: 4),
                      Text('FLASH BULLETIN', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['newsBody'] ?? 'Cyberpunk futuristic news update headline goes here.',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 16:9 FORMAT TEMPLATES (Horizontal / TV)
  // ==========================================

  /// ৩. Studio Anchor Template (১৬:৯)
  static Widget buildStudioAnchor169(BuildContext context, Map<String, dynamic> data) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: data['studioBg'] != null
                  ? Image.network(data['studioBg'], fit: BoxFit.cover)
                  : Container(color: Colors.blueGrey.shade900, child: const Icon(Icons.tv, color: Colors.white24, size: 64)),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.red.shade900,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      color: Colors.yellowAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: const Text('LIVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data['tickerText'] ?? 'Breaking News Ticker running at the bottom of the screen...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ৪. Minimalist Clean Broadcast Template (১৬:৯) - নতুন ডিজাইন
  static Widget buildMinimalistBroadcast169(BuildContext context, Map<String, dynamic> data) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: const Color(0xFF181818),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: data['mediaUrl'] != null
                  ? Image.network(data['mediaUrl'], fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade800, child: const Icon(Icons.videocam, color: Colors.white38, size: 48)),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: Colors.blueAccent,
                      child: Text(
                        data['category'] ?? 'WORLD',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['headline'] ?? 'Minimalist Broadcast Headline Design',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
