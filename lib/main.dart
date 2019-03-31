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
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'Game of Thrones Season 8 Tippspiel'),
    );
  }
}

class PersonalPage extends StatelessWidget {
  String name;
  Widget page;
  PersonalPage(String name, Widget page) {
    this.name = name;
    this.page = page;
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: name,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Scaffold(
        appBar:AppBar(
          title: Text(name),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        ),
        body: page,
      ),
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
  bool _redraw = false;

  void _redrawWidget() {
    setState(() {
      _redraw = !_redraw;
    });
  }
  
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

  Widget _buildOtherPersonalPredictions(BuildContext context, String name) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('predictions').document(name).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildDocument(context, snapshot.data, true);
      },
    );
  }

  Future<Widget> _buildPersonalPredictions(BuildContext context) async{
    final sp = await SharedPreferences.getInstance();
    DocumentSnapshot canChangeDoc = await Firestore.instance.collection("reference").document("settings").get();
    bool canChange = canChangeDoc.data["canChange"];

    if(!sp.getKeys().contains("name")){
      return Text("Bitte melde dich zuerst mit einem Namen an");
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('predictions').document(sp.getString("name")).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildDocument(context, snapshot.data, !canChange);
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
            Text("Regeln", style: TextStyle(fontWeight: FontWeight.bold),),
            Text("1) Wähle, ob ein Charakter stirbt oder überlebt. Jede richtige Antwort bringt einen Punkt."),
            Text("2) Wenn du dich für den Tod entschieden hast, wähle, ob er als Weißer Wanderer wieder aufersteht. WEnn du richtig liegst, erhälst du einen Extrapunkt - liegst du falsch, gibt es einen Minuspunkt."),
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
                _characterLine("Jon Snow", "JonSnow", snapshot, isReference),
                _characterLine("Arya Stark", "AryaStark", snapshot, isReference),
                _characterLine("Bran Stark", "BranStark", snapshot, isReference),
                _characterLine("Sansa Stark", "SansaStark", snapshot, isReference),
                _characterLine("Cersei Lennister", "Cersei", snapshot, isReference),
                _characterLine("Jaime Lennister", "Jaime", snapshot, isReference),
                _characterLine("Tyrion Lennister", "Tyrion", snapshot, isReference),
                _characterLine("Deanerys Targaryen", "Daenerys", snapshot, isReference),
                _characterLine("Asha Graufreud", "Asha", snapshot, isReference),
                _characterLine("Euron Graufreud", "Euron", snapshot, isReference),
                _characterLine("Theon Graufreud", "Theon", snapshot, isReference),
                _characterLine("Melisandre", "Melisandre", snapshot, isReference),
                _characterLine("Jorah Mormont", "Jorah", snapshot, isReference),
                _characterLine("Der Bluthund", "Bluthund", snapshot, isReference),
                _characterLine("Der Berg", "Berg", snapshot, isReference),
                _characterLine("Samwell Tarley", "Samwell", snapshot, isReference),
                _characterLine("Gilly", "Gilly", snapshot, isReference),
                _characterLine("Lord Varys", "LordVarys", snapshot, isReference),
                _characterLine("Brienne von Tarth", "Brienne", snapshot, isReference),
                _characterLine("Davos Seewert", "Davos", snapshot, isReference),
                _characterLine("Bronn", "Bronn", snapshot, isReference),
                _characterLine("Podrick Payne", "Podrick", snapshot, isReference),
                _characterLine("Tormund Riesentod", "Tormund", snapshot, isReference),
                _characterLine("Grauer Wurm", "GrauerWurm", snapshot, isReference),
                _characterLine("Gendry", "Gendry", snapshot, isReference),
                _characterLine("Beric Dondarrion", "Beric", snapshot, isReference),
              ],
            ),
            TextField(
              decoration:InputDecoration(
                helperText: snapshot.data["PayensGeheimnis"],
                labelText: "Wird Podrick Paynes Geheimnis aufgeklärt?",
                suffixText: "1 Punkt"
              ),
              onChanged: (value) => !isReference ? {snapshot.reference.updateData({"PayensGeheimnis":value})} : null,
            ),
            TextField(
              decoration:InputDecoration(
                helperText: snapshot.data["BranNachtkoenig"],
                labelText: "Ist Bran der Nachtkönig?",
                suffixText: "2 Punkte"
              ),
              onChanged: (value) => !isReference ? {snapshot.reference.updateData({"BranNachtkoenig":value})} : null,
            ),
            TextField(
              decoration:InputDecoration(
                helperText: snapshot.data["KillNachtkoenig"],
                labelText: "Wer tötet den Nachtkönig?",
                suffixText: "3 Punkte"
              ),
              onChanged: (value) => !isReference ? {snapshot.reference.updateData({"KillNachtkoenig":value})} : null,
            ),
            TextField(
              decoration:InputDecoration(
                helperText: snapshot.data["EisernerThron"],
                labelText: "Wer sitzt am Ende auf dem Eisernen Thron?",
                suffixText: "4 Punkte"
              ),
              onChanged: (value) => !isReference ? {snapshot.reference.updateData({"EisernerThron":value})} : null,
            ),
          ],
        ),
      ),
    );
  }

  TableRow _characterLine(String name, String code, DocumentSnapshot snap, bool isReference) {
    return TableRow(
      children: [
        Text(name, textAlign: TextAlign.center),
        Checkbox(value: snap.data[code + "Lives"], onChanged: (value) => !isReference ? _checkboxUpdate(value, code, "Lives", snap) : null), 
        Checkbox(value: snap.data[code + "Dies"], onChanged: (value) => !isReference ? _checkboxUpdate(value, code, "Dies", snap) : null),
        Checkbox(value: snap.data[code + "Walker"], onChanged: (value) => !isReference ? _checkboxUpdate(value, code, "Walker", snap) : null),
      ]
    );
  }

  void _checkboxUpdate(bool value,String code, String action, DocumentSnapshot snap) {
    if(action == "Walker" && snap.data[code + "Dies"] == false){
      snap.reference.updateData({code + "Dies":true});
    }

    snap.reference.updateData({code + action:value});
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

  Widget _buildListItem(BuildContext context, DocumentSnapshot snap) {
    return FutureBuilder(
      future: _buildFutureListItem(context, snap),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data;
        }
        else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<Widget> _buildFutureListItem(BuildContext context, DocumentSnapshot snap) async {

    DocumentSnapshot reference = await Firestore.instance.collection('reference').document('reference').get();  
    
    snap.reference.updateData({"points":_calcPoints(reference, snap)});

    return Padding(
     key: ValueKey(snap.data["name"]),
     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
     child: Container(
       decoration: BoxDecoration(
         border: Border.all(color: Colors.grey),
         borderRadius: BorderRadius.circular(5.0),
       ),
       child: ListTile(
         title: Text(snap.data["name"]),
         trailing: Text(snap.data["points"].toString()),
         onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalPage(snap.data["name"], _buildOtherPersonalPredictions(context, snap.data["name"]))));
         },
       ),
     ),
   );
  }

  int _calcPoints (DocumentSnapshot reference, DocumentSnapshot user) {
    int points = 0;
    List<String> names = ["JonSnow", "AryaStark", "BranStark", "SansaStark", "Cersei", "Jaime", "Tyrion",
        "Daenerys", "Asha", "Euron", "Theon", "Melisandre", "Jorah", "Bluthund", "Berg", "Samwell", "Gilly",
        "LordVarys", "Brienne", "Davos", "Bronn", "Podrick", "Tormund", "GrauerWurm", "Gendry", "Beric"];

    for (var name in names) {
      if(reference.data[name + "Lives"] == true && user.data[name + "Lives"] == true) {
        points++;
        continue;
      }
      if(reference.data[name + "Dies"] == true && user.data[name + "Dies"] == true) {
        points++;
        if(reference.data[name + "Walker"] == true && user.data[name + "Walker"] == true) {
          points++;
        }
        if(reference.data[name + "Walker"] != user.data[name + "Walker"]) {
          points--;
        }
        continue;
      }
    }

    points += reference.data["PayensGeheimnis"] == user.data["PayensGeheimnis"] ? 1 : 0;
    points += reference.data["BranNachtkoenig"] == user.data["BranNachtkoenig"] ? 2 : 0;
    points += reference.data["KillNachtkoenig"] == user.data["KillNachtkoenig"] ? 3 : 0;
    points += reference.data["EisernerThron"] == user.data["EisernerThron"] ? 4 : 0;

    return points;
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

      CollectionReference col = Firestore.instance.collection("predictions");

      Map<String, dynamic> data = Map<String, dynamic>();
      data["name"] = tc.text;
      data["points"] = 0;
      List<String> names = ["JonSnow", "AryaStark", "BranStark", "SansaStark", "Cersei", "Jaime", "Tyrion",
        "Daenerys", "Asha", "Euron", "Theon", "Melisandre", "Jorah", "Bluthund", "Berg", "Samwell", "Gilly",
        "LordVarys", "Brienne", "Davos", "Bronn", "Podrick", "Tormund", "GrauerWurm", "Gendry", "Beric"];
      for (var n in names) {
        data[n + "Lives"] = false;
        data[n + "Dies"] = false;
        data[n + "Walker"] = false;
      }

      data["PayensGeheimnis"] = "Bitte eintragen";
      data["BranNachtkoenig"] = "Bitte eintragen";
      data["KillNachtkoenig"] = "Bitte eintragen";
      data["EisernerThron"] = "Bitte eintragen";
      col.document(tc.text).setData(data);
      _redrawWidget();
      Navigator.pop(context);
    }
  }

}
