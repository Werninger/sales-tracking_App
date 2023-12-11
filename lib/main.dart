import'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String product1_Name = "Product 1";
  String product2_Name = "Product 2";
  String product3_Name = "Product 3";

  var product1_curr = 0;
  var product2_curr = 0;
  var product3_curr = 0;

  var product1 = 0;
  var product2 = 0;
  var product3 = 0;

  var babPrice = 16;
  var toPay = 0;

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
    toPay += babPrice;
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
    toPay = 0;
    notifyListeners();
  }

  var cash = 0;
  var twint = 0;
  
  var totalIncome = 0;
  void addToIncome(){
    totalIncome += toPay;
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
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.shopping_bag_outlined),
                      label: Text('Verkauf'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Overview'),
                    ),
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
                child: Text('${appState.product1_Name}: ${appState.product1_curr}'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                    onPressed: () {appState.add1('product2');},
                    child: Text('${appState.product2_Name}: ${appState.product2_curr}'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {appState.add1('product3');},
                child: Text('${appState.product3_Name}: ${appState.product3_curr}'),
              ),
            ],
          ), 
          const SizedBox(height: 50),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: (){appState.resetVariables();},
                child: Text('Reset'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {appState.showPayButtonF();},
                child: Text('Pay: ${appState.toPay}'),
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
                  child: const Text('Cash'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {appState.updateVariables();appState.addToIncome(); appState.resetVariables();appState.showPayButtonF();},
                  child: const Text('Twint'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {appState.updateVariables(); appState.resetVariables();appState.showPayButtonF();},
                  child: const Text('On the House'),
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
              Text('Total ${appState.product1_Name}: ${appState.product1}'),
              Text('Total ${appState.product2_Name}: ${appState.product2}'),
              Text('Total ${appState.product3_Name}: ${appState.product3}')
            ],
          ),
        ),
        Center(
          child: Text('Total income: ${appState.totalIncome}'),
        )
      ],
    );
  }
}

