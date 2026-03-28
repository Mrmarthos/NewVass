/**
* Clase de encargada de ejecutar periódicamente el método cargarDivisas() de la clase "ActualizadorDivisas.apxc"
* @author adiaz
* @date 28/08/2018 
*/
global class Job_ActualizadorDivisas implements Schedulable 
{    
    global void execute(SchedulableContext ctx) 
    {
        System.debug('Ejecutando actualización de divisas a día y hora: ' + System.now());
        ejecutarControlador();        
    }
    
    public void ejecutarControlador() 
    {
        ActualizadorDivisas.cargarDivisas();
    }    
}