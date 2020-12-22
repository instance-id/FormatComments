import 'dart:io';
import 'package:path/path.dart' as p;

final commentType = {
  '.cs': {'// ', 3}, // 3 refers to the number of characters in '// '
  '.ps1': {'# ', 2}, // 2 refers to the number of characters in '# '
};

// -- Take input comment and create dashes between method name equal to --
// -- passed parameter ---------------------------------------------------
String formatText(String str, Set<Object> cType, {int total = 75}) {
  var methodLength = 0;
  var words = str.split('- ');
  var methodName = words[words.length - 1];

  if (methodName.substring(methodName.length - 2, methodName.length - 1) != '-') {
    methodLength = methodName.length;
    methodName = ' ${methodName}';
  } else {
    methodName = '';
  }

  var commentSplit = str.split(cType.elementAt(0));
  var preComment = commentSplit[0];
  var paddingAmount = total - methodLength - preComment.length - cType.elementAt(1) - 1;

  if (methodName.isNotEmpty) {
    paddingAmount -= 1;
  }

  var lineStr = '';
  var resultComment = '${commentSplit[0]}${cType.elementAt(0)}${lineStr.padRight(paddingAmount, '-')}${methodName}';

  return resultComment;
}

Future<void> replaceComment(String filePath, int lineNumber, int total) async {
  final index = lineNumber - 1;
  var f = File(filePath);

  var ext = p.extension(filePath);

  if (await f.exists()) {
    var lines = await f.readAsLines();
    var commentLine = lines[index].toString();
    commentLine = commentLine.trimRight();

    if (!commentLine.contains(commentType[ext].elementAt(0).toString().trimRight())) {
      print('Line not comment: Exiting');
      exit(0);
    }

    var comment = formatText(commentLine, commentType[ext], total: total);

    lines.removeAt(index);
    lines.insert(index, comment);
    await f.writeAsString(lines.join('\n'));
  }
}
