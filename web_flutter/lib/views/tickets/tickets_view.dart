import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/web_api_service.dart';
import '../../core/theme/app_theme.dart';

class TicketsView extends StatefulWidget {
  const TicketsView({super.key});

  @override
  State<TicketsView> createState() => _TicketsViewState();
}

class _TicketsViewState extends State<TicketsView> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final api = Provider.of<WebApiService>(context, listen: false);
    setState(() => _isLoading = true);
    final t = await api.getTickets();
    if (mounted) {
      setState(() {
        _tickets = t;
        _isLoading = false;
      });
    }
  }

  void _resolveDialog(String id) {
    final notesCtrl = TextEditingController(text: 'Counselor provided contact for district transport pass.');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve Escalation Ticket'),
        content: TextField(
          controller: notesCtrl,
          decoration: const InputDecoration(labelText: 'Resolution Notes'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final api = Provider.of<WebApiService>(context, listen: false);
              await api.resolveTicket(id, notesCtrl.text.trim());
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              await _loadTickets();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket marked as resolved.')),
              );
            },
            child: const Text('Resolve Ticket'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 680;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Human Support Escalation Queue',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: WebColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cases escalated from AI voice & chat conversations requiring community counselor intervention',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 13,
                            color: WebColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTickets),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: WebColors.primaryGreen))
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: WebColors.borderSubtle),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _tickets.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final t = _tickets[index];
                          final isResolved = t['status'] == 'RESOLVED';

                          final detailsWidget = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      t['subject'] ?? 'Support Ticket',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WebColors.textDark),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isResolved ? WebColors.successGreen : WebColors.warningAmber).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      t['status'] ?? 'OPEN',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isResolved ? WebColors.successGreen : WebColors.warningAmber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Beneficiary: ${t['beneficiaryName'] ?? "Beneficiary"} • Channel: ${t['channel'] ?? "APP"}',
                                style: const TextStyle(fontSize: 12, color: WebColors.textMuted),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t['reason'] ?? '',
                                style: const TextStyle(fontSize: 13, color: WebColors.textDark, height: 1.4),
                              ),
                              if (isMobile && !isResolved) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _resolveDialog(t['id']),
                                    child: const Text('Resolve Case'),
                                  ),
                                ),
                              ],
                            ],
                          );

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isResolved ? WebColors.successGreen : WebColors.warningAmber).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isResolved ? Icons.check : Icons.priority_high,
                                    color: isResolved ? WebColors.successGreen : WebColors.warningAmber,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: detailsWidget),
                                if (!isMobile && !isResolved) ...[
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () => _resolveDialog(t['id']),
                                    child: const Text('Resolve Case'),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
