/**
*@description: job que realiza llamada al servicio de Actualizar JP de SAP
*@param name Description:
*@author name: rpolvera
*@date date: 21/12/2018
*@throws Exception: 
*@where description: TEST.
*@see class/method:
**/  
global class Job_ActualizaJP implements Schedulable 
{
    global void execute(SchedulableContext ctx) 
    {
        System.debug('Ejecutando actualización de JP a día y hora: ' + System.now());
        ActualizadorJP.actualizadorJP();
    }
}