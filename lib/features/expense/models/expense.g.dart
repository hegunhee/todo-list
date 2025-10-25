// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 2;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as int,
      category: fields[3] as ExpenseCategory,
      status: fields[4] as ExpenseStatus,
      date: fields[5] as DateTime,
      memo: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.memo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 0;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.food;
      case 1:
        return ExpenseCategory.transport;
      case 2:
        return ExpenseCategory.shopping;
      case 3:
        return ExpenseCategory.culture;
      default:
        return ExpenseCategory.food;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.food:
        writer.writeByte(0);
        break;
      case ExpenseCategory.transport:
        writer.writeByte(1);
        break;
      case ExpenseCategory.shopping:
        writer.writeByte(2);
        break;
      case ExpenseCategory.culture:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseStatusAdapter extends TypeAdapter<ExpenseStatus> {
  @override
  final int typeId = 1;

  @override
  ExpenseStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseStatus.good;
      case 1:
        return ExpenseStatus.normal;
      case 2:
        return ExpenseStatus.regret;
      case 3:
        return ExpenseStatus.bad;
      default:
        return ExpenseStatus.good;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseStatus obj) {
    switch (obj) {
      case ExpenseStatus.good:
        writer.writeByte(0);
        break;
      case ExpenseStatus.normal:
        writer.writeByte(1);
        break;
      case ExpenseStatus.regret:
        writer.writeByte(2);
        break;
      case ExpenseStatus.bad:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
