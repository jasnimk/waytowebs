import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plumber_job_model.dart';
import '../../../../core/utils/logger.dart';

class PlumberJobsRepository {
  final SupabaseClient _supabase;

  PlumberJobsRepository(this._supabase);

  // Fetch jobs for a specific plumber
  Future<List<PlumberJobModel>> getJobsByPlumberId(String plumberId) async {
    try {
      final response = await _supabase
          .from('plumber_jobs')
          .select()
          .eq('plumber_id', plumberId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PlumberJobModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching plumber jobs', e);
      rethrow;
    }
  }

  // Fetch jobs by status
  Future<List<PlumberJobModel>> getJobsByStatus(
      String plumberId, String status) async {
    try {
      final response = await _supabase
          .from('plumber_jobs')
          .select()
          .eq('plumber_id', plumberId)
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PlumberJobModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching jobs by status', e);
      rethrow;
    }
  }

  // Get active jobs (assigned or in_progress)
  Future<List<PlumberJobModel>> getActiveJobs(String plumberId) async {
    try {
      final response = await _supabase
          .from('plumber_jobs')
          .select()
          .eq('plumber_id', plumberId)
          .inFilter('status', ['assigned', 'in_progress'])
          .order('scheduled_date', ascending: true);

      return (response as List)
          .map((json) => PlumberJobModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching active jobs', e);
      rethrow;
    }
  }

  // Get scheduled jobs
  Future<List<PlumberJobModel>> getScheduledJobs(String plumberId) async {
    try {
      final response = await _supabase
          .from('plumber_jobs')
          .select()
          .eq('plumber_id', plumberId)
          .eq('status', 'assigned')
          .order('scheduled_date', ascending: true);

      return (response as List)
          .map((json) => PlumberJobModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching scheduled jobs', e);
      rethrow;
    }
  }

  // Get completed jobs
  Future<List<PlumberJobModel>> getCompletedJobs(String plumberId) async {
    try {
      final response = await _supabase
          .from('plumber_jobs')
          .select()
          .eq('plumber_id', plumberId)
          .eq('status', 'completed')
          .order('completed_date', ascending: false);

      return (response as List)
          .map((json) => PlumberJobModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching completed jobs', e);
      rethrow;
    }
  }

  // Update job status
  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      final now = DateTime.now();
      final updateData = {
        'status': status,
        'updated_at': now.toIso8601String(),
      };

      // Add completed_date only if status is completed (as DATE only, not timestamp)
      if (status == 'completed') {
        updateData['completed_date'] = DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];
      }

      await _supabase.from('plumber_jobs').update(updateData).eq('id', jobId);

      AppLogger.info('Job $jobId status updated to $status');
    } catch (e) {
      AppLogger.error('Error updating job status', e);
      rethrow;
    }
  }

  // Add plumber notes
  Future<void> updatePlumberNotes(String jobId, String notes) async {
    try {
      await _supabase.from('plumber_jobs').update({
        'plumber_notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jobId);
    } catch (e) {
      AppLogger.error('Error updating plumber notes', e);
      rethrow;
    }
  }

  // Get job by ID
  Future<PlumberJobModel> getJobById(String jobId) async {
    try {
      final response = await _supabase
          .from('plumber_jobs')
          .select()
          .eq('id', jobId)
          .single();

      return PlumberJobModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching job by ID', e);
      rethrow;
    }
  }
}
