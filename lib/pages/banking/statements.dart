import 'package:banking_track/database/banking_helper.dart';
import 'package:banking_track/pages/statement_dwd/pdf_service.dart';
import 'package:banking_track/pages/statement_dwd/save_and_open.dart';
import 'package:flutter/material.dart';

final List<String> list = <String>['Holding', 'Closed'];

class StatementsPage extends StatefulWidget {
  const StatementsPage({super.key});

  @override
  State<StatementsPage> createState() => _StatementsPageState();
}

class _StatementsPageState extends State<StatementsPage> {
  AccountHolderRepository _accountHolderRepository = AccountHolderRepository();
  BankAccountsRepository _bankAccountsRepository = BankAccountsRepository();
  // PanNumbersRepository _numbersRepository = PanNumbersRepository();
  FDRepository _fdRepository = FDRepository();
  List<Map<String, dynamic>> names = [];
  // List<Map<String, dynamic>> panNumbers = [];
  List<Map<String, dynamic>> accountNumbers = [];
  String currentHolder = '';
  String curretPan = '';
  String currentBank = '';
  final TextEditingController _yearNamecontroller = TextEditingController();
  // final TextEditingController _yearPancontroller = TextEditingController();

  final TextEditingController _yearBankAcccontroller = TextEditingController();

  String? dropdownValue = list.first;
  String? dropdownValueBank = list.first;

  @override
  void initState() {
    super.initState();
    // _fetchPanNumbers();
    fetchData();
  }

  Future<void> fetchData() async {
    final name = await _fdRepository.getACName();
    // final pans = await _numbersRepository.getPanNumbers();
    final banks = await _bankAccountsRepository.getAllBankAccountNumbers();
    // print(pans);
    setState(() {
      names = name;
      // panNumbers = pans;
      accountNumbers = banks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: const Text("Statement page"),
        backgroundColor: const Color.fromARGB(147, 90, 97, 161),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    DropdownMenu(
                      width: 340,
                      enableFilter: true,
                      hintText: "Select an AccountHolder",
                      dropdownMenuEntries:
                          names.map((Map<String, dynamic> name) {
                        return DropdownMenuEntry<String>(
                          value: name['primary_acc_holder'],
                          label: name['primary_acc_holder'],
                        );
                      }).toList(),
                      onSelected: (value) {
                        currentHolder = value!;
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: 100,
                      child: DropdownButton(
                        value: dropdownValue,
                        onChanged: (String? value) {
                          setState(() {
                            dropdownValue = value;
                          });
                          // print(dropdownValue);
                        },
                        items:
                            list.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        controller: _yearNamecontroller,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                            hintText: 'eg: 2024',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            labelText: 'Financial year'),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (dropdownValue == 'Holding') {
                          final tablePdf = await PdfApi.generateAcNameStatement(
                              currentHolder,
                              int.parse(_yearNamecontroller.text));
                          SaveAndOpenDocument.openPdf(tablePdf);
                        } else {
                          final tablePdf =
                              await PdfApi.generateAcNameStatementClosed(
                                  currentHolder,
                                  int.parse(_yearNamecontroller.text));
                          SaveAndOpenDocument.openPdf(tablePdf);
                        }
                      },
                      child: const Text("Submit"),
                    )
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                // const SizedBox(
                //   width: 20,
                // ),
                Column(
                  children: [
                    DropdownMenu(
                      width: 300,
                      enableFilter: true,
                      hintText: "Select a Bank Account",
                      dropdownMenuEntries:
                          accountNumbers.map((Map<String, dynamic> bank) {
                        return DropdownMenuEntry<String>(
                          value: bank['bank_account_number'],
                          label: bank['bank_account_number'],
                        );
                      }).toList(),
                      onSelected: (value) {
                        currentBank = value!;
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    // const SizedBox(
                    //   height: 30,
                    // ),
                    SizedBox(
                      width: 100,
                      child: DropdownButton(
                        value: dropdownValueBank,
                        onChanged: (String? value) {
                          setState(() {
                            dropdownValueBank = value;
                          });
                          // print(dropdownValue);
                        },
                        items:
                            list.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        controller: _yearBankAcccontroller,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                            hintText: 'eg: 2024',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            labelText: 'Financial year'),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (dropdownValueBank == 'Holding') {
                          final tablePdf = await PdfApi.generateBankStatement(
                              currentBank,
                              int.parse(_yearBankAcccontroller.text));
                          SaveAndOpenDocument.openPdf(tablePdf);
                        } else {
                          final tablePdf =
                              await PdfApi.generateBankStatementClosed(
                                  currentBank,
                                  int.parse(_yearBankAcccontroller.text));
                          SaveAndOpenDocument.openPdf(tablePdf);
                        }
                      },
                      child: const Text("Submit"),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
