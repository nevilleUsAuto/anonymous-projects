/**
 * Created by admin on 2019-03-22.
 */

public with sharing class addVehSoldToOppWebService {

    public class SoldVehiclesException extends Exception {}

    private String startDate;
    private String endDate;

    private class soldRecord {
        public String stockNo;
        public String salesPortalId;
        public String dateSold;
    }

    public addVehSoldToOppWebService(Date stDate, Date enDate ) {
        if (stDate == null || enDate == null) {
            System.debug('Start and End dates are required.  Process aborted...');
            throw new SoldVehiclesException('Start and End dates are required.  Process aborted...');
        } else {
            this.startDate = String.valueOf(stDate);
            this.endDate = String.valueOf(enDate);
        }
        //this.vehicleSoldProcess(String.valueOf(stDate), String.valueOf(enDate));
    }

    public String getToken() {
        return usauto_webservices_controller.retrieveToken();
    }

    @TestVisible private List<soldRecord> getVehiclesRecords(String t) {
        String vh = usauto_webservices_controller.vehiclesSold(t, this.startDate, this.endDate);
        System.debug('Vehicle List: ' + vh);
        return (List<soldRecord>) JSON.deserialize(vh, List<soldRecord>.class);
    }

    public Integer vehicleSoldProcess(String token) {
        return (this.processVehicles( this.getVehiclesRecords(token) ));
    }

    private Integer processVehicles(List<soldRecord> soldRecords ) {
        Map<String, soldRecord> mapVehSold = new Map<String, soldRecord>();
        List<Opportunity> opToUpdate = new List<Opportunity>();

        for (soldRecord s : soldRecords) {
            if (s.salesPortalId != '0') {
                System.debug('Sold Record: ' + s);
                mapVehSold.put(s.salesPortalId, s);
            }
        }

        List<Credit_Application__c> ncac = [SELECT Id, Sales_Portal_ID__c, Opportunity__c, Opportunity__r.StageName
            FROM Credit_Application__c WHERE Sales_Portal_ID__c IN :mapVehSold.keySet()];

        System.debug('Count of New CA: ' + ncac.size());

        //build list to update from new CA
        for (Credit_Application__c c : ncac) {
            soldRecord vs = mapVehSold.get(c.Sales_Portal_ID__c);

            if (vs != null ) {
                opToUpdate.add(
                        new Opportunity(
                                Id = c.Opportunity__c,
                                Sales_Portal_ID__c = vs.salesPortalId,
                                Stock_Number__c = vs.stockNo,
                                SoldToday__c = Date.valueOf(vs.dateSold),
                                CloseDate = Date.valueOf(vs.dateSold),
                                StageName = (c.Opportunity__r.StageName != 'Layaway' ? 'Closed Won' : c.Opportunity__r.StageName)
                        )
                );
            }
        }

        System.debug('Number of record to update: ' + opToUpdate.size() + '~~~~' + opToUpdate);
        //update opToUpdate;

        return opToUpdate.size();
    }

}