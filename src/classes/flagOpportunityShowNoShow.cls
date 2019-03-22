/**
 * Created by admin on 2019-03-06.
 * Description:  Appointment Activity Show/No Show.
 *                  This can occur on both Leads and Opportunities.
 *                  For Lead, the person may come into the store but chose not to complete a Credit App.
 *                  We still want to track that the person kept the appointment.
 */

public with sharing class flagOpportunityShowNoShow {

    public flagOpportunityShowNoShow(Date stDate, Date enDate ) {

        Set<Id> evtIds = new Set<Id>();
        List<String> oppSoldFlag = new List<String>{'Closed Won', 'Layaway'};
        Map<Id, Opportunity> oppMap;
        Map<Id, Credit_Application__c> credAppsMapWithOppIds = new Map<Id, Credit_Application__c>();
        List<Event> evtToUpdate = new List<Event>(); // list of Events to update
        List<Event> leadEvents;

        try {
            //get the list of events for the specified range, etc. and for which an opportunity record exist
            List<Event> oppEvents = [
                    SELECT Id, ActivityDate, StartDateTime, Appointment_Result__c, WhatId
                    FROM Event
                    WHERE ActivityDate >= :stDate AND ActivityDate <= :enDate
                        AND (Appointment_Result__c = '' OR Appointment_Result__c = 'Future Appointment')
                        AND WhatId IN (SELECT Id FROM Opportunity)
            ];

            // get set of WhatIds
            for (Event v : oppEvents) {
                evtIds.add(v.WhatId);
            }

            // get the opportunities that are in the list of events
            oppMap = (new Map<Id, Opportunity>([SELECT Id, CreatedDate, StageName FROM Opportunity WHERE Id IN :evtIds]));

            //get a map of Credit Apps that are associated with the list of opportunities
            for (Credit_Application__c ca : [
                    SELECT Id, LastModifiedDate, Opportunity__c
                    FROM Credit_Application__c
                    WHERE Opportunity__c IN :oppMap.keySet()]
            ) {
                credAppsMapWithOppIds.put(ca.Opportunity__c, ca);
            }

            // travers the list of events and flag the records according to business rule
            for (Event v : oppEvents) {

                Opportunity op = oppMap.get(v.WhatId);  // get the opp for the current event
                Credit_Application__c ca = credAppsMapWithOppIds.get(op.Id);  // get the credit app for the opportunity
                Date caDate = Date.newInstance(ca.LastModifiedDate.year(), ca.LastModifiedDate.month(), ca.LastModifiedDate.day());
                Date opDate = Date.newInstance(op.CreatedDate.year(), op.CreatedDate.month(), op.CreatedDate.day());

                if (op != null && oppSoldFlag.contains(op.StageName)) {
                    v.Appointment_Result__c = 'Show';
                    evtToUpdate.add(v);
                } else if (ca != null && caDate == v.ActivityDate) {
                    v.Appointment_Result__c = 'Show';
                    evtToUpdate.add(v);
                } else if (opDate != null && opDate == v.ActivityDate) {
                    v.Appointment_Result__c = 'Show';
                    evtToUpdate.add(v);

                } else {
                    v.Appointment_Result__c = 'No-Show';
                    evtToUpdate.add(v);
                }
            }

            // get the leads
            leadEvents = [
                    SELECT Id, ActivityDate, StartDateTime, Appointment_Result__c, WhatId
                    FROM Event
                    WHERE ActivityDate >= :stDate AND ActivityDate <= :enDate
                        AND  (Appointment_Result__c = '' OR Appointment_Result__c = 'Future Appointment')
                        AND WhoId IN (SELECT Id FROM Lead)
                        AND (NOT WhatId IN :evtIds)
            ];

            for (Event v : leadEvents) {
                v.Appointment_Result__c = 'No-Show';
                evtToUpdate.add(v);
            }

            System.debug('Number of Events Updated: ' + evtToUpdate.size());
            update evtToUpdate;

        } catch (Exception ex) {
            System.debug('Error occurred attempting to process Show/No-Show: ' + ex.getMessage());
        }
    }
}