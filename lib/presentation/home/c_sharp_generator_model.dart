import 'package:web_generator/c_sharp_constants.dart';
import 'package:web_generator/extension/string_extension.dart';

class CSharpGeneratorModel {
  String? input;
  String? output;
  String? prefix;
  String? objectName;
  CSharpGeneratorModel({this.input, this.output});

  String generator({bool includeFromToJson = false}) {
    if (input != null && input?.trim() != '') {
      final lines = input!.split('\n');
      objectName = getObjectName(lines.first);
      var vars = getListVariable(lines);
      var propsList = generatePropsList(lines);
      var baseFromJson = generateBaseFromJson(vars);
      // var propsList = generatePropsList(lines);
      // var jsonResult = generateJsonKey(lines, vars);
      // var initComponent = generatedInit(lines, vars);
      // var copyWithComponent = generatedCopyWith(lines, vars);
      // var fromJson = generatedFromJson(lines, vars);
      // var toJson = generatedToJson(lines, vars);
      // var equatable = generatedEquatable(lines, vars);
      // if (includeFromToJson) {
      //   return '''
      //   class $objectName{
      //     $propsList
      //     $jsonResult
      //     $initComponent
      //     $copyWithComponent
      //   }
      //   extension $objectName: Mappable{
      //     $fromJson
      //     $toJson
      //   }
      //   extension $objectName: Equatable {
      //     $equatable
      //   }
      // ''';
      // } else {
      //   return '''
      //   class $objectName{
      //     $propsList
      //     $initComponent
      //     $copyWithComponent
      //   }
      // ''';
      // }
      //   return '''
      //     class $objectName{
      //       $propsList
      //       $baseFromJson
      //     }
      // ''';
      return baseFromJson;
    }
    return '''
       
    ''';
  }

  String getObjectName(String firstLine) {
    return firstLine
        .split('public class ')
        .last
        .replaceAll('{', '')
        .trim()
        .split(': ')
        .first
        .trim();
  }

  List<Variable> getListVariable(List<String> lines) {
    var vars = <Variable>[];
    for (var i = 2; i < lines.length - 1; i++) {
      final line = lines[i].replaceAll(RegExp(' +'), ' ').trimLeft();
      final varType = line.split(' ')[1];
      final varName = line.split(' ')[2];
      final isPrimaryType = (CSharpConstants.allTypes.contains(varType));
      vars.add(
          Variable(name: varName, type: varType, isPrimaryType: isPrimaryType));
    }
    print("Danh sách var: $vars");
    return vars;
  }

  String generatePropsList(List<String> lines) {
    var propsResult = '';
    for (var i = 1; i < lines.length - 1; i++) {
      propsResult += '${lines[i]}\n';
    }
    return propsResult;
  }

  String baseFromJsonCase(List<Variable> vars) {
    var result = "";
    for (var variable in vars) {
      var newCase = '''
         case "$variable":
            var value = properties["valueString"];
            var valueType = properties["valueType"];
            result$objectName.$variable = Constant.getValue(value, valueType);
            break;
            
      ''';
      result += newCase;
    }
    return result;
  }

  String generateBaseFromJson(List<Variable> vars) {
    var declareFunc =
        'public static $objectName baseFromJson(Dictionary<string, dynamic> dictionary)';
    var declareObj = '$objectName returnObj = $objectName();';
    var getPropertiesString =
        'List<Dictionary<string, dynamic>> properties = dictionary[properties];';

    var fromJsonRows = '';
    for (var variable in vars) {
      if (variable.isPrimaryType) {
        var getProperty =
            '''List<Dictionary<string, dynamic>> property${variable.name} = properties.Where(prop => prop['propertyId'] == '${variable.name}';);''';
        fromJsonRows += '''
          $getProperty
          returnObj.${variable.name} = property${variable.name}['valueString'] as ${variable.type};\n
        ''';
      }
    }

    //   return '''
    //   $declareFunc
    //   {
    //     $declareObj
    //     $getPropertiesString
    //     $fromJsonRows
    //   }
    // ''';
    return '''
    $objectName result$objectName = new $objectName();
            foreach (var kv in json)
            {
                if (kv.Key == "${objectName?.lowerFirst()}Id")
                {
                    result$objectName.id = kv.Value;
                }
                if (kv.Key == "properties")
                {
                    List<Dictionary<string, dynamic>> listProperties = new List<Dictionary<string, dynamic>>();
                    JArray jsonItems = kv.Value;
                    foreach (var item in jsonItems)
                    {
                        JObject jObject = (JObject)item;
                        Dictionary<string, dynamic> tempDict = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(jObject.ToString());
                        listProperties.Add(tempDict);
                    }
                    foreach (var properties in listProperties)
                    {
                        switch (properties["propertyId"])
                        {
                            ${baseFromJsonCase(vars)}
                        }
                    }
                }
            }
            return result$objectName;
    ''';
  }

