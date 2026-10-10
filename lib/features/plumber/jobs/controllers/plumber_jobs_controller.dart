import 'package:flutter/foundation.dart';
import '../models/plumber_job_model.dart';
import '../repositories/plumber_jobs_repository.dart';
import '../../../../core/utils/logger.dart';

class PlumberJobsController extends ChangeNotifier {
  final PlumberJobsRepository _repository;
  final String _plumberId;

  PlumberJobsController(this._repository, this._plumberId);

  // State
  List<PlumberJobModel> _activeJobs = [];
  List<PlumberJobModel> _scheduledJobs = [];
  List<PlumberJobModel> _completedJobs = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PlumberJobModel> get activeJobs => _activeJobs;
  List<PlumberJobModel> get scheduledJobs => _scheduledJobs;
  List<PlumberJobModel> get completedJobs => _completedJobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all jobs
  Future<void> fetchAllJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getActiveJobs(_plumberId),
        _repository.getScheduledJobs(_plumberId),
        _repository.getCompletedJobs(_plumberId),
      ]);

      _activeJobs = results[0];
      _scheduledJobs = results[1];
      _completedJobs = results[2];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load jobs';
      _isLoading = false;
      AppLogger.error('Error in fetchAllJobs', e);
      notifyListeners();
    }
  }

  // Fetch active jobs
  Future<void> fetchActiveJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeJobs = await _repository.getActiveJobs(_plumberId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load active jobs';
      _isLoading = false;
      AppLogger.error('Error in fetchActiveJobs', e);
      notifyListeners();
    }
  }

  // Fetch scheduled jobs
  Future<void> fetchScheduledJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _scheduledJobs = await _repository.getScheduledJobs(_plumberId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load scheduled jobs';
      _isLoading = false;
      AppLogger.error('Error in fetchScheduledJobs', e);
      notifyListeners();
    }
  }

  // Fetch completed jobs
  Future<void> fetchCompletedJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _completedJobs = await _repository.getCompletedJobs(_plumberId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load completed jobs';
      _isLoading = false;
      AppLogger.error('Error in fetchCompletedJobs', e);
      notifyListeners();
    }
  }

  // Mark job as in progress
  Future<bool> startJob(String jobId) async {
    try {
      await _repository.updateJobStatus(jobId, 'in_progress');
      await fetchAllJobs(); // Refresh all jobs
      return true;
    } catch (e) {
      _errorMessage = 'Failed to start job';
      AppLogger.error('Error in startJob', e);
      notifyListeners();
      return false;
    }
  }

  // Mark job as completed
  Future<bool> completeJob(String jobId) async {
    try {
      await _repository.updateJobStatus(jobId, 'completed');
      await fetchAllJobs(); // Refresh all jobs
      return true;
    } catch (e) {
      _errorMessage = 'Failed to complete job';
      AppLogger.error('Error in completeJob', e);
      notifyListeners();
      return false;
    }
  }

  // Add notes to job
  Future<bool> addNotes(String jobId, String notes) async {
    try {
      await _repository.updatePlumberNotes(jobId, notes);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add notes';
      AppLogger.error('Error in addNotes', e);
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
