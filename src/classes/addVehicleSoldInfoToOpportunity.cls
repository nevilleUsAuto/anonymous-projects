/**
 * Created by admin on 2019-03-06.
 */

public with sharing class addVehicleSoldInfoToOpportunity {

    public static void runUpdateProcess() {

        Integer flagLimitCtr = 1000;
        List<Opportunity> opToUpdate = new List<Opportunity>();

        List<Vehicles_Sold_Upload__c> flagUpdated = new List<Vehicles_Sold_Upload__c>();
        Map<String, Vehicles_Sold_Upload__c> mapVehSold = new Map<String, Vehicles_Sold_Upload__c>();

        List<Vehicles_Sold_Upload__c> vsuc = [SELECT id, name, Date_Sold__c, Sales_Portal_ID__c, Stock_Number__c, Processed__c
            FROM Vehicles_Sold_Upload__c WHERE Processed__c = FALSE AND Sales_Portal_ID__c != '0'];

        for (Vehicles_Sold_Upload__c v : vsuc) {
            mapVehSold.put(v.Sales_Portal_ID__c, v);
        }

        List<Credit_Application__c> ncac = [SELECT Id, Sales_Portal_ID__c, Opportunity__c, Opportunity__r.StageName
            FROM Credit_Application__c WHERE Sales_Portal_ID__c IN :mapVehSold.keySet()];

        List<dealer__Credit_Application__c> dcac = [SELECT Id, Sales_Portal_ID__c, Sales_Up__c
            FROM dealer__Credit_Application__c	WHERE Sales_Portal_ID__c IN :mapVehSold.keySet()];

        System.debug('Count of New CA: ' + ncac.size());
        System.debug('Count of Dealer CA: ' + dcac.size());

        //build list to update from new CA
        for (Credit_Application__c c : ncac) {
            Vehicles_Sold_Upload__c vs = mapVehSold.get(c.Sales_Portal_ID__c);

            if (vs != null && opToUpdate.size() <= flagLimitCtr) {
                opToUpdate.add(
                        new Opportunity(
                                Id = c.Opportunity__c,
                                Sales_Portal_ID__c = vs.Sales_Portal_ID__c,
                                Stock_Number__c = vs.Stock_Number__c,
                                SoldToday__c = vs.Date_Sold__c,
                                StageName = (c.Opportunity__r.StageName != 'Layaway' ? 'Closed Won' : c.Opportunity__r.StageName)
                        )
                );
                vs.Processed__c = true;
                flagUpdated.add(new Vehicles_Sold_Upload__c(Id = vs.Id, Processed__c = true ));
            }
        }

        //add to list CA to update from Sales Up
        Map<Id, dealer__Credit_Application__c> mapDealerCA = new Map<Id, dealer__Credit_Application__c>();
        for (dealer__Credit_Application__c c : dcac) {
            mapDealerCA.put( Id.valueOf(c.Sales_Up__c), c);
        }

        System.debug('Number of Dealer CA Map: ' + mapDealerCA.size());
        Map<Id, Opportunity> idOppMap = new Map<Id, Opportunity>();

        List<Opportunity> opp = [SELECT Id, Old_Sales_Up_Id__c, StageName FROM Opportunity WHERE Old_Sales_Up_Id__c IN : mapDealerCA.keySet()];
        for (Opportunity o :opp) {
            idOppMap.put(o.Old_Sales_Up_Id__c, o);
        }
        System.debug('Opportunity Map Count: ' + idOppMap.size());

        for (dealer__Credit_Application__c c : dcac) {
            Vehicles_Sold_Upload__c vs = mapVehSold.get(c.Sales_Portal_ID__c);
            Opportunity op = idOppMap.get(c.Sales_Up__c);

            if (vs != null && op != null && opToUpdate.size() <= flagLimitCtr) {
                op.Sales_Portal_ID__c = vs.Sales_Portal_ID__c;
                op.Stock_Number__c = vs.Stock_Number__c;
                op.SoldToday__c = vs.Date_Sold__c;
                op.StageName = (op.StageName != 'Layaway' ? 'Closed Won' : op.StageName);
                opToUpdate.add(op);

                vs.Processed__c = true;
                flagUpdated.add(new Vehicles_Sold_Upload__c(Id = vs.Id, Processed__c = true ));
            }
        }

        System.debug('Number of record to update: ' + opToUpdate.size() + '~~~~' + opToUpdate);
        System.debug('Updated processed: ' + flagUpdated);

        update opToUpdate;
        update flagUpdated;

        /*List<Vehicles_Sold_Upload__c> noMatch = [SELECT id, name, Date_Sold__c, Sales_Portal_ID__c, Stock_Number__c, Processed__c
            FROM Vehicles_Sold_Upload__c WHERE NOT Sales_Portal_ID__c IN :portIdsNotUpdated ];

        System.debug('No Match Records: ' + noMatch.size() + '~~~ ' + noMatch);*/
    }
}