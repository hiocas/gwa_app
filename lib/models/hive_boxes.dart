import 'package:hive/hive.dart';
import 'package:gwa_app/models/library_gwa_submission.dart';
import 'package:gwa_app/models/app_settings.dart';

class HiveBoxes {
  static List<String> listTags = ['Favorites', 'Planned'];

  static Box<LibraryGwaSubmission> getLibraryBox() =>
      Hive.box<LibraryGwaSubmission>('library');

  static Future<Box<LibraryGwaSubmission>> openLibraryBox() async {
    return Hive.openBox<LibraryGwaSubmission>('library');
  }

  static Box<AppSettings> getAppSettingsBox() =>
      Hive.box<AppSettings>('settings');

  static Future<Box<AppSettings>> openAppSettingsBox() async {
    return Hive.openBox<AppSettings>('settings');
  }

  static LibraryGwaSubmission addLibrarySubmission(String title,
      String fullname, String thumbnailUrl, List<String> lists) {
    final LibraryGwaSubmission libraryGwaSubmission = LibraryGwaSubmission()
      ..title = title
      ..fullname = fullname
      ..thumbnailUrl = thumbnailUrl
      ..lists = lists;
    final box = getLibraryBox();
    box.add(libraryGwaSubmission);
    return libraryGwaSubmission;
  }

  static editLibrarySubmission(LibraryGwaSubmission submission,
      [String title,
        String fullname,
        String thumbnailUrl,
        List<String> lists]) {
    if (title != null && title.isNotEmpty) submission.title = title;
    if (fullname != null && fullname.isNotEmpty) submission.fullname = fullname;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
      submission.thumbnailUrl = thumbnailUrl;
    if (lists != null) submission.lists = lists;

    submission.save();
  }

  static Future<AppSettings> addAppSettings({String credentials}) async {
    final AppSettings settings = AppSettings(
        credentials: credentials);
    final box = getAppSettingsBox();
    await box.add(settings);
    return Future.value(settings);
  }

  static editAppSettings({String credentials}) async {
    final box = getAppSettingsBox();
    if (box.isNotEmpty){
      final AppSettings settings = box.getAt(0);
      settings.credentials = credentials;
      await settings.save();
    }
  }

  static clearAppSettings() async {
    final box = getAppSettingsBox();
    await box.clear();
  }

}
