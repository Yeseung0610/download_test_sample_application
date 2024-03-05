
The taskCompleteCallback has been added to FileDownloader().registerCallbacks.
(Actually, it seems better to perform the CallbackHandle task on the statusCallback and progressCallback when you do the work.)


When the taskCompleteCallback is added, 
the registerCallbacks function checks whether the 
taskCompleteCallback is a top level static function and delivers a unique handle identifier to the native using the method channel.


BDPlugin.kt passes the handle value as a Long type argument to WorkerAliveService, 
and the service saves the value in shared pref 
(shared pref is necessary to retrieve the handle value when the service is restarted after being terminated).


In the process function of DownloadTaskWorker.kt,
if the transferBytesResult value is TaskStatus.complete,
it passes the task information to the WorkerAliveService in the form of a json string.


The WorkerAliveService runs a function named callback corresponding to the dartEntryPoint with the task json string value.