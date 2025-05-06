import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
class DiabetesPredictionPage extends StatefulWidget {
  @override
  _DiabetesPredictionPageState createState() => _DiabetesPredictionPageState();
}
class _DiabetesPredictionPageState extends State<DiabetesPredictionPage> {
  TextEditingController pregnanciesController = TextEditingController();
  TextEditingController glucoseController = TextEditingController();
  TextEditingController bloodPressureController = TextEditingController();
  TextEditingController skinThicknessController = TextEditingController();
  TextEditingController insulinController = TextEditingController();
  TextEditingController bmiController = TextEditingController();
  TextEditingController diabetesPedigreeFunctionController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  List<String> selectedModels = [];
  Map<String, String> predictions = {};
  ScrollController _scrollController = ScrollController();
  bool isGroundTruthSwitched = false; // Track the state of the ground truth switch
  int selectedSample = 1; // Track the selected sample index
  List<String> models = ['Decision Tree', 'Random Forest', 'SVM', 'XGBoost'];

  // Sample data for ground truth output
  Map<int, Map<String, dynamic>> sampleData = {
    1: {
      'Pregnancies': 6,
      'Glucose': 148,
      'BloodPressure': 72,
      'SkinThickness': 35,
      'Insulin': 0,
      'BMI': 33.6,
      'DiabetesPedigreeFunction': 0.627,
      'Age': 50,
      'Outcome': 1,
    },
    2: {
      'Pregnancies': 1,
      'Glucose': 85,
      'BloodPressure': 66,
      'SkinThickness': 29,
      'Insulin': 0,
      'BMI': 26.6,
      'DiabetesPedigreeFunction': 0.351,
      'Age': 31,
      'Outcome': 0,
    },
    3: {
      'Pregnancies': 8,
      'Glucose': 183,
      'BloodPressure': 64,
      'SkinThickness': 0,
      'Insulin': 0,
      'BMI': 23.3,
      'DiabetesPedigreeFunction': 0.672,
      'Age': 32,
      'Outcome': 1,
    },
    4: {
      'Pregnancies': 1,
      'Glucose': 89,
      'BloodPressure': 66,
      'SkinThickness': 23,
      'Insulin': 94,
      'BMI': 28.1,
      'DiabetesPedigreeFunction': 0.167,
      'Age': 21,
      'Outcome': 0,
    },
    5: {
      'Pregnancies': 0,
      'Glucose': 137,
      'BloodPressure': 40,
      'SkinThickness': 35,
      'Insulin': 168,
      'BMI': 43.1,
      'DiabetesPedigreeFunction': 2.288,
      'Age': 33,
      'Outcome': 1,
    },
    6: {
      'Pregnancies': 5,
      'Glucose': 116,
      'BloodPressure': 74,
      'SkinThickness': 0,
      'Insulin': 0,
      'BMI': 25.6,
      'DiabetesPedigreeFunction': 0.201,
      'Age': 30,
      'Outcome': 0,
    },
    7: {
      'Pregnancies': 3,
      'Glucose': 78,
      'BloodPressure': 50,
      'SkinThickness': 32,
      'Insulin': 88,
      'BMI': 31,
      'DiabetesPedigreeFunction': 0.248,
      'Age': 26,
      'Outcome': 1,
    },
  };

  @override
  void initState() {
    super.initState();
    updateFieldsWithSampleData(selectedSample);
  }

  void updateFieldsWithSampleData(int sampleIndex) {
    Map<String, dynamic> sample = sampleData[sampleIndex]!;
    pregnanciesController.text = sample['Pregnancies'].toString();
    glucoseController.text = sample['Glucose'].toString();
    bloodPressureController.text = sample['BloodPressure'].toString();
    skinThicknessController.text = sample['SkinThickness'].toString();
    insulinController.text = sample['Insulin'].toString();
    bmiController.text = sample['BMI'].toString();
    diabetesPedigreeFunctionController.text = sample['DiabetesPedigreeFunction'].toString();
    ageController.text = sample['Age'].toString();
  }

