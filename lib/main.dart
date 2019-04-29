import 'package:flutter/material.dart';

import 'station.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final stationRepository = StationRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Station List"),
        ),
        body: FutureBuilder(
          future: stationRepository.getStations(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Station>> snapshot) {
            final hasData = snapshot.hasData;
            if (!hasData) {
              return loadingWidget();
            }
            return stationListView(snapshot.data);
          }),
      ),
    );
  }
  Center loadingWidget() {
    return new Center(
      child: new Container(
        margin: const EdgeInsets.only(top: 8.0),
        width: 32.0,
        height: 32.0,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  ListView stationListView(final List<Station> stationList) {
    return ListView.builder(
        itemCount: stationList.length * 2,
        itemBuilder: (context, final index) {
          if (index.isOdd) {
            return Divider(color: Colors.blue);
          }
          final size = MediaQuery.of(context).size.width * 0.6;
          final station = stationList[index ~/2];
          return ListTile(
            onTap: (){
              showDialog(
                  context: context,
                  builder: (BuildContext context) => FutureBuilder(
                    future: stationRepository.getCheckInStatus(station.id),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot){
                      final hasData = snapshot.hasData;
                      if (!hasData) {
                        return loadingWidget();
                      }
                      if (snapshot.data) {
                        return stationDialog(context, size, station, true);
                      }
                      return stationDialog(context, size, station, false);
                    }),
              ).then((checkIn) {
                if (checkIn != null && checkIn) {
                  stationRepository.saveCheckInStation(stationList[index ~/2].id);
                }
              });
            },
            title: Text(stationList[index ~/2].name,
                style: TextStyle(fontSize: 22.0)),
          );
        });
  }
}

AlertDialog stationDialog(final BuildContext context, final double size, final Station station, final bool checkIn) {
  final List<Widget> actions = [];
  final List<Widget> title = [
    Text(station.name, style: TextStyle(color: Colors.black, fontSize: 22.0))
  ];
  if (checkIn) {
    title.add(Icon(Icons.check_circle, color: Colors.green));
  } else {
    actions.add(FlatButton(
      child: Text('チェックイン'),
        onPressed: () {
          Navigator.pop(context, true);
        }));
  }
  return AlertDialog(
    title: Row(children: title, mainAxisAlignment: MainAxisAlignment.center),
    content: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: NetworkImage(station.image),
        ),
      ),
    ),
    actions: actions,
  );
}
