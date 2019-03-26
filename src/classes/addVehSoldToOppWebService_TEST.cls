/**
 * Created by admin on 2019-03-22.
 */

@IsTest
public with sharing class addVehSoldToOppWebService_TEST {

    /*

    HAD TO CREATED DATA LOCALLY TO AVOID CALLOUT ISSUES IN SCHEDULABLE TEST METHOD.

    @TestSetup static void setup() {

        List<Integer> portalId = new List<Integer>{167718, 168199, 169656, 172301, 172230, 172243, 172198, 171569, 170402};
        TestDataFactory_Opportunity.makeCreditApplications(9, true, portalId);

    } */

    @IsTest static void test1GetToken() {
        List<Integer> portalId = new List<Integer>{167718, 168199, 169656, 172301, 172230, 172243, 172198, 171569, 170402};
        TestDataFactory_Opportunity.makeCreditApplications(9, true, portalId);

        Test.setMock(HttpCalloutMock.class, new addVehSoldToOppWebService_Token_MOCK());

        Test.startTest();

        addVehSoldToOppWebService av = new addVehSoldToOppWebService(Date.today().addDays(-1), Date.today().addDays(-1) ); // yesterday.
        Map<String, Object> token = (Map<String, Object>) JSON.deserializeUntyped(av.getToken());

        Test.stopTest();

        System.assert(token.get('access_token') != null);
        System.assert(token.get('expiration') != null );

    }

    @IsTest static void test2ProcessVehicles() {
        List<Integer> portalId = new List<Integer>{167718, 168199, 169656, 172301, 172230, 172243, 172198, 171569, 170402};
        TestDataFactory_Opportunity.makeCreditApplications(9, true, portalId);

        String token='{"access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9","expiration": "2299-11-26T13:37:42Z"}';
        Test.setMock(HttpCalloutMock.class, new addVehSoldToOppWebService_MOCK());

        Test.startTest();

        addVehSoldToOppWebService av = new addVehSoldToOppWebService(Date.today().addDays(-1), Date.today().addDays(-1) ); // yesterday.
        Integer sz = av.vehicleSoldProcess(token);

        Test.stopTest();

        System.assertEquals(9, sz, 'There should be nine (9) records in test');

    }

    @IsTest static void test3Scheduler() {

        Test.setMock(HttpCalloutMock.class, new addVehSoldToOppWebService_Token_MOCK());
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('testVehiclesSoldScheduler', addVehSoldToOppWebService_Scheduler.CRON_EXP,
                new addVehSoldToOppWebService_Scheduler());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE Id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(addVehSoldToOppWebService_Scheduler.CRON_EXP,
                ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
}