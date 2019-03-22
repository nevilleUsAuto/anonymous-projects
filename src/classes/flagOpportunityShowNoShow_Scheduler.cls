/**
 * Created by admin on 2019-03-15.
 *
 * Description Scheduler Class for the ShowNoShow class
 *
 * scheduleSec  sch2 = new scheduleSec(); //Schedule apex class name
String sch = '0 0 8 13 2 ?'; //schedule interval time
system.schedule('One Time Pro', sch, sch2);


flagOpportunityShowNoShow_Scheduler  sch2 = new flagOpportunityShowNoShow_Scheduler(); //Schedule apex class name
system.schedule('Show NoShow Process', flagOpportunityShowNoShow_Scheduler.CRON_EXP, sch2); //system method to schedule apex class


 */

global with sharing class flagOpportunityShowNoShow_Scheduler implements Schedulable {

    public static String CRON_EXP = '0 0 4 * * ?'; // runs everyday at 4:00am.

    global void execute(SchedulableContext SC) {
        Date st = Date.today().addDays(-7);
        Date en = Date.today().addDays(-1);

        flagOpportunityShowNoShow flagOpps = new flagOpportunityShowNoShow(st, en);
    }

}