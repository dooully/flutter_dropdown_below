import 'package:dropdown_below/dropdown_below.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _testList = [
    {'no': 1, 'keyword': 'blue'},
    {'no': 2, 'keyword': 'black'},
    {'no': 3, 'keyword': 'red'}
  ];
  List<DropdownMenuItem> _dropdownTestItems;
  var _selectedTest;

  @override
  void initState() {
    _dropdownTestItems = buildDropdownTestItems(_testList);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DropdownMenuItem> buildDropdownTestItems(List _testList) {
    List<DropdownMenuItem> items = List();
    for (var i in _testList) {
      items.add(
        DropdownMenuItem(
          value: i,
          child: Text(i['keyword']),
        ),
      );
    }
    return items;
  }

  onChangeDropdownTests(selectedTest) {
    print(selectedTest);
    setState(() {
      _selectedTest = selectedTest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dropdown below example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownBelow(
              itemWidth: 200,
              itemTextstyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
              boxTextstyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0XFFbbbbbb)),
              boxPadding: EdgeInsets.only(left: 10),
              boxWidth: 200,
              boxHeight: 45,
              hint: Text('choose item'),
              value: _selectedTest,
              items: _dropdownTestItems,
              onChanged: onChangeDropdownTests,
            ),
            SizedBox(
              height: 30,
            ),
            DropdownBelow(
              spacing: 10,
              itemHeight: 40,
              itemWidth: 300,
              boxWidth: 300,
              elevation: 0,
              itemTextstyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
              boxTextstyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
              boxPadding: EdgeInsets.symmetric(horizontal: 8),
              boxDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.green,
                  width: 1,
                ),
                color: Colors.white,
              ),
              icon: Icon(Icons.arrow_drop_down, size: 24, color: Colors.red),
              selectedColor: Colors.grey[400],
              hint: Text(
                "Select",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              value: _selectedTest,
              items: _dropdownTestItems,
              onChanged: onChangeDropdownTests,
            )
          ],
        ),
      ),
    );
  }
}
