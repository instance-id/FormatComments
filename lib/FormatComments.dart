import 'dart:io';
import 'package:path/path.dart' as p;

import 'Languages.dart';

// --
// final commentType = {
//   '.cs': '//', // 3 refers to the number of characters in '// '
//   '.ps1': '#', // 2 refers to the number of characters in '# '
//   '.sh': '#', // 2 refers to the number of characters in '# '
//   '.zsh': '#', // 2 refers to the number of characters in '# '
// };

// -- Take input comment and create dashes between method name equal to passed parameter
// -------------------------------------------------------------------------------------
String formatText(String str, String cType, {int total = 75}) {
  cType = cType + ' ';
  var chars = cType.length;
  var methodLength = 0;
  var words = str.split('- ');
  var methodName = words[words.length - 1];

  if (methodName.substring(methodName.length - 2, methodName.length - 1) != '-') {
    methodLength = methodName.length;
    methodName = ' ${methodName}';
  } else {
    methodName = '';
  }

  var commentSplit = str.split(cType);
  var preComment = commentSplit[0];
  var paddingAmount = total - methodLength - preComment.length - (chars) - 1;

  if (methodName.isNotEmpty) {
    paddingAmount -= 1;
  }

  var lineStr = '';
  var resultComment = '${commentSplit[0]}$cType${lineStr.padRight(paddingAmount, '-')}$methodName';

  return resultComment;
}

Future<void> replaceComment(String filePath, int lineNumber, int total, Map<String, String> commentType) async {
  final index = lineNumber - 1;
  var f = File(filePath);

  var ext = p.extension(filePath);

  if (await f.exists()) {
    var lines = await f.readAsLines();
    var commentLine = lines[index].toString();
    commentLine = commentLine.trimRight();

    if (commentType.containsKey(ext)) {
      if (!commentLine.contains(commentType[ext]!.toString().trimRight())) {
        print('Line not comment: Exiting');
        exit(0);
      }
    } else {
      print('$ext language is not configured. Please add it to the languages.json file.');
      exit(0);
    }

    var comment = formatText(commentLine, commentType[ext]!, total: total);

    lines.removeAt(index);
    lines.insert(index, comment);
    await f.writeAsString(lines.join('\n'));
  }
}

String? homeDirectory() {
  switch (Platform.operatingSystem) {
    case 'linux':
    case 'macos':
      return Platform.environment['HOME'];
    case 'windows':
      return Platform.environment['USERPROFILE'];
    case 'android':
    // Probably want internal storage.
      return '/storage/sdcard0';
    case 'ios':
    // iOS doesn't really have a home directory.
      return null;
    case 'fuchsia':
    // I have no idea.
      return null;
    default:
      return null;
  }
}