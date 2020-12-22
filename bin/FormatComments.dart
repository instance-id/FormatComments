import 'package:FormatComments/FormatComments.dart' as FormatComments;

/// arg[0] - Path to file
/// arg[1] - Line number of comment
/// arg[2] - Total number of characters comment string should be;
void main(List<String> arguments) {
  var filePath = arguments[0];
  var lineNumber = int.parse(arguments[1]);
  var total = int.parse(arguments[2]);

  if (filePath != null && lineNumber != null && total != null) {
    FormatComments.replaceComment(filePath, lineNumber, total);
  } else {
    print('Parameter exists: FilePath: ${filePath != null} LineNumber: ${lineNumber != null} Total: ${total != null}');
  }
}