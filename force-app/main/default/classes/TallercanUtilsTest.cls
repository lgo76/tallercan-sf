/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-30-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TallercanUtilsTest {
    
    @testSetup
    static void setupTestData() {

        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

        Account newPersonAccount = new Account();
        // Create test Account
        Account acc = new Account(FirstName = 'Test Account', LastName = 'Test', recordTypeId = personAccountRecordTypeId);
        insert acc;
        Account a = [SELECT Id from Account LIMIT 1];

       
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

        // Create test Opportunity (reception)
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            LK_Vehicle__c = v.Id,
            StageName  = 'Created',
            Reception_Date__c = Date.today()
        );
        insert opp;

        // Create test Products
        Product2 prod1 = new Product2(Name = 'Product 1', IsActive = true, Required_materials__c = 'Material1');
        Product2 prod2 = new Product2(Name = 'Product 2', IsActive = true, Required_materials__c = 'Material2');
        insert new List<Product2> { prod1, prod2 };

        // Create Pricebook
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        
        // Create Pricebook Entries
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id, Product2Id = prod1.Id, UnitPrice = 100, IsActive = true
        );
        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id, Product2Id = prod2.Id, UnitPrice = 200, IsActive = true
        );
        insert new List<PricebookEntry> { pbe1, pbe2 };
    }
    
    @isTest
    static void testCreateRelatedQuotesByCategory() {
        // Retrieve test data
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1' LIMIT 1];
        Product2 prod2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2' LIMIT 1];
        
        // Create request object
        TallercanUtils.Request request = new TallercanUtils.Request();
        request.receptionId = opp.Id;
        request.category = 'Standard';
        request.servicesObject = new List<Product2> { prod1, prod2 };
        
        List<TallercanUtils.Request> requests = new List<TallercanUtils.Request> { request };

        // Test the createRelatedQuotesByCategory method
        Test.startTest();
        TallercanUtils.createRelatedQuotesByCategory(requests);
        Test.stopTest();
        
        // Verify OpportunityLineItems creation
        List<OpportunityLineItem> oppLineItems = [SELECT Id, OpportunityId, Product2Id, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        System.assertEquals(2, oppLineItems.size(), 'There should be 2 OpportunityLineItems');
        
        // Verify details of the created line items
        OpportunityLineItem oli1 = oppLineItems[0];
        OpportunityLineItem oli2 = oppLineItems[1];
        
        System.assertEquals(opp.Id, oli1.OpportunityId, 'OpportunityId should match the provided Opportunity Id');
        System.assertEquals(opp.Id, oli2.OpportunityId, 'OpportunityId should match the provided Opportunity Id');
        
        System.assertEquals(prod1.Id, oli1.Product2Id, 'First OpportunityLineItem should be for Product 1');
        System.assertEquals(prod2.Id, oli2.Product2Id, 'Second OpportunityLineItem should be for Product 2');
        
        System.assertEquals(1, oli1.Quantity, 'Quantity should be 1 for the first item');
        System.assertEquals(1, oli2.Quantity, 'Quantity should be 1 for the second item');
        
        System.assertEquals(100, oli1.UnitPrice, 'UnitPrice should be 100 for the first item');
        System.assertEquals(200, oli2.UnitPrice, 'UnitPrice should be 200 for the second item');
    }
}
