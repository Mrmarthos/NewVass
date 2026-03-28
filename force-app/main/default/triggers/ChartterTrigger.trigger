trigger ChartterTrigger on FeedItem (after insert,after update) {

 
    
    For (FeedItem FIR:trigger.new) { 
       
       
        if(FIR.ParentId.getSObjectType().getDescribe().getName()=='Opportunity' && FIR.Type=='TextPost' ){
            opportunity opp= new opportunity();
            opp.Fecha_Ultima_Actualizacion_Chatter__c=fir.LastModifiedDate;
            opp.Id=FIR.ParentId;
            update opp;
            
        }
     
  
    }
}