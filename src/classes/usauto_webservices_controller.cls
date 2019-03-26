/**
 * Created by admin on 2019-03-22.
 * THIS IS BEGINNING A CONVENTIONAL CHANGE IN DESIGN APPROACH.  THIS FILE BECOMES THE LOCATION FOR ALL INTERNAL WEB
 * SERVICES -- TO REPLACE THE CLASS: mw_worksheet_controller
 */

public with sharing class usauto_webservices_controller {

    /************************************************************************
    *
    *
    *      GLOBAL VARIABLES
    *
    *************************************************************************/
    @TestVisible private static String gPortalId;


    /************************************************************************
    *
    *
    *       WEB SERVICE CALLOUT SECTION
    *
    *************************************************************************/
    private static String endPoint_Token = 'https://sf.usauto-sales.com/auth/token';
    private static String userName = 'nomeally@usauto-sales.com';
    private static String userPswd = 'USAuto12!';
    //private static String endPoint_Deal = 'https://sf.usauto-sales.com/salesforce/getSFDeals?DealID=';
    //private static String endPoint_Vehicles = 'https://sf.usauto-sales.com/salesforce/getSFVehicles';
    private static String endPoint_Sold = 'https://sf.usauto-sales.com/salesforce/getSFSoldVehicles';

    // the callout
    private static String webServiceGet(String endPoint, String securityKey, String securityToken, String callMethod,
            String payload) {

        String score = 'Inside webService Get';
        System.debug('Inside webServiceGet');

        try {

            HttpResponse response;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod(callMethod);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Content-Length', '0'); // Not sure why this is required.
            request.setTimeout(120000);
            request.setEndpoint(endPoint);
            request.setHeader(securityKey, securityToken);

            if (payload != null) {
                request.setBody(payload);
            }

            System.debug('The Request: ' + request.getHeader('Authorization') + ' ~~~ ' + request.getHeader(securityKey));
            System.debug('The Request Body: ' + payload);

            response = http.send(request);
            score = 'Response Message: ' + response.getStatusCode() + ' ~~~ ' + response.getBody() + ' ~~~~~'  + request;

            System.debug('webServiceGet Method: ' + score);
            if (response.getStatusCode() == 200) {
                score = ( String.isEmpty(response.getBody()) ? String.valueOf(response.getStatusCode()) : response.getBody()) ;
            } else {
                System.debug(score);
            }

        } catch (Exception e) {
            String errMsg = 'Error: (usauto_webservices_controller->webServiceGet): ' + e.getMessage();
            System.debug(errMsg);
            throw new webServicesException(errMsg);
        }

        return score;
    }

    // get the callout token
    @AuraEnabled
    public static String retrieveToken() {
        String token;

        try {

            HttpResponse response;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000);
            request.setEndpoint(endPoint_Token);

            JSONGenerator msgBody = JSON.createGenerator(true);
            msgBody.writeStartObject();
            msgBody.writeStringField('Email', userName);
            msgBody.writeStringField('password', userPswd);
            msgBody.writeEndObject();

            //System.debug('get token body: ' + msgBody);
            request.setBody(msgBody.getAsString());
            response = http.send(request);

            //System.debug('Response Message: ' + response.getStatusCode() + ' ~~~ ' + response.getBody());
            if (response.getStatusCode() == 200) {
                token = response.getBody(); //JSON.serialize(fr);
            } else {
                System.debug(response.getStatusCode());
            }
        } catch (Exception e) {
            String errMsg = 'Error: (usauto_webservices_controller->retrieveToken) ' + e.getMessage();
            System.debug(errMsg);
            throw new webServicesException(errMsg);
        }

        return token;
    }

    //GET VEHICLES SOLD
    @AuraEnabled
    public static String vehiclesSold(String securityToken, String st, String en) {
        String result = null;

        if (st != null && en != null) {

            try {
                Map<String, Object> token = (Map<String, Object>) JSON.deserializeUntyped(securityToken);
                String securityKey = 'Authorization';
                String securityValue = 'Bearer ' + token.get('access_token');
                String callMethod = 'POST';

                System.debug('inside vehicleSold Method on usauto_webservices_controller');

                JSONGenerator generator = JSON.createGenerator(true);    //instantiation of the generator
                generator.writeStartObject();                // Writes the starting marker of a JSON object '{'

                generator.writeStringField('soldFrom', st);    //Writes the lot id
                generator.writeStringField('soldThru', en);

                generator.writeEndObject();                //Writes the ending marker of a JSON object '}'
                String payLoad = generator.getAsString();

                result = webServiceGet(endPoint_Sold, securityKey, securityValue, callMethod, payLoad);
                System.debug('Inside vehicle sold Result: ' + result);

            } catch (Exception ex) {
                String errMsg = 'Error: (usauto_webservices_controller->vehiclesSold) ' + ex.getMessage();
                System.debug(errMsg);
                throw new webServicesException(errMsg);
            }
        }

        return result;
    }

    public class webServicesException extends Exception {}


}