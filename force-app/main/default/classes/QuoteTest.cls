@Istest
public with sharing class QuoteTest {
        @isTest
        public static void quoteTest(){
		Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        // Crear Account
        Account acc = new Account();
        acc.LastName = 'Prueba';
        acc.FirstName = 'Account';
        acc.BillingStreet = 'Calle Inventada';
        acc.BillingCity = 'Santander';
        acc.BillingCountry = 'Spain';
        acc.Phone = '633445533';
        acc.PersonHomePhone = '942333333';
        acc.PersonEmail = 'prueba@prueba.com';
        acc.Document_Number__c = '76655443H';
        acc.RecordTypeId = personAccountRecordTypeId;
        insert acc;

        // Crear Vehicle
        Vehicle__c v = new Vehicle__c();
        v.Name = 'Test1';
        v.Chasis_number__c = '465859845';
        v.DT_Car_Registration_Date__c = Date.today();
        v.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        v.PK_Fuel_Type__c = 'Fuel Oil';
        v.PK_Vehicle_Brand__c = 'BMW';
        v.PK_Vehicle_Model__c = '2 Series';
        v.TX_Car_Number_Plate__c = '4321HTT';
        v.LK_Vehicle_Owner__c = acc.Id;
        insert v;

        // Crear Opportunity asociada a la Account
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp Prueba';
        opp.Description = 'Prueba de oportunidad';
        opp.AccountId = acc.id;
        opp.Amount = 500;
        opp.CloseDate = Date.today().addDays(10);
        opp.StageName = 'Created';
        opp.LK_Vehicle__c = v.Id;
        insert opp;
        
        //Crear Quote asociada a la Opportunity
        Quote quo = new Quote();
        quo.Name = 'Presupuesto Prueba';
        quo.Status = 'Draft';
        quo.OpportunityId = opp.Id;
        insert quo;
        
        Test.startTest();
		List<Quote> presupuesto = [SELECT Id, Name, Status from Quote Where Name IN ('Presupuesto Prueba')];
    	Quote q1 = presupuesto[0];

        // Modificar la Quote
        q1.Name = 'Nuevo Nombre de Presupuesto';
        update q1;
        // Obtener la Quote modificada
        Quote modifiedQuote = [SELECT Id, Name FROM Quote WHERE Id = :q1.Id];
        System.assertEquals('Nuevo Nombre de Presupuesto', modifiedQuote.Name);
            
        // Eliminar la Quote
        delete q1;
    
        // Verificar que la Quote se eliminó correctamente
        List<Quote> deletedQuotes = [SELECT Id FROM Quote WHERE Id = :q1.Id];
        System.assertEquals(0, deletedQuotes.size());
        Test.stopTest();
        }

   		@isTest
    	static void quotesApprovedTest() {   
		Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        // Crear Account
        Account acc2 = new Account();
        acc2.LastName = 'Prueba2';
        acc2.FirstName = 'Account 2';
        acc2.BillingStreet = 'Calle Inventada 2';
        acc2.BillingCity = 'Santander';
        acc2.BillingCountry = 'Spain';
        acc2.Phone = '633445533';
        acc2.PersonHomePhone = '942333333';
        acc2.PersonEmail = 'prueba@prueba.com';
        acc2.Document_Number__c = '76655443H';
        acc2.RecordTypeId = personAccountRecordTypeId;
        insert acc2;

        // Crear Vehicle
        Vehicle__c v2 = new Vehicle__c();
        v2.Name = 'Test2';
        v2.Chasis_number__c = '465859845';
        v2.DT_Car_Registration_Date__c = Date.today();
        v2.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        v2.PK_Fuel_Type__c = 'Fuel Oil';
        v2.PK_Vehicle_Brand__c = 'BMW';
        v2.PK_Vehicle_Model__c = '2 Series';
        v2.TX_Car_Number_Plate__c = '4321HTT';
        v2.LK_Vehicle_Owner__c = acc2.Id;
        insert v2;

        // Crear Opportunity asociada a la Account
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Opp Prueba 2';
        opp2.Description = 'Prueba de oportunidad';
        opp2.AccountId = acc2.id;
        opp2.Amount = 500;
        opp2.CloseDate = Date.today().addDays(10);
        opp2.StageName = 'Created';
        opp2.LK_Vehicle__c = v2.Id;
        insert opp2;
        
        //Crear Quotes asociada a la Opportunity
        Quote quo2 = new Quote();
        quo2.Name = 'Presupuesto Prueba 2';
        quo2.Status = 'Draft';
        quo2.OpportunityId = opp2.Id;
        insert quo2;

        Quote quo3 = new Quote();
        quo3.Name = 'Presupuesto Prueba 3';
        quo3.Status = 'Approved';
        quo3.OpportunityId = opp2.Id;
        insert quo3;

        Test.startTest();
		List<Quote> pres = [SELECT Id, Name, Status from Quote Where Name IN ('Presupuesto Prueba 2')];
    	Quote q2 = pres[0];

        // Modificar estado de la Quote
        q2.Status = 'Approved';
        update q2;
        // Obtener la Quote modificada
        Quote modifiedQuote2 = [SELECT Id, Name FROM Quote WHERE Id = :q2.Id];
        System.assertEquals('Approved', modifiedQuote2.Status);   
        Test.stopTest();
        }
}