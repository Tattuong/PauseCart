import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../pause/pause_book.dart';

class ShareInbox {
  ShareInbox._();

  static void listen(void Function(String link) onLink) {
    ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      final link = _link(files);
      if (link != null) onLink(link);
    }, onError: (_) {});
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      final link = _link(files);
      if (link == null) return;
      onLink(link);
      ReceiveSharingIntent.instance.reset();
    });
  }

  static String? _link(List<SharedMediaFile> files) {
    for (final file in files) {
      final link = PauseEngine.extractUrl(file.path);
      if (link != null) return link;
    }
    return null;
  }
}
