import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
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
  Product p1 = Product("Product 1", 10.0);
  Product p2 = Product("Product 3", 20.0);
  Product p3 = Product("Product 3", 30.0);
  
  List<Product> productList = [];
  
  void set(String name, var x){
    if (x == null){return;}
    switch (name){
      case 'p1_n': p1.name = x; break;
      case 'p2_n': p2.name = x; break;
      case 'p3_n': p3.name = x; break;
      case 'p1_p': p1.price = x; break;
      case 'p2_p': p2.price = x; break;
      case 'p3_p': p3.price = x; break;
      default:
        break;
    }
    notifyListeners();
  }


  double toPay = 0.0;

  bool showPayButton = false;

  void showPayButtonF(){
    showPayButton = !showPayButton;
    notifyListeners();
  }

  void add1(String variable) {
    switch (variable) {
      case 'product1':
        p1.curr++;
        toPay += p1.price;
        break;
      case 'product2':
        p2.curr++;
        toPay += p2.price;
        break;
      case 'product3':
        p3.curr++;
        toPay += p3.price;
        break;
      default:
        break;
    }
    
    notifyListeners();
  }
  int id = 0;
    
  List<Order> orderList = [];
  String payment = '';
  void setPayment(String s){
    payment = s;
    notifyListeners();
  }
  void approveOrder(){
    switch (payment){
      case 'cash': p1.cash += p1.curr; p2.cash += p2.curr; p3.cash += p3.curr; break;
      case 'twint': p1.twint += p1.curr; p2.twint += p2.curr; p3.twint += p3.curr; break;
      case 'oth': p1.oth += p1.curr; p2.oth += p2.curr; p3.oth += p3.curr; break;
    }
    Order order = Order(++id, toPay, payment);
    for (Product product in productList){
      order.map[product.name] = product.curr;}
    orderList.add(order);
    resetVariables();
    payment = '';
  }
  
  void resetVariables(){
    p1.curr = 0;
    p2.curr = 0;
    p3.curr = 0;
    toPay = 0.0;
    notifyListeners();
  }

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
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {appState.add1('product1');},
                child: Text('${appState.p1.name}: ${appState.p1.curr}'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                    onPressed: () {appState.add1('product2');},
                    child: Text('${appState.p2.name}: ${appState.p2.curr}'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {appState.add1('product3');},
                child: Text('${appState.p3.name}: ${appState.p3.curr}'),
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
                    const Icon(Icons.shopping_cart_checkout), // Add the payment icon
                    Text('Pay: ${appState.toPay}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (appState.showPayButton)
            AlertDialog(
              title: Text('Choose payment for ${appState.toPay}'),
              actions: [
                Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: (){appState.setPayment('cash');},
                            child: const Row(children: [Icon(Icons.money), Text('Cash'),],),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {appState.setPayment('twint');},
                            child: const Row(children: [Icon(Icons.hexagon_outlined),Text('Twint'),],)
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {appState.setPayment('oth');},
                            child: const Row(children: [Icon(Icons.home),Text('On the house')],)
                          ),
                          
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                        TextButton(
                          onPressed: () {appState.setPayment('');},
                          child: const Text('Cancel'),
                        ),
                        if (appState.payment != '')
                          TextButton(
                            onPressed: () {appState.approveOrder();appState.resetVariables();appState.showPayButtonF();},
                            child: const Text('OK'),
                          ),
                      ],)
                    ],
                  ),
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
    
    return Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total ${appState.p1.name}:  ${appState.p1.total}'),
            const SizedBox(width: 20),
            Text('x ${appState.p1.price} = ${appState.p1.total * appState.p1.price}'),
          ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total ${appState.p2.name}: ${appState.p2.total}'),
            const SizedBox(width: 20),
            Text('x ${appState.p2.price} = ${appState.p2.total * appState.p2.price}'),
          ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total ${appState.p3.name}: ${appState.p3.total}'),
            const SizedBox(width: 20),
            Text('x ${appState.p3.price} = ${appState.p3.total * appState.p3.price}'),
          ],),
        const SizedBox(height: 50),
        Text('Total income: ${appState.totalIncome}'),
        Text('Total on the house: ${appState.totalOTH}'),
        const SizedBox(height: 10),
        const Text('Orders: '),
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
          for (Order order in appState.orderList) 
            Text(' ${order.displayInfo()}'),
          ],)
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
        Row(mainAxisSize: MainAxisSize.min,children: [
          ElevatedButton(
            onPressed: () async {dynamic input = await _showInputDialog(context, 'Name of Product 1'); appState.set('p1_n', input);}, 
            child: Text('Name of ${appState.p1.name}'),),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {dynamic input = await _showInputDialog(context, 'Price of ${appState.p1.name}'); appState.set('p1_p',input);},
            child: Text('Price of ${appState.p1.name}'),),

        ],),
        const SizedBox(height: 10),
        Row(mainAxisSize: MainAxisSize.min,children: [
          ElevatedButton(
            onPressed: () async {dynamic input = await _showInputDialog(context, 'Name of Product 2'); appState.set('p2_n',input);}, 
            child: Text('Name of ${appState.p2.name}'),),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {dynamic input = await _showInputDialog(context, 'Price of Product 2'); appState.set('p2_p',input);}, 
            child: Text('Price of ${appState.p2.name}'),),
          
        ],),
        const SizedBox(height: 10),
        Row(mainAxisSize: MainAxisSize.min,children: [
          ElevatedButton(
            onPressed: () async {dynamic input = await _showInputDialog(context, 'Name of ${appState.p3.name}'); appState.set('p3_n',input);}, 
            child: Text('Name of ${appState.p3.name}'),),
          const SizedBox(width: 10),
          ElevatedButton(onPressed: () async {dynamic input = await _showInputDialog(context, 'Price of ${appState.p3.name}'); appState.set('p3_p',input);}, 
            child: Text('Price of ${appState.p3.name}'))
        ],),
        
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
            decoration: const InputDecoration(
              hintText: 'Type...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Get the user input as a string
                dynamic userInput = controller.text;

                // Try parsing as double
                double parsedValue;
                try {
                  parsedValue = double.parse(userInput);
                  Navigator.of(context).pop(parsedValue);
                } catch (e) {
                  Navigator.of(context).pop(userInput);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

class Product{
  String name;
  double price;

  int curr;
  int total;
  int cash;
  int twint;
  int oth;
  
  Product(this.name, this.price, [this.curr = 0, this.total = 0, this.cash = 0, this.twint = 0, this.oth = 0]);
  
  int totalF(){
    return cash+twint+oth;
  }
  dynamic totalIncome(dynamic t){
    return t*price;
  }
}
class Order{
  int id;
  String payment;
  double price;
  DateTime creationTime; // DateTime.now();
  Map<String, int> map;

  Order(this.id, this.price, this.payment)
    : map = {},
    creationTime = DateTime.now();
  

  String displayInfo() {
    return ('Order: $id, Price: ${price.toStringAsFixed(2)}, Payment: $payment, Created at: $creationTime');
  }

}