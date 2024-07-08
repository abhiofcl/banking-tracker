import 'dart:io';
// import 'package:path_provider/path_provider.dart';
import 'package:banking_track/database/banking_helper.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import './save_and_open.dart';

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});
}

class PdfApi {
  static Future<File> generateAcNameStatement(
      String accHoldername, int year) async {
    String fyEn = '${year - 1}-04-01';
    String fySt = '${year}-03-31';

    StatementGenerator _statementGenerator = StatementGenerator();
    List<Map<String, dynamic>> data = await _statementGenerator
        .getFDsByAccountHolder(accHoldername, fyEn, fySt);

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        // orientation: pw.PageOrientation.landscape,
        pageFormat: PdfPageFormat.a3,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          String start = '${year - 1}-04-01';
          String fyEnd = '${year}-03-31';
          DateTime startFy = DateTime.parse(start);
          DateTime fyEndDate = DateTime.parse(fyEnd);
          double totalDepositedAmount = data.isNotEmpty
              ? data
                  .where((item) => item['status'] != 'renewed')
                  .map((item) => item['amount_deposited'])
                  .fold(0, (a, b) => a + b)
              : 0;

          double calculateAccruedInterest(Map<String, dynamic> item) {
            final DateFormat dateFormat = DateFormat("dd-MM-yyyy");
            final DateTime formattedBuyDate =
                DateTime.parse(item['date_of_deposit']);
            final DateTime formattedDueDate = DateTime.parse(item['due_date']);
            DateTime startDate =
                formattedBuyDate.isAfter(startFy) ? formattedBuyDate : startFy;
            DateTime endDate = formattedDueDate.isBefore(fyEndDate)
                ? formattedDueDate
                : fyEndDate;
            int days = endDate.difference(startDate).inDays + 1;
            double rateOfInterest = item['rate_of_interest'];
            double amountDeposited = item['amount_deposited'];
            // print(formattedBuyDate);
            // print(formattedDueDate);
            // print(startDate);
            // print(endDate);
            // print(rateOfInterest);
            // print(amountDeposited);
            // print(days);
            // print(accruedInterest);
            return ((amountDeposited * rateOfInterest * days) / (100 * 365))
                .ceil()
                .toDouble();
          }

          double totalAccruedInterest = data.fold(0, (sum, item) {
            return sum + calculateAccruedInterest(item);
          });
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text('Interest Statment for FY: ${year - 1} -  $year',
                      textScaleFactor: 2),
                ],
              ),
            ),
            pw.Row(
              children: <pw.Widget>[
                pw.Text('Account Holder Name:  $accHoldername',
                    textScaleFactor: 1.5),
              ],
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
            ),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>[
                  'Bank account Number',
                  'Term deposit number',
                  'Date of deposit',
                  'Amount deposited',
                  'Rate of Interest',
                  'Due Date',
                  'Interest Accrued',
                  'days'
                ],
                ...data.map((item) {
                  final DateFormat dateFormat = DateFormat("dd-MM-yyyy");
                  final DateTime formattedBuyDate =
                      DateTime.parse(item['date_of_deposit']);
                  final DateTime formattedDueDate =
                      DateTime.parse(item['due_date']);
                  DateTime startDate = formattedBuyDate.isAfter(startFy)
                      ? formattedBuyDate
                      : startFy;
                  DateTime endDate = formattedDueDate.isBefore(fyEndDate)
                      ? formattedDueDate
                      : fyEndDate;
                  int days = endDate.difference(startDate).inDays + 1;
                  // double rateOfInterest = item['rate_of_interest'];
                  // double amountDeposited = item['amount_deposited'];
                  double rateOfInterest = item['rate_of_interest'];
                  double amountDeposited = item['amount_deposited'];
                  double accruedInterest =
                      (amountDeposited * rateOfInterest * days) / (100 * 365);

                  accruedInterest = calculateAccruedInterest(item);
                  return [
                    item['bank_account_number'].toString(),
                    item['term_deposit_ac_no'].toString(),
                    // (DateFormat('dd-MM-yy')
                    //         .format(DateTime.parse(item['buyDate'])))
                    //     .toString(),
                    item['date_of_deposit'].toString(),
                    item['amount_deposited'].toString(),
                    (item['rate_of_interest']).toString(),
                    item['due_date'].toString(),
                    accruedInterest.ceil().toString(),
                    days.toString(),
                  ];
                }),
                <String>[
                  'Total',
                  '',
                  '',
                  totalDepositedAmount.toString(),
                  '',
                  '',
                  totalAccruedInterest.toString(),
                ],
              ],
            ),
          ];
        },
      ),
    );

    return SaveAndOpenDocument.savePdf(name: 'table_pdf.pdf', pdf: pdf);
  }

  static Future<File> generatePanStatement(String panNo, int year) async {
    String fyEn = '${year - 1}-04-01';
    String fySt = '${year}-03-31';
    StatementGenerator _statementGenerator = StatementGenerator();
    List<Map<String, dynamic>> data =
        await _statementGenerator.getFDsByPanNumber(panNo, fyEn, fySt);
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        // orientation: pw.PageOrientation.landscape,
        pageFormat: PdfPageFormat.a3,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          double totalDepositedAmount = data.isNotEmpty
              ? data
                  .where((item) => item['status'] != 'renewed')
                  .map((item) => item['amount_deposited'])
                  .fold(0, (a, b) => a + b)
              : 0;
          String start = '${year - 1}-04-01';
          String fyEnd = '${year}-03-31';
          DateTime startFy = DateTime.parse(start);
          DateTime fyEndDate = DateTime.parse(fyEnd);
          // double totalDepositedAmount = data.isNotEmpty
          //     ? data
          //         .map((item) => item['amount_deposited'])
          //         .reduce((a, b) => a + b)
          //     : 0;

          double calculateAccruedInterest(Map<String, dynamic> item) {
            final DateFormat dateFormat = DateFormat("dd-MM-yyyy");
            final DateTime formattedBuyDate =
                DateTime.parse(item['date_of_deposit']);
            final DateTime formattedDueDate = DateTime.parse(item['due_date']);
            DateTime startDate =
                formattedBuyDate.isAfter(startFy) ? formattedBuyDate : startFy;
            DateTime endDate = formattedDueDate.isBefore(fyEndDate)
                ? formattedDueDate
                : fyEndDate;
            int days = endDate.difference(startDate).inDays + 1;
            double rateOfInterest = item['rate_of_interest'];
            double amountDeposited = item['amount_deposited'];
            // print(formattedBuyDate);
            // print(formattedDueDate);
            // print(startDate);
            // print(endDate);
            // print(rateOfInterest);
            // print(amountDeposited);
            // print(days);
            // print(accruedInterest);
            return ((amountDeposited * rateOfInterest * days) / (100 * 365))
                .ceil()
                .toDouble();
          }

          double totalAccruedInterest = data.fold(0, (sum, item) {
            return sum + calculateAccruedInterest(item);
          });
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text('Interest Statment for FY:  ${year - 1} -  $year',
                      textScaleFactor: 2),
                ],
              ),
            ),
            pw.Row(
              children: <pw.Widget>[
                pw.Text('PAN no: $panNo ', textScaleFactor: 1.5),
              ],
            ),
            // pw.Row(
            //   children: <pw.Widget>[
            //     pw.Text('Client id/Name:  $panNo', textScaleFactor: 1),
            //   ],
            // ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
            ),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>[
                  'Bank \n Account\n Number and Name',
                  'Term\n deposit\n number',
                  'First\n Account\n holder',
                  'Second\n Account\n Holder',
                  'Date of\n deposit',
                  'Amount \ndeposited',
                  'Rate \nOf\n Interest ',
                  'Due Date',
                  'Interest ',
                  'days'
                ],
                ...data.map((item) {
                  final DateFormat dateFormat = DateFormat("dd-MM-yyyy");
                  final DateTime formattedBuyDate =
                      DateTime.parse(item['date_of_deposit']);
                  final DateTime formattedDueDate =
                      DateTime.parse(item['due_date']);
                  DateTime startDate = formattedBuyDate.isAfter(startFy)
                      ? formattedBuyDate
                      : startFy;
                  DateTime endDate = formattedDueDate.isBefore(fyEndDate)
                      ? formattedDueDate
                      : fyEndDate;
                  int days = endDate.difference(startDate).inDays + 1;
                  // double rateOfInterest = item['rate_of_interest'];
                  // double amountDeposited = item['amount_deposited'];
                  double rateOfInterest = item['rate_of_interest'];
                  double amountDeposited = item['amount_deposited'];
                  double accruedInterest =
                      (amountDeposited * rateOfInterest * days) / (100 * 365);

                  accruedInterest = calculateAccruedInterest(item);

                  return [
                    item['bank_account_number'].toString(),
                    item['term_deposit_ac_no'].toString(),
                    item['account_holder_name1'].toString(),
                    item['account_holder_name2'].toString(),
                    item['date_of_deposit'].toString(),
                    item['amount_deposited'].toString(),
                    (item['rate_of_interest']).toString(),
                    item['due_date'].toString(),
                    accruedInterest.ceil().toString(),
                    days.toString()
                  ];
                }),
                <String>[
                  'Total',
                  '',
                  '',
                  '',
                  '',
                  totalDepositedAmount.toString(),
                  '',
                  '',
                  totalAccruedInterest.toString(),
                ],
              ],
            ),
          ];
        },
      ),
    );

    return SaveAndOpenDocument.savePdf(name: 'table_pdf.pdf', pdf: pdf);
  }

  static Future<File> generateBankStatement(
      String bankAccNumber, int year) async {
    String fyEn = '${year - 1}-04-01';
    String fySt = '${year}-03-31';
    StatementGenerator _statementGenerator = StatementGenerator();
    List<Map<String, dynamic>> data =
        await _statementGenerator.getFDsByBankNumber(bankAccNumber, fyEn, fySt);
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        // orientation: pw.PageOrientation.landscape,
        pageFormat: PdfPageFormat.a3,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          // double totalDepositedAmount = data.isNotEmpty
          //     ? data
          //         .map((item) => item['amount_deposited'])
          //         .reduce((a, b) => a + b)
          //     : 0;
          String start = '${year - 1}-04-01';
          String fyEnd = '${year}-03-31';
          DateTime startFy = DateTime.parse(start);
          DateTime fyEndDate = DateTime.parse(fyEnd);
          double totalDepositedAmount = data.isNotEmpty
              ? data
                  .where((item) => item['status'] != 'renewed')
                  .map((item) => item['amount_deposited'])
                  .fold(0, (a, b) => a + b)
              : 0;

          double calculateAccruedInterest(Map<String, dynamic> item) {
            final DateFormat dateFormat = DateFormat("dd-MM-yyyy");
            final DateTime formattedBuyDate =
                DateTime.parse(item['date_of_deposit']);
            final DateTime formattedDueDate = DateTime.parse(item['due_date']);
            DateTime startDate =
                formattedBuyDate.isAfter(startFy) ? formattedBuyDate : startFy;
            DateTime endDate = formattedDueDate.isBefore(fyEndDate)
                ? formattedDueDate
                : fyEndDate;
            int days = endDate.difference(startDate).inDays + 1;
            double rateOfInterest = item['rate_of_interest'];
            double amountDeposited = item['amount_deposited'];
            // print(formattedBuyDate);
            // print(formattedDueDate);
            // print(startDate);
            // print(endDate);
            // print(rateOfInterest);
            // print(amountDeposited);
            // print(days);
            // print(accruedInterest);
            return ((amountDeposited * rateOfInterest * days) / (100 * 365))
                .ceil()
                .toDouble();
          }

          double totalAccruedInterest = data.fold(0, (sum, item) {
            return sum + calculateAccruedInterest(item);
          });

          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text('Interest Statment for FY:  ${year - 1} -  $year',
                      textScaleFactor: 2),
                ],
              ),
            ),
            pw.Row(
              children: <pw.Widget>[
                pw.Text('Bank Name and No:  $bankAccNumber',
                    textScaleFactor: 1.5),
              ],
            ),
            // pw.Row(
            //   children: <pw.Widget>[
            //     pw.Text('Client id/Name:  $bankAccNumber', textScaleFactor: 1),
            //   ],
            // ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
            ),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>[
                  'Bank Account Number',
                  'Term deposit number',
                  'First Account holder',
                  'Second Account Holder',
                  'Date of deposit',
                  'Amount deposited',
                  'Rate of Interest',
                  'Due Date',
                  'Interest Accrued',
                  'days'
                ],
                ...data.map((item) {
                  final DateFormat dateFormat = DateFormat("dd-MM-yyyy");
                  final DateTime formattedBuyDate =
                      DateTime.parse(item['date_of_deposit']);
                  final DateTime formattedDueDate =
                      DateTime.parse(item['due_date']);
                  DateTime startDate = formattedBuyDate.isAfter(startFy)
                      ? formattedBuyDate
                      : startFy;
                  DateTime endDate = formattedDueDate.isBefore(fyEndDate)
                      ? formattedDueDate
                      : fyEndDate;
                  int days = endDate.difference(startDate).inDays + 1;
                  // double rateOfInterest = item['rate_of_interest'];
                  // double amountDeposited = item['amount_deposited'];
                  double rateOfInterest = item['rate_of_interest'];
                  double amountDeposited = item['amount_deposited'];
                  double accruedInterest =
                      (amountDeposited * rateOfInterest * days) / (100 * 365);

                  accruedInterest = calculateAccruedInterest(item);
                  return [
                    item['bank_account_number'].toString(),
                    item['term_deposit_ac_no'].toString(),
                    item['account_holder_name1'].toString(),
                    item['account_holder_name2'].toString(),
                    item['date_of_deposit'].toString(),
                    item['amount_deposited'].toString(),
                    (item['rate_of_interest']).toString(),
                    item['due_date'].toString(),
                    accruedInterest.ceil().toString(),
                    days.toString()
                  ];
                }),
                <String>[
                  'Total',
                  '',
                  '',
                  '',
                  '',
                  totalDepositedAmount.ceil().toString(),
                  '',
                  '',
                  totalAccruedInterest.ceil().toString(),
                ],
              ],
            ),
          ];
        },
      ),
    );

    return SaveAndOpenDocument.savePdf(name: 'table_pdf.pdf', pdf: pdf);
  }
}
