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
      var baseToJson = generateBaseToJson(vars);

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
      return '''
        $baseFromJson
        $baseToJson
      ''';
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

  List<VariableCSharp> getListVariable(List<String> lines) {
    var vars = <VariableCSharp>[];
    for (var i = 2; i < lines.length - 1; i++) {
      final line = lines[i].replaceAll(RegExp(' +'), ' ').trimLeft();
      final varType = line.split(' ')[1];
      final varName = line.split(' ')[2];
      VariableType variableType;
      if (CSharpConstants.allTypes.contains(varType)) {
        variableType = VariableType.primaryType;
      } else if (line.contains('//Enum')) {
        variableType = VariableType.enumType;
      } else if (varType.contains('List<')) {
        variableType = VariableType.listObjectType;
      } else {
        variableType = VariableType.objectType;
      }
      vars.add(VariableCSharp(
          name: varName, type: varType, variableType: variableType));
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

  String baseFromJsonCase(List<VariableCSharp> vars) {
    var result = "";
    for (var variable in vars) {
      if (variable.variableType == VariableType.primaryType) {
        var newCase = '''
         case "${variable.name}":
            result$objectName.${variable.name} = Constant.getValue(properties["valueString"], properties["valueType"]);
            break;
            
      ''';
        result += newCase;
      } else if (variable.variableType == VariableType.enumType) {
        var newCase = '''
         case "${variable.name}":
         result$objectName.${variable.name} = (${variable.type})Enum.Parse(typeof(${variable.type}), properties["valueString"], true);
            break;
            
      ''';
        result += newCase;
      } else if (variable.variableType == VariableType.objectType) {
        var newCase = '''
         case "${variable.name}":
          List<Dictionary<string, dynamic>> dict${variable.name} = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, dynamic>>>(properties["valueString"]);
         result$objectName.${variable.name} = dict${variable.name} != null ? ${variable.type.replaceAll('?', '')}.baseFromJson(dDict${variable.name}) : null;
            break;
      ''';
        result += newCase;
      } else {
        var newCase = '''
         case "${variable.name}":
          List<Dictionary<string, dynamic>> listDict${variable.name}s = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, dynamic>>>(properties["valueString"]);
          List<${variable.singleType?.replaceAll('?', '')}> listDict${variable.name}sTemp = new List<${variable.singleType?.replaceAll('?', '')}>();
           if (listDict${variable.name}s != null) {
            foreach (Dictionary<string, dynamic> dict${variable.name} in listDict${variable.name}s)
            {
                ${variable.singleType?.replaceAll('?', '')}? temp = ${variable.singleType?.replaceAll('?', '')}.baseFromJson(dict${variable.name});
                if (temp != null)
                {
                    listDict${variable.name}sTemp.Add(temp);
                }
            }
            result$objectName.${variable.name} = listDict${variable.name}sTemp;
          } else {
            result$objectName.${variable.name} = null;
          }
          break;
      ''';
        result += newCase;
      }
    }
    return result;
  }

  String generateBaseFromJson(List<VariableCSharp> vars) {
    var declareFunc =
        'public static $objectName baseFromJson(Dictionary<string, dynamic> dictionary)';
    var declareObj = '$objectName returnObj = $objectName();';
    var getPropertiesString =
        'List<Dictionary<string, dynamic>> properties = dictionary[properties];';

    var fromJsonRows = '';
    for (var variable in vars) {
      if (variable.variableType == VariableType.primaryType) {
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
    public static $objectName? baseFromJson(Dictionary<string, dynamic> json)
    {
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
    }
    ''';
  }

  String baseToJsonCase(List<VariableCSharp> vars) {
    var result = "";
    var lineValueString = "";
    for (var variable in vars) {
      switch (variable.variableType) {
        case VariableType.primaryType:
        case VariableType.enumType:
          if (variable.type == "string") {
            lineValueString =
                'tempDict["valueString"] = objectModel.${variable.name};';
          } else {
            lineValueString =
                'tempDict["valueString"] = objectModel.${variable.name}.ToString();';
          }
          break;
        case VariableType.objectType:
          lineValueString = '''
            tempDict["valueString"] = ${variable.singleType}.baseToJson(objectModel.${variable.name}).ToString();
          ''';
          break;
        case VariableType.listObjectType:
          lineValueString = '''
            List<Dictionary<string, dynamic>> list${variable.singleTypeNonNull} = new List<Dictionary<string, dynamic>>();
            if (objectModel.${variable.name} != null) {
                foreach (${variable.singleTypeNonNull} ${variable.singleTypeNonNull?.toLowerCase()} in objectModel.${variable.name})
                {
                    Dictionary<string, dynamic>? new${variable.singleTypeNonNull}Dict = ${variable.singleTypeNonNull}.baseToJson(${variable.singleTypeNonNull?.toLowerCase()});
                    if (new${variable.singleTypeNonNull}Dict != null) {
                      list${variable.singleType}.Add(new${variable.singleTypeNonNull}Dict);
                    }
                }
                tempDict["valueString"] = list${variable.singleType}.ToArray().ToString();                              
            } else {
                tempDict["valueString"] = "null";                              
            }
            
          ''';
          break;
        default:
      }
      result += '''
        tempDict = new Dictionary<string, dynamic>();
        tempDict["propertyId"] = "${variable.name}";
        tempDict["description"] = "${variable.name}";
        $lineValueString
        tempDict["valueType"] =  ${variable.valueTypeInt};
        tempDict["valueUnitOfMeasure"] = "";
        propertiesDictList.Add(tempDict);

      ''';
    }
    return result;
  }

  String generateBaseToJson(List<VariableCSharp> vars) {
    return '''
       public static Dictionary<string, dynamic>? baseToJson($objectName objectModel)
        {
            Dictionary<string, dynamic> newDict = new Dictionary<string, dynamic>();
            if (objectModel.id != null)
            {
                newDict.Add("${objectName?.lowerFirst()}Id", objectModel.id);
                newDict.Add("description", "");
                List<Dictionary<string, dynamic>> propertiesDictList = new List<Dictionary<string, dynamic>>();
                Dictionary<string, dynamic>[] propertiesArray = new Dictionary<string, dynamic>[${vars.length}];
                Dictionary<string, dynamic> tempDict = new Dictionary<string, dynamic>();
                ${baseToJsonCase(vars)}

                int i = 0;
                foreach(Dictionary<string, dynamic> dict in propertiesDictList)
                {
                    propertiesArray[i] = dict;
                    i++;
                }
                newDict.Add("properties", propertiesArray);
            }
            return newDict;
        }
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

class VariableCSharp {
  String name;
  String type;
  VariableType variableType;
  String? get singleType {
    if (variableType == VariableType.listObjectType) {
      return type.replaceAll('List<', '').replaceAll('>', '');
    }
    return null;
  }

  String? get singleTypeNonNull {
    return singleType?.replaceAll("?", "");
  }

  String get valueTypeInt {
    switch (type) {
      case 'bool':
        return "0";
      case 'int':
        return "1";
      case 'decimal':
        return "2";
      case 'string':
        return "3";
      default:
        return "4";
    }
  }

  VariableCSharp(
      {required this.name, required this.type, required this.variableType});
}

enum VariableType { primaryType, enumType, objectType, listObjectType }
