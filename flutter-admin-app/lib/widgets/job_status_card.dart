import 'package:flutter/material.dart';
import '../models/job_execution.dart';

class JobStatusCard extends StatelessWidget {
  final JobExecution job;

  const JobStatusCard({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(),
          child: Icon(
            _getStatusIcon(),
            color: Colors.white,
          ),
        ),
        title: Text(
          job.tableName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${job.jobType} - ${job.status}'),
            if (job.recordsProcessed > 0)
              Text('Processed: ${job.recordsProcessed} records'),
            if (job.recordsArchived > 0)
              Text('Archived: ${job.recordsArchived} records'),
            if (job.recordsPurged > 0)
              Text('Purged: ${job.recordsPurged} records'),
            if (job.duration != null)
              Text('Duration: ${_formatDuration(job.duration!)}'),
          ],
        ),
        trailing: job.isFailed && job.errorMessage != null
            ? IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showErrorDialog(context),
              )
            : null,
      ),
    );
  }

  Color _getStatusColor() {
    switch (job.status) {
      case 'RUNNING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (job.status) {
      case 'RUNNING':
        return Icons.play_arrow;
      case 'COMPLETED':
        return Icons.check;
      case 'FAILED':
        return Icons.error;
      case 'PENDING':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: Text(job.errorMessage ?? 'No error message available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}