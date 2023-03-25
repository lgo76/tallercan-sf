@isTest
public class VehicleTest {
    
    @isTest
    static void vehicleNumberPlateErrorTest() {
        Account a = new Account();
        a.Name = 'Account Prueba 1';
        insert a;
        Vehicle__c v = new Vehicle__c();
        v.Name = 'Test1';
        v.Chasis_number__c = '465859845';
        v.DT_Car_Registration_Date__c = Date.today();
        v.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        v.PK_Fuel_Type__c = 'Fuel Oil';
        v.PK_Vehicle_Brand__c = 'BMW';
        v.PK_Vehicle_Model__c = '2 Series';
        v.TX_Car_Number_Plate__c = '655447866';
        v.LK_Vehicle_Owner__c = a.Id;
        Test.startTest();
        try{
        	insert v;
        }catch(DmlException e){
            System.debug(e.getMessage());
            //Assert Error Message 
			System.assert(e.getMessage().contains('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,'+' Matrícula errónea: [TX_Car_Number_Plate__c]') ,e.getMessage());

			//Assert field 
			System.assertEquals(Vehicle__c.TX_Car_Number_Plate__c, e.getDmlFields(0)[0]);
            
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0));
    	}
        Test.stopTest();     
    }
    
    @isTest
    static void vehicleNumberPlateOKTest() {
        Account a = new Account();
        a.Name = 'Account Prueba 1';
        insert a;
        Vehicle__c v = new Vehicle__c();
        v.Name = 'Test1';
        v.Chasis_number__c = '465859845';
        v.DT_Car_Registration_Date__c = Date.today();
        v.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        v.PK_Fuel_Type__c = 'Fuel Oil';
        v.PK_Vehicle_Brand__c = 'BMW';
        v.PK_Vehicle_Model__c = '2 Series';
        v.TX_Car_Number_Plate__c = '4321HTT';
        v.LK_Vehicle_Owner__c = a.Id;
        Test.startTest();
        try{
        	insert v;
            List<Vehicle__c> vehicles = [SELECT Id from Vehicle__c];
            System.assert(vehicles.size() > 0);
            
        }catch(DmlException e){}
        Test.stopTest();     
    }
    
    
    /**@isTest
    static void vehicleNextITVRevisionDateErrorTest() {
        Account a = new Account();
        a.Name = 'Account Prueba 1';
        insert a;
        Vehicle__c v = new Vehicle__c();
        v.Name = 'Test1';
        v.Chasis_number__c = '465859845';
        v.DT_Car_Registration_Date__c = Date.today();
        v.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        v.PK_Fuel_Type__c = 'Fuel Oil';
        v.PK_Vehicle_Brand__c = 'BMW';
        v.PK_Vehicle_Model__c = '2 Series';
        v.TX_Car_Number_Plate__c = '655447866';
        v.LK_Vehicle_Owner__c = a.Id;
        Test.startTest();
        try{
        	insert v;
        }catch(DmlException e){
            System.debug(e.getMessage());
            //Assert Error Message 
			System.assert(e.getMessage().contains('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,'+' Matrícula errónea: [TX_Car_Number_Plate__c]') ,e.getMessage());

			//Assert field 
			System.assertEquals(Vehicle__c.TX_Car_Number_Plate__c, e.getDmlFields(0)[0]);
            
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0));
    	}
        Test.stopTest();     
    }**/
    
}