import 'package:flutter/material.dart';

void main() {
  runApp(const PyberGangzApp());
}

class PyberGangzApp extends StatelessWidget {
  const PyberGangzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PyberGangz IDLE',
      theme: ThemeData(
        useMaterial3: true,
        // Cấu hình Material You với tông màu xanh chủ đạo
        colorSchemeSeed: Colors.blue, 
        brightness: Brightness.dark,
      ),
      home: const MainEditorScreen(),
    );
  }
}

class MainEditorScreen extends StatefulWidget {
  const MainEditorScreen({super.key});

  @override
  State<MainEditorScreen> createState() => _MainEditorScreenState();
}

class _MainEditorScreenState extends State<MainEditorScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Terminal (Live)'];
  final List<TextEditingController> _controllers = [TextEditingController()];
  
  // Settings
  double _fontSize = 14.0;
  String _fontFamily = 'monospace';
  Color? _customBgColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  void _addNewTab() {
    setState(() {
      int newIdx = _tabs.length;
      _tabs.add('Script_$newIdx.py');
      _controllers.add(TextEditingController());
      _tabController = TabController(
        length: _tabs.length, 
        vsync: this, 
        initialIndex: newIdx
      );
    });
  }

  void _closeTab(int index) {
    if (index == 0) return; 
    setState(() {
      _tabs.removeAt(index);
      _controllers.removeAt(index);
      _tabController = TabController(
        length: _tabs.length, 
        vsync: this, 
        initialIndex: index - 1
      );
    });
  }

  void _runCode(int index) {
    String code = _controllers[index].text;
    setState(() {
      _controllers[0].text += "\n>>> Executing ${_tabs[index]}...\n$code\n[Finished]\n";
    });
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: _customBgColor ?? colorScheme.surface,
      appBar: AppBar(
        title: const Text('PyberGangz IDLE', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.notes), // Icon ba gạch kiểu Material 3
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          tabs: _tabs.asMap().entries.map((entry) {
            return Tab(
              child: Row(
                children: [
                  Icon(entry.key == 0 ? Icons.terminal : Icons.description_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(entry.value),
                  if (entry.key != 0) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _closeTab(entry.key),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ]
                ],
              ),
            );
          }).toList(),
        ),
      ),
      drawer: _buildDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: _controllers.asMap().entries.map((entry) {
          int idx = entry.key;
          bool isTerminal = idx == 0;
          
          return Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isTerminal ? Colors.black : colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16), // Bo góc kiểu Material 3
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: entry.value,
                    maxLines: null,
                    expands: true,
                    style: TextStyle(
                      color: isTerminal ? Colors.greenAccent : colorScheme.onSurface,
                      fontFamily: _fontFamily,
                      fontSize: _fontSize,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                // Nút chức năng bay bổng
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: isTerminal 
                    ? FloatingActionButton.small(
                        heroTag: 'add_tab_$idx',
                        onPressed: _addNewTab,
                        child: const Icon(Icons.add),
                      )
                    : _buildActionMenu(idx, colorScheme),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionMenu(int index, ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      tooltip: 'Options',
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: colorScheme.onPrimaryContainer),
      ),
      onSelected: (value) {
        if (value == 'run') _runCode(index);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'save', child: ListTile(leading: Icon(Icons.save), title: Text('Save'))),
        const PopupMenuItem(value: 'save_as', child: ListTile(leading: Icon(Icons.save_as), title: Text('Save As'))),
        const PopupMenuItem(value: 'run', child: ListTile(leading: Icon(Icons.play_arrow), title: Text('Save and Run'))),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
            child: const Center(
              child: Text('PyberGangz\nSettings', 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About this project'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'PyberGangz IDLE',
              applicationVersion: '1.0.0',
              children: [const Text('Dự án được phát triển bởi CyberGangz.')],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.extension),
            title: const Text('Install Module'),
            onTap: () {},
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Options", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.format_size, size: 20),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 12, max: 24,
                    onChanged: (v) => setState(() => _fontSize = v),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text("Background Deep Dark"),
            trailing: Switch(
              value: _customBgColor == Colors.black,
              onChanged: (val) {
                setState(() => _customBgColor = val ? Colors.black : null);
              },
            ),
          ),
        ],
      ),
    );
  }
}