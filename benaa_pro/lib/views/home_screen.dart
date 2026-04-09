import 'package:flutter/material.dart';
import 'concrete_calculator_tab.dart';
import 'block_calculator_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Benaa Pro"),
        backgroundColor: const Color(0xFF1E3A8A),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF59E0B),
          tabs: const [
            Tab(icon: Icon(Icons.foundation), text: "الخرسانة"),
            Tab(icon: Icon(Icons.layers), text: "الطابوق"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [ConcreteCalculatorTab(), BlockCalculatorTab()],
      ),
    );
  }
}
