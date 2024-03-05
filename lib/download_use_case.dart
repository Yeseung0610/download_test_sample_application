import 'package:background_downloader/background_downloader.dart';
import 'package:logger/logger.dart';

class DownloadUseCase {

  @pragma("vm:entry-point")
  static void taskCompleteCallback(Task task) {
    Logger().d('IN_NATIVE_WORK_MANAGER\nTASK_ID: ${task.taskId}\nNAME: ${task.filename}');
  }

  void taskStatusCallback(TaskStatusUpdate event) {
    Logger().d('IN_CALLBACK\nTASK_ID: ${event.task.taskId}\nSTATUS: ${event.status.name}');
  }

  void taskProgressCallback(TaskProgressUpdate event) {
    Logger().d('IN_CALLBACK\nTASK_ID: ${event.task.taskId}\nPROGRESS: ${event.progress}\nNETWORK_SPEED: ${event.networkSpeed}');
  }

  DownloadUseCase() {
    FileDownloader()
      ..configure(
        globalConfig: [(Config.requestTimeout, const Duration(seconds: 100))],
        androidConfig: [(Config.useCacheDir, Config.never)],
      )
      ..configureNotification(
        complete: const TaskNotification('Download Complete', 'download complete'),
        error: const TaskNotification('Download Failed', 'download failed'),
        paused: const TaskNotification('Download Paused', 'download paused'),
        running: const TaskNotification('Download Progress', 'download progress'),
        progressBar: true,
        tapOpensFile: false,
      )
      ..registerCallbacks(taskStatusCallback: taskStatusCallback, taskProgressCallback: taskProgressCallback, taskCompleteCallback: taskCompleteCallback)
      ..updates.listen((event) {
        if (event is TaskProgressUpdate) {
          Logger().d('IN_APPLICATION\nTASK_ID: ${event.task.taskId}\nPROGRESS: ${event.progress}\nNETWORK_SPEED: ${event.networkSpeed}');
        } else if (event is TaskStatusUpdate) {
          Logger().d('IN_APPLICATION\nTASK_ID: ${event.task.taskId}\nSTATUS: ${event.status.name}');
        }
      });

    FileDownloader().resumeFromBackground();
  }

  void startDownload() async {
    final downloadTask = DownloadTask(
      url: 'https://bit.ly/1GB-testfile',
      retries: 3,
      allowPause: true,
      baseDirectory: BaseDirectory.applicationDocuments,
      directory: '/download-files/${DateTime.now().millisecondsSinceEpoch}',
      filename: 'files-1GB',
      updates: Updates.statusAndProgress,
    );

    FileDownloader().enqueue(downloadTask);
  }
}