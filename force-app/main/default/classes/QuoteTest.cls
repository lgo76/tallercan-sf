@Istest
public with sharing class QuoteTest {
    
    static Product2 createMaterial(boolean stock){
        Product2 newProduct = new Product2();
        
        // Set the required fields
        newProduct.Name = 'material1';
        newProduct.ProductCode = 'MAT1-1';
        newProduct.IsActive = true;
        newProduct.Is_service__c = false;
        newProduct.Category__c = 'Standard';
        newProduct.Family = 'matCategory';
        newProduct.Stock__c = stock;
        return newProduct;
    }
    
    static Product2 createService(String materials){
        Product2 newProduct = new Product2();
        // Set the required fields
        newProduct.Name = 'service1';
        newProduct.ProductCode = 'SV1';
        newProduct.IsActive = true;
        newProduct.Is_service__c = true;
        newProduct.Required_materials__c = materials;
        return newProduct;
    }
    
    static List<OpportunityLineItem> createOppLineItems(Opportunity reception, List<Product2> products){
        
        Map<Id, PricebookEntry> mapProductPricebook = getPBMap();
        List<OpportunityLineItem> oliToInsert = new List<OpportunityLineItem>();
        OpportunityLineItem oli1 = null;
		        
        for(Product2 p : products){
            //Create OppLineItems
            oli1 = new OpportunityLineItem();
            oli1.PricebookEntryId = mapProductPricebook.get(p.Id).Id;
            oli1.Quantity = 1;
            oli1.opportunityId = reception.Id;
            oli1.product2id = p.Id;
            oli1.UnitPrice = mapProductPricebook.get(p.Id).UnitPrice * oli1.Quantity;
            oliToInsert.add(oli1);
            }
        insert oliToInsert;
        
        return oliToInsert;
    }
    
    static List<QuoteLineItem> createQuoteLineItems(List<Product2> prods, Quote q, Map<Id, PricebookEntry> ppbeMap){
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        for(Product2 p: prods){
            // Create a QuoteLineItem record
            qliList.add(new QuoteLineItem(
                QuoteId = q.Id,
                PricebookEntryId = ppbeMap.get(p.Id).Id,
                Quantity = 1,
                UnitPrice = 100
            ));
        }
        insert qliList;
        return qliList;
    }
    
    static Map<Id, PricebookEntry> getPBMap(){
        List<PricebookEntry> pbentriesinserted = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry];
        Map<Id, PricebookEntry> mapProductPricebook = new Map<Id, PricebookEntry>();
        for(PricebookEntry pbe1:pbentriesinserted){
            mapProductPricebook.put(pbe1.Product2Id, pbe1);
        }
        return mapProductPricebook;
    }
    
    @isTest
    public static void quoteTest(){
		Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        // Create Account
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

        // Create Vehicle
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

        // Create reception
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp Prueba';
        opp.Description = 'Prueba de oportunidad';
        opp.AccountId = acc.id;
        opp.Amount = 500;
        opp.CloseDate = Date.today().addDays(10);
        opp.StageName = 'Created';
        opp.LK_Vehicle__c = v.Id;
        insert opp;
        
        Test.startTest();
        //Create quote
        Quote quo = new Quote();
        quo.Name = 'Presupuesto Prueba';
        quo.Status = 'Draft';
        quo.OpportunityId = opp.Id;
        insert quo;
                
		List<Quote> presupuesto = [SELECT Id, Name, Status from Quote Where Name IN ('Presupuesto Prueba')];
    	Quote q1 = presupuesto[0];

        
        q1.Name = 'Nuevo Nombre de Presupuesto';
        update q1;
        
        Quote modifiedQuote = [SELECT Id, Name FROM Quote WHERE Id = :q1.Id];
        System.assertEquals('Nuevo Nombre de Presupuesto', modifiedQuote.Name);
            
 
        delete q1;
    

        List<Quote> deletedQuotes = [SELECT Id FROM Quote WHERE Id = :q1.Id];
        System.assertEquals(0, deletedQuotes.size());
        Test.stopTest();
	}

	@isTest
    static void quotesApprovedInReceptionErrorTest() {   
		Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        // Create Account
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

        // Create Vehicle
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

        // Create reception
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Opp Prueba 2';
        opp2.Description = 'Prueba de oportunidad';
        opp2.AccountId = acc2.id;
        opp2.Amount = 500;
        opp2.StageName = 'Created';
        opp2.LK_Vehicle__c = v2.Id;
        insert opp2;
        
        Opportunity opp2record = [SELECT Id from Opportunity LIMIT 1];
        
        //Create Quotes
        Quote quo2 = new Quote();
        quo2.Name = 'Presupuesto Prueba 2';
        quo2.Status = 'Draft';
        quo2.OpportunityId = opp2record.Id;
        insert quo2;

        Quote quo3 = new Quote();
        quo3.Name = 'Presupuesto Prueba 3';
        quo3.Status = 'Accepted';
        quo3.OpportunityId = opp2record.Id;
        insert quo3;

        Test.startTest();
		List<Quote> pres = [SELECT Id, Name, Status from Quote Where Name IN ('Presupuesto Prueba 2')];
    	Quote q2 = pres[0];

        // Modify estado de la Quote
        q2.Status = 'Accepted';
        
        try{
        update q2;
        }catch(System.DMLException e){
            //System.DmlException: Update failed. First exception on row 0 with id 0Q068000005FWpECAW; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Cannot approve more than one quote for each reception.: []
            System.debug(e.getMessage()); 
            //Assert Error Message
			System.assert(e.getMessage().contains('Update failed. First exception on row 0 with id'),e.getMessage());
            System.assert(e.getMessage().contains(' first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,'+' Cannot approve more than one quote for each reception.: []'),e.getMessage());
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0));
        }
        // Obtener la Quote para comprobar que no ha sido modificada
        Quote modifiedQuote2 = [SELECT Id, Name, Status FROM Quote WHERE Id = :q2.Id];
        System.assertEquals('Draft', modifiedQuote2.Status);   
        Test.stopTest();
	}
    
    @isTest
    static void approveQuoteTest() {   
		Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        // Create Account
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

        // Create Vehicle
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
        
        //Create materials and services
        Product2 serviceCreated = createService('matCategory');
        Product2 materialWithStock = createMaterial(false);
        //Create services and materials
        List<Product2> materialAndServiceList = new List<Product2>();
        materialAndServiceList.add(materialWithStock);
        materialAndServiceList.add(serviceCreated);
        insert materialAndServiceList;
        
        List<Product2> productsList = [SELECT Id, ProductCode, Name, Is_Service__c, Stock__c from Product2];
        
        //Create pricebookentries
        Id standardPricebookId = Test.getStandardPricebookId();
        System.debug('Standard Pricebook Id: ' + standardPricebookId);

        System.debug('Products List: ' + productsList);
        List<PricebookEntry> pbentries = new List<PricebookEntry>();
        for(Product2 p: productsList){
            //Create PBEntries
            pbentries.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = p.Id,
            UnitPrice = 100,
            IsActive = true));
        }
        insert pbentries;

        // Create reception
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Opp Prueba 2';
        opp2.Description = 'Prueba de oportunidad';
        opp2.AccountId = acc2.id;
        opp2.Amount = 500;
        opp2.StageName = 'Created';
        opp2.LK_Vehicle__c = v2.Id;
        insert opp2;
        
        Opportunity opp2record = [SELECT Id from Opportunity LIMIT 1];
        List<OpportunityLineItem> olis = createOppLineItems(opp2record, productsList);

        
        //Create Quotes
        Quote quo2 = new Quote();
        quo2.Name = 'Presupuesto Prueba 2';
        quo2.Status = 'Draft';
        quo2.OpportunityId = opp2record.Id;
        insert quo2;
        
        
        //Create Quote Line Items
        List<QuoteLineItem> qliList = createQuoteLineItems(productsList, quo2, getPBMap());
        System.debug('QLI: ' + qliList);
        

        Quote quo3 = new Quote();
        quo3.Name = 'Presupuesto Prueba 3';
        quo3.Status = 'Draft';
        quo3.OpportunityId = opp2record.Id;
        insert quo3;

        Test.startTest();
		List<Quote> pres = [SELECT Id, Name, Status from Quote Where Name IN ('Presupuesto Prueba 2')];
    	Quote q2 = pres[0];

        // Modify estado de la Quote
        q2.Status = 'Accepted';
        
        
        update q2;
        List<Service_Monitoring__c> smlist =[SELECT Id from Service_Monitoring__c];
        System.debug('LIST: ' + smlist.size());
        System.assert(smList.size() > 0);   
        Test.stopTest();
	}
}