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
      home: MyHomePage(title: 'Game of Thrones Season 8 Tippspiel'),
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
              Tab(icon: Icon(Icons.dashboard)),
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.tv)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDashboard(context),
            FutureBuilder(
              future: _buildPersonalPredictions(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data;
                }
                else {
                  return CircularProgressIndicator();
                }
                
              },
            ),
            FutureBuilder(
              future: _buildReferencePredictions(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data;
                }
                else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ]
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add),
          onPressed: () {_openNameDialog(context);},
        ),
      )
    );
  }

  Future<Widget> _buildPersonalPredictions(BuildContext context) async{
    final sp = await SharedPreferences.getInstance();
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('predictions').document("Herbert").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildDocument(context, snapshot.data, false);
      },
    );
  }

  Future<Widget> _buildReferencePredictions(BuildContext context) async{
    final sp = await SharedPreferences.getInstance();
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('reference').document("reference").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildDocument(context, snapshot.data, true);
      },
    );
  }

  Widget _buildDocument(BuildContext context, DocumentSnapshot snapshot, bool isReference) {
    return SingleChildScrollView(
      child:Padding(
        padding:EdgeInsets.all(10.0),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    Text("Charakter", textAlign: TextAlign.center),
                    Text("Überlebt", textAlign: TextAlign.center),
                    Text("Stirbt", textAlign: TextAlign.center),
                    Text("Weißer Wanderer", textAlign: TextAlign.center),
                  ]
                ),
                _characterLine("Jon Snow"),
                _characterLine("Arya Stark"),
                _characterLine("Bran Stark"),
                _characterLine("Sansa Stark"),
                _characterLine("Cersei Lennister"),
                _characterLine("Jaime Lennister"),
                _characterLine("Tyrion Lennister"),
                _characterLine("Deanerys Targaryen"),
                _characterLine("Asha Graufreud"),
                _characterLine("Euron Graufreud"),
                _characterLine("Melisandre"),
                _characterLine("Jorah Mormont"),
                _characterLine("Der Bluthund"),
                _characterLine("Der Berg"),
                _characterLine("Samwell Tarley"),
                _characterLine("Gilly"),
                _characterLine("Lord Varys"),
                _characterLine("Brienne von Tarth"),
                _characterLine("Davos Seewert"),
                _characterLine("Bronn"),
                _characterLine("Podrick Payne"),
                _characterLine("Tormund Riesentod"),
                _characterLine("Grauer Wurm"),
                _characterLine("Gendry"),
                _characterLine("Beric Dondarrion"),
              ],
            ),
            TextField(
              decoration:InputDecoration(
                hintText: "Hint",
                labelText: "Podrick Paynes Geheimnis",
                suffixText: "1 Punkt"
              ),
            ),
            TextField(
              decoration:InputDecoration(
                hintText: "Hint",
                labelText: "Bran Nachtkönig",
                suffixText: "2 Punkte"
              ),
            ),
            TextField(
              decoration:InputDecoration(
                hintText: "Hint",
                labelText: "Bran Nachtkönig",
                suffixText: "3 Punkte"
              ),
            ),
            TextField(
              decoration:InputDecoration(
                hintText: "Hint",
                labelText: "Eiserner Thron",
                suffixText: "4 Punkte"
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _characterLine(String name) {
    return TableRow(
      children: [
        Text(name, textAlign: TextAlign.center),
        Checkbox(value: false, onChanged: (value) {}),
        Checkbox(value: true, onChanged: (value) {}),
        Checkbox(value: false, onChanged: (value) {}),
      ]
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('predictions').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

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
         trailing: Text(record.points.toString()),
         onTap: () => record.reference.updateData({'points': record.points + 1}),
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
 final int points;
 final DocumentReference reference;

 Record.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['name'] != null),
       assert(map['points'] != null),
       name = map['name'],
       points = map['points'];

 Record.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);

 @override
 String toString() => "Record<$name:$points>";
}
