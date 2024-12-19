import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:step_track_app/drawer_pages/bmi_helpers/bmi_calculator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'bmi_helpers/constants.dart';
import 'bmi_helpers/icon.dart';
import 'bmi_helpers/result_page.dart';
import 'bmi_helpers/reusable_card.dart';
// Enum creation
enum GenderType{
  male,
  female,
}

class GetBmi extends StatefulWidget {
  @override
  _GetBmiState createState() => _GetBmiState();
}

class _GetBmiState extends State<GetBmi> {
  int age=18;
  int height=160;
  int weight= 70;
  Color maleCardColour = kinactiveCardColor;
  Color femaleCardColour = kinactiveCardColor;

  void updateColour(GenderType gender){
    if(gender==GenderType.male){
      if(maleCardColour==kinactiveCardColor){
        maleCardColour=kactiveCardColor;
        femaleCardColour=kinactiveCardColor;
      }
      else{
        maleCardColour=kinactiveCardColor;
      }
    }

    if(gender==GenderType.female){
      if(femaleCardColour==kinactiveCardColor){
        femaleCardColour=kactiveCardColor;
        maleCardColour=kinactiveCardColor;
      }
      else {
        femaleCardColour=kinactiveCardColor;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF111328),
        elevation: 8,
        iconTheme: IconThemeData(color: Colors.white),
        title: Center(
          child: Text(
            'B.M.I Calculator',
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23.0,color: Colors.white),
          ),
        ),
      ),
      body:Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: Row(
            children: <Widget>[

              Expanded(child: GestureDetector(
                onTap: (){
                  setState(() {
                    updateColour(GenderType.male);
                  });
                },
                child: ReusableCard(
                  colour:maleCardColour,
                  cardChild: IconContent(icon: FontAwesomeIcons.mars, label: 'MALE',),
                ),
              ),
              ),


              Expanded(child: GestureDetector(
                onTap: (){
                  setState(() {
                    updateColour(GenderType.female);
                  });
                },
                child:ReusableCard(
                  colour: femaleCardColour,
                  cardChild: IconContent(icon: FontAwesomeIcons.venus,label: 'FEMALE',),
                ),),
              )],
          )),


          Expanded(child: ReusableCard(
            colour: kactiveCardColor,
            cardChild:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[Text(
                'HEIGHT',
                style: klabelTextStyle,
              ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      height.toString(),
                      style: knumberTextStyle,
                    ),
                    Text('cm'),
                  ],
                ),

                // SLIDER
                SliderTheme(
                  data: SliderThemeData(
                    inactiveTrackColor: Colors.grey,
                    activeTrackColor: Colors.white,
                    thumbColor: Color(0xFF63E2C6),
                    overlayColor: Colors.black54,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
                  ),
                  child: Slider(
                    value: height.toDouble(),
                    min: 120,
                    max: 220,
                    onChanged: (double newValue) {
                      setState(() {
                        height=newValue.round();
                      });
                    },
                  ),
                )
              ],

            ),
          ),),
          Expanded(child: Row(
            children: <Widget>[
              Expanded(child: ReusableCard(
                  colour:kactiveCardColor,
                  cardChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'WEIGHT',
                          style: klabelTextStyle,
                        ),
                        Text(
                          weight.toString(),
                          style: knumberTextStyle,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton(
                              onPressed: () {
                                setState(() {
                                  weight--;
                                });
                              },
                              child: Icon(Icons.remove,color: Colors.white,size: 35.0,),
                              backgroundColor: Colors.black54,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            FloatingActionButton(
                              onPressed: (){
                                setState(() {
                                  weight++;
                                });
                              },
                              child: Icon(Icons.add,color: Colors.white,size: 35.0,),
                              backgroundColor: Colors.black54,
                            ),
                          ],
                        ),
                      ]
                  )
              ),),

              Expanded(child:ReusableCard(
                  colour: kactiveCardColor,
                  cardChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'AGE',
                          style: klabelTextStyle,
                        ),
                        Text(
                          age.toString(),
                          style: knumberTextStyle,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton(
                              onPressed: () {
                                setState(() {
                                  age--;
                                });
                              },
                              child: Icon(Icons.remove,color: Colors.white,size: 35.0,),
                              backgroundColor: Colors.black54,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            FloatingActionButton(
                              onPressed: (){
                                setState(() {
                                  age++;
                                });
                              },
                              child: Icon(Icons.add,color: Colors.white,size: 35.0,),
                              backgroundColor: Colors.black54,
                            ),
                          ],
                        ),
                      ]
                  )
              ),),
            ],
          )),
          GestureDetector(
            onTap: (){

              BmiCalculator calc=BmiCalculator(height: height, weight: weight);
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return ResultsPage(
                  bmiResult: calc.calculateBMI(),
                  resultText: calc.getResult(),
                  interpretation: calc.getStepRecommendation(),
                  colorResult: calc.getResultColor(),
                );
              }));
            },
            child: Container( 
              child: Card(
                color: Color(0xFF63E2C6),
                child: Center(
                  child: Text(
                    'Calculate',
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