  // String generatedDeclareSyntax(List<String> lines, List<Variable> vars) {
  //   var declareSyntax = '';
  //   for (var i = 0; i < vars.length; i++) {
  //     final variable = vars[i];
  //     if (variable.type.contains('?')) {
  //       declareSyntax += '${variable.name}: ${variable.type} = nil';
  //     } else {
  //       declareSyntax += '${variable.name}: ${variable.type}';
  //     }
  //     declareSyntax += (i == (vars.length - 1)) ? '\n' : ',\n';
  //   }
  //   return declareSyntax;
  // }

  // String generatedInit(List<String> lines, List<Variable> vars) {
  //   //Generated init
  //   var bodyInitSyntax = '';
  //   for (var i = 0; i < vars.length; i++) {
  //     final variable = vars[i];
  //     bodyInitSyntax += 'self.${variable.name} = ${variable.name}';
  //     bodyInitSyntax += '\n';
  //   }
  //   final declareSyntax = generatedDeclareSyntax(lines, vars);
  //   var initResult = '''
  //       internal init(
  //         $declareSyntax){
  //           $bodyInitSyntax
  //           }
  //     ''';
  //   return initResult;
  // }

  // String generateJsonKey(List<String> lines, List<Variable> vars) {
  //   //Generated init
  //   var jsonKeys = '';
  //   for (var i = 0; i < vars.length; i++) {
  //     final variable = vars[i];
  //     jsonKeys += 'case ${variable.name}';
  //     jsonKeys += '\n';
  //   }
  //   var jsonResult = '''
  //       enum JSONKeys: String {
  //         $jsonKeys
  //       }
  //     ''';
  //   return jsonResult;
  // }

  // String generatedCopyWith(List<String> lines, List<Variable> vars) {
  //   var bodySyntax = 'return $objectName(\n';
  //   for (var i = 0; i < vars.length; i++) {
  //     final variable = vars[i];
  //     bodySyntax +=
  //         '${variable.name}: ${variable.name} ?? self.${variable.name}';
  //     bodySyntax += (i == (vars.length - 1)) ? '\n' : ',\n';
  //   }
  //   bodySyntax += ')\n';
  //   final declareSyntax = generatedDeclareSyntax(lines, vars);
  //   var copyWithResult = '''
  //     func copyWith(
  //       $declareSyntax
  //     ) -> $objectName {
  //       $bodySyntax
  //     }
  //   ''';
  //   return copyWithResult;
  // }

  // String generatedFromJson(List<String> lines, List<Variable> vars) {
  //   var bodySyntax = '';
  //   for (var i = 0; i < vars.length; i++) {
  //     final variable = vars[i];
  //     bodySyntax +=
  //         '${variable.name} <- map[JSONKeys.${variable.name}.rawValue]\n';
  //   }
  //   var fromJsonResult = '''
  //       init?(map: Map) {

  //       }
  //       mutating func mapping(map: Map) {
  //         $bodySyntax
  //       }
  //   ''';
  //   return fromJsonResult;
  // }

  // String generatedToJson(List<String> lines, List<Variable> vars) {
  //   var bodySyntax = '';
  //   for (var i = 0; i < vars.length; i++) {
  //     final variable = vars[i];
  //     bodySyntax += '''if let ${variable.name} = ${variable.name} {
  //         json[JSONKeys.${variable.name}.rawValue] = ${variable.name}
  //         }
  //       ''';
  //   }
  //   var toJsonResult = '''
  //       func toJSON() -> [String : Any] {
  //       var json: [String : Any] = [String : Any]()
  //         $bodySyntax
  //         return json
  //       }
  //   ''';
  //   return toJsonResult;
  // }

  // String generatedEquatable(List<String> lines, List<Variable> vars) {
  //   var bodySyntax = '';
  //   for (var i = 0; i < vars.length; i++) {
  //     final variable = vars[i];
  //     bodySyntax += 'lhs.${variable.name} == rhs.${variable.name}';
  //     if (i != (vars.length - 1)) {
  //       bodySyntax += ' &&\n';
  //     } else {
  //       bodySyntax += '\n';
  //     }
  //   }
  //   var equaltableResult = '''
  //       public static func ==(lhs: $objectName, rhs: $objectName) -> Bool {
  //         return $bodySyntax
  //       }
  // ''';
  //   return equaltableResult;
  // }
}

class Variable {
  String name;
  String type;
  bool isPrimaryType;
  Variable(
      {required this.name, required this.type, required this.isPrimaryType});
}
