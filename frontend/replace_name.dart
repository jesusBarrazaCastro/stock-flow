import 'dart:io';

void replaceInFile(File file) {
  try {
    String content = file.readAsStringSync();
    String newContent = content.replaceAll('deteccion_placas', 'stock_flow')
        .replaceAll('DeteccionPlacas', 'StockFlow')
        .replaceAll('Deteccion Placas', 'Stock Flow')
        .replaceAll('deteccion-placas', 'stock-flow');

    if (content != newContent) {
      file.writeAsStringSync(newContent);
      print('Updated \${file.path}');
    }
  } catch (e) {
    // Skip unreadable files
  }
}

void processDirectory(Directory dir) {
  var entities = dir.listSync(recursive: false);
  for (var entity in entities) {
    String name = entity.path.split(Platform.pathSeparator).last;
    if (name == '.git' || name == 'build' || name == '.dart_tool') {
      continue;
    }
    if (entity is Directory) {
      processDirectory(entity);
    } else if (entity is File) {
      replaceInFile(entity);
    }
  }
}

void main() {
  Directory dir = Directory('/Users/jesusbarraza/GitHub/stock-flow/frontend/deteccion_placas');
  processDirectory(dir);
}
