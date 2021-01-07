import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:ui' as ui;

//import 'package:mobile_popup/mobile_popup.dart';

class FaceDetection extends StatefulWidget {

  File file; 
  FaceDetection(File file) {
    this.file = file;
  }
  // FaceDetection(this.file);

  @override
  _FaceDetectionState createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  ui.Image image;
  List<Face> faces;
  var result = "";

  @override
  void initState() {
    super.initState();
    detectFaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face/s Detected"),
        backgroundColor: Colors.redAccent,
      ),
      body: (image == null) ? Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.red)),): 
      Center(
        child: FittedBox(
          child: SizedBox(
            width: image.width.toDouble(),
            height: image.width.toDouble(),
            child: CustomPaint(painter: FacePainter(image, faces))
          ),
        ),
      )
    );
  }

   void loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        image = value;
      }),
    );
  }


  void detectFaces() async{
    
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(widget.file);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableClassification: true
        ));
    List<Face> detectedFaces = await faceDetector.processImage(visionImage);
    for (var i = 0; i < detectedFaces.length; i++) {
      final double lep= detectedFaces[i].leftEyeOpenProbability;
      final double rep= detectedFaces[i].rightEyeOpenProbability;
      final double smileProbablity = detectedFaces[i].smilingProbability;
      print("Smiling Probablity for face $i: $smileProbablity");
      print("Left eye open Probablity for face $i: $lep");
      print("Right eye open Probablity for face $i: $rep");
    }
      faces = detectedFaces;
      loadImage(widget.file);
  }
}

class FacePainter extends CustomPainter {
  ui.Image image;
  List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(ui.Image img, List<Face> faces) {
    this.image = img;
    this.faces = faces;
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..color = Colors.yellowAccent;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}