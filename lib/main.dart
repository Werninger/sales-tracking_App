import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'sales-tracking_App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String product1_name = "Product 1";
  String product2_name = "Product 2";
  String product3_name = "Product 3";

  void setName(String s, String name){
    switch (name){
      case 'p1':
        product1_name = s;
        break;
      case 'p2':
        product2_name = s;
        break;
      case 'p3':
        product3_name = s;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  var product1_curr = 0;
  var product2_curr = 0;
  var product3_curr = 0;

  var product1 = 0;
  var product2 = 0;
  var product3 = 0;

  double price_bab = 16.00;
  double toPay = 0.0;

  bool showPayButton = false;

  void showPayButtonF(){
    showPayButton = !showPayButton;
    notifyListeners();
  }

  void add1(String variable) {
    switch (variable) {
      case 'product1':
        product1_curr++;
        break;
      case 'product2':
        product2_curr++;
        break;
      case 'product3':
        product3_curr++;
        break;
      default:
        break;
    }
    toPay += price_bab;
    notifyListeners();
  }
  void updateVariables(){
    product1 += product1_curr;
    product2 += product2_curr;
    product3 += product3_curr;
  }
  void resetVariables(){
    product1_curr = 0;
    product2_curr = 0;
    product3_curr = 0;
    toPay = 0.0;
    notifyListeners();
  }

  var cash = 0;
  var twint = 0;
  
  double totalIncome = 0.0;
  void addToIncome(){
    totalIncome += toPay;
  }  

  double totalOTH = 0.0; // On The House
  void addToOTH(){
    totalOTH += toPay;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex){
      case 0:
        page = GeneratorPage();
        break;
      case 1 :
        page = OverviewPage();
        break;
      case 2 :
        page = SettingPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.shopping_bag_outlined),
                      label: Text('Verkauf'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Overview'),
                    ),
                    NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings'))
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
        
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {appState.add1('product1');},
                child: Text('${appState.product1_name}: ${appState.product1_curr}'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                    onPressed: () {appState.add1('product2');},
                    child: Text('${appState.product2_name}: ${appState.product2_curr}'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {appState.add1('product3');},
                child: Text('${appState.product3_name}: ${appState.product3_curr}'),
              ),
            ],
          ), 
          const SizedBox(height: 50),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: (){appState.resetVariables();},
                child: const Row(children: [Icon(Icons.restart_alt), Text('Reset'),],),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {appState.showPayButtonF();},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_checkout), // Add the payment icon
                    Text('Pay: ${appState.toPay}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (appState.showPayButton)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: (){appState.updateVariables();appState.addToIncome(); appState.resetVariables();appState.showPayButtonF();},
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.money), // Add the payment icon
                      SizedBox(width: 8), // Add some spacing between the icon and text
                      Text('Cash'),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {appState.updateVariables();appState.addToIncome(); appState.resetVariables();appState.showPayButtonF();},
                  child: const Row(children: [Icon(Icons.hexagon_outlined),Text('Twint'),],)
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {appState.updateVariables(); appState.addToOTH(); appState.resetVariables();appState.showPayButtonF();},
                  child: const Row(children: [Icon(Icons.home),Text('On the house')],)
                ),
              ],
            ),
        ],        
      ),
    );
  }     
}

class OverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Total ${appState.product1_name}: ${appState.product1}'),
              Text('Total ${appState.product2_name}: ${appState.product2}'),
              Text('Total ${appState.product3_name}: ${appState.product3}'),
              const SizedBox(height: 50),
              Text('Total income: ${appState.totalIncome}'),
              Text('Total on the house: ${appState.totalOTH}'),

            ],
          ),
        ),
      ],
    );
  }
}

class SettingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {String input = await _showInputDialog(context, 'Name of Product 1'); appState.setName(input, 'p1');}, 
          child: Text('Name of ${appState.product1_name}'),),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {String input = await _showInputDialog(context, 'Name of Product 1'); appState.setName(input, 'p2');}, 
          child: Text('Name of ${appState.product2_name}'),),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {String input = await _showInputDialog(context, 'Name of Product 1'); appState.setName(input, 'p3');}, 
          child: Text('Name of ${appState.product3_name}'),),
      ],
    );
  }
}

Future<dynamic> _showInputDialog(BuildContext context, String s) async {
    TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(s),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Type...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Get the user input as a string
                String userInput = controller.text;
                Navigator.of(context).pop(userInput);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
