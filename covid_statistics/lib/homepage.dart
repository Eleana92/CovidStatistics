import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  final Widget child;
  HomePage({Key key, this.child}) : super(key: key);
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  List<charts.Series<USCases, String>> _seriesUSCases;
  List<charts.Series<ContinentCases, String>> _seriesContinentCases;
  List<ContinentCases> continentCases;
  List<USCases> usCases;
  List<USCases> usCasesFiltered;
  int maxCases;
  String maxCasesString;
  DateFormat dateFormat;
  Timer timer;
  DateTime currentDate;
  String currentDateFormatted;
  Table table;
  var logger = Logger();
  String addCommasToInt(int number) {
    return number.toString().replaceAllMapped(
        new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  void initState() {
    super.initState();
    _seriesUSCases = <charts.Series<USCases, String>>[];
    _seriesContinentCases = <charts.Series<ContinentCases, String>>[];
    maxCases = 4000000;
    maxCasesString = addCommasToInt(maxCases);
    currentDate = DateTime.now();
    dateFormat = new DateFormat('hh:mm dd-MM-yyyy');
    currentDateFormatted = dateFormat.format(currentDate);
    makeRequest();
    timer =
        new Timer.periodic(new Duration(seconds: 120), (t) => makeRequest());
  }

  makeRequest() async {
    try {
      final responseStates =
          await http.get(Uri.https('covidtracking.com', 'api/states'));
      if (responseStates.statusCode == 200) {
        setState(() {
          usCases = parseUSCases(responseStates.body);
          currentDate = DateTime.now();
          currentDateFormatted = dateFormat.format(currentDate);
        });
      }
    } catch (Exception) {
      logger.e('Failed to load US cases.');
    }
    try {
      final responseContinents =
          await http.get(Uri.https('corona.lmao.ninja', 'v2/continents'));
      if (responseContinents.statusCode == 200) {
        setState(() {
          continentCases = parseContinentCases(responseContinents.body);
          currentDate = DateTime.now();
          currentDateFormatted = dateFormat.format(currentDate);
        });
      }
    } catch (Exception) {
      logger.e('Failed to load continent cases.');
    }
  }

  List<ContinentCases> parseContinentCases(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<ContinentCases>((json) => ContinentCases.fromJson(json))
        .toList();
  }

  List<USCases> parseUSCases(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<USCases>((json) => USCases.fromJson(json)).toList();
  }

  generateContinentData() {
    List<ContinentCases> continentCasesData = <ContinentCases>[];
    _seriesContinentCases = <charts.Series<ContinentCases, String>>[];
    for (int i = 0; i < continentCases.length; i++) {
      continentCasesData.add(new ContinentCases(
          continent: continentCases[i].continent,
          cases: continentCases[i].cases));
    }
    _seriesContinentCases.add(
      charts.Series(
        data: continentCasesData,
        domainFn: (ContinentCases continentCases, _) =>
            continentCases.continent,
        measureFn: (ContinentCases continentCases, _) => continentCases.cases,
        labelAccessorFn: (ContinentCases row, _) => '${row.cases}',
      ),
    );
    return _seriesContinentCases;
  }

  generateUSData() {
    List<USCases> usCasesData = <USCases>[];
    _seriesUSCases = <charts.Series<USCases, String>>[];
    usCasesFiltered =
        usCases.where((state) => state.cases.toInt() >= maxCases).toList();
    int colorValueCount = 0;
    Color colorValue;
    for (int i = 0; i < usCasesFiltered.length; i++) {
      if (colorValueCount < colorValues.length) {
        colorValue = colorValues[colorValueCount];
        colorValueCount++;
      } else // If there are no more colors in the list generate one randomly
      {
        colorValue =
            Colors.primaries[Random().nextInt(Colors.primaries.length)];
      }
      usCasesData.add(new USCases(
          state: usCasesFiltered[i].state,
          cases: usCasesFiltered[i].cases,
          colorValue: colorValue));
    }
    _seriesUSCases.add(
      charts.Series(
        data: usCasesData,
        domainFn: (USCases usCases, _) => usCases.state,
        measureFn: (USCases usCases, _) => usCases.cases,
        colorFn: (USCases usCases, _) =>
            charts.ColorUtil.fromDartColor(usCases.colorValue),
        labelAccessorFn: (USCases row, _) => '${addCommasToInt(row.cases)}',
      ),
    );
    return _seriesUSCases;
  }

  Widget createTable() {
    double headerFontSize = 16;
    double fontSize = 14;
    double padding = 8.0;
    table = new Table(
        border: TableBorder(
            horizontalInside: BorderSide(
                width: 1,
                color: Colors.deepPurple[100],
                style: BorderStyle.solid),
            bottom: BorderSide(
                width: 1,
                color: Colors.deepPurple[100],
                style: BorderStyle.solid)),
        children: [
          TableRow(
              decoration: BoxDecoration(color: Colors.deepPurple[100]),
              children: [
                Padding(
                    padding: EdgeInsets.only(top: padding, bottom: padding),
                    child: Center(
                        child: AutoSizeText('Continent',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: headerFontSize,
                                fontWeight: FontWeight.bold),
                            stepGranularity: 1,
                            maxLines: 1))),
                Padding(
                    padding: EdgeInsets.only(top: padding, bottom: padding),
                    child: Center(
                        child: AutoSizeText('Cases',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: headerFontSize,
                                fontWeight: FontWeight.bold),
                            stepGranularity: 1,
                            maxLines: 1))),
                Padding(
                    padding: EdgeInsets.only(top: padding, bottom: padding),
                    child: Center(
                        child: AutoSizeText('Deaths',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: headerFontSize,
                                fontWeight: FontWeight.bold),
                            stepGranularity: 1,
                            maxLines: 1))),
                Padding(
                    padding: EdgeInsets.only(top: padding, bottom: padding),
                    child: Center(
                        child: AutoSizeText('Recovered',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: headerFontSize,
                                fontWeight: FontWeight.bold),
                            stepGranularity: 1,
                            maxLines: 1))),
              ])
        ]);
    for (int i = 0; i < continentCases.length; i++) {
      table.children.add(TableRow(children: [
        Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
                child: AutoSizeText(continentCases[i].continent,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: fontSize, fontWeight: FontWeight.bold),
                    stepGranularity: 1,
                    maxLines: 2))),
        Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
                child: AutoSizeText(addCommasToInt(continentCases[i].cases),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: fontSize),
                    stepGranularity: 1,
                    maxLines: 2))),
        Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
                child: AutoSizeText(addCommasToInt(continentCases[i].deaths),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: fontSize),
                    stepGranularity: 1,
                    maxLines: 2))),
        Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
                child: AutoSizeText(addCommasToInt(continentCases[i].recovered),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: fontSize),
                    stepGranularity: 1,
                    maxLines: 2))),
      ]));
    }
    return table;
  }

  Widget createUSCasesChart() {
    return new charts.PieChart(
      generateUSData(),
      animate: true,
      animationDuration: Duration(seconds: 2),
      behaviors: [
        new charts.DatumLegend(
          outsideJustification: charts.OutsideJustification.endDrawArea,
          horizontalFirst: false,
          desiredMaxRows: 2,
          cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
          entryTextStyle: charts.TextStyleSpec(
              color: charts.MaterialPalette.purple.shadeDefault,
              fontFamily: 'Georgia',
              fontSize: 14),
        )
      ],
      defaultRenderer: new charts.ArcRendererConfig(
          arcWidth: 100,
          arcRendererDecorators: [
            new charts.ArcLabelDecorator(
                labelPosition: charts.ArcLabelPosition.inside)
          ]),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.blueGrey[900],
                  bottom: TabBar(indicatorColor: Color(0xff9976d0), tabs: [
                    Tab(icon: Icon(FontAwesomeIcons.chartPie)),
                    Tab(icon: Icon(FontAwesomeIcons.table))
                  ]),
                  title: AutoSizeText(
                      'COVID-19 Statistics (Last Update: ' +
                          currentDateFormatted +
                          ')',
                      minFontSize: 15,
                      stepGranularity: 1,
                      maxLines: 2),
                ),
                body: TabBarView(children: [
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                          child: Center(
                              child: Column(children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 30),
                          child: AutoSizeText(
                              'States with over ' + maxCasesString + ' cases',
                              style: TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.bold),
                              minFontSize: 15,
                              stepGranularity: 1,
                              maxLines: 2),
                        ),
                        usCases == null
                            ? CircularProgressIndicator()
                            : Expanded(child: createUSCasesChart())
                      ])))),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                          child: Center(
                              child: Column(children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 30),
                            child: AutoSizeText('Statistics per Continent',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold),
                                minFontSize: 15,
                                stepGranularity: 1,
                                maxLines: 2)),
                        continentCases == null
                            ? CircularProgressIndicator()
                            : Expanded(child: createTable())
                      ]))))
                ]))));
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
}
