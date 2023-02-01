import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  late String uid;
  late String? name;
  late String? offer;
  late String? answer;
  late Timestamp? created=Timestamp.now();

  Room({
    this.name="",
    this.uid="",
    this.offer="",
    this.answer="",
    this.created
  });

  factory Room.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Room(
      name: data?['name'],
      uid:snapshot.id,
      offer:data?['offer'],
      answer:data?['answer'],
        created:data?['created']

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (offer != null) "offer": offer,
      if (answer != null) "answer": answer,
      if (created != null) "created": created,
    };
  }
}