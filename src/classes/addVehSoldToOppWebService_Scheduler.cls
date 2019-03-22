/**
 * Created by admin on 2019-03-22.
 */

global with sharing class addVehSoldToOppWebService_Scheduler implements Schedulable {

    public static String CRON_EXP = '0 0 10 * * ?'; // runs everyday at 10:00am.

    global void execute(SchedulableContext SC) {
        Date runYesterday = Date.today().addDays(-1);
        addVehSoldToOppWebService addSoldVehocles = new addVehSoldToOppWebService(runYesterday, runYesterday);
    }

}