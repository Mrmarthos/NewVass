public with sharing class Utils {

	  /** 
	  * @description: Consigue el Id de los roles que se le pase
	  **
	  * @Autor: Noemi Escudero del Olmo (23/11/2018)
	  **
	  * @Modificacion: 
	  **
	  * @Parametro: - setRol: 	set de nombres de rol de usuario
	  **
	  * @return:    - Map<String,Id>: mapa con key rol, value el Id
	  **
	  */	
    public static Map<String,Id> queryUserRol(Set<String> setRol) 
    {   
        Map<String,Id> mapRolId = new  Map<String,Id>();
        Map<String,List<UserRole>> mapRolUser = new  Map<String,List<UserRole>>();

        //Conseguir el Id de los roles y que la clave sea el nombre del rol
        mapRolUser = (Map <String,List<UserRole>>) buildGroupStringMap([ SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN :setRol ], 'DeveloperName');

        for(String rol : setRol)
        {   
            //Consigo el Id del rol para no devolver la lista de Objetos
            mapRolId.put(rol, mapRolUser.get(rol)[0].Id);
        }

        return mapRolId;
    }


        /**
         * Generates a Map of lists from a SOQL query or a list of sObjects, where the key is a String field passed as argument.
         *
         * @author Javier Martínez de Pissón
         * @date 17/10/2016
         * @param objectList (List<sObject>, sobject list source)
         * @param field (String, key Field)
         * @return Map, must be casted to the corresponding Map type
         */
    public static Map<String, List<sObject>> buildGroupStringMap(List<sObject> sObjectList, String fieldName)
    {
        Map<String, List<sObject>> sObjListMap = new Map<String, List<sObject>>();
        String fieldValue;

        for(sObject o : sObjectList)
        {
            fieldValue = String.valueOf( o.get(fieldName) );

                if( String.isNotBlank(fieldValue) )
                {
                    if( !sObjListMap.containsKey(fieldValue) )
                    {
                        sObjListMap.put(fieldValue, new List<sObject> ());
                    }

                    sObjListMap.get(fieldValue).add(o);
                        }
        }
        return sObjListMap;
    }

}