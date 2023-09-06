/**
 * @description       : 
 * @author            : Shubham Raut
 * @group             : 
 * @last modified on  : 09-06-2023
 * @last modified by  : Shubham Raut
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   09-05-2023   Shubham Raut   Initial Version
**/
public with sharing class FileUploadUtility {
    
    @AuraEnabled(cacheable = false)
    public static String uploadFiles(String base64, String fileName, String recordId){
        try {
            ContentVersion cv = createContentVersion(base64, fileName);
            ContentDocumentLink cdl = createContentDocumentLink(cv.Id, recordId);
            return cdl.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static ContentVersion createContentVersion(String base64, String fileName) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        insert cv;
        return cv;
    }

    private static ContentDocumentLink createContentDocumentLink(Id contentVersionId, String recordId) {
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1].ContentDocumentId;
        insert cdl;
        return cdl;
    }

    @AuraEnabled(cacheable = false)
    public static List<ContentDistribution> fetchFiles(String recordId){
        try {
            List<ContentDocumentLink> cdlRecords = [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.CreatedDate, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            List<ContentDistribution> cdRecords = new List<ContentDistribution>();
            List<ContentDistribution> finalCDRecords = new List<ContentDistribution>();
            List<ContentVersion> cvRecords = new List<ContentVersion>();

            Set<Id> contentDocumentIds = new Set<Id>();
            for(ContentDocumentLink cdl: cdlRecords){
                if(String.isNotBlank(cdl.ContentDocumentId)){
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
            }
            for(ContentDistribution cdRec: [SELECT Id, Name, DistributionPublicUrl, ContentDocumentId FROM ContentDistribution WHERE ContentDocumentId IN :contentDocumentIds]){
                finalCDRecords.add(cdRec);
                contentDocumentIds.remove(cdRec.ContentDocumentId);
            }

            cvRecords = [SELECT Id,Title FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
            for(ContentVersion cv: cvRecords){
                /* Creating ContentDistribution record */
                ContentDistribution cd = new ContentDistribution(
                    Name = cv.Title,
                    ContentVersionId = cv.Id,
                    PreferencesAllowViewInBrowser= true
                );

                cdRecords.add(cd);
            }

            Database.insert(cdRecords, false);
            finalCDRecords.addAll([SELECT Id, Name, DistributionPublicUrl FROM ContentDistribution WHERE Id IN :cdRecords]);
            return finalCDRecords;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}