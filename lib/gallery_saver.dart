import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:gallery_saver/files.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class GallerySaver {
  static const String channelName = 'gallery_saver';
  static const String methodSaveImage = 'saveImage';
  static const String methodSaveVideo = 'saveVideo';
  static const String methodSaveImageForImageBytes = 'saveImageForImageBytes';

  static const String pleaseProvidePath = 'Please provide valid file path.';
  static const String fileIsNotVideo = 'File on path is not a video.';
  static const String fileIsNotImage = 'File on path is not an image.';
  static const MethodChannel _channel = const MethodChannel(channelName);

  ///saves video from provided temp path and optional album name in gallery
  static Future<bool?> saveVideo(File file, {String? albumName}) async {
    if(file.path.isEmpty){
      return false;
    }

    bool? result = await _channel.invokeMethod(
      methodSaveVideo,
      <String, dynamic>{'path': file.path, 'albumName': albumName},
    );
    return result;
  }

  /// 本地文件路径
  static Future<bool?> saveVideoForPath(String path, {String? albumName}) async {
    if(path.isEmpty){
      return false;
    }

    bool? result = await _channel.invokeMethod(
      methodSaveVideo,
      <String, dynamic>{'path': path, 'albumName': albumName},
    );
    return result;
  }

  ///saves image from provided temp path and optional album name in gallery
  static Future<bool?> saveImage(File file, {String? albumName}) async {
    print("saveImage file.path ${file.path}");
    if(file.path.isEmpty){
      return false;
    }


    bool? result = await _channel.invokeMethod(
      methodSaveImage,
      <String, dynamic>{'path': file.path, 'albumName': albumName},
    );

    return result;
  }

  /// 本地文件路径
  static Future<bool?> saveImageForPath(String path, {String? albumName}) async {
    if(path.isEmpty){
      return false;
    }


    bool? result = await _channel.invokeMethod(
      methodSaveImage,
      <String, dynamic>{'path': path, 'albumName': albumName},
    );

    return result;
  }

  // static Future<File> _downloadFile(String url) async {
  //   print(url);
  //   http.Client _client = new http.Client();
  //   var req = await _client.get(Uri.parse(url));
  //   var bytes = req.bodyBytes;
  //   String dir = (await getTemporaryDirectory()).path;
  //   File file = new File('$dir/${basename(url)}');
  //   await file.writeAsBytes(bytes);
  //   print('File size:${await file.length()}');
  //   print(file.path);
  //   return file;
  // }
}
