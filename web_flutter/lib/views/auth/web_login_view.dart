import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/web_api_service.dart';
import '../../core/theme/app_theme.dart';

class WebLoginView extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const WebLoginView({super.key, required this.onLoginSuccess});

  @override
  State<WebLoginView> createState() => _WebLoginViewState();
}

class _WebLoginViewState extends State<WebLoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'ADMINISTRATOR';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _applyDemoAccount('ADMINISTRATOR');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _applyDemoAccount(String role) {
    setState(() {
      _selectedRole = role;
      _errorMessage = null;
      final demo = WebApiService.demoAccounts.firstWhere(
        (d) => d.role == role,
        orElse: () => WebApiService.demoAccounts.first,
      );
      _emailController.text = demo.email;
      _passwordController.text = demo.defaultPassword;
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final webApi = Provider.of<WebApiService>(context, listen: false);
    final success = await webApi.login(
      email: email,
      password: password,
      role: _selectedRole,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        widget.onLoginSuccess();
      } else {
        setState(() => _errorMessage = 'Invalid credentials or network connection issue');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDemo = WebApiService.demoAccounts.firstWhere(
      (d) => d.role == _selectedRole,
      orElse: () => WebApiService.demoAccounts.first,
    );
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor: WebColors.sidebarBg,
      body: Stack(
        children: [
          // Background ambient design
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    WebColors.accentTeal.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 550,
              height: 550,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    WebColors.primaryGreen.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Center Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 960 : 480),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: isDesktop
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left Brand & Info Panel
                              Expanded(flex: 5, child: _buildLeftHeroPanel(currentDemo)),
                              // Right Login Form Panel
                              Expanded(flex: 6, child: _buildRightFormPanel(currentDemo)),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            _buildLeftHeroPanel(currentDemo, compact: true),
                            _buildRightFormPanel(currentDemo),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftHeroPanel(DemoAccount currentDemo, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WebColors.sidebarBg,
            Color(0xFF0D251E),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: WebColors.accentTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'THIRAN AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Operations Console',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Livelihood & Skills Intelligence Platform',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Multi-role administration, AI skills-pathway orchestration, vocational training, and verified wage placement.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              ),
            ],
          ),

          if (!compact) ...[
            const SizedBox(height: 32),
            // Current Role Permissions Preview
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: WebColors.accentTeal, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Active Role: ${currentDemo.title}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentDemo.description,
                    style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: currentDemo.allowedTabs.map((idx) {
                      final tabNames = [
                        'Dashboard',
                        'Beneficiaries',
                        'Training',
                        'Opportunities',
                        'Mentors',
                        'Comms',
                        'Tickets',
                      ];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: WebColors.accentTeal.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: WebColors.accentTeal.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          tabNames[idx],
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Footer
          Row(
            children: const [
              Icon(Icons.lock_outline, color: Colors.white38, size: 14),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Role-Based Access Control (RBAC) Enforced',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightFormPanel(DemoAccount currentDemo) {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Portal Sign In',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: WebColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select your organization role or log in with verified credentials.',
            style: TextStyle(fontSize: 13, color: WebColors.textMuted),
          ),
          const SizedBox(height: 24),

          // Role Selector Chips
          const Text(
            'SELECT ROLE FOR RBAC ACCESS:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: WebColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WebApiService.demoAccounts.map((account) {
              final isSelected = _selectedRole == account.role;
              return ChoiceChip(
                label: Text(
                  account.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : WebColors.textDark,
                  ),
                ),
                selected: isSelected,
                selectedColor: WebColors.primaryGreen,
                backgroundColor: WebColors.surfaceBg,
                side: BorderSide(
                  color: isSelected ? WebColors.primaryGreen : WebColors.borderSubtle,
                ),
                onSelected: (_) => _applyDemoAccount(account.role),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Error banner
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WebColors.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: WebColors.errorRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: WebColors.errorRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: WebColors.errorRed, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Email Input
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Work Email / Identifier',
              prefixIcon: Icon(Icons.alternate_email, size: 20),
            ),
          ),
          const SizedBox(height: 16),

          // Password Input
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: WebColors.textMuted,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            onSubmitted: (_) => _handleLogin(),
          ),

          const SizedBox(height: 14),

          // Account Info Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: WebColors.surfaceBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: WebColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_circle, color: WebColors.primaryGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentDemo.fullName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WebColors.textDark),
                      ),
                      Text(
                        currentDemo.organization,
                        style: const TextStyle(fontSize: 11, color: WebColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sign In Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sign In to Workspace',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
