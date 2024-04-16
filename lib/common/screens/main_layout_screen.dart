import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      animationDuration: Duration.zero,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('K톡'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.person, size: 30),
                iconMargin: EdgeInsets.only(bottom: 1),
                text: '친구',
              ),
              Tab(
                icon: Icon(Icons.chat_bubble_rounded, size: 30),
                iconMargin: EdgeInsets.only(bottom: 1),
                text: '채팅',
              ),
              Tab(
                icon: Icon(Icons.wechat_outlined, size: 30),
                iconMargin: EdgeInsets.only(bottom: 1),
                text: '그룹',
              )
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Center(
              child: Text('1번'),
            ),
            Center(
              child: Text('2번'),
            ),
            Center(
              child: Text('3번'),
            ),
          ],
        ),
      ),
    );
  }
}
