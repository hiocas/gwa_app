import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/models/hive_boxes.dart';
import 'package:gwa_app/models/library_gwa_submission.dart';
import 'package:gwa_app/widgets/gradient_appbar_flexible_space.dart';
import 'package:gwa_app/widgets/gwa_list_item.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Library extends StatefulWidget {
  const Library({Key key}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

/* FIXME: Sometimes if I remove a submission from the library while in it,
    when I come back it still shows it there until I reopen this screen. */
class _LibraryState extends State<Library> {
  /// Returns a list of [Tab] widgets from [HiveBoxes.listTags].
  List<Widget> _makeListTabs() {
    List<Widget> tabs = [Tab(text: 'All')];
    for (String list in HiveBoxes.listTags) {
      tabs.add(Tab(
        text: list,
      ));
    }
    return tabs;
  }

  /// Returns a list of [TabBarView] children from [HiveBoxes.listTags].
  List<Widget> _makeListTabViews(
      List<LibraryGwaSubmission> librarySubmissions) {
    List<Widget> tabBarViews = [_makeListOf(librarySubmissions)];
    for (String list in HiveBoxes.listTags) {
      tabBarViews.add(_makeListOf(_sortOnListTag(list, librarySubmissions)));
    }
    return tabBarViews;
  }

  /// Filters a [LibraryGwaSubmission] list to another based on a list tag.
  List<LibraryGwaSubmission> _sortOnListTag(
      String listTag, List<LibraryGwaSubmission> librarySubmissions) {
    List<LibraryGwaSubmission> list = [];
    for (LibraryGwaSubmission submission in librarySubmissions) {
      for (String subList in submission.lists) {
        if (subList.contains(listTag)) list.add(submission);
      }
    }
    return list;
  }

  /// Makes the UI list based on a [LibraryGwaSubmission] list it receives.
  Widget _makeListOf(List<LibraryGwaSubmission> list) {
    return Container(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return GwaLibraryListItem(
                    title: list[index].title,
                    fullname: list[index].fullname,
                    thumbnailUrl: list[index].thumbnailUrl,
                  );
                },
                childCount: list.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*TODO: Find a more efficient way to update the list (I don't think we need
       this since we won't be in this page when adding submissions to the
       library unless I change it). */
    return FutureBuilder(
      future: HiveBoxes.openLibraryBox(),
      builder: (context, futureBox) {
        if (futureBox.hasData)
          return ValueListenableBuilder<Box<LibraryGwaSubmission>>(
            valueListenable: HiveBoxes.getLibraryBox().listenable(),
            builder: (context, libraryBox, _) {
              final List<LibraryGwaSubmission> librarySubmissions =
                  libraryBox.values.toList().cast<LibraryGwaSubmission>();
              return DefaultTabController(
                initialIndex: 0,
                length: HiveBoxes.listTags.length + 1,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text('Library'),
                    backgroundColor: Colors.transparent,
                    elevation: 15.0,
                    flexibleSpace: GradientAppBarFlexibleSpace(),
                    leading: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        print('The app bar leading button has been pressed');
                        // Navigator.pop(context);
                      },
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Clear Library'),
                            content: const Text('Are you sure you want to clear'
                                ' your library? This action cannot be reverted.'),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () {
                                    libraryBox.clear();
                                    Navigator.pop(context, 'Clear my Library');
                                  },
                                  child: const Text('Clear my Library'))
                            ],
                          ),
                        ),
                      )
                    ],
                    bottom: TabBar(
                      tabs: _makeListTabs(),
                      indicatorSize: TabBarIndicatorSize.label,
                    ),
                  ),
                  backgroundColor: Theme.of(context).backgroundColor,
                  body: TabBarView(
                    children: _makeListTabViews(librarySubmissions),
                  ),
                ),
              );
            },
          );
        return CircularProgressIndicator();
      },
    );
  }
}