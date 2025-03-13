import 'package:disco_party/logics/disco_party_api.dart' show DiscoPartyApi;
import 'package:flutter/material.dart';

class CurrentUserWidget extends StatefulWidget {
  const CurrentUserWidget({Key? key}) : super(key: key);

  @override
  State<CurrentUserWidget> createState() => _CurrentUserWidgetState();
}

class _CurrentUserWidgetState extends State<CurrentUserWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 14,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DiscoPartyApi().currentUser?.name ?? 'Guest',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.credit_card,
                    size: 14,
                    color: Color(0xFFC51162),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${DiscoPartyApi().currentUser?.credits ?? 0} credit(s)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFC51162),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
