public class FormatUtility {
    public static Object handleNull(Object value) {
        return value != null ? value : '';
    }
    
    public static String formatDate(Date d) {
        return d != null ? DateTime.newInstance(d, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd') : null;
    }
    
    public static String formatDateTime(Datetime dt) {
        return dt?.format('yyyy-MM-dd\'T\'HH:mm:ss');
    }
    
    public static String convertirMultiPicklistASeparadorPipe(String multiPicklistValue) {
        if (String.isBlank(multiPicklistValue)) {
            return '';
        }
        // Reemplaza los ";" por "|"
        return multiPicklistValue.replace(';', '|');
    }
    
    public static String padLeftWithZeros(String input) {
     
    if (input == null || String.isBlank(input) ) {
        
        input = '';
        return input;
    }

    while (input.length() < 8) {
        input = '0' + input;
    }
    return input;
}
}