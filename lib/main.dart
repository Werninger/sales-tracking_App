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
  List<Product> productList = [];
  void productListAdd(Product p){
    productList.add(p);
    notifyListeners();
  }
  double totalIncome = 0.0;
  double totalOTH = 0.0; // On The House
  
  // Bill
  double toPay = 0.0;

  bool showPayButton = false;
  void showPayButtonF(){
    showPayButton = !showPayButton;
    notifyListeners();
  }

  void addProdocutToBill(Product product) {
    product.curr++;
    toPay += product.price;
    notifyListeners();
  }
  
  String payment = '';
  void setPayment(String s){
    payment = s;
    notifyListeners();
  }
  int orderID = 0;
    
  List<Order> orderList = [];
  
  
  void approveOrder(){
    switch (payment){
      case 'Cash': for (Product product in productList) {product.cash += product.curr; totalIncome += toPay;} break;
      case 'Twint': for (Product product in productList) {product.twint += product.curr; totalIncome += toPay;} break;
      case 'OTH': for (Product product in productList) {product.oth += product.curr; totalOTH += toPay;} break;
    }
    Order order = Order(orderList.length, toPay, payment);
    orderList.add(order);

    resetVariables();
    payment = '';
  }
  
  void resetVariables(){
    for (Product product in productList) {
      product.curr = 0;}
    notifyListeners();
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
                      label: Text('Rechnung'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Verkauf'),
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
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min,
            children: [
              for (Product product in appState.productList)
                Row(children: [
                  ElevatedButton(
                    onPressed: () {
                      appState.addProdocutToBill(product);
                    },
                    child: Text('${product.name}: ${product.curr}'),
                  ),
                  const SizedBox(width: 10),
                ],) 
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
                            onPressed: (){appState.setPayment('Cash');},
                            child: const Row(children: [Icon(Icons.money), Text('Cash'),],),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {appState.setPayment('Twint');},
                            child: const Row(children: [Icon(Icons.hexagon_outlined),Text('Twint'),],)
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {appState.setPayment('OTH');},
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
                            child: Text('OK: ${appState.toPay} ${appState.payment}'),
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
        for (Product product in appState.productList)
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total ${product.name}:  ${product.totalF()}'),
              const SizedBox(width: 20),
              Text('x ${product.price} = ${product.totalIncome()}'),
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
        for (Product product in appState.productList)
          Row(mainAxisAlignment: MainAxisAlignment.center,children: [
            Text(product.name),
            const SizedBox(width: 10),
            Text('${product.price}'),
          ],),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {dynamic input = await _addProduct(context, 'Name of Product ${appState.productList.length}', 'Price of ${appState.productList.length}'); appState.productListAdd(input);}, 
          child: const Text('Create a new Product'),),
      ],
    );
  }
}
Future<dynamic> _addProduct(BuildContext context, String textName, String textPrice) async {
    TextEditingController controller1 = TextEditingController();
    TextEditingController controller2 = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add new Product'),
          content: Column(
            children: [
              TextField(
                controller: controller1,
                decoration: InputDecoration(
                  hintText: textName,
                ),
              ),
              TextField(
                controller: controller2,
                decoration: InputDecoration(
                  hintText: textPrice,
                ),
              ),
            ],),
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
                String userInput1 = controller1.text;
                String userInput2 = controller2.text;
                // Try parsing as double
                double parsedValue;
                try {
                  parsedValue = double.parse(userInput2);
                  Navigator.of(context).pop(Product(userInput1, parsedValue));
                } catch (e) {
                  Navigator.of(context).pop(const Text('failed'));
                }
              },
              child: const Text('Create Product'),
            ),
          ],
        );
      },
    );
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
  dynamic totalIncomeCategory(dynamic t){
    return t*price;
  }
  dynamic totalIncome(){
    return totalF()*price;
  }
}
class Order{
  int orderID;
  String payment;
  double price;
  DateTime creationTime; // DateTime.now();
  Map<String, int> map;

  Order(this.orderID, this.price, this.payment)
    : map = {},
    creationTime = DateTime.now();
  

  String displayInfo() {
    return ('Order: $orderID, Price: ${price.toStringAsFixed(2)}, Payment: $payment, Created at: $creationTime');
  }

}