package carnegietechnologies.gallery_saver

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.*

enum class MediaType { image, video }
/**
 * Class holding implementation of saving images and videos
 */
class GallerySaver internal constructor(private val activity: Activity) :
    PluginRegistry.RequestPermissionsResultListener {

    private var pendingResult: MethodChannel.Result? = null
    private var mediaType: MediaType? = null
    private var filePath: String = ""
    private var albumName: String = ""

    private val job = Job()
    private val uiScope = CoroutineScope(Dispatchers.Main + job)

    /**
     * Saves image or video to device
     *
     * @param methodCall - method call
     * @param result     - result to be set when saving operation finishes
     * @param mediaType    - media type
     */
    internal fun checkPermissionAndSaveFile(
        methodCall: MethodCall,
        result: MethodChannel.Result,
        mediaType: MediaType
    ) {
        filePath = methodCall.argument<Any>(KEY_PATH)?.toString() ?: ""
        albumName = methodCall.argument<Any>(KEY_ALBUM_NAME)?.toString() ?: ""
        this.mediaType = mediaType
        this.pendingResult = result

        if (isWritePermissionGranted() || android.os.Build.VERSION.SDK_INT >= 29) {
            saveMediaFile()
        } else {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION
            )
        }
    }

    private fun isWritePermissionGranted(): Boolean {
        return PackageManager.PERMISSION_GRANTED ==
                ActivityCompat.checkSelfPermission(
                    activity, Manifest.permission.WRITE_EXTERNAL_STORAGE
                )
    }

    private fun saveMediaFile() {
        // 方法一：可行
//        try {
//            GlobalScope.launch(Dispatchers.IO){
//                if (mediaType == MediaType.video) {
//                    FileUtils.insertVideo(activity.contentResolver, filePath, albumName)
//                } else {
//                    FileUtils.insertImage(activity.contentResolver, filePath, albumName)
//                }
//                GlobalScope.launch(Dispatchers.Main){
//                    finishWithSuccess()
//                }
//            }
//        }catch (e: Exception){
//            finishWithFail()
//        }

        // 方法二：可行，也可以直接使用以下方式
//        if (mediaType == MediaType.video) {
//            FileUtils.insertVideo(activity.contentResolver, filePath, albumName)
//        } else {
//            FileUtils.insertImage(activity.contentResolver, filePath, albumName)
//        }
//        finishWithSuccess()

        // 使用这个方式，不知道为啥在debug没问题，在release会卡线程造成ANR，考虑可能跟success.await()有关
        uiScope.launch {
            val success = async(Dispatchers.IO) {
                if (mediaType == MediaType.video) {
                    FileUtils.insertVideo(activity.contentResolver, filePath, albumName)
                } else {
                    FileUtils.insertImage(activity.contentResolver, filePath, albumName)
                }
            }
            // 但是去掉这句又能正常运行
//            success.await()
            finishWithSuccess()
        }
    }

    private fun finishWithSuccess() {
        if(pendingResult != null){
            pendingResult!!.success(true)
//            pendingResult = null
        }
    }

    private fun finishWithFail() {
        if(pendingResult != null){
            pendingResult!!.success(false)
//            pendingResult = null
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<String>, grantResults: IntArray
    ): Boolean {
        val permissionGranted = grantResults.isNotEmpty()
                && grantResults[0] == PackageManager.PERMISSION_GRANTED

        if (requestCode == REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION) {
            if (permissionGranted) {
                if (mediaType == MediaType.video) {
                    FileUtils.insertVideo(activity.contentResolver, filePath, albumName)
                } else {
                    FileUtils.insertImage(activity.contentResolver, filePath, albumName)
                }
            }
        } else {
            return false
        }
        return true
    }

    companion object {

        private const val REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION = 2408

        private const val KEY_PATH = "path"
        private const val KEY_ALBUM_NAME = "albumName"
    }
}