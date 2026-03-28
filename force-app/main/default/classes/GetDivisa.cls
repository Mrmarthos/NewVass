public with sharing  class GetDivisa {


//Use @AuraEnabled to enable client- and server-side access to the method
  @AuraEnabled
  public static String getUserDivisa() {
      system.debug(userinfo.getDefaultCurrency());
    return userinfo.getDefaultCurrency();
  }
 }