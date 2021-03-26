import 'dart:io';
import 'dart:convert' show JsonEncoder, json;
import 'package:FormatComments/FormatComments.dart';
import 'package:FormatComments/Languages.dart';
import 'package:path/path.dart' as p;

// ignore: library_prefixes
import 'package:FormatComments/FormatComments.dart' as FormatComments;

/// arg[0] - Path to file
/// arg[1] - Line number of comment
/// arg[2] - Total number of characters comment string should be;

final path = p.join(homeDirectory()!, '.config', 'fcomment', 'languages.json');
final Languages langs = Languages();

// ------------------------------------------------- Default Comment Types
// -----------------------------------------------------------------------
final defaultTypes = {
  '.cs': '//',
  '.ps1': '#',
  '.sh': '#',
  '.zsh': '#',
  '.dart': '//',
  '.lua': '--',
};

Future<void> main(List<String> arguments) async {
  try {
    if ((await CheckIfFileExists().catchError((e) => throw Exception('File exists error: $e'))) != true) {
      for (var c in defaultTypes.entries) {
        var lang = Language(ext: c.key, chars: c.value);
        langs.items.add(lang);
      }

      var encoder = JsonEncoder.withIndent('  ');
      var prettyprint = encoder.convert(langs.toJSONEncodable());

      await WriteLanguageFile(prettyprint);
      exit(0);
    }
  } catch (e) {
    print(e.toString());
    exit(0);
  }

  if (arguments.isEmpty) {
    var messageString = '''

    Parameters missing. Please include the following positional parameters:
        Path to file:                 /home/user/project/myfile.cs
        Line number of comment:       127
        Characters in comment string: 75

    Example: ./fcomment /home/user/project/myfile.cs 127 75
    ''';

    print(messageString);
    exit(1);
  }

  var langJson = await ReadLanguageFile().catchError((e) => throw Exception('Inside ReadLanguageFile $e'));

  langs.items = List<Language>.from(
    (langJson as List).map(
      (item) => Language(
        ext: item['ext'],
        chars: item['chars'],
      ),
    ),
  );

  var commentTypes = <String, String>{};
  for (var o in langs.items) {
    commentTypes[o.ext] = o.chars;
  }

  String? filePath;
  int? lineNumber, total;

  try {
    filePath = arguments[0];
    lineNumber = int.parse(arguments[1]);
    total = int.parse(arguments[2]);
  } catch (e) {
    print(e);
  }

  if (filePath != null && lineNumber != null && total != null) {
    await FormatComments.replaceComment(filePath, lineNumber, total, commentTypes);
  } else {
    print('Parameter exists: FilePath: ${filePath != null} LineNumber: ${lineNumber != null} Total: ${total != null}');
  }
}

Future<bool> CheckIfFileExists() async {
  try {
    var f = File(path);
    if (!await f.exists()) {
      await File(path).create(recursive: true);
      print('Creating default language file: $path');
      return false;
    }
  } on Exception catch (e) {
    print('Inside catch: $e');
  }
  return true;
}

Future ReadLanguageFile() async {
  dynamic file;
  try {
    file = json.decode(await File(path).readAsString());
  } on Exception catch (e) {
    print('Inside catch: $e');
  }
  return file;
}

Future<void> WriteLanguageFile(String jsonString) async {
  try {
    await File(path).create();
    var f = File(path);
    if (await f.exists()) {
      await f.writeAsString(jsonString);
    }
  } on Exception catch (e) {
    print('Inside catch: $e');
  }
}
