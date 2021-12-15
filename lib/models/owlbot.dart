import 'package:dictionary/models/definition.dart';
import 'package:json_annotation/json_annotation.dart';

part 'owlbot.g.dart';

@JsonSerializable()
class OwlBot {
  String word;
  String pronunciation;
  List<Definition> definitions;
  String errorMessage;

  OwlBot({
    this.word = '',
    this.pronunciation = '',
    this.definitions = const [],
    this.errorMessage = '',
  });

  factory OwlBot.fromJson(Map<String, dynamic> json) => _$OwlBotFromJson(json);
}
