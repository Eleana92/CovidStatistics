import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class USCases {
  final String state;
  final int cases;
  final Color colorValue;
  USCases({@required this.state, @required this.cases, this.colorValue});
  factory USCases.fromJson(Map<String, dynamic> json) {
    return USCases(state: states[json['state']], cases: json['total']);
  }
}

class ContinentCases {
  final String continent;
  final int cases;
  final int deaths;
  final int recovered;
  ContinentCases(
      {@required this.continent,
      @required this.cases,
      @required this.deaths,
      @required this.recovered});
  factory ContinentCases.fromJson(Map<String, dynamic> json) {
    return ContinentCases(
        continent: json['continent'],
        cases: json['cases'],
        deaths: json['deaths'],
        recovered: json['recovered']);
  }
}

List<Color> colorValues = <Color>[
  Colors.blue[400],
  Colors.purple[400],
  Colors.green[700],
  Colors.red[700],
  Colors.lime[700],
  Colors.amber[800],
  Colors.lightBlue[900],
  Colors.yellow[900],
  Colors.cyan[800],
  Colors.pink[900]
];
var states = {
  'AL': 'Alabama',
  'AK': 'Alaska',
  'AS': 'American Samoa',
  'AZ': 'Arizona',
  'AR': 'Arkansas',
  'CA': 'California',
  'CO': 'Colorado',
  'CT': 'Connecticut',
  'DE': 'Delaware',
  'DC': 'District of Columbia',
  'FL': 'Florida',
  'GA': 'Georgia',
  'GU': 'Guam',
  'HI': 'Hawaii',
  'ID': 'Idaho',
  'IL': 'Illinois',
  'IN': 'Indiana',
  'IA': 'Iowa',
  'KS': 'Kansas',
  'KY': 'Kentucky',
  'LA': 'Louisiana',
  'ME': 'Maine',
  'MD': 'Maryland',
  'MA': 'Massachusetts',
  'MI': 'Michigan',
  'MN': 'Minnesota',
  'MS': 'Mississippi',
  'MO': 'Missouri',
  'NE': 'Nebraska',
  'NV': 'Nevada',
  'NH': 'New Hampshire',
  'NJ': 'New Jersey',
  'NM': 'New Mexico',
  'NY': 'New York',
  'NC': 'North Carolina',
  'ND': 'North Dakota',
  'MP': 'Northern Mariana Is',
  'OH': 'Ohio',
  'OK': 'Oklahoma',
  'OR': 'Oregon',
  'PA': 'Pennsylvania',
  'PR': 'Puerto Rico',
  'RI': 'Rhode Island',
  'SC': 'South Carolina',
  'SD': 'South Dakota',
  'TN': 'Tennessee',
  'TX': 'Texas',
  'UT': 'Utah',
  'VT': 'Vermont',
  'VA': 'Virginia',
  'VI': 'Virgin Islands',
  'WA': 'Washington',
  'WV': 'West Virginia',
  'WI': 'Wisconsin',
  'WY': 'Wyoming',
};
