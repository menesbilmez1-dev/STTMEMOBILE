import 'package:flutter_test/flutter_test.dart';
import 'package:stt_merve/models/app_config.dart';
import 'package:stt_merve/services/speech_parser_service.dart';

void main() {
  const parser = SpeechParserService();
  final config = AppConfig(
    categories: [
      CategoryConfig(name: '', types: ['SATIŞ']),
      CategoryConfig(name: 'YAĞ SATIŞI', types: ['NAKİT', 'HAVALE', 'K.K']),
      CategoryConfig(name: 'HAK PARASI', types: ['NAKİT', 'HAVALE', 'K.K']),
    ],
  );

  test('splits the example utterance into its configured commands', () {
    final commands = parser.parse(
      'satış Muhiddin dede yağ satışı havale 500.',
      config,
    );

    expect(commands, hasLength(2));
    expect(commands[0].category, '');
    expect(commands[0].type, 'SATIŞ');
    expect(commands[0].value, 'Muhiddin dede');
    expect(commands[1].category, 'YAĞ SATIŞI');
    expect(commands[1].type, 'HAVALE');
    expect(commands[1].value, '500');
  });

  test('matches Turkish dotted and dotless I independent of casing', () {
    final commands = parser.parse(
      'SATIŞ müşteri adı YAĞ SATIŞI K.K 500',
      config,
    );

    expect(commands, hasLength(2));
    expect(commands[0].value, 'müşteri adı');
    expect(commands[1].type, 'K.K');
    expect(commands[1].value, '500');
  });

  test('retains a command value as text until the next category/type pair', () {
    final commands = parser.parse(
      'satış Muhiddin dede 24 YAĞ SATIŞI nakit 500,50',
      config,
    );

    expect(commands, hasLength(2));
    expect(commands[0].value, 'Muhiddin dede 24');
    expect(commands[1].value, '500,50');
  });

  test('returns no commands when the configured markers are absent', () {
    expect(parser.parse('Muhiddin dede 500', config), isEmpty);
  });

  test('returns an incomplete command for later draft review', () {
    final commands = parser.parse('satış', config);

    expect(commands, hasLength(1));
    expect(commands.single.category, '');
    expect(commands.single.type, 'SATIŞ');
    expect(commands.single.value, isEmpty);
  });
}
