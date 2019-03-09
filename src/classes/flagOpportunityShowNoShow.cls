/**
 * Created by admin on 2019-03-06.
 */

public with sharing class flagOpportunityShowNoShow {

    public static void flagOpps(Integer yr, Integer mt) {

        Date stDate = Date.newInstance(yr, mt, 1);
        Date enDate = Date.today().addDays(-1); // use yesterday's date --- Date.newInstance(yr, mt, Date.daysInMonth(yr, mt));

        Set<ID> evtIds = new Set<ID>();

        List<Event> evts = [SELECT Id, ActivityDate, StartDateTime, Appointment_Result__c, WhatId
        FROM Event
        WHERE WhatId != '' AND Appointment_Result__c = ''
        AND ActivityDate >= :stDate  AND ActivityDate <= : enDate LIMIT 400];

        // get WhatIds
        for (Event v : evts) {
            evtIds.add(v.WhatId);
        }

        Map<Id, Opportunity> oppMap = (new Map<Id, Opportunity>([SELECT Id, CreatedDate FROM Opportunity WHERE Id IN : evtIds]));
        Map<Id, Lead> leadMap = (new Map<Id, Lead>([SELECT Id, CreatedDate FROM Lead WHERE Id IN : evtIds]));

        System.debug('Number of Opps: ' + oppMap.size());
        System.debug('Number of Events: ' + evts.size());

        List<Event> evtToUpdate = new List<Event>(); // build list of Events to update
        for( Event v : evts) {

            Date opDate = null;
            Opportunity op = oppMap.get(v.WhatId);
            Lead ld = leadMap.get(v.WhatId);

            if (op != null) {
                opDate = Date.newInstance(op.CreatedDate.year(), op.CreatedDate.month(), op.CreatedDate.day());
            } else if (ld != null) {
                opDate = Date.newInstance(ld.CreatedDate.year(), ld.CreatedDate.month(), ld.CreatedDate.day());
            }

            if (opDate != null) {
                if (opDate == v.ActivityDate) {
                    v.Appointment_Result__c = 'Show';
                    evtToUpdate.add(v);
                } else if (v.ActivityDate < Date.TODAY()) {
                    v.Appointment_Result__c = 'No-Show';
                    evtToUpdate.add(v);
                }
            }
        }

        System.debug('To update: ' + evtToUpdate.size());
        update evtToUpdate;

    }
}