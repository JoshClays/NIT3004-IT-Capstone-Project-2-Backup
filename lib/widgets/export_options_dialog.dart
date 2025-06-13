import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/export_service.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class ExportOptionsDialog extends StatefulWidget {
  final List<Transaction> transactions;

  const ExportOptionsDialog({
    super.key,
    required this.transactions,
  });

  @override
  State<ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<ExportOptionsDialog> with TickerProviderStateMixin {
  bool _isExporting = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.file_download_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Export Financial Report',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${widget.transactions.length} transactions',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Export Method',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Local Save Option
                          _buildExportOption(
                            icon: Icons.save_alt_rounded,
                            title: 'Save to Device',
                            subtitle: 'Save files to Downloads folder',
                            color: Colors.green,
                            onTap: () => _showLocalSaveOptions(),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Gmail Option
                          _buildExportOption(
                            icon: Icons.email_rounded,
                            title: 'Send via Gmail',
                            subtitle: 'Share files through email',
                            color: Colors.blue,
                            onTap: () => _showGmailOptions(),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Info Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'File Locations',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '📁 Downloads: /storage/emulated/0/Download/\n'
                                  '📱 Access via: File Manager → Downloads',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Footer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isExporting ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showLocalSaveOptions() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => _LocalSaveDialog(transactions: widget.transactions),
    );
  }
  
  void _showGmailOptions() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => _GmailShareDialog(transactions: widget.transactions),
    );
  }
}

class _LocalSaveDialog extends StatefulWidget {
  final List<Transaction> transactions;

  const _LocalSaveDialog({required this.transactions});

  @override
  State<_LocalSaveDialog> createState() => _LocalSaveDialogState();
}

class _LocalSaveDialogState extends State<_LocalSaveDialog> {
  bool _isExporting = false;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.save_alt_rounded, color: Colors.green),
          const SizedBox(width: 8),
          Text('Save to Device'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose format to save to your Downloads folder:'),
          const SizedBox(height: 16),
          
          // Format options
          _buildFormatOption(
            icon: Icons.picture_as_pdf,
            title: 'PDF Report',
            subtitle: 'Professional formatted report',
            color: Colors.red,
            onTap: () => _saveFormat('PDF'),
          ),
          const SizedBox(height: 8),
          _buildFormatOption(
            icon: Icons.table_chart,
            title: 'CSV Data',
            subtitle: 'Spreadsheet format for Excel',
            color: Colors.green,
            onTap: () => _saveFormat('CSV'),
          ),
          const SizedBox(height: 8),
          _buildFormatOption(
            icon: Icons.all_inclusive,
            title: 'Both Formats',
            subtitle: 'PDF + CSV files',
            color: Colors.purple,
            onTap: () => _saveFormat('BOTH'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
      ],
    );
  }
  
  Widget _buildFormatOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isExporting ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _saveFormat(String format) async {
    setState(() => _isExporting = true);
    
    try {
      bool success = false;
      List<String> savedFiles = [];
      
      switch (format) {
        case 'PDF':
          success = await ExportService.exportToPDF(widget.transactions);
          if (success) savedFiles.add('PDF');
          break;
        case 'CSV':
          success = await ExportService.exportToCSV(widget.transactions);
          if (success) savedFiles.add('CSV');
          break;
        case 'BOTH':
          final results = await ExportService.saveToLocalStorage(widget.transactions);
          success = results.values.any((s) => s);
          if (results['PDF'] == true) savedFiles.add('PDF');
          if (results['CSV'] == true) savedFiles.add('CSV');
          break;
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        _showSaveResult(success, savedFiles);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showSaveResult(false, []);
      }
    }
  }
  
  void _showSaveResult(bool success, List<String> savedFiles) {
    final message = success 
      ? 'Files saved to Downloads folder:\n${savedFiles.map((f) => '• $f').join('\n')}\n\nAccess via File Manager → Downloads'
      : 'Failed to save files. Please try again.';
      
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(success ? 'Files Saved!' : 'Save Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          if (success)
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '/storage/emulated/0/Download/'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Download path copied to clipboard')),
                );
              },
              child: Text('Copy Path'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _GmailShareDialog extends StatefulWidget {
  final List<Transaction> transactions;

  const _GmailShareDialog({required this.transactions});

  @override
  State<_GmailShareDialog> createState() => _GmailShareDialogState();
}

class _GmailShareDialogState extends State<_GmailShareDialog> {
  bool _isExporting = false;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.email_rounded, color: Colors.blue),
          const SizedBox(width: 8),
          Text('Send via Gmail'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose format to share via Gmail:'),
          const SizedBox(height: 16),
          
          // Format options
          _buildFormatOption(
            icon: Icons.picture_as_pdf,
            title: 'PDF Report',
            subtitle: 'Professional formatted report',
            color: Colors.red,
            onTap: () => _shareFormat('PDF'),
          ),
          const SizedBox(height: 8),
          _buildFormatOption(
            icon: Icons.table_chart,
            title: 'CSV Data',
            subtitle: 'Spreadsheet format for Excel',
            color: Colors.green,
            onTap: () => _shareFormat('CSV'),
          ),
          const SizedBox(height: 8),
          _buildFormatOption(
            icon: Icons.all_inclusive,
            title: 'Both Formats',
            subtitle: 'PDF + CSV files',
            color: Colors.purple,
            onTap: () => _shareFormat('BOTH'),
          ),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Files will also be saved to Downloads folder',
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
      ],
    );
  }
  
  Widget _buildFormatOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isExporting ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _shareFormat(String format) async {
    setState(() => _isExporting = true);
    
    try {
      bool success = false;
      
      switch (format) {
        case 'PDF':
          success = await ExportService.exportToPDF(widget.transactions);
          break;
        case 'CSV':
          success = await ExportService.exportToCSV(widget.transactions);
          break;
        case 'BOTH':
          success = await ExportService.exportAndShareAllFormats(widget.transactions);
          break;
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Files exported! Select Gmail from share dialog to send via email.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 