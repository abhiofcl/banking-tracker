import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bank_deposits.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Function to delete the entire database for testing purposes only
  // Don't include in production code without warnings!!!!
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bank_deposits.db');
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS PanNumbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pan_number TEXT UNIQUE NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS BankAccounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pan_id INTEGER NOT NULL,
        bank_account_number TEXT NOT NULL,
        FOREIGN KEY (pan_id) REFERENCES PanNumbers (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS FixedDeposits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bank_account_id INTEGER NOT NULL,
        term_deposit_ac_no TEXT NOT NULL,
        date_of_deposit TEXT NOT NULL,
        amount_deposited REAL NOT NULL,
        primary_acc_holder TEXT NOT NULL,
        rate_of_interest REAL NOT NULL,
        due_date TEXT NOT NULL,
        interest_accrued REAL,
        status TEXT,
        FOREIGN KEY (bank_account_id) REFERENCES BankAccounts (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS AccountHolders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fd_id INTEGER NOT NULL,
        account_holder_name TEXT NOT NULL,
        FOREIGN KEY (fd_id) REFERENCES FixedDeposits (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS fy_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fy TEXT 
    )
    ''');
  }
}

class PanNumbersRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertPanNumber(String panNumber) async {
    final db = await _databaseHelper.database;
    int panId = await db.insert(
      'PanNumbers',
      {'pan_number': panNumber},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    if (panId == 0) {
      // Query the PanNumbers table to get the existing PAN number ID
      List<Map<String, dynamic>> existingPan = await db
          .query('PanNumbers', where: 'pan_number = ?', whereArgs: [panNumber]);
      // Update panId to the ID of the existing PAN number
      panId = existingPan.first['id'];
    }
    return panId;
  }

  Future<List<Map<String, dynamic>>> getPanNumbers() async {
    final db = await _databaseHelper.database;
    return await db.query('PanNumbers');
  }

  Future<int> deletePanNumber(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('PanNumbers', where: 'id = ?', whereArgs: [id]);
  }
}

class BankAccountsRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertBankAccount(String bankAccountNumber, int panId) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'BankAccounts',
      {
        'bank_account_number': bankAccountNumber,
        'pan_id': panId,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllBankAccountNumbers() async {
    final db = await _databaseHelper.database;
    return await db.query('BankAccounts',
        distinct: true, columns: ['bank_account_number']);
  }

  Future<List<Map<String, dynamic>>> getBankAccountNumbers(int panId) async {
    final db = await _databaseHelper.database;
    return await db.query(
      'BankAccounts',
      where: 'pan_id = ?',
      whereArgs: [panId],
    );
  }

  Future<List<Map<String, dynamic>>> getBankAccountNumbersByBankNo(
      String bankAccNo) async {
    final db = await _databaseHelper.database;
    return await db.query(
      'BankAccounts',
      where: 'bank_account_number = ?',
      whereArgs: [bankAccNo],
    );
  }

  Future<int> deleteBankAccountNumber(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'BankAccounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class FDRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertFD(String bankAccId, fd) async {
    final db = await _databaseHelper.database;
    int fdId = await db.insert(
      'FixedDeposits',
      fd,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    if (fdId == 0) {
      // Query the PanNumbers table to get the existing PAN number ID
      List<Map<String, dynamic>> existingPan = await db.query('FixedDeposits',
          where: 'bank_account_id = ?', whereArgs: [bankAccId]);
      // Update panId to the ID of the existing PAN number
      fdId = existingPan.first['id'];
    }
    return fdId;
  }

  Future<List<Map<String, dynamic>>> getFD() async {
    final db = await _databaseHelper.database;
    return await db.query('FixedDeposits');
  }

  Future<List<Map<String, dynamic>>> getFDByBankId(int id) async {
    final db = await _databaseHelper.database;
    return await db
        .query('FixedDeposits', where: 'bank_account_id=?', whereArgs: [id]);
  }

  Future<int> updateFD(int id, String date, double roi) async {
    final db = await _databaseHelper.database;
    return await db.update(
        'FixedDeposits', {'due_date': date, 'rate_of_interest': roi},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStatusFD(int id, String status) async {
    final db = await _databaseHelper.database;
    return await db.update('FixedDeposits', {'status': status},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFD(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('FixedDeposits', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getACName() async {
    final db = await _databaseHelper.database;
    return await db.query('FixedDeposits',
        distinct: true, columns: ['primary_acc_holder']);
  }
}

class AccountHolderRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertACName(int fdId, List<String> fd_ids) async {
    final db = await _databaseHelper.database;
    int flagId;
    flagId = await db.insert(
        'AccountHolders', {'fd_id': fdId, 'account_holder_name': fd_ids[0]});
    flagId = await db.insert(
        'AccountHolders', {'fd_id': fdId, 'account_holder_name': fd_ids[1]});
    return flagId;
    // for(){

    // }
    // int ACNameId = await db.insert(
    //   'AccountHolders',
    //   fd,
    //   // conflictAlgorithm: ConflictAlgorithm.ignore,
    // );
    // if (fdId == 0) {
    //   // Query the PanNumbers table to get the existing PAN number ID
    //   List<Map<String, dynamic>> existingPan = await db.query(
    //     'AccountHolders',
    //     where: 'bank_account_id = ?',
    //     whereArgs: [bankAccId],
    //   );
    //   // Update panId to the ID of the existing PAN number
    //   fdId = existingPan.first['id'];
    // }
    // return fdId;
  }

  Future<List<Map<String, dynamic>>> getACName() async {
    final db = await _databaseHelper.database;
    return await db.query('AccountHolders',
        distinct: true, columns: ['account_holder_name']);
  }

  Future<List<Map<String, dynamic>>> getACNameByAccountNumber(int id) async {
    final db = await _databaseHelper.database;
    return await db.query(
      'AccountHolders',
    );
  }

  Future<int> deleteACName(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'AccountHolders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class StatementGenerator {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Future<List<Map<String, dynamic>>> getFDsByAccountHolder(
      String accountHolderName, String year, String start) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT 
          fd.term_deposit_ac_no,
          fd.date_of_deposit,
          fd.amount_deposited,
          fd.rate_of_interest,
          fd.due_date,
          fd.status,
          ba.bank_account_number,
          pn.pan_number,
          ah.account_holder_name
      FROM 
          FixedDeposits fd
      JOIN 
          BankAccounts ba ON fd.bank_account_id = ba.id
      JOIN 
          PanNumbers pn ON ba.pan_id = pn.id
      JOIN 
          AccountHolders ah ON fd.id = ah.fd_id
      WHERE 
          ah.account_holder_name = ? and fd.primary_acc_holder=?  and fd.due_date>=? and fd.date_of_deposit<=?
      ORDER BY ba.bank_account_number,fd.term_deposit_ac_no
    ''', [accountHolderName, accountHolderName, year, start]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getFDsByPanNumber(
      String panNo, String year, String start) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
    SELECT 
        fd.term_deposit_ac_no,
        fd.date_of_deposit,
        fd.amount_deposited,
        fd.rate_of_interest,
        fd.due_date,
        fd.status,
        ba.bank_account_number,
        pn.pan_number,
        ah1.account_holder_name AS account_holder_name1,
        ah2.account_holder_name AS account_holder_name2
    FROM 
        FixedDeposits fd
    JOIN 
        BankAccounts ba ON fd.bank_account_id = ba.id
    JOIN 
        PanNumbers pn ON ba.pan_id = pn.id
    LEFT JOIN 
        AccountHolders ah1 ON fd.id = ah1.fd_id AND ah1.id = (SELECT MIN(id) FROM AccountHolders WHERE fd_id = fd.id)
    LEFT JOIN 
        AccountHolders ah2 ON fd.id = ah2.fd_id AND ah2.id = (SELECT MAX(id) FROM AccountHolders WHERE fd_id = fd.id)
    WHERE 
        pn.pan_number = ? and fd.due_date>=? and fd.date_of_deposit<=?
      ORDER BY ba.bank_account_number,fd.term_deposit_ac_no
  ''', [panNo, year, start]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getFDsByBankNumber(
      String bankAccNo, String year, String start) async {
    final db = await _databaseHelper.database;
    // String fyEnd = '${year + 1}-03-31';
    final result = await db.rawQuery('''
    SELECT 
        fd.term_deposit_ac_no,
        fd.date_of_deposit,
        fd.amount_deposited,
        fd.rate_of_interest,
        fd.due_date,
        fd.status,
        ba.bank_account_number,
        pn.pan_number,
        ah1.account_holder_name AS account_holder_name1,
        ah2.account_holder_name AS account_holder_name2
    FROM 
        FixedDeposits fd
    JOIN 
        BankAccounts ba ON fd.bank_account_id = ba.id
    JOIN 
        PanNumbers pn ON ba.pan_id = pn.id
    LEFT JOIN 
        AccountHolders ah1 ON fd.id = ah1.fd_id AND ah1.id = (SELECT MIN(id) FROM AccountHolders WHERE fd_id = fd.id)
    LEFT JOIN 
        AccountHolders ah2 ON fd.id = ah2.fd_id AND ah2.id = (SELECT MAX(id) FROM AccountHolders WHERE fd_id = fd.id)
    WHERE 
        ba.bank_account_number = ? and fd.due_date>=? and fd.date_of_deposit<=?
      ORDER BY fd.term_deposit_ac_no
  ''', [bankAccNo, year, start]);
    return result;
  }
  // Future<List<Map<String, dynamic>>> getFDsByAccountHolderFY(
  //     String accountHolderName, int year) async {
  //   final db = await _databaseHelper.database;
  //   String start = '$year-03-31';
  //   String end = '${year + 1}-03-31';
  //   final result = await db.rawQuery('''
  //     SELECT
  //         fd.term_deposit_ac_no,
  //         fd.date_of_deposit,
  //         fd.amount_deposited,
  //         fd.rate_of_interest,
  //         fd.due_date,
  //         ba.bank_account_number,
  //         pn.pan_number,
  //         ah.account_holder_name
  //     FROM
  //         FixedDeposits fd
  //     JOIN
  //         BankAccounts ba ON fd.bank_account_id = ba.id
  //     JOIN
  //         PanNumbers pn ON ba.pan_id = pn.id
  //     JOIN
  //         AccountHolders ah ON fd.id = ah.fd_id
  //     WHERE
  //         ah.account_holder_name = ?
  //   ''', [accountHolderName]);

  //   return result;
  // }

  Future<List<Map<String, dynamic>>> getFDS(int fdID) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
SELECT 
  fd.id, 
  fd.term_deposit_ac_no, 
  fd.date_of_deposit, 
  fd.amount_deposited, 
  fd.rate_of_interest, 
  fd.due_date, 
  fd.interest_accrued,
  fd.status, 
  ah1.account_holder_name AS account_holder_name1, 
  ah2.account_holder_name AS account_holder_name2 
FROM 
  FixedDeposits fd
  LEFT JOIN AccountHolders ah1 ON fd.id = ah1.fd_id AND ah1.id IN (
    SELECT id FROM AccountHolders WHERE fd_id = fd.id ORDER BY id LIMIT 1
  )
  LEFT JOIN AccountHolders ah2 ON fd.id = ah2.fd_id AND ah2.id IN (
    SELECT id FROM AccountHolders WHERE fd_id = fd.id ORDER BY id LIMIT 1 OFFSET 1
  )
WHERE 
  fd.bank_account_id = ? 
ORDER BY fd.term_deposit_ac_no

''', [fdID]);
  }
}
