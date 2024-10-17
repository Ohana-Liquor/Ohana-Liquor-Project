public with sharing class AccountOrderController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getOrderStats(Id accountId) {
        // Account page 방문 시 해당 account에 대한 주문 통계를 반환하는 메서드

        Map<String, Object> result = new Map<String, Object>();
        
        // 초기값 설정
        Integer totalOrders = 0;
        Date lastActivateDate = null;
        Long totalRevenue = 0;

        // 결과 집계
        for (List<Order> orders:[SELECT AccountId, ActivatedDate, Status, TotalAmount FROM Order WHERE AccountId = :accountId]){

            for (Order ord: orders){
                if (ord.AccountId != null) {
                    // 주문이 활성화되어 있고 활성화된 날짜가 있는 경우에만 집계
                    if (ord.Status == 'Activated' && ord.ActivatedDate != null) {
                        totalOrders += 1;
                        if (lastActivateDate == null || ord.ActivatedDate > lastActivateDate){
                            lastActivateDate = ord.ActivatedDate.date();
                        }
                        totalRevenue += ord.TotalAmount != null ? ord.TotalAmount.intValue() : 0;
                    }
                }
            }
        }

        // 결과 맵에 값 저장
        result.put('totalOrders', totalOrders);
        if (lastActivateDate != null){
            result.put('lastActivateDate', lastActivateDate.year() + '년 ' + lastActivateDate.month() + '월 ' + lastActivateDate.day() + '일');
        } else{
            result.put('lastActivateDate', '없음');
        }
        result.put('totalRevenue', totalRevenue);

        return result;
    }
}