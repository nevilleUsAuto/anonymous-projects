/**
 * Created by admin on 2019-03-07.
 */

public with sharing class ReplaceExpiredCreditApplication {

    public static String associateNewCreditApplication(String oldCreditAppName ) {

        // CA-00750
        //https://usautosales--full.lightning.force.com/lightning/r/Opportunity/0066100000Rag4LAAR/view
        // old CA: https://usautosales--full.lightning.force.com/lightning/r/Credit_Application__c/a4v61000000kCTuAAM/view
        // new CA: https://usautosales--full.lightning.force.com/lightning/r/Credit_Application__c/a4v3B0000006TtUQAU/view

        List<String> returnValues = new List<String>{'Process completed Successfully', 'Unable to complete request: '};
        String returnMsg;
        try {
            List<Credit_Application__c> cac = [
                    SELECT Id, Name, Verified_Lead__c, Opportunity__c, Store_Location__c,
                            OwnerId, Expiring_Date__c, Co_Buyer__c, Buyer__c
                    FROM Credit_application__c
                    WHERE Name = :oldCreditAppName
            ];

            List<Reference__c> refs = [
                    SELECT Id, Name, Credit_Application__c
                    FROM Reference__c
                    WHERE Credit_Application__c = :cac[0].Id
            ];

            // create the new credit application to replace the old.
            Credit_Application__c newc = new Credit_Application__c(
                    Opportunity__c = cac[0].Opportunity__c,
                    Store_Location__c = cac[0].Store_Location__c,
                    OwnerId = cac[0].OwnerId,
                    Co_Buyer__c = cac[0].Co_Buyer__c,
                    Buyer__c = cac[0].Buyer__c,
                    Credit_Application_Status__c = 'In Progress'
            );

            insert newc;

            for (Reference__c r : refs) {
                r.Credit_Application__c = newc.Id;
            }

            update refs;

            // expire old CA
            cac[0].Credit_Application_Status__c = 'Expired';
            //cac[0].Expire_From_Opportunity__c = cac[0].Opportunity__c; //Expire From Opportunity
            cac[0].Opportunity__c = null;
            update cac;

            returnMsg = returnValues[0];

        } catch (Exception e) {
            returnMsg = returnValues[1] + e.getMessage();
        }

        return returnMsg;
    }
}