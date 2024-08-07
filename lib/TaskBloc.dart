import 'package:bloc/bloc.dart';
import 'package:todo/taskmodel.dart';


abstract class TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final Task task;

  AddTaskEvent(this.task);
}

class ToggleTaskEvent extends TaskEvent {
  final String taskId;

  ToggleTaskEvent(this.taskId);
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  DeleteTaskEvent(this.taskId);
}

class FilterTaskEvent extends TaskEvent {
  final TaskFilter filter;

  FilterTaskEvent(this.filter);
}

enum TaskFilter { all, completed, pending }

class TaskState {
  final List<Task> tasks;
  final TaskFilter filter;

  TaskState({required this.tasks, this.filter = TaskFilter.all});

  List<Task> get filteredTasks {
    switch (filter) {
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.all:
      default:
        return tasks;
    }
  }
}

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskState(tasks: [])) {
    on<AddTaskEvent>((event, emit) {
      final updatedTasks = List<Task>.from(state.tasks)..add(event.task);
      emit(TaskState(tasks: updatedTasks, filter: state.filter));
    });

    on<ToggleTaskEvent>((event, emit) {
      final updatedTasks = state.tasks.map((task) {
        if (task.id == event.taskId) {
          return Task(id: task.id, title: task.title, isCompleted: !task.isCompleted);
        }
        return task;
      }).toList();
      emit(TaskState(tasks: updatedTasks, filter: state.filter));
    });

    on<DeleteTaskEvent>((event, emit) {
      final updatedTasks = state.tasks.where((task) => task.id != event.taskId).toList();
      emit(TaskState(tasks: updatedTasks, filter: state.filter));
    });

    on<FilterTaskEvent>((event, emit) {
      emit(TaskState(tasks: state.tasks, filter: event.filter));
    });
  }
}
