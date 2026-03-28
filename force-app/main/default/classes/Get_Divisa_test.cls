@istest
public class Get_Divisa_test {

    
    @istest
    public static void getDivisa(){
        
        system.assertEquals('EUR', GetDivisa.getUserDivisa());
        
    }
}