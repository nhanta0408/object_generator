class EquipmentClass {
              {
        public string? id { get; set; }
        public string code { get; set; }
        public string name { get; set; }
        public string? type { get; set; }
        public double mtbf { get; set; }
        public double mttf { get; set; }
        public double oee { get; set; }
        public string? status { get; set; }
        public List<MaintenanceResponse>? recentMaintenanceWorkOrder { get; set; }
        public List<ChartObj>? errors { get; set; }
        public List<SparePart>? sparePart { get; set; }

              public static EquipmentClass  baseFromJson(Dictionary<string, dynamic> dictionary)
    {
      EquipmentClass  returnObj = EquipmentClass ();
      List<Dictionary<string, dynamic>> properties = dictionary[properties];
                List<Dictionary<string, dynamic>> property = properties.Where(prop => prop['propertyId'] == 'id';);
          returnObj.id = property['valueString'] as string?;

                  List<Dictionary<string, dynamic>> property = properties.Where(prop => prop['propertyId'] == 'code';);
          returnObj.code = property['valueString'] as string;

                  List<Dictionary<string, dynamic>> property = properties.Where(prop => prop['propertyId'] == 'name';);
          returnObj.name = property['valueString'] as string;

                  List<Dictionary<string, dynamic>> property = properties.Where(prop => prop['propertyId'] == 'type';);
          returnObj.type = property['valueString'] as string?;

                  List<Dictionary<string, dynamic>> property = properties.Where(prop => prop['propertyId'] == 'mtbf';);
          returnObj.mtbf = property['valueString'] as double;

                  List<Dictionary<string, dynamic>> property = properties.Where(prop => prop['propertyId'] == 'mttf';);
          returnObj.mttf = property['valueString'] as double;

                  List<Dictionary<string, dynamic>> property = properties.Where(prop => prop['propertyId'] == 'oee';);
          returnObj.oee = property['valueString'] as double;

                  List<Dictionary<string, dynamic>> property = properties.Where(prop => prop['propertyId'] == 'status';);
          returnObj.status = property['valueString'] as string?;

        
    }
  
        }