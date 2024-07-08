import 'package:banking_track/database/banking_helper.dart';
import 'package:banking_track/pages/banking/add_fds.dart';
import 'package:banking_track/pages/banking/statements.dart';
import 'package:flutter/material.dart';
// import 'your_repository_file.dart';

class BankingApp extends StatefulWidget {
  @override
  _BankingAppState createState() => _BankingAppState();
}

class _BankingAppState extends State<BankingApp> {
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _bankAccountNumberController =
      TextEditingController();
  final PanNumbersRepository _repository = PanNumbersRepository();
  final BankAccountsRepository _bankAccountsRepository =
      BankAccountsRepository();

  List<Map<String, dynamic>> _panNumbers = [];
  Map<int, List<Map<String, dynamic>>> _bankAccounts = {};

  @override
  void initState() {
    super.initState();
    _fetchPanNumbers();
  }

  @override
  void dispose() {
    _panNumberController.dispose();
    _bankAccountNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchPanNumbers() async {
    List<Map<String, dynamic>> panNumbers = await _repository.getPanNumbers();
    // print(panNumbers);
    setState(() {
      _panNumbers = panNumbers;
    });
  }

  Future<void> _fetchBankAccounts(int panId) async {
    List<Map<String, dynamic>> bankAccounts =
        await _bankAccountsRepository.getBankAccountNumbers(panId);
    // print(bankAccounts);
    setState(() {
      _bankAccounts[panId] = bankAccounts;
    });
  }

  Future<void> _submitBankAccount() async {
    final panNumber = _panNumberController.text;
    final bankAccountNumber = _bankAccountNumberController.text;

    if (panNumber.isNotEmpty && bankAccountNumber.isNotEmpty) {
      int panId = await _repository.insertPanNumber(panNumber);
      // print(panId);
      if (panId > 0) {
        int rs = await _bankAccountsRepository.insertBankAccount(
            bankAccountNumber, panId);
        // print(rs);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank Account inserted successfully')),
        );
        _fetchBankAccounts(panId); // Fetch bank accounts for the new PAN ID
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to insert PAN Number')),
        );
      }
      _panNumberController.clear();
      _bankAccountNumberController.clear();
      _fetchPanNumbers(); // Refresh PAN numbers
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter both PAN Number and Bank Account Number')),
      );
    }
  }

  Future<void> _deletePan(int id) async {
    _repository.deletePanNumber(id);
    _fetchPanNumbers();
  }

  Future<void> _deleteBank(int id, int panid) async {
    _bankAccountsRepository.deleteBankAccountNumber(id);
    _fetchPanNumbers();
    _fetchBankAccounts(panid);
  }

  Future<void> _deleteDB() async {
    await DatabaseHelper.instance.deleteDatabaseFile();
    _fetchPanNumbers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(147, 90, 97, 161),
        title: const Text('Bank Account Deposits'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete the entire database?'),
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
                          _deleteDB();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.delete,
              // color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _panNumberController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                  labelText: 'PAN Number',
                  hintText: 'eg: DDPS12345'),
            ),
            TextField(
              controller: _bankAccountNumberController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                labelText: 'Bank Account Number',
                hintText: 'eg: SBI 12345456',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _submitBankAccount,
                  child: const Text('Submit Bank Account'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const StatementsPage();
                        },
                      ),
                    );
                  },
                  child: const Text('Fetch Statements'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _panNumbers.length,
                itemBuilder: (context, index) {
                  final pan = _panNumbers[index];
                  final panId = pan['id'];
                  final panNumber = pan['pan_number'];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      collapsedBackgroundColor:
                          const Color.fromARGB(255, 95, 94, 164),
                      textColor: Colors.black,
                      title: Text(
                        panNumber,
                        style: const TextStyle(color: Colors.black),
                      ),
                      onExpansionChanged: (expanded) {
                        if (expanded) {
                          _fetchBankAccounts(panId);
                        }
                      },
                      leading: IconButton(
                          onPressed: () {
                            _showDeleteDialog(context, index);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          )),
                      children: _bankAccounts[panId]?.map((bankAccount) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                trailing: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text('Delete This Bank?'),
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
                                                  _deleteBank(
                                                      bankAccount['id'], panId);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.delete)),
                                tileColor: Colors.amber,
                                leading: const Icon(Icons.account_balance),
                                title: Text(
                                  bankAccount['bank_account_number'],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return AddFDs(
                                      bankAccNo:
                                          bankAccount['bank_account_number'],
                                      panNo: panNumber,
                                    );
                                  }));
                                },
                              ),
                            );
                          }).toList() ??
                          [const CircularProgressIndicator()],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete This Pan?'),
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
                _deletePan(_panNumbers[index]['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
