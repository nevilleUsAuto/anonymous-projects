/**
 * Created by admin on 2019-03-06.
 */

public with sharing class OpportunityPhoneAndEmail {

    public static void AddPhonesAndEmailVoid() {
        String qry = 'select id, Buyer__c, Buyer__r.mobilePhone, Buyer__r.Work_Phone__c, Buyer__r.Phone,  Buyer__r.email,' +
                'Co_Buyer__r.mobilePhone, Co_Buyer__r.Work_Phone__c, Co_Buyer__r.Phone, Opportunity__c,' +
                'Opportunity__r.mobile__c, Opportunity__r.Phone__c, Opportunity__r.Home_Phone__c, Opportunity__r.Email__c ' +
                'FROM Credit_Application__c ' +
                'WHERE ( Opportunity__r.ID != \'\' ' +
                'AND (' +
                '(Opportunity__r.mobile__c = \'\' AND Buyer__r.mobilePhone != \'\') OR ' +
                '(Opportunity__r.Phone__c = \'\' AND Buyer__r.Work_Phone__c != \'\') OR ' +
                '(Opportunity__r.Home_Phone__c = \'\' and Buyer__r.Phone != \'\') OR ' +
                '(Opportunity__r.Email__c = \'\' AND Buyer__r.email != \'\') ' +
                ') ) ORDER BY CREATEDDATE DESC LIMIT 2000';

        List<Credit_Application__c> cac = Database.query(qry);

        List<Opportunity> opp = new List<Opportunity>();
        for (Credit_Application__c c : cac) {
            opp.add(
                    new Opportunity(
                            Id = c.Opportunity__c,
                            mobile__c = c.Buyer__r.mobilePhone,
                            Phone__c = c.Buyer__r.Work_Phone__c,
                            Home_Phone__c = c.Buyer__r.Phone,
                            Email__c = c.Buyer__r.email
                    )
            );
        }

        System.debug('Number of CAs: ' + cac.size());
        System.debug('Number of records to update: ' + opp.size());
        update opp;
    }
}