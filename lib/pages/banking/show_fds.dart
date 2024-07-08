import 'package:banking_track/database/banking_helper.dart';
import 'package:banking_track/pages/banking/fd_details.dart';
import 'package:flutter/material.dart';

class ShowFDs extends StatefulWidget {
  final int bankId;
  const ShowFDs({super.key, required this.bankId});

  @override
  State<ShowFDs> createState() => _ShowFDsState();
}

class _ShowFDsState extends State<ShowFDs> {
  List<Map<String, dynamic>> fdList = [];
  FDRepository _fdRepository = FDRepository();
  @override
  void initState() {
    super.initState();
    // _fetchPanNumbers();
    _fetchFds();
  }

  Future<void> _fetchFds() async {
    List<Map<String, dynamic>> fds =
        await _fdRepository.getFDByBankId(widget.bankId);
    // print(panNumbers);
    setState(() {
      fdList = fds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved FDs under : "),
      ),
      body: fdList.isEmpty
          ? const Center(
              child: Text("Empty"),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: fdList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor: Colors.green,
                          title: Text(
                            fdList[index]['term_deposit_ac_no'],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return FDDetails(
                                    fdId: fdList[index]['id'],
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
