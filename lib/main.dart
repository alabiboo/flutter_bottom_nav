import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom NavBar Demo',
      home: BottomNavigationBarController(),
    );
  }
}

class BottomNavigationBarController extends StatefulWidget {
  BottomNavigationBarController({Key key}) : super(key: key);

  @override
  _BottomNavigationBarControllerState createState() =>
      _BottomNavigationBarControllerState();
}

class _BottomNavigationBarControllerState
    extends State<BottomNavigationBarController> with SingleTickerProviderStateMixin{
  int _selectedIndex = 0;
  List<int> _history = [0];
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  TabController _tabController;
  List<Widget> mainTabs;
  List<BuildContext> navStack = [null, null]; // one buildContext for each tab to store history  of navigation

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    mainTabs = <Widget>[
      Navigator(
          onGenerateRoute: (RouteSettings settings){
            return PageRouteBuilder(pageBuilder: (context, animiX, animiY) { // use page PageRouteBuilder instead of 'PageRouteBuilder' to avoid material route animation
              navStack[0] = context;
              return B_HomePage();
            });
          }),
      Navigator(
          onGenerateRoute: (RouteSettings settings){
            return PageRouteBuilder(pageBuilder: (context, animiX, animiY) {  // use page PageRouteBuilder instead of 'PageRouteBuilder' to avoid material route animation
              navStack[1] = context;
              return B_MonComptePages();//SettingsPage();
            });
          }),
    ];
    super.initState();
  }

  final List<BottomNavigationBarRootItem> bottomNavigationBarRootItems = [
    BottomNavigationBarRootItem(
      bottomNavigationBarItem: BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: Text('Home'),
      ),
    ),
    BottomNavigationBarRootItem(
      bottomNavigationBarItem: BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        title: Text('Settings'),
      ),
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: mainTabs,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: bottomNavigationBarRootItems.map((e) => e.bottomNavigationBarItem).toList(),
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
      onWillPop: () async{
        if (Navigator.of(navStack[_tabController.index]).canPop()) {
          Navigator.of(navStack[_tabController.index]).pop();
          setState((){ _selectedIndex = _tabController.index; });
          return false;
        }else{
          if(_tabController.index == 0){
            setState((){ _selectedIndex = _tabController.index; });
            SystemChannels.platform.invokeMethod('SystemNavigator.pop'); // close the app
            return true;
          }else{
            _tabController.index = 0; // back to first tap if current tab history stack is empty
            setState((){ _selectedIndex = _tabController.index; });
            return false;
          }
        }
      },
    );
  }

  void _onItemTapped(int index) {
    _tabController.index = index;
    setState(() => _selectedIndex = index);
  }

}

class BottomNavigationBarRootItem {
  final String routeName;
  final NestedNavigator nestedNavigator;
  final BottomNavigationBarItem bottomNavigationBarItem;

  BottomNavigationBarRootItem({
    @required this.routeName,
    @required this.nestedNavigator,
    @required this.bottomNavigationBarItem,
  });
}

abstract class NestedNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  NestedNavigator({Key key, @required this.navigatorKey}) : super(key: key);
}

class HomeNavigator extends NestedNavigator {
  HomeNavigator({Key key, @required GlobalKey<NavigatorState> navigatorKey})
      : super(
    key: key,
    navigatorKey: navigatorKey,
  );

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/':
            builder = (BuildContext context) => B_HomePage();
            break;
          case '/home/1':
            builder = (BuildContext context) => HomeSubPage();
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(
          builder: builder,
          settings: settings,
        );
      },
    );
  }
}

class B_HomePage extends StatelessWidget {
  const B_HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: RaisedButton(
          //onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeSubPage())),
          
          onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (context) =>HomeSubPage())),
          child: Text('Open Sub-Page'),
        ),
      ),
    );
  }
}

class HomeSubPage extends StatefulWidget {
  const HomeSubPage({Key key}) : super(key: key);

  @override
  _HomeSubPageState createState() => _HomeSubPageState();
}

class _HomeSubPageState extends State<HomeSubPage> with AutomaticKeepAliveClientMixin{
  @override
  // implement wantKeepAlive
  bool get wantKeepAlive => true;


  String _text;

  @override
  void initState() {
    _text = 'Click me';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Sub Page'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () => setState(() => _text = 'Clicked'),
          child: Text(_text),
        ),
      ),
    );
  }

}

/* convert it to statfull so i can use AutomaticKeepAliveClientMixin to avoid disposing tap */

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin{

  @override
  // implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Page'),
      ),
      body: Container(
        child: Center(//SubPage2
          child: Column(
            children: <Widget>[
              Text('Settings Page'),
              RaisedButton(
                onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (context) =>SubPage2())) ,
                child: Text("Open subpage2"),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class SubPage2 extends StatefulWidget {
  @override
  _SubPage2State createState() => _SubPage2State();
}

class _SubPage2State extends State<SubPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subpage 2"),
      ),

      body: Center(
        child: Container(
          child: Text("dont click"),
        ),
      ),
    );
  }
}

class B_MonComptePages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text("Mon Compte"),),
    );
  }
}