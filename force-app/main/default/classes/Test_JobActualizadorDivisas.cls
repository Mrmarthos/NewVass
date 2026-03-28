/**
* Clase de test encargada de probar el funcionamiento de la clase "Job_ActualizadorDivisas.apxc"
* @author adiaz
* @date 29/08/2018 
*/
@isTest
public class Test_JobActualizadorDivisas 
{

    /**
* Método de test encargado de probar el funcionamiento de los métodos contenidos en la clase "Job_ActualizadorDivisas.apxc"
* @author adiaz
* @date 28/08/2018 
*/
    @isTest public static void testFuncionaBien_Job_ActualizadorDivisas() 
    {
        Test.startTest();
        System.schedule('Test Job_ActualizadorDivisas', '0 0 8 * * ? *', new Job_ActualizadorDivisas());
        Test.stopTest();
    }
}