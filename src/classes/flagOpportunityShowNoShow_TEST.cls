/**
 * Created by admin on 2019-03-19.
 */

@IsTest
private class flagOpportunityShowNoShow_TEST {

    @TestSetup static void setup() {

        /*  required fields by sObject
            Account-->Name
            Contact-->LastName
            Lead-->Company,LastName,status
            Opportunity-->Name,stage,closedate
         */

        Id contactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Contact').getRecordTypeId();

        Location__c location = new Location__c(
                Name = 'BDC',
                City__c = 'test',
                Postal_Code__c = '12345',
                State__c = 'TX',
                SalesPortalId__c = 99,
                General_Manager__c = UserInfo.getUserId()
        );
        insert location;

        Account account =  new Account(Name = 'MyTest Account');
        insert account;

        List<Contact> contact = new List<Contact>{
                new Contact(LastName = 'TestLastName', Email='Testor151@test.com', AccountId = account.Id,
                        RecordTypeId = contactTypeId),
                new Contact(LastName = 'Test2LastName', Email='Testor152@test.com', AccountId = account.Id,
                        RecordTypeId = contactTypeId)
        };
        insert contact;

        Lead lead = new Lead(Status = 'Open', Lead_Status__c = 'WORKING', Company = account.Name, LastName = 'ShouldHaveToBeContact' );
        insert lead;

        List<Opportunity> opportunity = new List<Opportunity>{
                new Opportunity(Name = 'OppName', StageName = 'Qualify', CloseDate = Date.today().addDays(30)),
                new Opportunity(Name = 'OppName', StageName = 'Layaway', CloseDate = Date.today().addDays(30))
        };
        insert opportunity;

        List<Credit_Application__c> creditApp = new List<Credit_Application__c>{
                new Credit_Application__c(
                        Buyer__c = contact[0].Id,
                        Opportunity__c = opportunity[0].Id,
                        Repeat_Customer__c = '1 Prior Purchase',
                        Co_App_Repeat_Customer__c = '1 Prior Purchase',
                        Store_Location__c = location.Id,
                        Sales_Portal_ID__c = '12334'
                ),
                new Credit_Application__c(
                        Buyer__c = contact[1].Id,
                        Opportunity__c = opportunity[1].Id,
                        Repeat_Customer__c = '1 Prior Purchase',
                        Co_App_Repeat_Customer__c = '1 Prior Purchase',
                        Store_Location__c = location.Id,
                        Sales_Portal_ID__c = '12324'
                )
        };

        insert creditApp;
        creditApp = [SELECT Id, LastModifiedDate FROM Credit_Application__c];

        ID uid = UserInfo.getUserId();

        List<Event> events = new List<Event>{
                new Event(ActivityDateTime = System.now().addDays( -7), WhoId = contact[0].Id, Subject='First Visit', DurationInMinutes = 30, Set_By__c = uid ),
                new Event(ActivityDateTime = System.now().addDays( 1), WhoId = contact[0].Id, Subject='Follow up Visit', DurationInMinutes = 40, Set_By__c = uid ),
                new Event(ActivityDateTime = System.now().addDays( -6), WhoId = contact[1].Id, Subject='First Visit', DurationInMinutes = 30, Set_By__c = uid ),
                new Event(ActivityDateTime = System.now(), WhoId = contact[1].Id, Subject='Follow up Visit', DurationInMinutes = 40, Set_By__c = uid ),
                new Event(ActivityDateTime = System.now().addDays( -1), WhatId = opportunity[0].Id, Subject='First opp Visit', DurationInMinutes = 30, Set_By__c = uid ),
                new Event(ActivityDateTime = Date.newInstance(creditApp[0].LastModifiedDate.year(), creditApp[0].LastModifiedDate.month(), creditApp[0].LastModifiedDate.day()),
                        WhatId = opportunity[0].Id, Subject='First opp Visit', DurationInMinutes = 30, Set_By__c = uid ),
                new Event(ActivityDateTime = Date.newInstance(creditApp[1].LastModifiedDate.year(), creditApp[1].LastModifiedDate.month(), creditApp[1].LastModifiedDate.day()),
                        WhatId = opportunity[1].Id, Subject='First opp Visit', DurationInMinutes = 30, Set_By__c = uid ),
                new Event(ActivityDateTime = System.now().addDays( 2),  WhatId = opportunity[1].Id, Subject='Follow up opp Visit', DurationInMinutes = 30, Set_By__c = uid )
        };
        insert events;

    }

    @IsTest static void test() {
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('testBasicScheduledApex', flagOpportunityShowNoShow_Scheduler.CRON_EXP,
                new flagOpportunityShowNoShow_Scheduler());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(flagOpportunityShowNoShow_Scheduler.CRON_EXP,
                ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();

    }
}