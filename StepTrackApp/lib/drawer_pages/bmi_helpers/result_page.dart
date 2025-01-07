import 'package:flutter/material.dart';
import 'package:step_track_app/drawer_pages/bmi_helpers/reusable_card.dart';

import 'constants.dart';


class ResultsPage extends StatelessWidget {
  ResultsPage({required this.bmiResult,required this.resultText,required this.interpretation,required this.colorResult});
  final String bmiResult;
  final String resultText;
  final String interpretation;
  final Color colorResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:  Color(0xFF111328),
        title: Text('B.M.I Results',style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              child: Center(child: Text('Your Result',style: ktitleTextStyle,)),
            ),
          ),
          Expanded(
            flex: 5,
            child: ReusableCard(
              colour:Color(0xFF0084B2),
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    resultText.toUpperCase(),
                    style:  TextStyle(color: colorResult,fontSize: 22.0,fontWeight: FontWeight.bold),
                  ),
                  Text(
                    bmiResult,
                    style: kBMITextStyle,
                  ),
                  Text(
                    interpretation,
                    style: kbodyTextStyle,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),


          GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              child: Card(
                color: Color(0xFF63E2C6),
                child: Center(
                  child: Text(
                    'Re-Calculate',
                    style:klargestButtonTextStyle,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              margin: EdgeInsets.only(top: 10.0),
              padding: EdgeInsets.only(bottom: 10.0),
              height:70.0,
            ),
          ),
        ],
      ),
    );
  }
}
