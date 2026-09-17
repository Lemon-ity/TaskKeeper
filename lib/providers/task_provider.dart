
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _service;
  late final StreamSubscription<User?> _authSubscription;
  StreamSubscription<List<Task>>? _taskSubscription;

  List<Task> _tasks = [];
  bool _loading = false;
  String? _error;
  String? _uid;

  TaskProvider(this._service, FirebaseAuth auth) {
    _authSubscription = auth.authStateChanges().listen(_handleUser);
    _handleUser(auth.currentUser);
  }

  List<Task> get tasks => List.unmodifiable(_tasks);

  bool get loading => _loading;

  String? get error => _error;

  void _handleUser(User? user) {
    _uid = user?.uid;

    _taskSubscription?.cancel();
    _tasks = [];
    _error = null;

    notifyListeners();

    if (user == null) {
      return;
    }

    _taskSubscription = _service.getTasks(user.uid).listen(
      (tasks) {
        _tasks = tasks;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _error = 'Unable to load tasks. Please check your connection.';
        notifyListeners();
      },
    );
  }

  Future<bool> createTask(
    String title,
    String description,
  ) async {
    final uid = _uid;

    if (uid == null) {
      return false;
    }

    _start();

    try {
      await _service.createTask(
        uid: uid,
        title: title,
        description: description,
      );

      return true;
    } catch (_) {
      _error = 'Unable to create the task. Please try again.';
      return false;
    } finally {
      _stop();
    }
  }

  Future<bool> updateTask(
    Task task,
    String title,
    String description,
  ) async {
    final uid = _uid;

    if (uid == null) {
      return false;
    }

    _start();

    try {
      await _service.updateTask(
        uid: uid,
        task: task,
        title: title,
        description: description,
      );

      return true;
    } catch (_) {
      _error = 'Unable to update the task. Please try again.';
      return false;
    } finally {
      _stop();
    }
  }

  Future<bool> deleteTask(Task task) async {
    final uid = _uid;

    if (uid == null) {
      return false;
    }

    _start();

    try {
      await _service.deleteTask(
        uid: uid,
        taskId: task.id,
      );

      return true;
    } catch (_) {
      _error = 'Unable to delete the task. Please try again.';
      return false;
    } finally {
      _stop();
    }
  }

  Future<bool> toggleCompleted(Task task) async {
    final uid = _uid;

    if (uid == null) {
      return false;
    }

    _start();

    try {
      await _service.toggleTaskCompletion(
        uid: uid,
        task: task,
        completed: !task.completed,
      );

      return true;
    } catch (_) {
      _error = 'Unable to update task status.';
      return false;
    } finally {
      _stop();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _start() {
    _loading = true;
    notifyListeners();
  }

  void _stop() {
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    _authSubscription.cancel();
    super.dispose();
  }
}

