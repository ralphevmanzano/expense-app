import 'dart:io';

import 'package:expense_app/widgets/chart.dart';
import 'package:expense_app/widgets/new_transaction.dart';
import 'package:expense_app/widgets/transaction_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'models/transaction.dart';

void main() {
//  SystemChrome.setPreferredOrientations([
//    DeviceOrientation.portraitUp,
//    DeviceOrientation.portraitDown,
//  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.amber,
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                button: TextStyle(color: Colors.white),
              ),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                  title: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          )),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Transaction> _userTransaction = [
    /*Transaction(
      id: 't1',
      title: 'New Shoes',
      amount: 69.99,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't1',
      title: 'Weekly Groceries',
      amount: 69.99,
      date: DateTime.now(),
    ),*/
  ];

  bool _showChart = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
  }

  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  List<Transaction> get _recentTransaction {
    return _userTransaction.where((tx) {
      return tx.date.isAfter(
        tx.date.subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(String title, double amount, DateTime chosenDate) {
    final newTx = Transaction(
      title: title,
      amount: amount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransaction.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return NewTransaction(_addNewTransaction);
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransaction.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    final PreferredSizeWidget appBar = Platform.isIOS
        ? _buildCupertinoNavigationBar(context)
        : _buildMaterialAppBar(context);

    final availableHeight = (mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top);

    final chartHeight =
        isLandscape ? (availableHeight * 0.7) : (availableHeight * 0.3);

    var homeBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape) _buildSwitch(),
            if (!isLandscape)
              ..._buildPortraitContent(
                chartHeight,
                availableHeight,
              ),
            if (isLandscape)
              _buildLandscapeContent(
                isLandscape,
                _showChart,
                chartHeight,
                availableHeight,
              ),
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: homeBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: homeBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _startAddNewTransaction(context),
                  ),
          );
  }

  AppBar _buildMaterialAppBar(BuildContext context) {
    return AppBar(
      title: Text('Personal Expenses'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
        ),
      ],
    );
  }

  CupertinoNavigationBar _buildCupertinoNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text('Personal Expenses'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => _startAddNewTransaction(context),
            child: Icon(CupertinoIcons.add),
          )
        ],
      ),
    );
  }

  Row _buildSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Show Chart',
          style: Theme.of(context).textTheme.title,
        ),
        Switch.adaptive(
          activeColor: Theme.of(context).accentColor,
          value: _showChart,
          onChanged: (val) {
            setState(() {
              _showChart = val;
            });
          },
        ),
      ],
    );
  }

  Widget _txListWidget(double availableHeight) {
    return Container(
      height: availableHeight * 0.7,
      child: TransactionList(_userTransaction, _deleteTransaction),
    );
  }

  Widget _chartWidget(double chartHeight) {
    return Container(height: chartHeight, child: Chart(_recentTransaction));
  }

  List<Widget> _buildPortraitContent(
      double chartHeight,
      double availableHeight,
      ) {
    return [_chartWidget(chartHeight), _txListWidget(availableHeight)];
  }

  Widget _buildLandscapeContent(
      bool isLandscape,
      bool showChart,
      double chartHeight,
      double availableHeight,
      ) {
    if (isLandscape) {
      if (showChart) {
        return _chartWidget(chartHeight);
      } else {
        return _txListWidget(availableHeight);
      }
    }
    return Container();
  }
}
