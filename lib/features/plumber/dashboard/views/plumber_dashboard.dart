import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/controllers/auth_provider.dart';
import '../../jobs/controllers/plumber_jobs_controller.dart';
import '../../jobs/repositories/plumber_jobs_repository.dart';
import '../../jobs/models/plumber_job_model.dart';

class PlumberDashboard extends StatefulWidget {
  const PlumberDashboard({super.key});

  @override
  State<PlumberDashboard> createState() => _PlumberDashboardState();
}

class _PlumberDashboardState extends State<PlumberDashboard> {
  PlumberJobsController? _jobsController;
  bool _isInitialized = false;

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
    _jobsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null || _jobsController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _jobsController!,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plumber Dashboard'),
          actions: [
            IconButton(
              onPressed: () {
                authProvider.logout();
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Consumer<PlumberJobsController>(
          builder: (context, jobsController, _) {
            final activeJobsCount = jobsController.activeJobs.length;
            final completedJobsCount = jobsController.completedJobs.length;
            final todaysJobs = _getTodaysJobs(jobsController);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colors.secondary, // Slate
                          context.colors.fog, // Light gray
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🔧 PLUMBER',
                            style: AppTextStyles.labelSmall(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome Back!',
                          style: AppTextStyles.titleLarge(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.fullName ?? user.phoneNumber,
                          style: AppTextStyles.displaySmall(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Cards
                  if (jobsController.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Active Jobs',
                            value: activeJobsCount.toString(),
                            icon: Icons.work,
                            color: context.colors.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Completed',
                            value: completedJobsCount.toString(),
                            icon: Icons.check_circle,
                            color: context.colors.green,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Today's Jobs Section
                  if (!jobsController.isLoading) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Jobs',
                          style: AppTextStyles.titleLarge(color: context.colors.black),
                        ),
                        if (todaysJobs.isNotEmpty)
                          Text(
                            '${todaysJobs.length} job${todaysJobs.length == 1 ? '' : 's'}',
                            style: AppTextStyles.bodyMedium(color: context.colors.grey),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (todaysJobs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: context.colors.canvas,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 48,
                                color: context.colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No jobs scheduled for today',
                                style: AppTextStyles.bodyLarge(color: context.colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.canvas,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < todaysJobs.length; i++) ...[
                              _JobCard(job: todaysJobs[i]),
                              if (i < todaysJobs.length - 1) const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<PlumberJobModel> _getTodaysJobs(PlumberJobsController controller) {
    final today = DateTime.now();
    final allJobs = [
      ...controller.activeJobs,
      ...controller.scheduledJobs,
    ];

    return allJobs.where((job) {
      if (job.scheduledDate == null) return false;
      final scheduledDate = job.scheduledDate!;
      return scheduledDate.year == today.year &&
          scheduledDate.month == today.month &&
          scheduledDate.day == today.day;
    }).toList();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.titleLarge(color: context.colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption(color: context.colors.grey),
          ),
        ],
      ),
    );
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
      default:
        return job.status;
    }
  }

  String _getTimeText() {
    if (job.scheduledDate != null) {
      return DateFormat('h:mm a').format(job.scheduledDate!);
    }
    return 'No time set';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
                  style: AppTextStyles.titleSmall(color: context.colors.black),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(height: 8),
          if (job.customerName != null) ...[
            Row(
              children: [
                Icon(Icons.person, size: 16, color: context.colors.grey),
                const SizedBox(width: 4),
                Text(
                  job.customerName!,
                  style: AppTextStyles.bodySmall(color: context.colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (job.location != null) ...[
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: context.colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location!,
                    style: AppTextStyles.bodySmall(color: context.colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: context.colors.grey),
              const SizedBox(width: 4),
              Text(
                _getTimeText(),
                style: AppTextStyles.bodySmall(color: context.colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
