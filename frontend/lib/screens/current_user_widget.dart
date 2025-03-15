import 'dart:async';

import 'package:disco_party/logics/disco_party_api.dart' show DiscoPartyApi;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CurrentUserWidget extends StatefulWidget {
  const CurrentUserWidget({super.key});

  @override
  State<CurrentUserWidget> createState() => _CurrentUserWidgetState();
}

class _CurrentUserWidgetState extends State<CurrentUserWidget> {
  StreamSubscription<DatabaseEvent>? creditSub;

  @override
  void initState() {
    creditSub = FirebaseDatabase.instance
        .ref('disco_party/users')
        .child(DiscoPartyApi.instance.currentUser?.id ?? '')
        .child('credits')
        .onValue
        .listen((event) {
      DiscoPartyApi.instance.currentUser?.credits = event.snapshot.value as int;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    creditSub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                DiscoPartyApi().currentUser?.name ?? 'Guest',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 4),
              Text(
                '   |   credits: ${DiscoPartyApi().currentUser?.credits ?? 0}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.album,
                size: 14,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
