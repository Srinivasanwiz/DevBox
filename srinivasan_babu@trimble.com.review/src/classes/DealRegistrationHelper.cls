/*****************************************************************************************
    Name    : DealRegistrationHelper 
    Desc    : 
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       4/27/2013          Created
******************************************************************************************/
global class DealRegistrationHelper {

    public static void PartOppCreation(Map < Id, Deal_Registration__c > mapDealRegnew, Map < Id, Deal_Registration__c > mapDealRegold) {
        Schema.DescribeSObjectResult oppObj = Schema.SObjectType.Opportunity;
        Map < String, Schema.RecordTypeInfo > rtMapByName = OppObj.getRecordTypeInfosByName();
        //Id opprecordTypeId = rtMapByName.get('Partner Opportunity Record Type').getRecordTypeId();
        Id opprecordTypeId = rtMapByName.get('Opportunity (Partner) Record Type').getRecordTypeId();
        Id accPendingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account (Pending) Record Type').getRecordTypeId();
       
        Id conrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact (Partner User) Record Type').getRecordTypeId();
        Set < id > setDealId = new Set < id > ();
        List < Opportunity > lstParentOpp = new List < Opportunity > ();
        List < Account > lstParentAcc = new List < Account > ();
        Boolean ret = false;
        Opportunity parentOpp;
        Map < String, Deal_Registration__c > mapNameDealReg = new Map < String, Deal_Registration__c > ();
        Map < String, Opportunity > oppMap = new Map < String, Opportunity > ();
        Map < String, Contact > conMap = new Map < String, Contact > ();
        for (Deal_Registration__c dr: mapDealRegnew.values()) {
            system.debug('Status New === ' + dr.Approval_Status__c);
            system.debug('Status Old === ' + mapDealRegold.get(dr.id).Approval_Status__c);
            if (dr.Approval_Status__c == 'Approved' && mapDealRegold.get(dr.id).Approval_Status__c != 'Approved') {
                //Creating Opportunity
                parentOpp = new Opportunity();
                parentOpp.name = dr.Name + ' - PartnerOpp';
                parentOpp.Type = 'New Customer';
                parentOpp.Amount = dr.Approximate_Deal_Amount_Rollup__c;
                parentOpp.CloseDate = dr.Estimated_Close_Date__c;
                parentOpp.stageName = dr.Sales_Stage__c;
                parentOpp.RecordtypeId = opprecordTypeId;
                // opportunity ownership is given to deal reg owner
                parentOpp.OwnerId = dr.OwnerId;
                parentOpp.LeadSource = 'Partner Registered Deal';
                lstParentOpp.add(parentOpp);
                mapNameDealReg.put(dr.Name + ' - PartnerOpp', dr);

                ret = true;
                //Creating Account
                Account acc = new Account();
                acc.Name = dr.Company__c;
                acc.Type = 'Customer - Channel End User';
                acc.Account_Status__c = 'Pending';
                acc.RecordtypeId = accPendingRecordTypeId;
                acc.Requested_Account_Record_Type__c = 'Account (Customer) Record Type';
                acc.Website = dr.Website__c;
                acc.Industry = dr.Industry__c;
                acc.BillingCity = dr.City__c;
                acc.BillingCountry = dr.Country__c;
                acc.BillingState = dr.State_Province__c;
                acc.BillingStreet = dr.Street__c;
                acc.BillingPostalCode = dr.Zip_Postal_Code__c;
                acc.ShippingCity = dr.City__c;
                acc.ShippingCountry = dr.Country__c;
                acc.ShippingState = dr.State_Province__c;
                acc.ShippingStreet = dr.Street__c;
                acc.ShippingPostalCode = dr.Zip_Postal_Code__c;
                acc.OwnerId = dr.OwnerId;

                lstParentAcc.add(acc);
                oppMap.put(acc.Name, parentOpp);

                //Creating Contact
	
                Contact con = new Contact();
                con.RecordtypeId = conrecordTypeId;
                con.FirstName = dr.First_Name__c;
                con.LastName = dr.Last_Name__c;
                con.Title = dr.Title__c;
                con.Email = dr.Email__c;
                con.MailingCity = dr.City__c;
                con.MailingCountry = dr.Country__c;
                con.MailingState = dr.State_Province__c;
                con.MailingStreet = dr.Street__c;
                con.MailingPostalCode = dr.Zip_Postal_Code__c;
                con.MobilePhone = dr.Mobile__c;
                con.Phone = dr.Phone__c;
                con.OwnerId = dr.OwnerId;
                conMap.put(acc.Name, con);
            }
        }

        if (ret) {
            if (lstParentAcc.size() > 0) {
                insert lstParentAcc;
                for (Account acc: lstParentAcc) {
                    if (oppMap.containsKey(acc.name)) {
                        oppMap.get(acc.name).AccountId = acc.Id;
                        conMap.get(acc.name).AccountId = acc.Id;
                    }
                    //triggering approval process
                    /** commented this code on 30/06/2013, 
                      *as automatic approval process already exists, code is already written in AccountTrigger
                    if (acc.Account_Status__c == 'Pending' && acc.RecordtypeId == accPendingRecordTypeId) {
                        // create the new approval request to submit
                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setComments('Submitted for approval. Please approve.');
                        req.setObjectId(acc.Id);
                        // submit the approval request for processing
                        Approval.ProcessResult result = Approval.process(req);
                    }*/
                }
            }
            if (oppMap.values().size() > 0) {
                insert oppMap.values();

                for (Opportunity opp: oppMap.values()) {
                    if (mapNameDealReg.containsKey(opp.name)) {
                        mapNameDealReg.get(opp.name).Partner_Opportunity__c = opp.Id;
                        mapNameDealReg.get(opp.name).Partner_Account__c = opp.AccountId;
                    }
                }
            }
            if (conMap.values().size() > 0) {
                insert conMap.values();
            }
            OpportunityLineItem oli;
            Map < ID, Deal_Registration_Line__c > mapDealReg = new Map < ID, Deal_Registration_Line__c > ();
            Map < ID, ID > mapDealRegProduct = new Map < ID, ID > ();
            List < OpportunityLineItem > lstOppLineItem = new List < OpportunityLineItem > ();
            for (Deal_Registration_Line__c drl: [SELECT CreatedById, CreatedDate, Deal_Registration__c, Deal_Registration__r.Name, Id, IsDeleted, LastModifiedById,
                LastModifiedDate, Name, Product__c, Quantity__c, SystemModstamp, Unit_Price__c, Total_Price__c FROM
                Deal_Registration_Line__c where Deal_Registration__c = : mapDealRegnew.keySet()
            ]) {
                mapDealReg.put(drl.id, drl);
                mapDealRegProduct.put(drl.Product__c, drl.id);
            }
            PriceBook2 pbe2 = new PriceBook2();
            pbe2 = [Select id, name from PriceBook2 where name = 'Philips Lumileds Pricebook'
                limit 1
            ];
            //priceBookList  = [Select id,Product2Id,unitprice from PricebookEntry where Pricebook2Id =: pbe2.Id ];
            //Next take the list of products and create a map for the pricebookid
            List < PricebookEntry > priceBookListforDealRegProducts = [select id, product2id from PricebookEntry where Product2Id in : mapDealRegProduct.keySet() and Pricebook2Id = : pbe2.Id and isActive = true];
            if (!priceBookListforDealRegProducts.isEmpty()) {
                for (PricebookEntry curEntry: priceBookListforDealRegProducts) {
                    oli = new OpportunityLineItem();
                    system.debug('********' + mapDealRegProduct.get(curEntry.product2id));
                    system.debug('********' + mapNameDealReg.get(mapDealReg.get(mapDealRegProduct.get(curEntry.product2id)).Deal_Registration__r.Name + ' - PartnerOpp'));
                    oli.OpportunityId = mapNameDealReg.get(mapDealReg.get(mapDealRegProduct.get(curEntry.product2id)).Deal_Registration__r.Name + ' - PartnerOpp').Partner_Opportunity__c;
                    oli.PricebookEntryId = curEntry.Id;
                    oli.Quantity = mapDealReg.get(mapDealRegProduct.get(curEntry.product2id)).Quantity__c;
                    oli.UnitPrice = mapDealReg.get(mapDealRegProduct.get(curEntry.product2id)).Unit_Price__c;
                    //oli.TotalPrice = mapDealReg.get(mapDealRegProduct.get(curEntry.product2id)).Total_Price__c;
                    lstOppLineItem.add(oli);
                }

                insert lstOppLineItem;
            }
        }
    }

    webservice static string thresholdMetCheck(Id dealId, String dealAmount) {
        String ret = '';
        String totDealAmount;
        totDealAmount = dealAmount.replace('$', '').replace(',', '');
        if (double.valueof(totDealAmount) >= double.valueof(System.Label.Threshold_Amount)) {
            ret = 'true';
            Deal_registration__c dr = [Select id, Approval_Status__c from Deal_registration__c where id = : dealId];
            //  dr.Approval_Status__c = 'Submitted';
            update dr;
            system.debug('>>>>>>>>>>>>>>>>>>DR<<<<<<<<<<<<<<<<<' + dr);

            //setNextApproverIds 
            if (dr.Approval_Status__c == 'Unsubmitted') {
                // create the new approval request to submit
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please approve.');
                req.setObjectId(dr.Id);
                // submit the approval request for processing
                Approval.ProcessResult result = Approval.process(req);
            }
            system.debug('test');
        } else {
            ret = 'false';
        }
        return ret;
    }
}