global class ReprocesaEvento implements Schedulable
    {
        List<sObject> eventosRepublicar;
        global ReprocesaEvento (List<sObject> eventos)
        {
            //guardamos la lista de eventos a republicar
            eventosRepublicar =  eventos;
        }
        global void execute(SchedulableContext SC) {
            //publicamos y borramos el job
            EventBus.publish(eventosRepublicar);
            finish(SC);
        }
        global void finish(System.SchedulableContext sc)
        {
        //una vez finalizado abortamos el trabajo, puesto que solo queremos ejecutarlo una vez
          system.abortJob(sc.getTriggerId());
        }
    }