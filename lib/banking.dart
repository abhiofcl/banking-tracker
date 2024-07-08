// import 'package:flutter/material.dart';

// class AddFdScreen extends StatefulWidget {
//   @override
//   _AddFdScreenState createState() => _AddFdScreenState();
// }

// class _AddFdScreenState extends State<AddFdScreen> {
//   final List<TextEditingController> _accountHolderControllers = [];
//   final _dateOfDepositController = TextEditingController();
//   final _amountDepositedController = TextEditingController();
//   final _rateOfInterestController = TextEditingController();
//   final _dueDateController = TextEditingController();
//   final _interestAccruedController = TextEditingController();

//   void _addAccountHolderField() {
//     setState(() {
//       _accountHolderControllers.add(TextEditingController());
//     });
//   }

//   void _submitFd() {
//     final dateOfDeposit = _dateOfDepositController.text;
//     final amountDeposited = double.parse(_amountDepositedController.text);
//     final rateOfInterest = double.parse(_rateOfInterestController.text);
//     final dueDate = _dueDateController.text;
//     final interestAccrued = double.parse(_interestAccruedController.text);
//     final accountHolderNames =
//         _accountHolderControllers.map((controller) => controller.text).toList();

//     // Save FD details and account holder names to the database
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add FD')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _dateOfDepositController,
//               decoration: const InputDecoration(labelText: 'Date of Deposit'),
//             ),
//             TextField(
//               controller: _amountDepositedController,
//               decoration: const InputDecoration(labelText: 'Amount Deposited'),
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               controller: _rateOfInterestController,
//               decoration: const InputDecoration(labelText: 'Rate of Interest'),
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               controller: _dueDateController,
//               decoration: const InputDecoration(labelText: 'Due Date'),
//             ),
//             TextField(
//               controller: _interestAccruedController,
//               decoration: const InputDecoration(labelText: 'Interest Accrued'),
//               keyboardType: TextInputType.number,
//             ),
//             ..._accountHolderControllers.map((controller) {
//               return TextField(
//                 controller: controller,
//                 decoration:
//                     const InputDecoration(labelText: 'Account Holder Name'),
//               );
//             }).toList(),
//             ElevatedButton(
//               onPressed: _addAccountHolderField,
//               child: const Text('Add Account Holder'),
//             ),
//             ElevatedButton(
//               onPressed: _submitFd,
//               child: const Text('Submit'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _dateOfDepositController.dispose();
//     _amountDepositedController.dispose();
//     _rateOfInterestController.dispose();
//     _dueDateController.dispose();
//     _interestAccruedController.dispose();
//     for (var controller in _accountHolderControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
// }
