import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'signaling.dart';
import 'video_screeen.dart';


List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  await Firebase.initializeApp();
  runApp(MyApp());
}

//todo
// swap camera
// fix muste and un mute
// fix connection
// end call
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  List<String> romesId = [];
  bool? mute;
  bool? cameraOpern;

  CameraController? controller;

  @override
  initState() {
    mute = true;
    cameraOpern = true;
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    getRooms();

    controller = CameraController(cameras![0], ResolutionPreset.medium);
    Logger().e(controller!.cameraId);

    super.initState();
  }

  getRooms() async {
    romesId = await signaling.getallRomsId();
    Logger().e('N id : $romesId');
    roomId = romesId[0];
    setState(() {});
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Flutter Explained - WebRTC"),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  signaling.openUserMedia(
                      _localRenderer, _remoteRenderer, true, true);
                },
                child: Text("Open camera & microphone"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () async {
                  roomId = await signaling.createRoom(_remoteRenderer);
                  textEditingController.text = roomId!;
                  setState(() {});
                },
                child: Text("Create room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  textEditingController.text = roomId!;
                  // Add roomId
                  signaling.joinRoom(
                    textEditingController.text,
                    _remoteRenderer,
                  );
                  Get.to(() => VideoScreen(
                        localRenderer: _localRenderer,
                        remoteRenderer: _remoteRenderer,
                        signaling: signaling,
                        textEditingController: textEditingController,
                      ));
                },
                child: Text("Join room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  signaling.hangUp(_localRenderer);
                },
                child: Text("Hangup"),
              )
            ],
          ),
          Container(
            width: 300,
            height: 30,
            child: DropdownButton(
              value: roomId,
              // selectedItemBuilder: (BuildContext context) {
              //   return romesId.map<Widget>((String item) {
              //     return Text('$item');
              //   }).toList();
              // },
              items: romesId.map((String item) {
                return DropdownMenuItem<String>(
                  child: Text('$item'),
                  value: item,
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  roomId = value;
                });
              },
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          TextButton.icon(
              onPressed: () {
                setState(() {
                  mute = !mute!;
                });

                signaling.openUserMedia(
                    _localRenderer, _remoteRenderer, mute!, cameraOpern!);
              },
              icon: mute == false
                  ? Icon(Icons.mic_external_off)
                  : Icon(Icons.mic_external_on),
              label: Text("mic of")),
          TextButton.icon(
              onPressed: () {
               controller = CameraController(cameras![1], ResolutionPreset.medium);
               Logger().e(controller!.cameraId);

                setState(() {
                  cameraOpern = !cameraOpern!;
                });
                signaling.openUserMedia(
                    _localRenderer, _remoteRenderer, mute!, cameraOpern!);
              },
              icon: cameraOpern == false
                  ? Icon(Icons.camera_outdoor)
                  : Icon(Icons.camera),
              label: Text("camera of")),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
