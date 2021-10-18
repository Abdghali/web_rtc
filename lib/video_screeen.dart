import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling.dart';

class VideoScreen extends StatefulWidget {
  RTCVideoRenderer localRenderer;
  RTCVideoRenderer remoteRenderer;
  Signaling signaling;
  TextEditingController textEditingController;
  VideoScreen(
      {required this.localRenderer,
      required this.remoteRenderer,
      required this.signaling,
      required this.textEditingController});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool muted = false;
  @override
  void initState() {
    widget.signaling.joinRoom(
      widget.textEditingController.text,
      widget.remoteRenderer,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              color: Colors.amberAccent,
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(
                widget.remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )),
          Padding(
            padding: const EdgeInsets.only(top: 50, right: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
// todo put an radus for the video container
                // decoration: BoxDecoration(
                //   color: Colors.black,
                //   borderRadius: BorderRadius.all(Radius.circular(100)),
                // ),
                width: 150,
                height: 200,
                child: Center(
                  child: RTCVideoView(
                    widget.localRenderer,
                    mirror: true,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _toolbar(),
            ],
          )
        ],
      ),
    );
  }

  


  /// Toolbar layout
  Widget _toolbar() {
    // if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            // onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0), onPressed: () {  },
          ),
          RawMaterialButton(
            onPressed: () {},
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            // onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera_outlined,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0), onPressed: () {  },
          )
        ],
      ),
    );
  }
}
