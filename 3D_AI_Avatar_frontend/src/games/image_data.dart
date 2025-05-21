import 'dart:convert';
import 'package:flutter/services.dart';

class ImageData {
  final int id;
  final String image;
  final String description;

  ImageData({ required this.id, required this.image, required this.description });

  factory ImageData.fromJson(Map<String, dynamic> json) => ImageData(
    id: json['id'],
    image: json['image'],
    description: json['description'],
  );

  static Future<List<ImageData>> loadAll() async {
    final raw = await rootBundle.loadString('assets/data/images.json');
    final List<dynamic> list = json.decode(raw);
    return list.map((e) => ImageData.fromJson(e)).toList();
  }
}

