/**
*@description: trigger que procesa los eventos Linea_de_Proyecto__c e invoca 
               el manager para realizar operaciones DML 
*@author name: rpolvera
*@date date: 22/10/2018
*@change name date description: Nueva clase.
*@see class/method:
**/
     
trigger LineaProyectoEventTrigger on E_Linea_de_Proyecto__e (after insert) {
    LineaProyectoEventTriggerUtil LPET = new LineaProyectoEventTriggerUtil();
    LPET.process(trigger.new); 
}