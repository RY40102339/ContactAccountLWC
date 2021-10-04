@isTest
public with sharing class YG_FetchRecordtypeHandlerTest {
    
    @TestSetup static void makeData(){
        WorkOrder WO=YG_TestDataFactory.createWorkOrder('Inspection Created','Email');
        insert WO;

        WorkOrderLineItem WOIL=new WorkOrderLineItem();
        WOIL.workOrderId=WO.Id;
        Insert WOIL;
    }

    @isTest public static void positiveSenario1() {
        WorkOrder wo=[select id from WorkOrder where status='Inspection Created'];
        YG_FetchRecordtypeHandler.fetchMainMethods(wo.Id, 'WorkOrderLineItem');
    }
}