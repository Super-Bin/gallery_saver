import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

double textSize = 20;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String firstButtonText = 'Take photo';
  String secondButtonText = 'Record video';

  String albumName = 'Media';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Container(
                  child: SizedBox.expand(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      onPressed: _takePhoto,
                      child: Text(firstButtonText,
                          style: TextStyle(
                              fontSize: textSize, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              ScreenshotWidget(),
              Flexible(
                child: Container(
                    child: SizedBox.expand(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    onPressed: _networkImage,
                    child: Text(secondButtonText,
                        style: TextStyle(
                            fontSize: textSize, color: Colors.blueGrey)),
                  ),
                )),
                flex: 1,
              )
            ],
          ),
        ),
      ),
    ));
  }

  void _takePhoto() async {
    ImagePicker()
        .getImage(source: ImageSource.camera)
        .then((PickedFile recordedImage) async{
      if (recordedImage != null && recordedImage.path != null) {
        setState(() {
          firstButtonText = 'saving in progress...';
        });
        GallerySaver.saveImageForPath(recordedImage.path, albumName: albumName)
            .then((bool success) {
              print("保存图片结果 $success");
          setState(() {
            firstButtonText = 'image saved!';
          });
        });
      }
    });
  }

  void _recordVideo() async {
    ImagePicker()
        .getVideo(source: ImageSource.camera)
        .then((PickedFile recordedVideo) {
      if (recordedVideo != null && recordedVideo.path != null) {
        setState(() {
          secondButtonText = 'saving in progress...';
        });
        // GallerySaver.saveVideo(recordedVideo.path, albumName: albumName)
        //     .then((bool success) {
        //   setState(() {
        //     secondButtonText = 'video saved!';
        //   });
        // });
      }
    });
  }

  void _networkImage() async {
    String imageUrl =
        "https://image.shutterstock.com/image-photo/montreal-canada-july-11-2019-600w-1450023539.jpg";
    CachedNetworkImage image = CachedNetworkImage(imageUrl: imageUrl);
    File file = await (image.cacheManager ?? DefaultCacheManager())
        .getSingleFile(imageUrl);

    GallerySaver.saveImage(file);
  }

  // ignore: unused_element
  // void _saveNetworkVideo() async {
  //   String path =
  //       'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
  //   GallerySaver.saveVideo(path, albumName: albumName).then((bool success) {
  //     setState(() {
  //       print('Video is saved');
  //     });
  //   });
  // }

  // ignore: unused_element
  // void _saveNetworkImage() async {
  //   String path =
  //       'https://image.shutterstock.com/image-photo/montreal-canada-july-11-2019-600w-1450023539.jpg';
  //   GallerySaver.saveImage(path, albumName: albumName).then((bool success) {
  //     setState(() {
  //       print('Image is saved');
  //     });
  //   });
  // }

}

class ScreenshotWidget extends StatefulWidget {
  @override
  _ScreenshotWidgetState createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
  final GlobalKey _globalKey = GlobalKey();
  String screenshotButtonText = 'Save screenshot';

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: RepaintBoundary(
        key: _globalKey,
        child: Container(
          child: SizedBox.expand(
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.pink),
              ),
              onPressed: _saveScreenshot,
              child: Text(screenshotButtonText,
                  style: TextStyle(fontSize: textSize, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveScreenshot() async {
    setState(() {
      screenshotButtonText = 'saving in progress...';
    });
    try {
      // 需要延迟
      return new Future.delayed(const Duration(milliseconds: 20), () async {
        //extract bytes
        final RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        //create file
        final String dir = (await getApplicationDocumentsDirectory()).path;
        final String fullPath = '$dir/${DateTime.now().millisecond}.png';
        print("fullPath $fullPath");
        File capturedFile = File(fullPath);
        await capturedFile.writeAsBytes(pngBytes);
        print("capturedFile.path ${capturedFile.path}");

        await GallerySaver.saveImage(capturedFile).then((value) {
          setState(() {
            screenshotButtonText = 'screenshot saved!';
          });
        });
      });

    } catch (e) {
      print("报错 $e");
    }
  }
}
