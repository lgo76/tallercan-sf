@isTest
public class CustomerTest{
    
    @isTest
    static void customerCreationTest() {
        
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

        Account a = new Account();
        //a.RecordTypeId = personAccountRT;
        a.FirstName = 'Account Prueba';
        a.LastName = 'Apellidos Prueba';
        a.BillingStreet = 'Calle Inventada';
        a.BillingCity = 'Santander';
        a.BillingCountry = 'Spain';
        a.Phone = '633445533';
        a.PersonHomePhone = '942333333';
        a.PersonEmail = 'prueba@prueba.com';
        a.Document_Number__c = '76655443H';
        a.recordTypeId = personAccountRecordTypeId;
        
       	Test.startTest();
        insert a;
        
        List<Account> a1 = [SELECT Id from Account];
        System.assertEquals(1, a1.size());
        Test.stopTest();
        
    }
    
    
    @isTest
    static void deleteAccountWithActiveReceptionsTest() {
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account a = new Account();
        //a.RecordTypeId = personAccountRT;
        a.FirstName = 'Account Prueba';
        a.LastName = 'Apellidos Prueba';
        a.BillingStreet = 'Calle Inventada';
        a.BillingCity = 'Santander';
        a.BillingCountry = 'Spain';
        a.Phone = '633445533';
        a.PersonHomePhone = '942333333';
        a.PersonEmail = 'prueba@prueba.com';
        a.Document_Number__c = '76655443H';
        a.recordTypeId = personAccountRecordTypeId;
        insert a;
        
        Account a1 = [SELECT Id from Account limit 1];
        
        Vehicle__c v = new Vehicle__c();
        v.Name = 'Test1';
        v.Chasis_number__c = '465859845';
        v.DT_Car_Registration_Date__c = Date.today();
        v.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        v.PK_Fuel_Type__c = 'Fuel Oil';
        v.PK_Vehicle_Brand__c = 'BMW';
        v.PK_Vehicle_Model__c = '2 Series';
        v.TX_Car_Number_Plate__c = '4321HTT';
        v.LK_Vehicle_Owner__c = a1.Id;
        insert v;
        
        Vehicle__c v1 = [SELECT Id FROM Vehicle__c LIMIT 1];
        
        Opportunity r = new Opportunity();
        r.Name = 'Reception Test';
        r.AccountId = a1.Id;
        r.StageName ='Making budget';
        r.LK_Vehicle__c = v1.Id;
        r.CloseDate = Date.newInstance(2024,06,22);
        insert r;
        
       	Test.startTest();
        try{
        	delete a1;
        }catch(DmlException e){
            System.debug(e.getMessage()); 
            //Assert Error Message
			System.assert(e.getMessage().contains('Delete failed. First exception on row 0 with id'),e.getMessage());
            System.assert(e.getMessage().contains(' first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,'+' Cannot delete customer with any active receptions.: []'),e.getMessage());
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0));
    	}
        
        Test.stopTest();
    }

    @isTest
    static void deleteAccountWithClosedReceptionsTest() {
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account a = new Account();
        //a.RecordTypeId = personAccountRT;
        a.FirstName = 'Account Prueba';
        a.LastName = 'Apellidos Prueba';
        a.BillingStreet = 'Calle Inventada';
        a.BillingCity = 'Santander';
        a.BillingCountry = 'Spain';
        a.Phone = '633445533';
        a.PersonHomePhone = '942333333';
        a.PersonEmail = 'prueba@prueba.com';
        a.Document_Number__c = '76655443H';
        a.recordTypeId = personAccountRecordTypeId;
        insert a;
        
        Account a1 = [SELECT Id from Account limit 1];
        
        Vehicle__c v = new Vehicle__c();
        v.Name = 'Test1';
        v.Chasis_number__c = '465859845';
        v.DT_Car_Registration_Date__c = Date.today();
        v.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        v.PK_Fuel_Type__c = 'Fuel Oil';
        v.PK_Vehicle_Brand__c = 'BMW';
        v.PK_Vehicle_Model__c = '2 Series';
        v.TX_Car_Number_Plate__c = '4321HTT';
        v.LK_Vehicle_Owner__c = a1.Id;
        insert v;
        
        Vehicle__c v1 = [SELECT Id FROM Vehicle__c LIMIT 1];
        
        Opportunity r = new Opportunity();
        r.Name = 'Reception Test';
        r.AccountId = a1.Id;
        r.StageName ='Created';
        r.LK_Vehicle__c = v1.Id;
        r.CloseDate = Date.newInstance(2024,06,22);
        insert r;
        
        List<Opportunity> oppslist = [SELECT Id, stagename, isclosed from Opportunity WHERE AccountId =: a1.Id];
        System.debug('OPPPPPS: ' + oppslist);
        
        //Close reception
        update (new Opportunity(id = oppslist[0].Id, stagename = 'Deilvered'));
        List<Opportunity> oppslist2 = [SELECT Id, stagename, isclosed from Opportunity WHERE AccountId =: a1.Id];
        System.debug('OPPPPPS: ' + oppslist2);
        
       	Test.startTest();
        delete a1;
        
        List<Account> deletedCustomerList = [SELECT Id FROM Account WHERE Id = :a1.Id];

        System.assertEquals(0, deletedCustomerList.size());
        
        Test.stopTest();
    }
}