import 'package:flutter/material.dart';

import 'c_sharp_generator_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String result = '';
  final inputTextController = TextEditingController();
  final outputTextController = TextEditingController();
  bool includeFromToJson = false;

  String selectedLanguage = "C#";
  @override
  Widget build(BuildContext context) {
    outputTextController.text = result;
    return Scaffold(
      body: Container(
          child: Column(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Chọn ngôn ngữ: "),
                  ),
                  DropdownButton<String>(
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'C#',
                        child: Text("C#"),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Swift',
                        child: Text("Swift"),
                      )
                    ],
                    onChanged: (value) {
                      print('Đã chọn $value');
                      setState(() {
                        selectedLanguage = value ?? "";
                      });
                    },
                    value: selectedLanguage,
                  ),
                ],
              )),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Include from/toJSON"),
              ),
              Checkbox(
                  value: includeFromToJson,
                  onChanged: (value) {
                    setState(() {
                      includeFromToJson = value ?? false;
                    });
                  }),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black12,
                    child: TextField(
                      controller: inputTextController,
                      maxLines: 100,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                  height: 10,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black12,
                    child: TextField(
                        maxLines: 100,
                        controller: outputTextController,
                        readOnly: true),
                  ),
                )
              ],
            ),
          ),
          Container(
              padding: const EdgeInsets.all(30),
              child: GestureDetector(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.blue,
                  child: const Text(
                    'Generate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () {
                  final generator =
                      CSharpGeneratorModel(input: inputTextController.text);
                  final output =
                      generator.generator(includeFromToJson: includeFromToJson);

                  setState(() {
                    result = output;
                  });
                },
              ))
        ],
      )),
    );
  }
}
