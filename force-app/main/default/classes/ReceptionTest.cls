@isTest
public class ReceptionTest {
    
    @isTest
    static void receptionCreationCloseDateTest(){
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        // Create an account.
        Account a = new Account();
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
        
        // Create a vehicle.
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
        
        // Create an opportunity.
        Opportunity r = new Opportunity();
        r.Name = 'Reception Test';
        r.AccountId = a1.Id;
        r.StageName ='Making budget';
        r.LK_Vehicle__c = v1.Id;
        insert r;
        
        //  Perform a query after insertion.
        Opportunity opp = [SELECT Id, Name, CloseDate FROM Opportunity WHERE Id = :r.Id];
        
        // It checks that the CloseDate field matches the current date + 1 year.
		System.assertEquals(Date.today().AddDays(365), opp.CloseDate, 'The CloseDate field does not have the correct value.');

    }
    
    @isTest
	static void receptionCreationEmailTest(){
		
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        // Create an account.
        Account acc = new Account();
        acc.FirstName = 'Account Prueba 2';
        acc.LastName = 'Apellidos Prueba 2';
        acc.BillingStreet = 'Calle Inventada 2';
        acc.BillingCity = 'Santander';
        acc.BillingCountry = 'Spain';
        acc.Phone = '633445533';
        acc.PersonHomePhone = '942333333';
        acc.PersonEmail = 'prueba2@prueba.com';
        acc.Document_Number__c = '76655443H';
        acc.recordTypeId = personAccountRecordTypeId;
        insert acc;
        
        // Create a vehicle.
        Vehicle__c veh = new Vehicle__c();
        veh.Name = 'Test 2';
        veh.Chasis_number__c = '465859845';
        veh.DT_Car_Registration_Date__c = Date.today();
        veh.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        veh.PK_Fuel_Type__c = 'Fuel Oil';
        veh.PK_Vehicle_Brand__c = 'BMW';
        veh.PK_Vehicle_Model__c = '2 Series';
        veh.TX_Car_Number_Plate__c = '4321HTT';
        veh.LK_Vehicle_Owner__c = acc.Id;
        insert veh;

        // Create a contact associated with the account.
    	Contact con = new Contact();
    	con.FirstName = 'Nombre de Prueba';
    	con.LastName = 'Apellidos de Prueba';
    	con.Email = 'prueba2@prueba.com';
    	insert con;
        
        // Create an opportunity.
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Reception Test';
        opp2.AccountId = acc.Id;
        opp2.StageName ='Making budget';
        opp2.LK_Vehicle__c = veh.Id;
        insert opp2;
        
    	// Create an email.
    	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    	email.setTargetObjectId(con.Id);
    	email.setSubject('Correo de prueba');
    	email.setPlainTextBody('Este es un correo de prueba.');

    	// Send the email.
   	 	Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

    	// Check if the email was sent correctly.
    	System.assert(results[0].isSuccess(), 'El correo no se envió correctamente.');
	}
    
    @isTest
    static void receptionDeleteWorkStatusTest(){

        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        // Create an account.
        Account acc3 = new Account();
        acc3.FirstName = 'Account Prueba 3';
        acc3.LastName = 'Apellidos Prueba 3';
        acc3.BillingStreet = 'Calle Inventada 3';
        acc3.BillingCity = 'Santander';
        acc3.BillingCountry = 'Spain';
        acc3.Phone = '633445533';
        acc3.PersonHomePhone = '942333333';
        acc3.PersonEmail = 'prueba2@prueba.com';
        acc3.Document_Number__c = '76655443H';
        acc3.recordTypeId = personAccountRecordTypeId;
        insert acc3;
        
        // Create a vehicle.
        Vehicle__c veh3 = new Vehicle__c();
        veh3.Name = 'Test 3';
        veh3.Chasis_number__c = '465859845';
        veh3.DT_Car_Registration_Date__c = Date.today();
        veh3.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        veh3.PK_Fuel_Type__c = 'Fuel Oil';
        veh3.PK_Vehicle_Brand__c = 'BMW';
        veh3.PK_Vehicle_Model__c = '2 Series';
        veh3.TX_Car_Number_Plate__c = '4321HTT';
        veh3.LK_Vehicle_Owner__c = acc3.Id;
        insert veh3;
        
        // Create an opportunity.
        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Reception Test 3';
        opp3.AccountId = acc3.Id;
        opp3.StageName ='Making budget';
        opp3.LK_Vehicle__c = veh3.Id;
        insert opp3;        
        
        // Create Work Status (Service_monitoring__c).
        Service_monitoring__c ser = new Service_monitoring__c();
        ser.Name = 'Test 3 Service';
        ser.Related_reception_service__c = opp3.Id;
        insert ser;

        // Remove the opportunity.
        delete opp3;

    	// Verify if the Service_monitoring__c record has also been deleted.
    	try {
        	Service_monitoring__c deletedSer = [SELECT Id FROM Service_monitoring__c WHERE Related_reception_service__c = :opp3.Id LIMIT 1];
        	System.assert(deletedSer == null, 'The Service_monitoring__c record was not deleted correctly.');
   	 	} catch (QueryException e) {
        	System.debug('No Service_monitoring__c record found. This is expected.');
    		}  
    }
}