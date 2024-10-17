import { LightningElement, api, wire } from 'lwc';
import getOrderStats from '@salesforce/apex/AccountOrderController.getOrderStats';
import { NavigationMixin } from 'lightning/navigation';

export default class AccountOrderStats extends NavigationMixin(LightningElement) {
    @api recordId;
    totalOrders = 0;
    lastActivateDate = null;
    totalRevenue = 0;

    // Apex 메서드 호출
    @wire(getOrderStats, { accountId: '$recordId' })
    wiredOrders({ error, data }) {
        if (data) {
            this.totalOrders = data.totalOrders;
            this.lastActivateDate = data.lastActivateDate != null ? data.lastActivateDate : '없음';
            this.totalRevenue = Intl.NumberFormat().format(data.totalRevenue);
        } else if (error) {
            console.error('Error fetching Orders data:', error);
        }
    }

    // 상세 페이지로 이동
    navigateToListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                relationshipApiName: 'Orders',
                actionName: 'view'
            },
        });
    }
}