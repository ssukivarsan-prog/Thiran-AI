import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/network/web_api_service.dart';
import '../core/theme/app_theme.dart';

class WebLayoutShell extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget child;

  const WebLayoutShell({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  State<WebLayoutShell> createState() => _WebLayoutShellState();
}

class _WebLayoutShellState extends State<WebLayoutShell> {
  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Operations Dashboard', 'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard},
    {'title': 'Beneficiary Directory', 'icon': Icons.people_outline, 'activeIcon': Icons.people},
    {'title': 'Training Programs', 'icon': Icons.school_outlined, 'activeIcon': Icons.school},
    {'title': 'Livelihood Opportunities', 'icon': Icons.work_outline, 'activeIcon': Icons.work},
    {'title': 'Mentor Network', 'icon': Icons.handshake_outlined, 'activeIcon': Icons.handshake},
    {'title': 'Omnichannel Comms', 'icon': Icons.cell_tower, 'activeIcon': Icons.cell_tower},
    {'title': 'Escalation Tickets', 'icon': Icons.confirmation_number_outlined, 'activeIcon': Icons.confirmation_number},
  ];

  Widget _buildSidebarContent(BuildContext context, {bool isDrawer = false}) {
    final webApi = Provider.of<WebApiService>(context);
    final permittedTabs = webApi.getPermittedTabs();
    final visibleNavItems = permittedTabs.map((idx) => {'item': _navItems[idx], 'index': idx}).toList();

    return Container(
      width: 260,
      color: WebColors.sidebarBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: WebColors.accentTeal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'THIRAN AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Operations Console',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (isDrawer)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),

            // Active Workspace Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: WebColors.accentTeal, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      webApi.activeDemoAccount.title.toUpperCase(),
                      style: const TextStyle(
                        color: WebColors.accentTeal,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Navigation items (strictly filtered by RBAC)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: visibleNavItems.length,
                itemBuilder: (context, i) {
                  final entry = visibleNavItems[i];
                  final item = entry['item'] as Map<String, dynamic>;
                  final originalIndex = entry['index'] as int;
                  final isSelected = widget.selectedIndex == originalIndex;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: InkWell(
                      onTap: () {
                        widget.onIndexChanged(originalIndex);
                        if (isDrawer) {
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? WebColors.sidebarActive : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item['activeIcon'] : item['icon'],
                              color: isSelected ? Colors.white : Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['title'],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // System Status Card (Zero Gemini mentions)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.circle, color: WebColors.successGreen, size: 8),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thiran AI Engine Online',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Thiran AI Intelligence Core Connected', style: TextStyle(color: Colors.white60, fontSize: 10)),
                ],
              ),
            ),

            // User & Logout Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: WebColors.accentTeal,
                    child: Text(
                      (webApi.currentUser?.fullName.isNotEmpty == true)
                          ? webApi.currentUser!.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          webApi.currentUser?.fullName ?? 'Authorized User',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          webApi.currentUser?.organization ?? 'Thiran AI Network',
                          style: const TextStyle(color: Colors.white60, fontSize: 9),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
                    tooltip: 'Sign Out',
                    onPressed: () => webApi.logout(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final webApi = Provider.of<WebApiService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final isMobile = screenWidth < 600;

    return Scaffold(
      drawer: isDesktop ? null : Drawer(child: _buildSidebarContent(context, isDrawer: true)),
      body: Row(
        children: [
          // Permanent Sidebar on Desktop
          if (isDesktop) _buildSidebarContent(context),

          // Main View Content with Responsive TopBar
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                Container(
                  height: 64,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: WebColors.borderSubtle)),
                  ),
                  child: Row(
                    children: [
                      // Hamburger Menu Button on Mobile / Tablet
                      if (!isDesktop)
                        Builder(
                          builder: (innerContext) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: const Icon(Icons.menu, color: WebColors.textDark),
                              tooltip: 'Open Menu',
                              onPressed: () => Scaffold.of(innerContext).openDrawer(),
                            ),
                          ),
                        ),

                      // Search field
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: SizedBox(
                            height: 38,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: isMobile ? 'Search...' : 'Search beneficiaries, skills, courses...',
                                hintStyle: const TextStyle(fontSize: 12),
                                prefixIcon: const Icon(Icons.search, size: 16, color: WebColors.textMuted),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                fillColor: WebColors.surfaceBg,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Role Switcher Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: WebColors.surfaceBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: WebColors.borderSubtle),
                        ),
                        child: DropdownButton<String>(
                          value: webApi.activeRole,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                          items: const [
                            DropdownMenuItem(value: 'ADMINISTRATOR', child: Text('Admin Console', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                            DropdownMenuItem(value: 'TRAINING_PROVIDER', child: Text('Training Partner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                            DropdownMenuItem(value: 'EMPLOYER', child: Text('Hiring Partner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                            DropdownMenuItem(value: 'SUPPORT_WORKER', child: Text('Support Counselor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                            DropdownMenuItem(value: 'MENTOR', child: Text('Industry Mentor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              webApi.setRole(val);
                              final permitted = webApi.getPermittedTabs();
                              if (!permitted.contains(widget.selectedIndex)) {
                                widget.onIndexChanged(permitted.first);
                              }
                            }
                          },
                        ),
                      ),

                      if (!isMobile) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Notifications',
                          icon: const Icon(Icons.notifications_none, color: WebColors.textDark, size: 20),
                          onPressed: () {},
                        ),
                      ],

                      const SizedBox(width: 8),

                      CircleAvatar(
                        radius: 15,
                        backgroundColor: WebColors.primaryGreen,
                        child: Text(
                          (webApi.currentUser?.fullName.isNotEmpty == true)
                              ? webApi.currentUser!.fullName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              webApi.currentUser?.fullName ?? 'Thiran Admin',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WebColors.textDark),
                            ),
                            Text(
                              webApi.activeDemoAccount.title,
                              style: const TextStyle(fontSize: 10, color: WebColors.textMuted),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Sign Out',
                        icon: const Icon(Icons.logout, color: WebColors.errorRed, size: 20),
                        onPressed: () => webApi.logout(),
                      ),
                    ],
                  ),
                ),

                // View Body
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