  Future<void> sendPredictionRequest() async {
    if (selectedModels.isEmpty) {
      // Show a snackbar or some validation to ensure at least one model is selected
      return;
    }

    final url = 'https://flask-mobile-diacare.el.r.appspot.com/predict_diabetes';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Pregnancies': double.parse(pregnanciesController.text),
        'Glucose': double.parse(glucoseController.text),
        'BloodPressure': double.parse(bloodPressureController.text),
        'SkinThickness': double.parse(skinThicknessController.text),
        'Insulin': double.parse(insulinController.text),
        'BMI': double.parse(bmiController.text),
        'DiabetesPedigreeFunction': double.parse(diabetesPedigreeFunctionController.text),
        'Age': double.parse(ageController.text),
        'SelectedModels': selectedModels,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        predictions = Map<String, String>.from(data['predictions']);
      });

      // Store user input and predictions in Firestore
      await storePredictionInFirestore();

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      print('Failed to send data. Error: ${response.reasonPhrase}');
    }
  }

  Future<void> storePredictionInFirestore() async {
    try {
      // Reference to the 'users' collection
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      // Reference to the 'predictions' collection inside 'users'
      CollectionReference predictionsCollection = usersCollection.doc('predictions').collection('predictions');

      // Store user input and predictions
      await predictionsCollection.add({
        'Pregnancies': double.parse(pregnanciesController.text),
        'Glucose': double.parse(glucoseController.text),
        'BloodPressure': double.parse(bloodPressureController.text),
        'SkinThickness': double.parse(skinThicknessController.text),
        'Insulin': double.parse(insulinController.text),
        'BMI': double.parse(bmiController.text),
        'DiabetesPedigreeFunction': double.parse(diabetesPedigreeFunctionController.text),
        'Age': double.parse(ageController.text),
        'SelectedModels': selectedModels,
        'Predictions': predictions,
        'GroundTruth': isGroundTruthSwitched ? getGroundTruth(selectedSample) : '-',
        'Timestamp': FieldValue.serverTimestamp(),
      });

      print('User input and predictions stored in Firestore');
    } catch (error) {
      print('Error storing data in Firestore: $error');
    }
  }

  String getGroundTruth(int sampleIndex) {
    // Get ground truth based on the selected sample index
    int outcome = sampleData[sampleIndex]!['Outcome'];
    return outcome == 1 ? 'High risk' : 'Low risk';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diabetes Prediction'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sample Dropdown and Ground Truth Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sample Dropdown
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<int>(
                    hint: Text('Samples'),
                    value: selectedSample,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedSample = newValue!;
                        updateFieldsWithSampleData(selectedSample);
                      });
                    },
                    items: List.generate(8, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('Sample ${index + 1}'),
                      );
                    }),
                  ),
                ),
                // Ground Truth Switch
                Row(
                  children: [
                    Text('Ground Truth'),
                    Switch(
                      value: isGroundTruthSwitched,
                      onChanged: (value) {
                        setState(() {
                          isGroundTruthSwitched = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Other widgets go here
            buildParameterTextField('Pregnancies', pregnanciesController),
            buildParameterTextField('Glucose', glucoseController),
            buildParameterTextField('Blood Pressure', bloodPressureController),
            buildParameterTextField('Skin Thickness', skinThicknessController),
            buildParameterTextField('Insulin', insulinController),
            buildParameterTextField('BMI', bmiController),
            buildParameterTextField('Diabetes Pedigree Function', diabetesPedigreeFunctionController),
            buildParameterTextField('Age', ageController),
            SizedBox(height: 20),
            buildCheckboxList(models),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendPredictionRequest,
              child: Text('Predict Diabetes'),
            ),
            SizedBox(height: 20),
            Text(
              'Prediction Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...predictions.entries.map((entry) {
              final modelName = entry.key;
              final prediction = entry.value;
              final resultText = '$modelName prediction: $prediction';

              return Text(
                resultText,
                style: TextStyle(fontSize: 16),
              );
            }).toList(),
            // Display ground truth only when the switch is on
            if (isGroundTruthSwitched)
              Text(
                'Ground Truth: ${getGroundTruth(selectedSample)}',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildParameterTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      style: TextStyle(fontSize: 16),
    );
  }

  Widget buildCheckboxList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items.map((String value) {
        return CheckboxListTile(
          title: Text(value),
          value: selectedModels.contains(value),
          onChanged: (bool? newValue) {
            setState(() {
              if (newValue != null) {
                if (newValue) {
                  selectedModels.add(value);
                } else {
                  selectedModels.remove(value);
                }
              }
            });
          },
        );
      }).toList(),
    );
  }
}
