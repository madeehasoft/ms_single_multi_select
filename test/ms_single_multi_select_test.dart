import 'package:flutter/material.dart';
import 'package:ms_single_multi_select/ms_single_multi_select.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MS Dropdown Demo',
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ms_controller multyController = ms_controller();
  final ms_controller singleController = ms_controller();
  FocusNode useridFTB = FocusNode();
  List<ms_class> cities = [];

  @override
  void initState() {
    super.initState();
    cities = List.generate(
      500,
      (i) => ms_class(
        prefixCode: 'Prefix Code ${i.toString().padLeft(3, '0')}',
        name: 'City Name $i',
        suffixCode: 'Suffix Code $i',
      ),
    );
  }

  @override
  void dispose() {
    singleController.dispose();
    multyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Madeehasoft® Single Or Multiple Selector Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 10,
            children: [
              MsSingleMultiSelector(
                hintText: "Select Single City",
                msFieldwidth: 400,
                prefixIcon: Icon(Icons.search),
                items: cities,
                multiSelect: false,
                controller: singleController,
                highlightColor: const Color.fromARGB(255, 191, 255, 192),
                checkboxActiveColor: const Color.fromARGB(255, 251, 5, 5),
                prefixCodeTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                listNameTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color.fromARGB(255, 75, 20, 224),
                ),
                onSubmit: () {
                  //useridFTB.requestFocus();
                  multyController.requestFocus();
                },
                onChangedMulti: (selected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Selected: ${selected.map((c) => c.name).join(', ')}',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              MsSingleMultiSelector(
                hintText: "Select Multiple Cities",
                searchTextStyle: TextStyle(fontWeight: FontWeight.bold),
                msFieldwidth: 300,
                msFieldheight: 45,
                prefixIcon: Icon(Icons.search),
                items: cities,
                multiSelect: true,
                controller: multyController,
                highlightColor: const Color.fromARGB(255, 191, 255, 192),
                checkboxActiveColor: const Color.fromARGB(255, 251, 5, 5),
                prefixCodeTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 177, 11, 11),
                ),
                suffixCodeTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 41, 142, 8),
                ),
                listNameTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color.fromARGB(255, 38, 5, 129),
                ),
                onSubmit: () {
                  useridFTB.requestFocus();
                },
                onChangedMulti: (selected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Selected: ${selected.map((c) => c.name).join(', ')}',
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  if (multyController.isSelected || singleController.isSelected) {
                   if (!singleController.isSelected) {
                      _showToast(
                      context,
                      'Selected items: ${multyController.selectedMulti.map((c) => c.name).join(', ')}',
                    );
                   }else{
                    _showToast(
                      context,
                      'Selected item: ${singleController.selectedSingle?.name ?? 'None'}',
                    );
                   }
                  } else {
                    _showToast(context, 'No selection made');
                  }
                },
                child: Text('Check Select Or Not Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showToast(BuildContext context, value) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1300),
        content: const Text('Message'),
        action: SnackBarAction(
          label: value,
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  }
}
