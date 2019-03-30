import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Game of Thrones Tippspiel'),
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
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom:TabBar(
            tabs: [
              Tab(icon: Icon(Icons.beach_access)),
              Tab(icon: Icon(Icons.bluetooth_connected)),
              Tab(icon: Icon(Icons.landscape)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDashboard(context),
            Text("Tab2"),
            Text("Tab3"),
          ]
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {_openNameDialog(context);},
        ),
      )
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('predictions').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
     key: ValueKey(record.name),
     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
     child: Container(
       decoration: BoxDecoration(
         border: Border.all(color: Colors.grey),
         borderRadius: BorderRadius.circular(5.0),
       ),
       child: ListTile(
         title: Text(record.name),
         trailing: Text(record.votes.toString()),
         onTap: () => record.reference.updateData({'votes': record.votes + 1}),
       ),
     ),
   );
  }

  Future _openNameDialog(BuildContext context) async{
    Dialog nameDialog = await _buildDialog();
    showDialog(context: context, builder: (BuildContext context) => nameDialog);
  }

  Future<Widget> _buildDialog() async {
    final sp = await SharedPreferences.getInstance();
    String name = sp.getString("name") ?? "";   
    
    String hintText = name.isNotEmpty ? "Dein Name ist " + name : "Bitte trage deinen Namen ein";

    bool buttonEnabled = name.isNotEmpty ? false : true;
    String buttonText = name.isNotEmpty ? "Bereits gespeichert" : "Speichern";

    TextEditingController nameController = new TextEditingController();
    return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Container (
              height: 150.0,
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: hintText,
                    ),
                  ),
                  RaisedButton(
                    child: Text(buttonText),
                    onPressed: () => buttonEnabled ? _nameSaving(nameController, sp) : null,
                  ),
                ],
              ),
            ),
          );
  }

  void _nameSaving(TextEditingController tc, SharedPreferences sp) {
    if (tc.text.isNotEmpty) {
      sp.setString("name", tc.text);
      Navigator.pop(context);
    }
  }

}

class Record {
 final String name;
 final int votes;
 final DocumentReference reference;

 Record.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['name'] != null),
       assert(map['votes'] != null),
       name = map['name'],
       votes = map['votes'];

 Record.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);

 @override
 String toString() => "Record<$name:$votes>";
}
