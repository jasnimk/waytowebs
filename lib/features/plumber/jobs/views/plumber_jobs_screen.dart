import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/common/app_snackbar.dart';
import '../../../auth/controllers/auth_provider.dart';
import '../controllers/plumber_jobs_controller.dart';
import '../repositories/plumber_jobs_repository.dart';
import '../models/plumber_job_model.dart';

class PlumberJobsScreen extends StatefulWidget {
  const PlumberJobsScreen({super.key});

  @override
  State<PlumberJobsScreen> createState() => _PlumberJobsScreenState();
}

class _PlumberJobsScreenState extends State<PlumberJobsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  PlumberJobsController? _jobsController;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize once
    if (!_isInitialized) {
      _isInitialized = true;

      final authProvider = context.read<AuthProvider>();
      final plumberId = authProvider.currentUser?.id;

      if (plumberId != null) {
        final repository = PlumberJobsRepository(Supabase.instance.client);
        _jobsController = PlumberJobsController(repository, plumberId);
        _jobsController!.fetchAllJobs();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _jobsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final authProvider = context.watch<AuthProvider>();
    final plumberId = authProvider.currentUser?.id;

    if (plumberId == null || _jobsController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _jobsController!,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.primary,
          title: const Text('My Jobs', style: TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: context.colors.secondary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Scheduled'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _JobsListView(jobType: JobType.active),
            _JobsListView(jobType: JobType.scheduled),
            _JobsListView(jobType: JobType.completed),
          ],
        ),
      ),
    );
  }
}

enum JobType { active, scheduled, completed }

class _JobsListView extends StatelessWidget {
  final JobType jobType;

  const _JobsListView({required this.jobType});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlumberJobsController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: context.colors.grey),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage!,
                  style: AppTextStyles.bodyLarge(color: context.colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchAllJobs(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final jobs = _getJobs(controller);

        if (jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: context.colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${_getJobTypeName()} jobs',
                  style: AppTextStyles.titleMedium(color: context.colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return _JobCard(job: job);
          },
        );
      },
    );
  }

  List<PlumberJobModel> _getJobs(PlumberJobsController controller) {
    switch (jobType) {
      case JobType.active:
        return controller.activeJobs;
      case JobType.scheduled:
        return controller.scheduledJobs;
      case JobType.completed:
        return controller.completedJobs;
    }
  }

  String _getJobTypeName() {
    switch (jobType) {
      case JobType.active:
        return 'active';
      case JobType.scheduled:
        return 'scheduled';
      case JobType.completed:
        return 'completed';
    }
  }
}

class _JobCard extends StatelessWidget {
  final PlumberJobModel job;

  const _JobCard({required this.job});

  Color _getStatusColor(BuildContext context) {
    switch (job.status) {
      case 'in_progress':
        return context.colors.secondary;
      case 'assigned':
        return context.colors.blue;
      case 'completed':
        return context.colors.green;
      default:
        return context.colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (job.status) {
      case 'in_progress':
        return 'In Progress';
      case 'assigned':
        return 'Scheduled';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return job.status;
    }
  }

  String _getTimeText() {
    if (job.status == 'completed' && job.completedDate != null) {
      final now = DateTime.now();
      final difference = now.difference(job.completedDate!);
      
      if (difference.inDays == 0) {
        return 'Today, ${DateFormat('h:mm a').format(job.completedDate!)}';
      } else if (difference.inDays == 1) {
        return 'Yesterday, ${DateFormat('h:mm a').format(job.completedDate!)}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago, ${DateFormat('h:mm a').format(job.completedDate!)}';
      } else {
        return DateFormat('MMM d, h:mm a').format(job.completedDate!);
      }
    } else if (job.scheduledDate != null) {
      return DateFormat('MMM d, yyyy').format(job.scheduledDate!);
    }
    return 'No date set';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.mist),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: AppTextStyles.titleMedium(color: context.colors.black),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: AppTextStyles.labelSmall(color: statusColor),
                ),
              ),
            ],
          ),
          if (job.description != null && job.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              job.description!,
              style: AppTextStyles.bodySmall(color: context.colors.grey),
            ),
          ],
          const SizedBox(height: 12),
          if (job.customerName != null) ...[
            Row(
              children: [
                Icon(Icons.person, size: 18, color: context.colors.grey),
                const SizedBox(width: 6),
                Text(
                  job.customerName!,
                  style: AppTextStyles.bodyMedium(color: context.colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          if (job.location != null) ...[
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: context.colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    job.location!,
                    style: AppTextStyles.bodyMedium(color: context.colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: context.colors.grey),
              const SizedBox(width: 6),
              Text(
                _getTimeText(),
                style: AppTextStyles.bodyMedium(color: context.colors.grey),
              ),
            ],
          ),
          if (job.status == 'in_progress') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Complete Job'),
                          content: Text('Mark "${job.title}" as completed?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.green,
                              ),
                              child: const Text('Complete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        final controller = context.read<PlumberJobsController>();
                        final success = await controller.completeJob(job.id);

                        if (context.mounted) {
                          if (success) {
                            AppSnackbar.success(context, '✓ Job marked as completed');
                          } else {
                            AppSnackbar.error(context, controller.errorMessage ?? 'Failed to complete job');
                          }
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.colors.green),
                      foregroundColor: context.colors.green,
                    ),
                    child: const Text('Mark Complete'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
