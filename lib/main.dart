import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';

import 'fbitems/Room.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _localVideoRenderer = RTCVideoRenderer();
  final _remoteVideoRenderer = RTCVideoRenderer();
  final sdpController = TextEditingController();
  final List<Room> roomListArray =[];

  bool _offer = false;
  String createdRoomID="";

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  FirebaseFirestore db = FirebaseFirestore.instance;

  initRenderer() async {
    await _localVideoRenderer.initialize();
    await _remoteVideoRenderer.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };

    MediaStream stream =
    await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localVideoRenderer.srcObject = stream;
    return stream;
  }

  _createPeerConnecion() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
    await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream!);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        print(json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMLineIndex,
        }));
      }
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteVideoRenderer.srcObject = stream;
    };

    return pc;
  }

  void _createOffer() async {
    RTCSessionDescription description =
    await _peerConnection!.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    //print("OFFER---->>>>"+json.encode(session));
    createdRoomID=sdpController.text;
    Room room = Room(
        uid: createdRoomID, //DateTime.now().millisecondsSinceEpoch.toString(),
        offer: json.encode(session),
        created: Timestamp.now());

    //final room = <String, dynamic>{
    //  "offer": json.encode(session),
    //};

// Add a new document with a generated ID
    db.collection("rooms").doc(room.uid).set(room.toFirestore());

    _offer = true;

    _peerConnection!.setLocalDescription(description);
  }

  void _createAnswer() async {
    RTCSessionDescription description =
    await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp.toString());
    //print("ANSWER---->>>>"+json.encode(session));

    final room = <String, dynamic>{
      "answer": json.encode(session),
    };

// Add a new document with a generated ID
    db.collection("rooms2").add(room).then((DocumentReference doc) =>
          print('DocumentSnapshot added with ID: ${doc.id}'));

    _peerConnection!.setLocalDescription(description);
  }

  void _setRemoteDescription() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode(jsonString);

    String sdp = write(session, null);

    RTCSessionDescription description =
    RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print(description.toMap());

    await _peerConnection!.setRemoteDescription(description);
  }

  void _addCandidate() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode(jsonString);
    print(session['candidate']);
    dynamic candidate = RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection!.addCandidate(candidate);
  }

  @override
  void initState() {
    initRenderer();
    _createPeerConnecion().then((pc) {
      _peerConnection = pc;
    });
    // _getUserMedia();

    final docRef = db.collection("rooms")
        .withConverter(fromFirestore: Room.fromFirestore, toFirestore: (value, options) => value.toFirestore(),);
    docRef.snapshots().listen(
          (event) {
            setState(() {
              roomListArray.clear();
              for (int i = 0; i < event.docs.length; i++) {
                roomListArray.add(event.docs.elementAt(i).data());
              }
              //roomListArray.sort(compareRoom);
            });

        //final source = (event.metadata.hasPendingWrites) ? "Local" : "Server";
        //print("$source data: ${event.data()}");
      },
      onError: (error) => print("Listen failed: $error"),
    );

    sdpController.text="Nombre de la sala";

    super.initState();
  }

  int compareRoom(Room a,Room b){
    int? res=a.created?.compareTo(b.created!);
    //print("COMPARATOR A: "+a.time.toString()+"  B: "+b.time.toString()+" = "+res.toString());
    return res!;
    //return a.time?.compareTo(b.time!);

    //return 0;
  }

  @override
  void dispose() async {
    await _localVideoRenderer.dispose();
    sdpController.dispose();
    super.dispose();
  }

  SizedBox videoRenderers() => SizedBox(
    height: 210,
    child: Row(children: [
      Flexible(
        child: Container(
          key: const Key('local'),
          margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          decoration: const BoxDecoration(color: Colors.black),
          child: RTCVideoView(_localVideoRenderer),
        ),
      ),
      Flexible(
        child: Container(
          key: const Key('remote'),
          margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          decoration: const BoxDecoration(color: Colors.black),
          child: RTCVideoView(_remoteVideoRenderer),
        ),
      ),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            videoRenderers(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextField(
                      controller: sdpController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      maxLength: TextField.noMaxLength,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _createOffer,
                      child: const Text("Crear Sala"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        db.collection("rooms").doc(sdpController.text).delete().then(
                              (doc) => print("Document deleted"),
                          onError: (e) => print("Error updating document $e"),
                        );
                      },
                      child: const Text("Borrar sala (escribir nombre)"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    /*ElevatedButton(
                      onPressed: _createAnswer,
                      child: const Text("Answer"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: _setRemoteDescription,
                      child: const Text("Set Remote Description"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: _addCandidate,
                      child: const Text("Set Candidate"),
                    ),*/
                  ],
                )
              ],
            ),
            Container(
              color: Colors.amberAccent,
              height: 300,
              child: ListView.builder(
                //padding: const EdgeInsets.all(8),
                itemCount: roomListArray.length,
                itemBuilder: (BuildContext context, int index) {
                  return ElevatedButton(
                    onPressed: () {
                      //print("OFFER!!!!--->>>>>>>>   "+roomListArray[index].offer.toString());
                      if(!_offer)_acceptOffer(index);
                      else _acceptAnswer(index);
                    },
                    child: Text(roomListArray[index].uid),
                    //child: Text("Room "+index.toString()),
                  );
                },
                /*separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                  //return RFInputText2(sTitulo: "DIVISOR DEL: "+entries[index],);
                },*/
              ),
                /*separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                  //return RFInputText2(sTitulo: "DIVISOR DEL: "+entries[index],);
                },*/

            ),
          ],
        ));
  }

  void _acceptOffer(int index) async{

    String jsonString = roomListArray[index].offer.toString();
    dynamic session = await jsonDecode(jsonString);

    String sdp = write(session, null);

    RTCSessionDescription description =
    RTCSessionDescription(sdp, 'offer');
    print(description.toMap());

    await _peerConnection!.setRemoteDescription(description);

    RTCSessionDescription description2 =
    await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});

    var session2 = parse(description2.sdp.toString());

    await _peerConnection!.setLocalDescription(description2);

    roomListArray[index].answer=json.encode(session2);
    db.collection("rooms").doc(roomListArray[index].uid).set(roomListArray[index].toFirestore());
  }

  void _acceptAnswer(int index) async{
    String jsonString = roomListArray[index].answer.toString();
    dynamic session = await jsonDecode(jsonString);

    String sdp = write(session, null);

    RTCSessionDescription description =
    RTCSessionDescription(sdp, 'answer' );
    print(description.toMap());

    await _peerConnection!.setRemoteDescription(description);
  }

}