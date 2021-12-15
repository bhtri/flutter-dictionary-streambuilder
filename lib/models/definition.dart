import 'package:json_annotation/json_annotation.dart';

part 'definition.g.dart';

@JsonSerializable()
class Definition {
  String type;
  String definition;
  String example;
  String imageUrl;
  String emoji;

  Definition({
    this.type = '',
    this.definition = '',
    this.example = '',
    this.imageUrl = '',
    this.emoji = '',
  });

  factory Definition.fromJson(Map<String, dynamic> json) =>
      _$DefinitionFromJson(json);
}
