import 'package:disco_party/models/user_infos.dart';
import 'package:firebase_database/firebase_database.dart';

class LandingPageLogic {
  final DatabaseReference _discoPartRef =
      FirebaseDatabase.instance.ref('disco_party');

  Future<void> onClickEnterName(String username, String id) async {
    DataSnapshot datas = await _discoPartRef.get();

    if (datas.value != null && (datas.value as Map).containsKey(id)) {
      //TODO: go to personal page
      print('redirect to personal page');
    } else {
      _initUser(username, id);
    }
  }

  void _initUser(String name, String id) {
    UserInfos user = UserInfos(credits: 0, name: name);

    _discoPartRef.child(id).set(user.toJson());
  }
}
