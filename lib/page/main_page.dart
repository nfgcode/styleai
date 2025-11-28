import 'package:flutter/material.dart';

import '../fragment/fragment_generate_image.dart';
import '../fragment/fragment_generate_text.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade100,
        centerTitle: true,
        title: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: const Text(
            'StyleAI',
            style: TextStyle(
              color: Color(0xFF5A5A5A),
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1.5,
            ),
          ),
        ),
        bottom: setTabBar(),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          FragmentGenerateText(),
          FragmentGenerateImage(),
        ],
      ),
    );
  }

  TabBar setTabBar() {
    return TabBar(
        controller: tabController,
        labelColor: const Color(0xFF5A5A5A),
        unselectedLabelColor: Colors.black26,
        indicatorColor: const Color(0xFF5A5A5A),
        tabs: const [
          Tab(
            text: 'Generate Text',
            icon: Icon(Icons.text_fields),
          ),
          Tab(
            text: 'Generate Image',
            icon: Icon(Icons.image_search),
          ),
        ]
    );
  }
}
