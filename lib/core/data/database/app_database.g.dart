// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalAccountsTable extends LocalAccounts
    with TableInfo<$LocalAccountsTable, LocalAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loginIdentifierMeta = const VerificationMeta(
    'loginIdentifier',
  );
  @override
  late final GeneratedColumn<String> loginIdentifier = GeneratedColumn<String>(
    'login_identifier',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 320,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [accountId, loginIdentifier, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('login_identifier')) {
      context.handle(
        _loginIdentifierMeta,
        loginIdentifier.isAcceptableOrUnknown(
          data['login_identifier']!,
          _loginIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_loginIdentifierMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId};
  @override
  LocalAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAccount(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      loginIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login_identifier'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalAccountsTable createAlias(String alias) {
    return $LocalAccountsTable(attachedDatabase, alias);
  }
}

class LocalAccount extends DataClass implements Insertable<LocalAccount> {
  final String accountId;
  final String loginIdentifier;
  final DateTime createdAt;
  const LocalAccount({
    required this.accountId,
    required this.loginIdentifier,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['login_identifier'] = Variable<String>(loginIdentifier);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalAccountsCompanion toCompanion(bool nullToAbsent) {
    return LocalAccountsCompanion(
      accountId: Value(accountId),
      loginIdentifier: Value(loginIdentifier),
      createdAt: Value(createdAt),
    );
  }

  factory LocalAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAccount(
      accountId: serializer.fromJson<String>(json['accountId']),
      loginIdentifier: serializer.fromJson<String>(json['loginIdentifier']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'loginIdentifier': serializer.toJson<String>(loginIdentifier),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalAccount copyWith({
    String? accountId,
    String? loginIdentifier,
    DateTime? createdAt,
  }) => LocalAccount(
    accountId: accountId ?? this.accountId,
    loginIdentifier: loginIdentifier ?? this.loginIdentifier,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalAccount copyWithCompanion(LocalAccountsCompanion data) {
    return LocalAccount(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      loginIdentifier: data.loginIdentifier.present
          ? data.loginIdentifier.value
          : this.loginIdentifier,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccount(')
          ..write('accountId: $accountId, ')
          ..write('loginIdentifier: $loginIdentifier, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountId, loginIdentifier, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAccount &&
          other.accountId == this.accountId &&
          other.loginIdentifier == this.loginIdentifier &&
          other.createdAt == this.createdAt);
}

class LocalAccountsCompanion extends UpdateCompanion<LocalAccount> {
  final Value<String> accountId;
  final Value<String> loginIdentifier;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalAccountsCompanion({
    this.accountId = const Value.absent(),
    this.loginIdentifier = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAccountsCompanion.insert({
    required String accountId,
    required String loginIdentifier,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       loginIdentifier = Value(loginIdentifier),
       createdAt = Value(createdAt);
  static Insertable<LocalAccount> custom({
    Expression<String>? accountId,
    Expression<String>? loginIdentifier,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (loginIdentifier != null) 'login_identifier': loginIdentifier,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAccountsCompanion copyWith({
    Value<String>? accountId,
    Value<String>? loginIdentifier,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalAccountsCompanion(
      accountId: accountId ?? this.accountId,
      loginIdentifier: loginIdentifier ?? this.loginIdentifier,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (loginIdentifier.present) {
      map['login_identifier'] = Variable<String>(loginIdentifier.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountsCompanion(')
          ..write('accountId: $accountId, ')
          ..write('loginIdentifier: $loginIdentifier, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CredentialVerifiersTable extends CredentialVerifiers
    with TableInfo<$CredentialVerifiersTable, CredentialVerifier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CredentialVerifiersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_accounts (account_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _algorithmMeta = const VerificationMeta(
    'algorithm',
  );
  @override
  late final GeneratedColumn<String> algorithm = GeneratedColumn<String>(
    'algorithm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (algorithm = \'argon2id\')',
  );
  static const VerificationMeta _algorithmVersionMeta = const VerificationMeta(
    'algorithmVersion',
  );
  @override
  late final GeneratedColumn<String> algorithmVersion = GeneratedColumn<String>(
    'algorithm_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<Uint8List> salt = GeneratedColumn<Uint8List>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _verifierMeta = const VerificationMeta(
    'verifier',
  );
  @override
  late final GeneratedColumn<Uint8List> verifier = GeneratedColumn<Uint8List>(
    'verifier',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryKiBMeta = const VerificationMeta(
    'memoryKiB',
  );
  @override
  late final GeneratedColumn<int> memoryKiB = GeneratedColumn<int>(
    'memory_ki_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (memory_ki_b >= 19456)',
  );
  static const VerificationMeta _iterationsMeta = const VerificationMeta(
    'iterations',
  );
  @override
  late final GeneratedColumn<int> iterations = GeneratedColumn<int>(
    'iterations',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (iterations >= 2)',
  );
  static const VerificationMeta _parallelismMeta = const VerificationMeta(
    'parallelism',
  );
  @override
  late final GeneratedColumn<int> parallelism = GeneratedColumn<int>(
    'parallelism',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (parallelism >= 1)',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    algorithm,
    algorithmVersion,
    salt,
    verifier,
    memoryKiB,
    iterations,
    parallelism,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credential_verifiers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CredentialVerifier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('algorithm')) {
      context.handle(
        _algorithmMeta,
        algorithm.isAcceptableOrUnknown(data['algorithm']!, _algorithmMeta),
      );
    } else if (isInserting) {
      context.missing(_algorithmMeta);
    }
    if (data.containsKey('algorithm_version')) {
      context.handle(
        _algorithmVersionMeta,
        algorithmVersion.isAcceptableOrUnknown(
          data['algorithm_version']!,
          _algorithmVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_algorithmVersionMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('verifier')) {
      context.handle(
        _verifierMeta,
        verifier.isAcceptableOrUnknown(data['verifier']!, _verifierMeta),
      );
    } else if (isInserting) {
      context.missing(_verifierMeta);
    }
    if (data.containsKey('memory_ki_b')) {
      context.handle(
        _memoryKiBMeta,
        memoryKiB.isAcceptableOrUnknown(data['memory_ki_b']!, _memoryKiBMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryKiBMeta);
    }
    if (data.containsKey('iterations')) {
      context.handle(
        _iterationsMeta,
        iterations.isAcceptableOrUnknown(data['iterations']!, _iterationsMeta),
      );
    } else if (isInserting) {
      context.missing(_iterationsMeta);
    }
    if (data.containsKey('parallelism')) {
      context.handle(
        _parallelismMeta,
        parallelism.isAcceptableOrUnknown(
          data['parallelism']!,
          _parallelismMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parallelismMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId};
  @override
  CredentialVerifier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CredentialVerifier(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      algorithm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm'],
      )!,
      algorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm_version'],
      )!,
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}salt'],
      )!,
      verifier: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}verifier'],
      )!,
      memoryKiB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}memory_ki_b'],
      )!,
      iterations: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iterations'],
      )!,
      parallelism: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parallelism'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CredentialVerifiersTable createAlias(String alias) {
    return $CredentialVerifiersTable(attachedDatabase, alias);
  }
}

class CredentialVerifier extends DataClass
    implements Insertable<CredentialVerifier> {
  final String accountId;
  final String algorithm;
  final String algorithmVersion;
  final Uint8List salt;
  final Uint8List verifier;
  final int memoryKiB;
  final int iterations;
  final int parallelism;
  final DateTime updatedAt;
  const CredentialVerifier({
    required this.accountId,
    required this.algorithm,
    required this.algorithmVersion,
    required this.salt,
    required this.verifier,
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['algorithm'] = Variable<String>(algorithm);
    map['algorithm_version'] = Variable<String>(algorithmVersion);
    map['salt'] = Variable<Uint8List>(salt);
    map['verifier'] = Variable<Uint8List>(verifier);
    map['memory_ki_b'] = Variable<int>(memoryKiB);
    map['iterations'] = Variable<int>(iterations);
    map['parallelism'] = Variable<int>(parallelism);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CredentialVerifiersCompanion toCompanion(bool nullToAbsent) {
    return CredentialVerifiersCompanion(
      accountId: Value(accountId),
      algorithm: Value(algorithm),
      algorithmVersion: Value(algorithmVersion),
      salt: Value(salt),
      verifier: Value(verifier),
      memoryKiB: Value(memoryKiB),
      iterations: Value(iterations),
      parallelism: Value(parallelism),
      updatedAt: Value(updatedAt),
    );
  }

  factory CredentialVerifier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CredentialVerifier(
      accountId: serializer.fromJson<String>(json['accountId']),
      algorithm: serializer.fromJson<String>(json['algorithm']),
      algorithmVersion: serializer.fromJson<String>(json['algorithmVersion']),
      salt: serializer.fromJson<Uint8List>(json['salt']),
      verifier: serializer.fromJson<Uint8List>(json['verifier']),
      memoryKiB: serializer.fromJson<int>(json['memoryKiB']),
      iterations: serializer.fromJson<int>(json['iterations']),
      parallelism: serializer.fromJson<int>(json['parallelism']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'algorithm': serializer.toJson<String>(algorithm),
      'algorithmVersion': serializer.toJson<String>(algorithmVersion),
      'salt': serializer.toJson<Uint8List>(salt),
      'verifier': serializer.toJson<Uint8List>(verifier),
      'memoryKiB': serializer.toJson<int>(memoryKiB),
      'iterations': serializer.toJson<int>(iterations),
      'parallelism': serializer.toJson<int>(parallelism),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CredentialVerifier copyWith({
    String? accountId,
    String? algorithm,
    String? algorithmVersion,
    Uint8List? salt,
    Uint8List? verifier,
    int? memoryKiB,
    int? iterations,
    int? parallelism,
    DateTime? updatedAt,
  }) => CredentialVerifier(
    accountId: accountId ?? this.accountId,
    algorithm: algorithm ?? this.algorithm,
    algorithmVersion: algorithmVersion ?? this.algorithmVersion,
    salt: salt ?? this.salt,
    verifier: verifier ?? this.verifier,
    memoryKiB: memoryKiB ?? this.memoryKiB,
    iterations: iterations ?? this.iterations,
    parallelism: parallelism ?? this.parallelism,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CredentialVerifier copyWithCompanion(CredentialVerifiersCompanion data) {
    return CredentialVerifier(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      algorithm: data.algorithm.present ? data.algorithm.value : this.algorithm,
      algorithmVersion: data.algorithmVersion.present
          ? data.algorithmVersion.value
          : this.algorithmVersion,
      salt: data.salt.present ? data.salt.value : this.salt,
      verifier: data.verifier.present ? data.verifier.value : this.verifier,
      memoryKiB: data.memoryKiB.present ? data.memoryKiB.value : this.memoryKiB,
      iterations: data.iterations.present
          ? data.iterations.value
          : this.iterations,
      parallelism: data.parallelism.present
          ? data.parallelism.value
          : this.parallelism,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CredentialVerifier(')
          ..write('accountId: $accountId, ')
          ..write('algorithm: $algorithm, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('salt: $salt, ')
          ..write('verifier: $verifier, ')
          ..write('memoryKiB: $memoryKiB, ')
          ..write('iterations: $iterations, ')
          ..write('parallelism: $parallelism, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    algorithm,
    algorithmVersion,
    $driftBlobEquality.hash(salt),
    $driftBlobEquality.hash(verifier),
    memoryKiB,
    iterations,
    parallelism,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CredentialVerifier &&
          other.accountId == this.accountId &&
          other.algorithm == this.algorithm &&
          other.algorithmVersion == this.algorithmVersion &&
          $driftBlobEquality.equals(other.salt, this.salt) &&
          $driftBlobEquality.equals(other.verifier, this.verifier) &&
          other.memoryKiB == this.memoryKiB &&
          other.iterations == this.iterations &&
          other.parallelism == this.parallelism &&
          other.updatedAt == this.updatedAt);
}

class CredentialVerifiersCompanion extends UpdateCompanion<CredentialVerifier> {
  final Value<String> accountId;
  final Value<String> algorithm;
  final Value<String> algorithmVersion;
  final Value<Uint8List> salt;
  final Value<Uint8List> verifier;
  final Value<int> memoryKiB;
  final Value<int> iterations;
  final Value<int> parallelism;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CredentialVerifiersCompanion({
    this.accountId = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.salt = const Value.absent(),
    this.verifier = const Value.absent(),
    this.memoryKiB = const Value.absent(),
    this.iterations = const Value.absent(),
    this.parallelism = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CredentialVerifiersCompanion.insert({
    required String accountId,
    required String algorithm,
    required String algorithmVersion,
    required Uint8List salt,
    required Uint8List verifier,
    required int memoryKiB,
    required int iterations,
    required int parallelism,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       algorithm = Value(algorithm),
       algorithmVersion = Value(algorithmVersion),
       salt = Value(salt),
       verifier = Value(verifier),
       memoryKiB = Value(memoryKiB),
       iterations = Value(iterations),
       parallelism = Value(parallelism),
       updatedAt = Value(updatedAt);
  static Insertable<CredentialVerifier> custom({
    Expression<String>? accountId,
    Expression<String>? algorithm,
    Expression<String>? algorithmVersion,
    Expression<Uint8List>? salt,
    Expression<Uint8List>? verifier,
    Expression<int>? memoryKiB,
    Expression<int>? iterations,
    Expression<int>? parallelism,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (algorithm != null) 'algorithm': algorithm,
      if (algorithmVersion != null) 'algorithm_version': algorithmVersion,
      if (salt != null) 'salt': salt,
      if (verifier != null) 'verifier': verifier,
      if (memoryKiB != null) 'memory_ki_b': memoryKiB,
      if (iterations != null) 'iterations': iterations,
      if (parallelism != null) 'parallelism': parallelism,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CredentialVerifiersCompanion copyWith({
    Value<String>? accountId,
    Value<String>? algorithm,
    Value<String>? algorithmVersion,
    Value<Uint8List>? salt,
    Value<Uint8List>? verifier,
    Value<int>? memoryKiB,
    Value<int>? iterations,
    Value<int>? parallelism,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CredentialVerifiersCompanion(
      accountId: accountId ?? this.accountId,
      algorithm: algorithm ?? this.algorithm,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      salt: salt ?? this.salt,
      verifier: verifier ?? this.verifier,
      memoryKiB: memoryKiB ?? this.memoryKiB,
      iterations: iterations ?? this.iterations,
      parallelism: parallelism ?? this.parallelism,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<String>(algorithm.value);
    }
    if (algorithmVersion.present) {
      map['algorithm_version'] = Variable<String>(algorithmVersion.value);
    }
    if (salt.present) {
      map['salt'] = Variable<Uint8List>(salt.value);
    }
    if (verifier.present) {
      map['verifier'] = Variable<Uint8List>(verifier.value);
    }
    if (memoryKiB.present) {
      map['memory_ki_b'] = Variable<int>(memoryKiB.value);
    }
    if (iterations.present) {
      map['iterations'] = Variable<int>(iterations.value);
    }
    if (parallelism.present) {
      map['parallelism'] = Variable<int>(parallelism.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CredentialVerifiersCompanion(')
          ..write('accountId: $accountId, ')
          ..write('algorithm: $algorithm, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('salt: $salt, ')
          ..write('verifier: $verifier, ')
          ..write('memoryKiB: $memoryKiB, ')
          ..write('iterations: $iterations, ')
          ..write('parallelism: $parallelism, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _preferenceIdMeta = const VerificationMeta(
    'preferenceId',
  );
  @override
  late final GeneratedColumn<int> preferenceId = GeneratedColumn<int>(
    'preference_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL CHECK (preference_id = 1)',
  );
  static const VerificationMeta _displayLanguageTagMeta =
      const VerificationMeta('displayLanguageTag');
  @override
  late final GeneratedColumn<String> displayLanguageTag =
      GeneratedColumn<String>(
        'display_language_tag',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('en'),
      );
  static const VerificationMeta _selectedRegionIdMeta = const VerificationMeta(
    'selectedRegionId',
  );
  @override
  late final GeneratedColumn<String> selectedRegionId = GeneratedColumn<String>(
    'selected_region_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reducedMotionMeta = const VerificationMeta(
    'reducedMotion',
  );
  @override
  late final GeneratedColumn<bool> reducedMotion = GeneratedColumn<bool>(
    'reduced_motion',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reduced_motion" IN (0, 1))',
    ),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    preferenceId,
    displayLanguageTag,
    selectedRegionId,
    reducedMotion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('preference_id')) {
      context.handle(
        _preferenceIdMeta,
        preferenceId.isAcceptableOrUnknown(
          data['preference_id']!,
          _preferenceIdMeta,
        ),
      );
    }
    if (data.containsKey('display_language_tag')) {
      context.handle(
        _displayLanguageTagMeta,
        displayLanguageTag.isAcceptableOrUnknown(
          data['display_language_tag']!,
          _displayLanguageTagMeta,
        ),
      );
    }
    if (data.containsKey('selected_region_id')) {
      context.handle(
        _selectedRegionIdMeta,
        selectedRegionId.isAcceptableOrUnknown(
          data['selected_region_id']!,
          _selectedRegionIdMeta,
        ),
      );
    }
    if (data.containsKey('reduced_motion')) {
      context.handle(
        _reducedMotionMeta,
        reducedMotion.isAcceptableOrUnknown(
          data['reduced_motion']!,
          _reducedMotionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {preferenceId};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      preferenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preference_id'],
      )!,
      displayLanguageTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_language_tag'],
      )!,
      selectedRegionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_region_id'],
      ),
      reducedMotion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reduced_motion'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final int preferenceId;
  final String displayLanguageTag;
  final String? selectedRegionId;
  final bool? reducedMotion;
  final DateTime updatedAt;
  const UserPreference({
    required this.preferenceId,
    required this.displayLanguageTag,
    this.selectedRegionId,
    this.reducedMotion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['preference_id'] = Variable<int>(preferenceId);
    map['display_language_tag'] = Variable<String>(displayLanguageTag);
    if (!nullToAbsent || selectedRegionId != null) {
      map['selected_region_id'] = Variable<String>(selectedRegionId);
    }
    if (!nullToAbsent || reducedMotion != null) {
      map['reduced_motion'] = Variable<bool>(reducedMotion);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      preferenceId: Value(preferenceId),
      displayLanguageTag: Value(displayLanguageTag),
      selectedRegionId: selectedRegionId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedRegionId),
      reducedMotion: reducedMotion == null && nullToAbsent
          ? const Value.absent()
          : Value(reducedMotion),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      preferenceId: serializer.fromJson<int>(json['preferenceId']),
      displayLanguageTag: serializer.fromJson<String>(
        json['displayLanguageTag'],
      ),
      selectedRegionId: serializer.fromJson<String?>(json['selectedRegionId']),
      reducedMotion: serializer.fromJson<bool?>(json['reducedMotion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'preferenceId': serializer.toJson<int>(preferenceId),
      'displayLanguageTag': serializer.toJson<String>(displayLanguageTag),
      'selectedRegionId': serializer.toJson<String?>(selectedRegionId),
      'reducedMotion': serializer.toJson<bool?>(reducedMotion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserPreference copyWith({
    int? preferenceId,
    String? displayLanguageTag,
    Value<String?> selectedRegionId = const Value.absent(),
    Value<bool?> reducedMotion = const Value.absent(),
    DateTime? updatedAt,
  }) => UserPreference(
    preferenceId: preferenceId ?? this.preferenceId,
    displayLanguageTag: displayLanguageTag ?? this.displayLanguageTag,
    selectedRegionId: selectedRegionId.present
        ? selectedRegionId.value
        : this.selectedRegionId,
    reducedMotion: reducedMotion.present
        ? reducedMotion.value
        : this.reducedMotion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      preferenceId: data.preferenceId.present
          ? data.preferenceId.value
          : this.preferenceId,
      displayLanguageTag: data.displayLanguageTag.present
          ? data.displayLanguageTag.value
          : this.displayLanguageTag,
      selectedRegionId: data.selectedRegionId.present
          ? data.selectedRegionId.value
          : this.selectedRegionId,
      reducedMotion: data.reducedMotion.present
          ? data.reducedMotion.value
          : this.reducedMotion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('preferenceId: $preferenceId, ')
          ..write('displayLanguageTag: $displayLanguageTag, ')
          ..write('selectedRegionId: $selectedRegionId, ')
          ..write('reducedMotion: $reducedMotion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    preferenceId,
    displayLanguageTag,
    selectedRegionId,
    reducedMotion,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.preferenceId == this.preferenceId &&
          other.displayLanguageTag == this.displayLanguageTag &&
          other.selectedRegionId == this.selectedRegionId &&
          other.reducedMotion == this.reducedMotion &&
          other.updatedAt == this.updatedAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<int> preferenceId;
  final Value<String> displayLanguageTag;
  final Value<String?> selectedRegionId;
  final Value<bool?> reducedMotion;
  final Value<DateTime> updatedAt;
  const UserPreferencesCompanion({
    this.preferenceId = const Value.absent(),
    this.displayLanguageTag = const Value.absent(),
    this.selectedRegionId = const Value.absent(),
    this.reducedMotion = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    this.preferenceId = const Value.absent(),
    this.displayLanguageTag = const Value.absent(),
    this.selectedRegionId = const Value.absent(),
    this.reducedMotion = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<UserPreference> custom({
    Expression<int>? preferenceId,
    Expression<String>? displayLanguageTag,
    Expression<String>? selectedRegionId,
    Expression<bool>? reducedMotion,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (preferenceId != null) 'preference_id': preferenceId,
      if (displayLanguageTag != null)
        'display_language_tag': displayLanguageTag,
      if (selectedRegionId != null) 'selected_region_id': selectedRegionId,
      if (reducedMotion != null) 'reduced_motion': reducedMotion,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<int>? preferenceId,
    Value<String>? displayLanguageTag,
    Value<String?>? selectedRegionId,
    Value<bool?>? reducedMotion,
    Value<DateTime>? updatedAt,
  }) {
    return UserPreferencesCompanion(
      preferenceId: preferenceId ?? this.preferenceId,
      displayLanguageTag: displayLanguageTag ?? this.displayLanguageTag,
      selectedRegionId: selectedRegionId ?? this.selectedRegionId,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (preferenceId.present) {
      map['preference_id'] = Variable<int>(preferenceId.value);
    }
    if (displayLanguageTag.present) {
      map['display_language_tag'] = Variable<String>(displayLanguageTag.value);
    }
    if (selectedRegionId.present) {
      map['selected_region_id'] = Variable<String>(selectedRegionId.value);
    }
    if (reducedMotion.present) {
      map['reduced_motion'] = Variable<bool>(reducedMotion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('preferenceId: $preferenceId, ')
          ..write('displayLanguageTag: $displayLanguageTag, ')
          ..write('selectedRegionId: $selectedRegionId, ')
          ..write('reducedMotion: $reducedMotion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FootprintEstimatesTable extends FootprintEstimates
    with TableInfo<$FootprintEstimatesTable, FootprintEstimate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FootprintEstimatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _estimateIdMeta = const VerificationMeta(
    'estimateId',
  );
  @override
  late final GeneratedColumn<String> estimateId = GeneratedColumn<String>(
    'estimate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerAccountIdMeta = const VerificationMeta(
    'ownerAccountId',
  );
  @override
  late final GeneratedColumn<String> ownerAccountId = GeneratedColumn<String>(
    'owner_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_accounts (account_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta(
    'periodEnd',
  );
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
    'period_end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answersMeta = const VerificationMeta(
    'answers',
  );
  @override
  late final GeneratedColumn<String> answers = GeneratedColumn<String>(
    'answers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimateValueMeta = const VerificationMeta(
    'estimateValue',
  );
  @override
  late final GeneratedColumn<double> estimateValue = GeneratedColumn<double>(
    'estimate_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (estimate_value >= 0)',
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionnaireVersionMeta =
      const VerificationMeta('questionnaireVersion');
  @override
  late final GeneratedColumn<String> questionnaireVersion =
      GeneratedColumn<String>(
        'questionnaire_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _completionStateMeta = const VerificationMeta(
    'completionState',
  );
  @override
  late final GeneratedColumn<String> completionState = GeneratedColumn<String>(
    'completion_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (completion_state IN (\'complete\', \'incomplete\'))',
  );
  static const VerificationMeta _assumptionsMeta = const VerificationMeta(
    'assumptions',
  );
  @override
  late final GeneratedColumn<String> assumptions = GeneratedColumn<String>(
    'assumptions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    estimateId,
    ownerAccountId,
    createdAt,
    periodStart,
    periodEnd,
    answers,
    estimateValue,
    unit,
    questionnaireVersion,
    completionState,
    assumptions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'footprint_estimates';
  @override
  VerificationContext validateIntegrity(
    Insertable<FootprintEstimate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('estimate_id')) {
      context.handle(
        _estimateIdMeta,
        estimateId.isAcceptableOrUnknown(data['estimate_id']!, _estimateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_estimateIdMeta);
    }
    if (data.containsKey('owner_account_id')) {
      context.handle(
        _ownerAccountIdMeta,
        ownerAccountId.isAcceptableOrUnknown(
          data['owner_account_id']!,
          _ownerAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(
        _periodEndMeta,
        periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta),
      );
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('answers')) {
      context.handle(
        _answersMeta,
        answers.isAcceptableOrUnknown(data['answers']!, _answersMeta),
      );
    } else if (isInserting) {
      context.missing(_answersMeta);
    }
    if (data.containsKey('estimate_value')) {
      context.handle(
        _estimateValueMeta,
        estimateValue.isAcceptableOrUnknown(
          data['estimate_value']!,
          _estimateValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimateValueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('questionnaire_version')) {
      context.handle(
        _questionnaireVersionMeta,
        questionnaireVersion.isAcceptableOrUnknown(
          data['questionnaire_version']!,
          _questionnaireVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionnaireVersionMeta);
    }
    if (data.containsKey('completion_state')) {
      context.handle(
        _completionStateMeta,
        completionState.isAcceptableOrUnknown(
          data['completion_state']!,
          _completionStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completionStateMeta);
    }
    if (data.containsKey('assumptions')) {
      context.handle(
        _assumptionsMeta,
        assumptions.isAcceptableOrUnknown(
          data['assumptions']!,
          _assumptionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assumptionsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {estimateId};
  @override
  FootprintEstimate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FootprintEstimate(
      estimateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estimate_id'],
      )!,
      ownerAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_account_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
      periodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_end'],
      )!,
      answers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers'],
      )!,
      estimateValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimate_value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      questionnaireVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}questionnaire_version'],
      )!,
      completionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_state'],
      )!,
      assumptions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assumptions'],
      )!,
    );
  }

  @override
  $FootprintEstimatesTable createAlias(String alias) {
    return $FootprintEstimatesTable(attachedDatabase, alias);
  }
}

class FootprintEstimate extends DataClass
    implements Insertable<FootprintEstimate> {
  final String estimateId;
  final String? ownerAccountId;
  final DateTime createdAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String answers;
  final double estimateValue;
  final String unit;
  final String questionnaireVersion;
  final String completionState;
  final String assumptions;
  const FootprintEstimate({
    required this.estimateId,
    this.ownerAccountId,
    required this.createdAt,
    required this.periodStart,
    required this.periodEnd,
    required this.answers,
    required this.estimateValue,
    required this.unit,
    required this.questionnaireVersion,
    required this.completionState,
    required this.assumptions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['estimate_id'] = Variable<String>(estimateId);
    if (!nullToAbsent || ownerAccountId != null) {
      map['owner_account_id'] = Variable<String>(ownerAccountId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['period_end'] = Variable<DateTime>(periodEnd);
    map['answers'] = Variable<String>(answers);
    map['estimate_value'] = Variable<double>(estimateValue);
    map['unit'] = Variable<String>(unit);
    map['questionnaire_version'] = Variable<String>(questionnaireVersion);
    map['completion_state'] = Variable<String>(completionState);
    map['assumptions'] = Variable<String>(assumptions);
    return map;
  }

  FootprintEstimatesCompanion toCompanion(bool nullToAbsent) {
    return FootprintEstimatesCompanion(
      estimateId: Value(estimateId),
      ownerAccountId: ownerAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerAccountId),
      createdAt: Value(createdAt),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      answers: Value(answers),
      estimateValue: Value(estimateValue),
      unit: Value(unit),
      questionnaireVersion: Value(questionnaireVersion),
      completionState: Value(completionState),
      assumptions: Value(assumptions),
    );
  }

  factory FootprintEstimate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FootprintEstimate(
      estimateId: serializer.fromJson<String>(json['estimateId']),
      ownerAccountId: serializer.fromJson<String?>(json['ownerAccountId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime>(json['periodEnd']),
      answers: serializer.fromJson<String>(json['answers']),
      estimateValue: serializer.fromJson<double>(json['estimateValue']),
      unit: serializer.fromJson<String>(json['unit']),
      questionnaireVersion: serializer.fromJson<String>(
        json['questionnaireVersion'],
      ),
      completionState: serializer.fromJson<String>(json['completionState']),
      assumptions: serializer.fromJson<String>(json['assumptions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'estimateId': serializer.toJson<String>(estimateId),
      'ownerAccountId': serializer.toJson<String?>(ownerAccountId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime>(periodEnd),
      'answers': serializer.toJson<String>(answers),
      'estimateValue': serializer.toJson<double>(estimateValue),
      'unit': serializer.toJson<String>(unit),
      'questionnaireVersion': serializer.toJson<String>(questionnaireVersion),
      'completionState': serializer.toJson<String>(completionState),
      'assumptions': serializer.toJson<String>(assumptions),
    };
  }

  FootprintEstimate copyWith({
    String? estimateId,
    Value<String?> ownerAccountId = const Value.absent(),
    DateTime? createdAt,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? answers,
    double? estimateValue,
    String? unit,
    String? questionnaireVersion,
    String? completionState,
    String? assumptions,
  }) => FootprintEstimate(
    estimateId: estimateId ?? this.estimateId,
    ownerAccountId: ownerAccountId.present
        ? ownerAccountId.value
        : this.ownerAccountId,
    createdAt: createdAt ?? this.createdAt,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    answers: answers ?? this.answers,
    estimateValue: estimateValue ?? this.estimateValue,
    unit: unit ?? this.unit,
    questionnaireVersion: questionnaireVersion ?? this.questionnaireVersion,
    completionState: completionState ?? this.completionState,
    assumptions: assumptions ?? this.assumptions,
  );
  FootprintEstimate copyWithCompanion(FootprintEstimatesCompanion data) {
    return FootprintEstimate(
      estimateId: data.estimateId.present
          ? data.estimateId.value
          : this.estimateId,
      ownerAccountId: data.ownerAccountId.present
          ? data.ownerAccountId.value
          : this.ownerAccountId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      answers: data.answers.present ? data.answers.value : this.answers,
      estimateValue: data.estimateValue.present
          ? data.estimateValue.value
          : this.estimateValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      questionnaireVersion: data.questionnaireVersion.present
          ? data.questionnaireVersion.value
          : this.questionnaireVersion,
      completionState: data.completionState.present
          ? data.completionState.value
          : this.completionState,
      assumptions: data.assumptions.present
          ? data.assumptions.value
          : this.assumptions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FootprintEstimate(')
          ..write('estimateId: $estimateId, ')
          ..write('ownerAccountId: $ownerAccountId, ')
          ..write('createdAt: $createdAt, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('answers: $answers, ')
          ..write('estimateValue: $estimateValue, ')
          ..write('unit: $unit, ')
          ..write('questionnaireVersion: $questionnaireVersion, ')
          ..write('completionState: $completionState, ')
          ..write('assumptions: $assumptions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    estimateId,
    ownerAccountId,
    createdAt,
    periodStart,
    periodEnd,
    answers,
    estimateValue,
    unit,
    questionnaireVersion,
    completionState,
    assumptions,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FootprintEstimate &&
          other.estimateId == this.estimateId &&
          other.ownerAccountId == this.ownerAccountId &&
          other.createdAt == this.createdAt &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.answers == this.answers &&
          other.estimateValue == this.estimateValue &&
          other.unit == this.unit &&
          other.questionnaireVersion == this.questionnaireVersion &&
          other.completionState == this.completionState &&
          other.assumptions == this.assumptions);
}

class FootprintEstimatesCompanion extends UpdateCompanion<FootprintEstimate> {
  final Value<String> estimateId;
  final Value<String?> ownerAccountId;
  final Value<DateTime> createdAt;
  final Value<DateTime> periodStart;
  final Value<DateTime> periodEnd;
  final Value<String> answers;
  final Value<double> estimateValue;
  final Value<String> unit;
  final Value<String> questionnaireVersion;
  final Value<String> completionState;
  final Value<String> assumptions;
  final Value<int> rowid;
  const FootprintEstimatesCompanion({
    this.estimateId = const Value.absent(),
    this.ownerAccountId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.answers = const Value.absent(),
    this.estimateValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.questionnaireVersion = const Value.absent(),
    this.completionState = const Value.absent(),
    this.assumptions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FootprintEstimatesCompanion.insert({
    required String estimateId,
    this.ownerAccountId = const Value.absent(),
    required DateTime createdAt,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String answers,
    required double estimateValue,
    required String unit,
    required String questionnaireVersion,
    required String completionState,
    required String assumptions,
    this.rowid = const Value.absent(),
  }) : estimateId = Value(estimateId),
       createdAt = Value(createdAt),
       periodStart = Value(periodStart),
       periodEnd = Value(periodEnd),
       answers = Value(answers),
       estimateValue = Value(estimateValue),
       unit = Value(unit),
       questionnaireVersion = Value(questionnaireVersion),
       completionState = Value(completionState),
       assumptions = Value(assumptions);
  static Insertable<FootprintEstimate> custom({
    Expression<String>? estimateId,
    Expression<String>? ownerAccountId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<String>? answers,
    Expression<double>? estimateValue,
    Expression<String>? unit,
    Expression<String>? questionnaireVersion,
    Expression<String>? completionState,
    Expression<String>? assumptions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (estimateId != null) 'estimate_id': estimateId,
      if (ownerAccountId != null) 'owner_account_id': ownerAccountId,
      if (createdAt != null) 'created_at': createdAt,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (answers != null) 'answers': answers,
      if (estimateValue != null) 'estimate_value': estimateValue,
      if (unit != null) 'unit': unit,
      if (questionnaireVersion != null)
        'questionnaire_version': questionnaireVersion,
      if (completionState != null) 'completion_state': completionState,
      if (assumptions != null) 'assumptions': assumptions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FootprintEstimatesCompanion copyWith({
    Value<String>? estimateId,
    Value<String?>? ownerAccountId,
    Value<DateTime>? createdAt,
    Value<DateTime>? periodStart,
    Value<DateTime>? periodEnd,
    Value<String>? answers,
    Value<double>? estimateValue,
    Value<String>? unit,
    Value<String>? questionnaireVersion,
    Value<String>? completionState,
    Value<String>? assumptions,
    Value<int>? rowid,
  }) {
    return FootprintEstimatesCompanion(
      estimateId: estimateId ?? this.estimateId,
      ownerAccountId: ownerAccountId ?? this.ownerAccountId,
      createdAt: createdAt ?? this.createdAt,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      answers: answers ?? this.answers,
      estimateValue: estimateValue ?? this.estimateValue,
      unit: unit ?? this.unit,
      questionnaireVersion: questionnaireVersion ?? this.questionnaireVersion,
      completionState: completionState ?? this.completionState,
      assumptions: assumptions ?? this.assumptions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (estimateId.present) {
      map['estimate_id'] = Variable<String>(estimateId.value);
    }
    if (ownerAccountId.present) {
      map['owner_account_id'] = Variable<String>(ownerAccountId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (answers.present) {
      map['answers'] = Variable<String>(answers.value);
    }
    if (estimateValue.present) {
      map['estimate_value'] = Variable<double>(estimateValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (questionnaireVersion.present) {
      map['questionnaire_version'] = Variable<String>(
        questionnaireVersion.value,
      );
    }
    if (completionState.present) {
      map['completion_state'] = Variable<String>(completionState.value);
    }
    if (assumptions.present) {
      map['assumptions'] = Variable<String>(assumptions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FootprintEstimatesCompanion(')
          ..write('estimateId: $estimateId, ')
          ..write('ownerAccountId: $ownerAccountId, ')
          ..write('createdAt: $createdAt, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('answers: $answers, ')
          ..write('estimateValue: $estimateValue, ')
          ..write('unit: $unit, ')
          ..write('questionnaireVersion: $questionnaireVersion, ')
          ..write('completionState: $completionState, ')
          ..write('assumptions: $assumptions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalAccountsTable localAccounts = $LocalAccountsTable(this);
  late final $CredentialVerifiersTable credentialVerifiers =
      $CredentialVerifiersTable(this);
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  late final $FootprintEstimatesTable footprintEstimates =
      $FootprintEstimatesTable(this);
  late final Index localAccountsLoginIdentifierUnique = Index(
    'local_accounts_login_identifier_unique',
    'CREATE UNIQUE INDEX local_accounts_login_identifier_unique ON local_accounts (login_identifier)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localAccounts,
    credentialVerifiers,
    userPreferences,
    footprintEstimates,
    localAccountsLoginIdentifierUnique,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credential_verifiers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('footprint_estimates', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LocalAccountsTableCreateCompanionBuilder =
    LocalAccountsCompanion Function({
      required String accountId,
      required String loginIdentifier,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalAccountsTableUpdateCompanionBuilder =
    LocalAccountsCompanion Function({
      Value<String> accountId,
      Value<String> loginIdentifier,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$LocalAccountsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalAccountsTable, LocalAccount> {
  $$LocalAccountsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CredentialVerifiersTable,
    List<CredentialVerifier>
  >
  _credentialVerifiersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.credentialVerifiers,
        aliasName:
            'local_accounts__account_id__credential_verifiers__account_id',
      );

  $$CredentialVerifiersTableProcessedTableManager get credentialVerifiersRefs {
    final manager =
        $$CredentialVerifiersTableTableManager(
          $_db,
          $_db.credentialVerifiers,
        ).filter(
          (f) => f.accountId.accountId.sqlEquals(
            $_itemColumn<String>('account_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _credentialVerifiersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FootprintEstimatesTable, List<FootprintEstimate>>
  _footprintEstimatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.footprintEstimates,
        aliasName:
            'local_accounts__account_id__footprint_estimates__owner_account_id',
      );

  $$FootprintEstimatesTableProcessedTableManager get footprintEstimatesRefs {
    final manager =
        $$FootprintEstimatesTableTableManager(
          $_db,
          $_db.footprintEstimates,
        ).filter(
          (f) => f.ownerAccountId.accountId.sqlEquals(
            $_itemColumn<String>('account_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _footprintEstimatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loginIdentifier => $composableBuilder(
    column: $table.loginIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> credentialVerifiersRefs(
    Expression<bool> Function($$CredentialVerifiersTableFilterComposer f) f,
  ) {
    final $$CredentialVerifiersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.credentialVerifiers,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CredentialVerifiersTableFilterComposer(
            $db: $db,
            $table: $db.credentialVerifiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> footprintEstimatesRefs(
    Expression<bool> Function($$FootprintEstimatesTableFilterComposer f) f,
  ) {
    final $$FootprintEstimatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.footprintEstimates,
      getReferencedColumn: (t) => t.ownerAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FootprintEstimatesTableFilterComposer(
            $db: $db,
            $table: $db.footprintEstimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loginIdentifier => $composableBuilder(
    column: $table.loginIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get loginIdentifier => $composableBuilder(
    column: $table.loginIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> credentialVerifiersRefs<T extends Object>(
    Expression<T> Function($$CredentialVerifiersTableAnnotationComposer a) f,
  ) {
    final $$CredentialVerifiersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.accountId,
          referencedTable: $db.credentialVerifiers,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CredentialVerifiersTableAnnotationComposer(
                $db: $db,
                $table: $db.credentialVerifiers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> footprintEstimatesRefs<T extends Object>(
    Expression<T> Function($$FootprintEstimatesTableAnnotationComposer a) f,
  ) {
    final $$FootprintEstimatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.accountId,
          referencedTable: $db.footprintEstimates,
          getReferencedColumn: (t) => t.ownerAccountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FootprintEstimatesTableAnnotationComposer(
                $db: $db,
                $table: $db.footprintEstimates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAccountsTable,
          LocalAccount,
          $$LocalAccountsTableFilterComposer,
          $$LocalAccountsTableOrderingComposer,
          $$LocalAccountsTableAnnotationComposer,
          $$LocalAccountsTableCreateCompanionBuilder,
          $$LocalAccountsTableUpdateCompanionBuilder,
          (LocalAccount, $$LocalAccountsTableReferences),
          LocalAccount,
          PrefetchHooks Function({
            bool credentialVerifiersRefs,
            bool footprintEstimatesRefs,
          })
        > {
  $$LocalAccountsTableTableManager(_$AppDatabase db, $LocalAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> loginIdentifier = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountsCompanion(
                accountId: accountId,
                loginIdentifier: loginIdentifier,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String loginIdentifier,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountsCompanion.insert(
                accountId: accountId,
                loginIdentifier: loginIdentifier,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalAccountsTable, LocalAccount>(table),
                  $$LocalAccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                credentialVerifiersRefs = false,
                footprintEstimatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (credentialVerifiersRefs) db.credentialVerifiers,
                    if (footprintEstimatesRefs) db.footprintEstimates,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (credentialVerifiersRefs)
                        await $_getPrefetchedDataByColumns<
                          LocalAccount,
                          $LocalAccountsTable,
                          CredentialVerifier,
                          $CredentialVerifiersTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocalAccountsTableReferences
                              ._credentialVerifiersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).credentialVerifiersRefs,
                          currentColumn: 'account_id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                      if (footprintEstimatesRefs)
                        await $_getPrefetchedDataByColumns<
                          LocalAccount,
                          $LocalAccountsTable,
                          FootprintEstimate,
                          $FootprintEstimatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocalAccountsTableReferences
                              ._footprintEstimatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).footprintEstimatesRefs,
                          currentColumn: 'account_id',
                          referencedColumn: 'owner_account_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAccountsTable,
      LocalAccount,
      $$LocalAccountsTableFilterComposer,
      $$LocalAccountsTableOrderingComposer,
      $$LocalAccountsTableAnnotationComposer,
      $$LocalAccountsTableCreateCompanionBuilder,
      $$LocalAccountsTableUpdateCompanionBuilder,
      (LocalAccount, $$LocalAccountsTableReferences),
      LocalAccount,
      PrefetchHooks Function({
        bool credentialVerifiersRefs,
        bool footprintEstimatesRefs,
      })
    >;
typedef $$CredentialVerifiersTableCreateCompanionBuilder =
    CredentialVerifiersCompanion Function({
      required String accountId,
      required String algorithm,
      required String algorithmVersion,
      required Uint8List salt,
      required Uint8List verifier,
      required int memoryKiB,
      required int iterations,
      required int parallelism,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CredentialVerifiersTableUpdateCompanionBuilder =
    CredentialVerifiersCompanion Function({
      Value<String> accountId,
      Value<String> algorithm,
      Value<String> algorithmVersion,
      Value<Uint8List> salt,
      Value<Uint8List> verifier,
      Value<int> memoryKiB,
      Value<int> iterations,
      Value<int> parallelism,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CredentialVerifiersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CredentialVerifiersTable,
          CredentialVerifier
        > {
  $$CredentialVerifiersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalAccountsTable _accountIdTable(_$AppDatabase db) =>
      db.localAccounts.createAlias(
        'credential_verifiers__account_id__local_accounts__account_id',
      );

  $$LocalAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$LocalAccountsTableTableManager(
      $_db,
      $_db.localAccounts,
    ).filter((f) => f.accountId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CredentialVerifiersTableFilterComposer
    extends Composer<_$AppDatabase, $CredentialVerifiersTable> {
  $$CredentialVerifiersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get verifier => $composableBuilder(
    column: $table.verifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memoryKiB => $composableBuilder(
    column: $table.memoryKiB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parallelism => $composableBuilder(
    column: $table.parallelism,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalAccountsTableFilterComposer get accountId {
    final $$LocalAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.localAccounts,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAccountsTableFilterComposer(
            $db: $db,
            $table: $db.localAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CredentialVerifiersTableOrderingComposer
    extends Composer<_$AppDatabase, $CredentialVerifiersTable> {
  $$CredentialVerifiersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get verifier => $composableBuilder(
    column: $table.verifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memoryKiB => $composableBuilder(
    column: $table.memoryKiB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parallelism => $composableBuilder(
    column: $table.parallelism,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalAccountsTableOrderingComposer get accountId {
    final $$LocalAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.localAccounts,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.localAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CredentialVerifiersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CredentialVerifiersTable> {
  $$CredentialVerifiersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => column);

  GeneratedColumn<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<Uint8List> get verifier =>
      $composableBuilder(column: $table.verifier, builder: (column) => column);

  GeneratedColumn<int> get memoryKiB =>
      $composableBuilder(column: $table.memoryKiB, builder: (column) => column);

  GeneratedColumn<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parallelism => $composableBuilder(
    column: $table.parallelism,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LocalAccountsTableAnnotationComposer get accountId {
    final $$LocalAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.localAccounts,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.localAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CredentialVerifiersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CredentialVerifiersTable,
          CredentialVerifier,
          $$CredentialVerifiersTableFilterComposer,
          $$CredentialVerifiersTableOrderingComposer,
          $$CredentialVerifiersTableAnnotationComposer,
          $$CredentialVerifiersTableCreateCompanionBuilder,
          $$CredentialVerifiersTableUpdateCompanionBuilder,
          (CredentialVerifier, $$CredentialVerifiersTableReferences),
          CredentialVerifier,
          PrefetchHooks Function({bool accountId})
        > {
  $$CredentialVerifiersTableTableManager(
    _$AppDatabase db,
    $CredentialVerifiersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CredentialVerifiersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CredentialVerifiersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CredentialVerifiersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> algorithm = const Value.absent(),
                Value<String> algorithmVersion = const Value.absent(),
                Value<Uint8List> salt = const Value.absent(),
                Value<Uint8List> verifier = const Value.absent(),
                Value<int> memoryKiB = const Value.absent(),
                Value<int> iterations = const Value.absent(),
                Value<int> parallelism = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CredentialVerifiersCompanion(
                accountId: accountId,
                algorithm: algorithm,
                algorithmVersion: algorithmVersion,
                salt: salt,
                verifier: verifier,
                memoryKiB: memoryKiB,
                iterations: iterations,
                parallelism: parallelism,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String algorithm,
                required String algorithmVersion,
                required Uint8List salt,
                required Uint8List verifier,
                required int memoryKiB,
                required int iterations,
                required int parallelism,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CredentialVerifiersCompanion.insert(
                accountId: accountId,
                algorithm: algorithm,
                algorithmVersion: algorithmVersion,
                salt: salt,
                verifier: verifier,
                memoryKiB: memoryKiB,
                iterations: iterations,
                parallelism: parallelism,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CredentialVerifiersTable, CredentialVerifier>(
                    table,
                  ),
                  $$CredentialVerifiersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$CredentialVerifiersTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$CredentialVerifiersTableReferences
                            ._accountIdTable(db)
                            .accountId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CredentialVerifiersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CredentialVerifiersTable,
      CredentialVerifier,
      $$CredentialVerifiersTableFilterComposer,
      $$CredentialVerifiersTableOrderingComposer,
      $$CredentialVerifiersTableAnnotationComposer,
      $$CredentialVerifiersTableCreateCompanionBuilder,
      $$CredentialVerifiersTableUpdateCompanionBuilder,
      (CredentialVerifier, $$CredentialVerifiersTableReferences),
      CredentialVerifier,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> preferenceId,
      Value<String> displayLanguageTag,
      Value<String?> selectedRegionId,
      Value<bool?> reducedMotion,
      required DateTime updatedAt,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> preferenceId,
      Value<String> displayLanguageTag,
      Value<String?> selectedRegionId,
      Value<bool?> reducedMotion,
      Value<DateTime> updatedAt,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get preferenceId => $composableBuilder(
    column: $table.preferenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayLanguageTag => $composableBuilder(
    column: $table.displayLanguageTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedRegionId => $composableBuilder(
    column: $table.selectedRegionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reducedMotion => $composableBuilder(
    column: $table.reducedMotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get preferenceId => $composableBuilder(
    column: $table.preferenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayLanguageTag => $composableBuilder(
    column: $table.displayLanguageTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedRegionId => $composableBuilder(
    column: $table.selectedRegionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reducedMotion => $composableBuilder(
    column: $table.reducedMotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get preferenceId => $composableBuilder(
    column: $table.preferenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayLanguageTag => $composableBuilder(
    column: $table.displayLanguageTag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedRegionId => $composableBuilder(
    column: $table.selectedRegionId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reducedMotion => $composableBuilder(
    column: $table.reducedMotion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreference,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreference
            >,
          ),
          UserPreference,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> preferenceId = const Value.absent(),
                Value<String> displayLanguageTag = const Value.absent(),
                Value<String?> selectedRegionId = const Value.absent(),
                Value<bool?> reducedMotion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserPreferencesCompanion(
                preferenceId: preferenceId,
                displayLanguageTag: displayLanguageTag,
                selectedRegionId: selectedRegionId,
                reducedMotion: reducedMotion,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> preferenceId = const Value.absent(),
                Value<String> displayLanguageTag = const Value.absent(),
                Value<String?> selectedRegionId = const Value.absent(),
                Value<bool?> reducedMotion = const Value.absent(),
                required DateTime updatedAt,
              }) => UserPreferencesCompanion.insert(
                preferenceId: preferenceId,
                displayLanguageTag: displayLanguageTag,
                selectedRegionId: selectedRegionId,
                reducedMotion: reducedMotion,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserPreferencesTable, UserPreference>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserPreferencesTable,
                    UserPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreference,
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>,
      ),
      UserPreference,
      PrefetchHooks Function()
    >;
typedef $$FootprintEstimatesTableCreateCompanionBuilder =
    FootprintEstimatesCompanion Function({
      required String estimateId,
      Value<String?> ownerAccountId,
      required DateTime createdAt,
      required DateTime periodStart,
      required DateTime periodEnd,
      required String answers,
      required double estimateValue,
      required String unit,
      required String questionnaireVersion,
      required String completionState,
      required String assumptions,
      Value<int> rowid,
    });
typedef $$FootprintEstimatesTableUpdateCompanionBuilder =
    FootprintEstimatesCompanion Function({
      Value<String> estimateId,
      Value<String?> ownerAccountId,
      Value<DateTime> createdAt,
      Value<DateTime> periodStart,
      Value<DateTime> periodEnd,
      Value<String> answers,
      Value<double> estimateValue,
      Value<String> unit,
      Value<String> questionnaireVersion,
      Value<String> completionState,
      Value<String> assumptions,
      Value<int> rowid,
    });

final class $$FootprintEstimatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FootprintEstimatesTable,
          FootprintEstimate
        > {
  $$FootprintEstimatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalAccountsTable _ownerAccountIdTable(_$AppDatabase db) =>
      db.localAccounts.createAlias(
        'footprint_estimates__owner_account_id__local_accounts__account_id',
      );

  $$LocalAccountsTableProcessedTableManager? get ownerAccountId {
    final $_column = $_itemColumn<String>('owner_account_id');
    if ($_column == null) return null;
    final manager = $$LocalAccountsTableTableManager(
      $_db,
      $_db.localAccounts,
    ).filter((f) => f.accountId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FootprintEstimatesTableFilterComposer
    extends Composer<_$AppDatabase, $FootprintEstimatesTable> {
  $$FootprintEstimatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get estimateId => $composableBuilder(
    column: $table.estimateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimateValue => $composableBuilder(
    column: $table.estimateValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionnaireVersion => $composableBuilder(
    column: $table.questionnaireVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionState => $composableBuilder(
    column: $table.completionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assumptions => $composableBuilder(
    column: $table.assumptions,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalAccountsTableFilterComposer get ownerAccountId {
    final $$LocalAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerAccountId,
      referencedTable: $db.localAccounts,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAccountsTableFilterComposer(
            $db: $db,
            $table: $db.localAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FootprintEstimatesTableOrderingComposer
    extends Composer<_$AppDatabase, $FootprintEstimatesTable> {
  $$FootprintEstimatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get estimateId => $composableBuilder(
    column: $table.estimateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimateValue => $composableBuilder(
    column: $table.estimateValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionnaireVersion => $composableBuilder(
    column: $table.questionnaireVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionState => $composableBuilder(
    column: $table.completionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assumptions => $composableBuilder(
    column: $table.assumptions,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalAccountsTableOrderingComposer get ownerAccountId {
    final $$LocalAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerAccountId,
      referencedTable: $db.localAccounts,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.localAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FootprintEstimatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FootprintEstimatesTable> {
  $$FootprintEstimatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get estimateId => $composableBuilder(
    column: $table.estimateId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<String> get answers =>
      $composableBuilder(column: $table.answers, builder: (column) => column);

  GeneratedColumn<double> get estimateValue => $composableBuilder(
    column: $table.estimateValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get questionnaireVersion => $composableBuilder(
    column: $table.questionnaireVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completionState => $composableBuilder(
    column: $table.completionState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assumptions => $composableBuilder(
    column: $table.assumptions,
    builder: (column) => column,
  );

  $$LocalAccountsTableAnnotationComposer get ownerAccountId {
    final $$LocalAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerAccountId,
      referencedTable: $db.localAccounts,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.localAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FootprintEstimatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FootprintEstimatesTable,
          FootprintEstimate,
          $$FootprintEstimatesTableFilterComposer,
          $$FootprintEstimatesTableOrderingComposer,
          $$FootprintEstimatesTableAnnotationComposer,
          $$FootprintEstimatesTableCreateCompanionBuilder,
          $$FootprintEstimatesTableUpdateCompanionBuilder,
          (FootprintEstimate, $$FootprintEstimatesTableReferences),
          FootprintEstimate,
          PrefetchHooks Function({bool ownerAccountId})
        > {
  $$FootprintEstimatesTableTableManager(
    _$AppDatabase db,
    $FootprintEstimatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FootprintEstimatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FootprintEstimatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FootprintEstimatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> estimateId = const Value.absent(),
                Value<String?> ownerAccountId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
                Value<DateTime> periodEnd = const Value.absent(),
                Value<String> answers = const Value.absent(),
                Value<double> estimateValue = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> questionnaireVersion = const Value.absent(),
                Value<String> completionState = const Value.absent(),
                Value<String> assumptions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FootprintEstimatesCompanion(
                estimateId: estimateId,
                ownerAccountId: ownerAccountId,
                createdAt: createdAt,
                periodStart: periodStart,
                periodEnd: periodEnd,
                answers: answers,
                estimateValue: estimateValue,
                unit: unit,
                questionnaireVersion: questionnaireVersion,
                completionState: completionState,
                assumptions: assumptions,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String estimateId,
                Value<String?> ownerAccountId = const Value.absent(),
                required DateTime createdAt,
                required DateTime periodStart,
                required DateTime periodEnd,
                required String answers,
                required double estimateValue,
                required String unit,
                required String questionnaireVersion,
                required String completionState,
                required String assumptions,
                Value<int> rowid = const Value.absent(),
              }) => FootprintEstimatesCompanion.insert(
                estimateId: estimateId,
                ownerAccountId: ownerAccountId,
                createdAt: createdAt,
                periodStart: periodStart,
                periodEnd: periodEnd,
                answers: answers,
                estimateValue: estimateValue,
                unit: unit,
                questionnaireVersion: questionnaireVersion,
                completionState: completionState,
                assumptions: assumptions,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FootprintEstimatesTable, FootprintEstimate>(
                    table,
                  ),
                  $$FootprintEstimatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerAccountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ownerAccountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ownerAccountId,
                        referencedTable: $$FootprintEstimatesTableReferences
                            ._ownerAccountIdTable(db),
                        referencedColumn: $$FootprintEstimatesTableReferences
                            ._ownerAccountIdTable(db)
                            .accountId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FootprintEstimatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FootprintEstimatesTable,
      FootprintEstimate,
      $$FootprintEstimatesTableFilterComposer,
      $$FootprintEstimatesTableOrderingComposer,
      $$FootprintEstimatesTableAnnotationComposer,
      $$FootprintEstimatesTableCreateCompanionBuilder,
      $$FootprintEstimatesTableUpdateCompanionBuilder,
      (FootprintEstimate, $$FootprintEstimatesTableReferences),
      FootprintEstimate,
      PrefetchHooks Function({bool ownerAccountId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalAccountsTableTableManager get localAccounts =>
      $$LocalAccountsTableTableManager(_db, _db.localAccounts);
  $$CredentialVerifiersTableTableManager get credentialVerifiers =>
      $$CredentialVerifiersTableTableManager(_db, _db.credentialVerifiers);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$FootprintEstimatesTableTableManager get footprintEstimates =>
      $$FootprintEstimatesTableTableManager(_db, _db.footprintEstimates);
}
