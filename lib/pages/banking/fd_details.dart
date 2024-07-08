import 'package:banking_track/database/banking_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FDDetails extends StatefulWidget {
  final int fdId;
  const FDDetails({super.key, required this.fdId});

  @override
  State<FDDetails> createState() => _FDDetailsState();
}

class _FDDetailsState extends State<FDDetails> {
  List<Map<String, dynamic>> fdList = [];
  List<Map<String, dynamic>> nameList = [];

  FDRepository _fdRepository = FDRepository();
  StatementGenerator _statementGenerator = StatementGenerator();
  AccountHolderRepository _accountHolderRepository = AccountHolderRepository();
  TextEditingController _modifyAmountController = TextEditingController();
  TextEditingController _modifyDueDateController = TextEditingController();
  TextEditingController _modifyROIController = TextEditingController();
  DateTime? _selectModifyDate;
  final _modifyFormKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    // _fetchPanNumbers();
    _loadFDs();
  }

  Future<void> _loadFDs() async {
    try {
      final fds = await _statementGenerator.getFDS(widget.fdId);
      final names =
          await _accountHolderRepository.getACNameByAccountNumber(widget.fdId);
      print(fds);
      setState(() {
        fdList = fds;
        nameList = names;
      });
    } catch (e) {
      debugPrint("error");
    }
  }

  Future<void> _modifyFD(int id, String date, String roi) async {
    await _fdRepository.updateFD(id, date, double.parse(roi));
    await _fdRepository.updateStatusFD(id, 'closed');
    _loadFDs();
  }

  Future<void> _deleteStock(int id) async {
    await _fdRepository.deleteFD(id);
    _loadFDs();
  }

  Future<void> _renewStock(int id) async {
    await _fdRepository.updateStatusFD(id, 'renewed');
    _loadFDs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 193, 198, 207),
      appBar: AppBar(
        title: const Text("FD Details"),
        backgroundColor: const Color.fromARGB(147, 90, 97, 161),
      ),
      body: Column(
        children: [
          SizedBox(
            width: 250,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text("Active"),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text("Closed"),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Colors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text("Renewed"),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DataTable(
                  showBottomBorder: true,
                  border: TableBorder.all(
                    borderRadius: BorderRadius.circular(8),
                    width: 1,
                  ),
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => const Color.fromARGB(255, 144, 150, 202)),
                  decoration: BoxDecoration(border: Border.all(width: 2)),
                  dataTextStyle: const TextStyle(fontSize: 18),
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Sl No.')),
                    DataColumn(label: Text('Term Deposit \n number')),
                    DataColumn(label: Text('Account \nHolder 1')),
                    DataColumn(label: Text('Account\n Holder 2')),
                    DataColumn(label: Text('Date of \n Deposit')),
                    DataColumn(label: Text('Amount \n Deposited')),
                    DataColumn(label: Text('ROI')),
                    DataColumn(label: Text('Interest ')),
                    DataColumn(label: Text('Returns At\n Maturity')),
                    DataColumn(label: Text('Due Date')),
                    DataColumn(label: Icon(Icons.edit))
                  ],
                  rows: List<DataRow>.generate(
                    fdList.length,
                    (index) {
                      final DateFormat dateFormat = DateFormat("dd-MM-yyyy");
                      final DateTime formattedBuyDate =
                          DateTime.parse(fdList[index]['date_of_deposit']);
                      final DateTime formattedDueDate =
                          DateTime.parse(fdList[index]['due_date']);
                      int days =
                          formattedDueDate.difference(formattedBuyDate).inDays;
                      // print(days);
                      double dailyInterest =
                          (fdList[index]['rate_of_interest'] * (days)) / 365;
                      double accruedInterest =
                          (dailyInterest * fdList[index]['amount_deposited']) /
                              100;
                      // print(formattedBuyDate);
                      // print(formattedDueDate);
                      // print(dailyInterest);
                      // print('days:$days');
                      // print(accruedInterest);
                      double returns =
                          fdList[index]['amount_deposited'] + accruedInterest;
                      String status = fdList[index]['status'] ?? '';
                      print(status);
                      print(fdList[index]);
                      return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(fdList[index]['term_deposit_ac_no'])),
                            DataCell(Text(fdList[index]['account_holder_name1']
                                .toString())),
                            DataCell(Text(fdList[index]['account_holder_name2']
                                    ?.toString() ??
                                '')),
                            DataCell(Text(
                                fdList[index]['date_of_deposit'].toString())),
                            DataCell(Text(
                                fdList[index]['amount_deposited'].toString())),
                            DataCell(Text(
                                fdList[index]['rate_of_interest'].toString())),
                            DataCell(Text(accruedInterest.ceil().toString())),
                            DataCell(Text(returns.ceil().toString())),
                            DataCell(
                                Text(fdList[index]['due_date'].toString())),
                            DataCell(
                              PopupMenuButton<String>(
                                onSelected: (String result) {
                                  switch (result) {
                                    case 'Modify':
                                      _showModifyDialog(context, index);
                                      break;
                                    case 'Delete':
                                      _showDeleteDialog(context, index);
                                      break;
                                    case 'Renewed':
                                      _showRenewDialog(context, index);
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'Modify',
                                    child: Text('Close'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'Delete',
                                    child: Text('Delete'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'Renewed',
                                    child: Text('Mark as renewed'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          color: MaterialStateColor.resolveWith((states) =>
                              status == 'renewed'
                                  ? Colors.grey
                                  : (status == 'closed'
                                      ? Colors.amber
                                      : Colors.green)));
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showModifyDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Early Closure'),
          content: Form(
            key: _modifyFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _modifyDueDateController,
                  decoration: const InputDecoration(
                    labelText: 'Closing Date',
                  ),
                  keyboardType: TextInputType.datetime,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectModifyDate = picked;
                        _modifyDueDateController.text = _selectModifyDate!
                            .toIso8601String()
                            .split('T')
                            .first;
                      });
                    }
                  },
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    final doubleValue = double.tryParse(value);
                    if (doubleValue == null) {
                      return 'Please enter a valid value';
                    }
                    return null;
                  },
                  controller: _modifyROIController,
                  decoration: const InputDecoration(
                    labelText: 'Rate of Interest',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                // Handle OK action
                if (_modifyFormKey.currentState!.validate()) {
                  _modifyFD(fdList[index]['id'], _modifyDueDateController.text,
                      _modifyROIController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showRenewDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark as renewed?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Handle OK action
                _renewStock(fdList[index]['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete This Item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Handle OK action
                _deleteStock(fdList[index]['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
