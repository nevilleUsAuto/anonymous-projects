/**
 * Created by admin on 2019-03-22.
 *
 * addVehSoldToOppWebService_Scheduler  sch2 = new addVehSoldToOppWebService_Scheduler(); //Schedule apex class name
system.schedule('Vehicles Sold Update', addVehSoldToOppWebService_Scheduler.CRON_EXP, sch2); //system method to schedule apex class

 */

global with sharing class addVehSoldToOppWebService_Scheduler implements Schedulable {

    public static String CRON_EXP = '0 0 10 * * ?'; // runs everyday at 10:00am.

    private static addVehSoldToOppWebService av;

    global void execute(SchedulableContext SC) {
        Date runYesterday = Date.today().addDays(-1);
        av = new addVehSoldToOppWebService(runYesterday, runYesterday);

        processing();
    }

    @Future(Callout=true)
    public static void processing() {
        String token = av.getToken();
        if (!Test.isRunningTest()) {
            av.vehicleSoldProcess(token);  //testing already in Test2.  Causing issues with callout for test3...
        }
    }


}