public class OpportunityTriggerHandler {
    public static void OpportunityTriggerInsert(List<Opportunity> Opportunities,  Map<Id,Opportunity> oldMap) {
        // oppty가 Insert될 때마다 해당 oppty의 Owner의 Daily_Quota_Opportunity_Count__c를 1씩 증가시키는 로직
        
        // 각 Owner의 oppty 개수를 저장하기 위한 Map
        Map<Id, Integer> userOpportunityCountMap = new Map<Id, Integer>();

        // 새로 insert되는 oppty들에 대해 loop 돌면서 Owner별로 oppty 개수를 count
        // 수주완료, 수주실패는 제외
        for (Opportunity opp : Opportunities) {
            if (opp.OwnerId != null && (opp.StageName != '수주완료' || opp.StageName != '수주실패')) {
                // OwnerId에 해당하는 값이 Map에 없으면 0으로 초기화
                if (!userOpportunityCountMap.containsKey(opp.OwnerId)) {
                    userOpportunityCountMap.put(opp.OwnerId, 0);
                }
                // 해당 Owner의 oppty 개수를 1씩 증가
                userOpportunityCountMap.put(opp.OwnerId, userOpportunityCountMap.get(opp.OwnerId) + 1);
            }
        }

        // Daily_Quota_Opportunity_Count__c 필드를 업데이트할 사용자 목록 저장용
        List<User> usersToUpdate = new List<User>();

        // 각 Owner의 기존 oppty 개수를 반영하기 위해 User를 쿼리
        for (Id userId : userOpportunityCountMap.keySet()) {
            User userRecord = [SELECT Id, Daily_Quota_Opportunity_Count__c FROM User WHERE Id = :userId LIMIT 1];
            if (userRecord != null) {
                // 기존 값에 새로 추가된 oppty 개수를 더함 (기존 값이 null인 경우 0으로 처리)
                userRecord.Daily_Quota_Opportunity_Count__c = (userRecord.Daily_Quota_Opportunity_Count__c != null ? userRecord.Daily_Quota_Opportunity_Count__c : 0) + userOpportunityCountMap.get(userId);
                usersToUpdate.add(userRecord);
            }
        }

        // User 레코드를 한 번의 DML로 업데이트
        if (!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
    }




    public static void OpportunityTriggerUpdate(List<Opportunity> Opportunities, Map<Id, Opportunity> oldMap) {
        // oppty가 Update될 때마다 해당 oppty의 기존 Owner와 신규 Owner의 Daily_Quota_Opportunity_Count__c를 변경하는 로직
        
        Map<Id, Integer> userOpportunityCountMap = new Map<Id, Integer>(); // 신규 oppty 개수를 저장할 Map (User Id로 구분)
        Map<Id, Integer> oldUserOpportunityCountMap = new Map<Id, Integer>(); // 기존 oppty 개수를 저장할 Map (User Id로 구분)

        for (Opportunity opp: Opportunities){
            Opportunity oldOpp = oldMap.get(opp.Id);

            // onwer가 바뀔 경우 실행
            if (opp.OwnerId != oldOpp.OwnerId){
                // stage가 변경이 안될 경우 수주완료, 수주실패인 경우만 owner 변경
                // 수주완료, 수주실패는 업무가 끝난 것으로 간주하여 owner의 oppty 개수를 변경하지 않음
                if (opp.StageName != oldOpp.StageName && (opp.StageName == '수주완료' || opp.StageName == '수주실패')){
                    if (oldOpp.OwnerId != null) {
                        if (!oldUserOpportunityCountMap.containsKey(oldOpp.OwnerId)) {
                            oldUserOpportunityCountMap.put(oldOpp.OwnerId, 0);
                        }
                        oldUserOpportunityCountMap.put(oldOpp.OwnerId, oldUserOpportunityCountMap.get(oldOpp.OwnerId) - 1);
                    }
                } else {
                    // onwer만 변경된 조건
                    // 신규 owner의 oppty 개수를 1 증가
                    if (opp.OwnerId != null) {
                        if (!userOpportunityCountMap.containsKey(opp.OwnerId)) {
                            userOpportunityCountMap.put(opp.OwnerId, 0);
                        }
                        userOpportunityCountMap.put(opp.OwnerId, userOpportunityCountMap.get(opp.OwnerId) + 1);
                    }
        
                    // 기존 owner의 oppty 개수를 1 감소
                    if (oldOpp.OwnerId != null) {
                        if (!oldUserOpportunityCountMap.containsKey(oldOpp.OwnerId)) {
                            oldUserOpportunityCountMap.put(oldOpp.OwnerId, 0);
                        }
                        oldUserOpportunityCountMap.put(oldOpp.OwnerId, oldUserOpportunityCountMap.get(oldOpp.OwnerId) - 1);
                    }
                }
            } else{
                // stage가 수주완료, 수주실패로 변경된 경우만 oppty 감소
                if (opp.StageName != oldOpp.StageName && (opp.StageName == '수주완료' || opp.StageName == '수주실패')){
                    if (oldOpp.OwnerId != null) {
                        if (!oldUserOpportunityCountMap.containsKey(oldOpp.OwnerId)) {
                            oldUserOpportunityCountMap.put(oldOpp.OwnerId, 0);
                        }
                        oldUserOpportunityCountMap.put(oldOpp.OwnerId, oldUserOpportunityCountMap.get(oldOpp.OwnerId) - 1);
                    }
                }
            }
        }
    
        // Update할 유저 목록 저장용
        List<User> usersToUpdate = new List<User>();
        
        // map을 이용하여 신규 onwer의 oppty 개수를 업데이트
        for (Id userId : userOpportunityCountMap.keySet()) {
            User userRecord = [SELECT Id, Daily_Quota_Opportunity_Count__c FROM User WHERE Id = :userId LIMIT 1];
            if (userRecord != null) {
                userRecord.Daily_Quota_Opportunity_Count__c = (userRecord.Daily_Quota_Opportunity_Count__c != null ? userRecord.Daily_Quota_Opportunity_Count__c : 0) + userOpportunityCountMap.get(userId);
                usersToUpdate.add(userRecord);
            }
        }
    
        // map을 이용하여 기존 onwer의 oppty 개수를 업데이트
        for (Id oldUserId : oldUserOpportunityCountMap.keySet()) {
            User oldUserRecord = [SELECT Id, Daily_Quota_Opportunity_Count__c FROM User WHERE Id = :oldUserId LIMIT 1];
            if (oldUserRecord != null) {
                oldUserRecord.Daily_Quota_Opportunity_Count__c = (oldUserRecord.Daily_Quota_Opportunity_Count__c != null ? oldUserRecord.Daily_Quota_Opportunity_Count__c : 0) + oldUserOpportunityCountMap.get(oldUserId);
                usersToUpdate.add(oldUserRecord);
            }
        }
    
        // User 레코드를 한 번의 DML로 업데이트
        if (!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
    }
}