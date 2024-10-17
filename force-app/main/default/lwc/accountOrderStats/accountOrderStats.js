import { LightningElement, api, wire } from 'lwc';
import getOrderStats from '@salesforce/apex/AccountOrderController.getOrderStats';
import { NavigationMixin } from 'lightning/navigation';

export default class AccountOrderStats extends NavigationMixin(LightningElement) { // NavigationMixin 상속
    @api recordId;
    totalOrders = 0;
    lastActivateDate = null;
    totalRevenue = 0;

    @wire(getOrderStats, { accountId: '$recordId' })
    wiredOrders({ error, data }) {
        if (data) {
            this.totalOrders = data.totalOrders || 0;
            this.lastActivateDate = data.lastActivateDate != null ? data.lastActivateDate : '없음';
            this.totalRevenue = Intl.NumberFormat().format(data.totalRevenue) || 0;
        } else if (error) {
            console.error('Error fetching Orders data:', error);
        }
    }

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