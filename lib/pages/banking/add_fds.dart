import 'package:banking_track/database/banking_helper.dart';
import 'package:banking_track/pages/banking/fd_details.dart';
// import 'package:banking_track/pages/banking/show_fds.dart';
import 'package:flutter/material.dart';

class AddFDs extends StatefulWidget {
  final String bankAccNo;
  final String panNo;

  const AddFDs({super.key, required this.bankAccNo, required this.panNo});

  @override
  State<AddFDs> createState() => _AddFDsState();
}

class _AddFDsState extends State<AddFDs> {
  final TextEditingController _termDepositNumberController =
      TextEditingController();
  final TextEditingController _firstACNameController = TextEditingController();
  final TextEditingController _secondACnameController = TextEditingController();
  final TextEditingController _dateOfDepositController =
      TextEditingController();
  final TextEditingController _depositAmountController =
      TextEditingController();
  final TextEditingController _rateOfInterestController =
      TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  List<Map<String, dynamic>> _bankAccountNos = [];
  BankAccountsRepository _bankAccountsRepository = BankAccountsRepository();
  FDRepository _fdRepository = FDRepository();
  AccountHolderRepository _accountHolderRepository = AccountHolderRepository();
  DateTime? _selectBuyDate;
  DateTime? _selectDueDate;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    // _fetchPanNumbers();
    _fetchBankAccNumbers();
  }

  Future<void> _fetchBankAccNumbers() async {
    final banksId = await _bankAccountsRepository
        .getBankAccountNumbersByBankNo(widget.bankAccNo);
    setState(() {
      _bankAccountNos = banksId;
    });
  }

  Future<void> handleSubmit() async {
    // _fdRepository.insertFD(panNumber, fd);
    int bankId = _bankAccountNos[0]['id'];
    if (_termDepositNumberController.text != null &&
        _selectBuyDate != null &&
        _depositAmountController.text != null &&
        _firstACNameController != null &&
        _rateOfInterestController != null &&
        _selectDueDate != null) {
      int flag = await _fdRepository.insertFD(bankId.toString(), {
        'bank_account_id': bankId,
        'term_deposit_ac_no': _termDepositNumberController.text,
        'date_of_deposit': _selectBuyDate?.toIso8601String().split('T').first,
        'amount_deposited': _depositAmountController.text,
        'primary_acc_holder': _firstACNameController.text,
        'rate_of_interest': _rateOfInterestController.text,
        'due_date': _selectDueDate?.toIso8601String().split('T').first,
        'status': 'open'
      });
      if (flag > 0) {
        int flag2 = await _accountHolderRepository.insertACName(flag,
            [(_firstACNameController.text), _secondACnameController.text]);
        if (flag2 > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inserted FD')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing values')),
      );
    }
  }

  @override
  void dispose() {
    _termDepositNumberController.dispose();
    _firstACNameController.dispose();
    _secondACnameController.dispose();
    _dateOfDepositController.dispose();
    _depositAmountController.dispose();
    _rateOfInterestController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.bankAccNo} FDs"),
        backgroundColor: const Color.fromARGB(147, 90, 97, 161),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: const Icon(Icons.add),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Deposit Number';
                        }
                        return null;
                      },
                      controller: _termDepositNumberController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF008080),
                        labelStyle: const TextStyle(
                          color: Colors.amber,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: "Enter deposit number",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _firstACNameController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF008080),
                        labelStyle: const TextStyle(
                          color: Colors.amber,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: "Enter 1st account holder name",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _secondACnameController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF008080),
                        labelStyle: const TextStyle(
                          color: Colors.amber,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: "Enter 2nd account holder name",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _dateOfDepositController,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectBuyDate = picked;
                            _dateOfDepositController.text = _selectBuyDate!
                                .toIso8601String()
                                .split('T')
                                .first;
                          });
                        }
                        // print(_selectBuyDate?.toIso8601String().split('T').first);
                      },
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF008080),
                        labelStyle: const TextStyle(
                          color: Colors.amber,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: "Enter Date of Deposit",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
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
                      controller: _depositAmountController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF008080),
                        labelStyle: const TextStyle(
                          color: Colors.amber,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: "Enter Amount Deposited",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
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
                      controller: _rateOfInterestController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF008080),
                        labelStyle: const TextStyle(
                          color: Colors.amber,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: "Enter Rate Of Interest",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _dueDateController,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectDueDate = picked;
                            _dueDateController.text = _selectDueDate!
                                .toIso8601String()
                                .split('T')
                                .first;
                          });
                        }
                      },
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF008080),
                        labelStyle: const TextStyle(
                          color: Colors.amber,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: "Enter Due Date",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(content: Text('Valid value')),
                          // );
                          await handleSubmit();
                        }
                      },
                      child: const Text("Submit"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return FDDetails(
                      fdId: _bankAccountNos[0]['id'],
                    );
                  }));
                },
                child: const Text("Show saved FDs"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
