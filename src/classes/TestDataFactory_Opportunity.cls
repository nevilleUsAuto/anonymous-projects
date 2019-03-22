/**
 * Created by admin on 2019-03-22.
 */

@IsTest
public with sharing class TestDataFactory_Opportunity {

    public static Location__c makeOneLocation() {
        Location__c location = new Location__c(
                Name = 'BDC',
                City__c = 'test',
                Postal_Code__c = '12345',
                State__c = 'TX',
                SalesPortalId__c = 99,
                General_Manager__c = UserInfo.getUserId()
        );
        insert location;
        return location;
    }

    public static List<Opportunity> makeOpportunity(Integer oppCnt, Boolean dbPost) {

        List<Opportunity> opp = new List<Opportunity>();

        for (Integer i = 0; i < oppCnt; i++) {
            opp.add(
                    new Opportunity(Name = 'OppName' + String.valueOf(i),
                            StageName = 'Qualify',
                            CloseDate = Date.today().addDays(120))
            );
        }

        if (dbPost) {
            insert opp;
        }

        return opp;
    }

    public static List<Account> makeAccounts(Integer Cnt, Boolean dbPost) {

        List<Account> obj = new List<Account>();

        for (Integer i = 0; i < Cnt; i++) {
            obj.add(
                    new Account(
                            Name = 'MyTest Account' + String.valueOf(i)
                    )
            );
        }

        if (dbPost) {
            insert obj;
        }

        return obj;
    }

    public static List<Contact> makeContacts(List<Account> acc, Boolean dbPost) {
        Id contactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Contact').getRecordTypeId();
        List<Contact> obj = new List<Contact>();

        for (Integer i = 0; i < acc.size(); i++) {
            obj.add(
                    new Contact(LastName = 'TestLastName' + String.valueOf(i),
                            Email='Testor' + String.valueOf(i) + '@test.com', AccountId = acc[i].Id,
                            RecordTypeId = contactTypeId)
            );
        }

        if (dbPost) {
            insert obj;
        }

        return obj;
    }


    public static List<Credit_Application__c> makeCreditApplications(Integer caCnt, Boolean dbPost, List<Integer> portalId) {

        // build required related objects
        List<Contact> ct = makeContacts( makeAccounts(caCnt, true), true);
        List<Opportunity> opp = makeOpportunity(caCnt, true);
        Location__c loc = makeOneLocation();
        //Integer portalIndex = 12334;
        // end build required related objects

        List<Credit_Application__c> obj = new List<Credit_Application__c>();

        for (Integer i = 0; i < caCnt; i++) {
            obj.add(
                    new Credit_Application__c(
                            Buyer__c = ct[i].Id,
                            Opportunity__c = opp[i].Id,
                            Repeat_Customer__c = '1 Prior Purchase',
                            Co_App_Repeat_Customer__c = '1 Prior Purchase',
                            Store_Location__c = loc.Id,
                            Sales_Portal_ID__c = String.valueOf(portalId[i])
                    )
            );
        }

        if (dbPost) {
            insert obj;
        }

        return obj;
    }

}