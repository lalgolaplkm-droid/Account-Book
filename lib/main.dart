import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// ----------------- Models -----------------
class TransactionItem {
  final String id;
  final String type;
  String account;
  String category;
  double amount;
  String description;
  DateTime date;

  TransactionItem({
    required this.id,
    required this.type,
    required this.account,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'account': account,
    'category': category,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
  };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
    id: json['id'],
    type: json['type'],
    account: json['account'],
    category: json['category'],
    amount: json['amount'],
    description: json['description'],
    date: DateTime.parse(json['date']),
  );
}

class LoanItem {
  final String id;
  String personName;
  double amount;
  String type;
  DateTime date;
  bool isPaid;

  LoanItem({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.date,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'personName': personName,
    'amount': amount,
    'type': type,
    'date': date.toIso8601String(),
    'isPaid': isPaid,
  };

  factory LoanItem.fromJson(Map<String, dynamic> json) => LoanItem(
    id: json['id'],
    personName: json['personName'],
    amount: json['amount'],
    type: json['type'],
    date: DateTime.parse(json['date']),
    isPaid: json['isPaid'],
  );
}

class ShoppingItem {
  String name;
  double amount;
  bool isChecked;
  ShoppingItem({required this.name, this.amount = 0.0, this.isChecked = false});

  Map<String, dynamic> toJson() => {'name': name, 'amount': amount, 'isChecked': isChecked};
  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(name: json['name'], amount: json['amount'], isChecked: json['isChecked']);
}

class BudgetModel {
  String category;
  double amount;
  BudgetModel({required this.category, required this.amount});

  Map<String, dynamic> toJson() => {'category': category, 'amount': amount};
  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(category: json['category'], amount: json['amount']);
}

class SavingsModel {
  String title;
  double targetAmount;
  double currentAmount;
  bool isCompleted;
  SavingsModel({required this.title, required this.targetAmount, required this.currentAmount, this.isCompleted = false});

  Map<String, dynamic> toJson() => {'title': title, 'targetAmount': targetAmount, 'currentAmount': currentAmount, 'isCompleted': isCompleted};
  factory SavingsModel.fromJson(Map<String, dynamic> json) => SavingsModel(title: json['title'], targetAmount: json['targetAmount'], currentAmount: json['currentAmount'], isCompleted: json['isCompleted']);
}

class AccountModel {
  String name;
  String type;
  String details;
  bool isDefault;

  AccountModel({
    required this.name,
    required this.type,
    required this.details,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {'name': name, 'type': type, 'details': details, 'isDefault': isDefault};
  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(name: json['name'], type: json['type'], details: json['details'], isDefault: json['isDefault']);
}

class RepeatedTransactionModel {
  String title;
  double amount;
  String frequency;
  RepeatedTransactionModel({required this.title, required this.amount, required this.frequency});

  Map<String, dynamic> toJson() => {'title': title, 'amount': amount, 'frequency': frequency};
  factory RepeatedTransactionModel.fromJson(Map<String, dynamic> json) => RepeatedTransactionModel(title: json['title'], amount: json['amount'], frequency: json['frequency']);
}

class ReminderModel {
  String title;
  double amount;
  String dueDate;
  ReminderModel({required this.title, required this.amount, required this.dueDate});

  Map<String, dynamic> toJson() => {'title': title, 'amount': amount, 'dueDate': dueDate};
  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(title: json['title'], amount: json['amount'], dueDate: json['dueDate']);
}
