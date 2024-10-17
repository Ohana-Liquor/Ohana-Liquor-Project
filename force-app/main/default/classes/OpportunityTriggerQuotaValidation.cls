public with sharing class OpportunityTriggerQuotaValidation {
    public static void QuotaValidation(List<Opportunity> opportunities) {

        String INSIDESALES_NAME = '인사이드영업';
        Map<Id, User> usersMap = new Map<Id, User>();

        for(Opportunity opp: opportunities){
            Id createdById = opp.CreatedById;
            Id Id = opp.OwnerId;
            User createUser = [SELECT Id, UserRole.Name, Daily_Quota_Opportunity_Count__c FROM User WHERE Id =: createdById];
            User ownerUser = [SELECT Id, UserRole.Name, Daily_Quota_Opportunity_Count__c FROM User WHERE Id =: Id];
            
            // 인사이드 영업이면서 할당된 업무량이 5개 이상일 경우에만 조건 실행
            if (createUser.UserRole.Name == INSIDESALES_NAME && ownerUser.Daily_Quota_Opportunity_Count__c >=5){
                opp.addError('해당 필드 영업 사원은 할당된 업무량이 초과했습니다');
            }
        }
    }
}