public class Multibooking {

  /**
      *@description: Añade el comercial de la oportunidad al equipo multobooking como principal
      *@param name la oportunidad asociada
      *@author name: Amartos
      *@date date: 13/06/2019
      *@change name date description: Nuevo Método.
      *@throws Exception: 
      *@where description: 
      *@see class/method: Multibooking
      **/ 

    public static void AddComercialPrincipalMultibooking (list<Opportunity> Oportunidad){


          List<Comerciales_Multibooking__c> Relacion = new List<Comerciales_Multibooking__c>(); 
          Integer i=0;    
          try 
                  {
                    for (i=0; i<Oportunidad.size();i++){

                              Relacion.add( new Comerciales_Multibooking__c(
                            
                              Principal__c   = true,
                              Comercial__c               = Oportunidad.get(i).OwnerId,
                              Oportunidad__c                = Oportunidad.get(i).id,
                              Mercado__c                    =Oportunidad.get(i).mercado__c
                    
                  
                        ));

                    }

                    if (Relacion.size()>0){  system.debug('--------relacuib-----'+Relacion.size());insert Relacion;
                    }
                    }catch (Exception e) 
                  {
                    System.debug(e.getMessage());
                    
                  
                  }
                

                    }

     /**
      *@description: Añade el comercial de la oportunidad al equipo multobooking como secundario
      *@param name la relacion comercial-oportunidad
      *@author name: Amartos
      *@date date: 13/06/2019
      *@change name date description: Nuevo Método.
      *@throws Exception: 
      *@where description: 
      *@see class/method: Multibooking
      **/ 

    public static void AddCoomercialTeamOportunidad(list<Comerciales_Multibooking__c> Relaciones){

     List<OpportunityTeamMember> opportunityTeamMembers= new List<OpportunityTeamMember>(); 
    
       Integer i=0; 
          try 
                  {
                    for (i=0; i<Relaciones.size();i++){

                        List<Comerciales_Multibooking__c> accts =[ SELECT  Oportunidad__r.OwnerId from Comerciales_Multibooking__c WHERE id = :Relaciones.get(i).id]; 
                        
                          if(Relaciones.get(i).Comercial__c!=accts.get(i).Oportunidad__r.OwnerId){
                              opportunityTeamMembers.add( new OpportunityTeamMember(
                            
                              OpportunityAccessLevel   = Constants.DEFAULT_ACCESS_LEVEL_ACC_WHEN_SHARING_OPPTY,
                              UserId               = Relaciones.get(i).Comercial__c,
                              OpportunityId                = Relaciones.get(i).Oportunidad__c,
                              TeamMemberRole                    =Constants.DEFAULT_TEAM_MEMBER_ROLE_OPPORTUNITY_TEAM
                            
                  
                        ));
                          }
                    }
                    if (opportunityTeamMembers.size()>0){  system.debug('--------relacion-----'+opportunityTeamMembers);insert opportunityTeamMembers;}
                    }catch (Exception e) 
                  {
                    System.debug(e.getMessage());
                  
                  }

        system.debug('---------relaciones-------');       
      system.debug(Relaciones);

 


                    }

                      /**
      *@description: Añade el comercial de la oportunidad al equipo multobooking como secundario
      *@param name la relacion comercial-oportunidad
      *@author name: Amartos
      *@date date: 13/06/2019
      *@change name date description: Nuevo Método.
      *@throws Exception: 
      *@where description: 
      *@see class/method: Multibooking
      **/ 

    public static void RemoveCoomercialTeamOportunidad(Comerciales_Multibooking__c relacion){

              system.debug('relacionnnn en borrao'+relacion);
             
               List<OpportunityTeamMember> del =[ SELECT  id from OpportunityTeamMember  where OpportunityId  =:relacion.Oportunidad__c and user.id =:relacion.Comercial__c] ;

              delete del;



                    }









    }