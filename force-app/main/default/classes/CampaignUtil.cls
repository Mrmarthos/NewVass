public class CampaignUtil 
{
	/**
	 * Recupera una lista de Usuario_de_Campana__c y un mapa con las campanas utilizadas en esa lista y
	 * devuelve un listado de tareas asociadas a los usuarios y campañas
	 * 
	 * @author: amartinez
	 **/
 /*   public static List<Task> createTaskToSalesReps(List<Usuario_de_Campana__c> usersAndCampaigns, Map<Id, Campaign> campaigns) 
    {
        List<Task> newTasks = new List<Task>();
         
        for (Usuario_de_Campana__c usu : usersAndCampaigns) 
        {
            Campaign camp = campaigns.get(usu.Campana__c);
            Task t = new Task();
            t.Subject = camp.Name;
            t.WhatId = camp.Id;
            t.Description = camp.Description;
            t.ActivityDate = camp.EndDate;
            t.OwnerId = usu.Usuario__c;
            newTasks.add(t);
        }
        
        return newTasks;
    }
    */

 
}