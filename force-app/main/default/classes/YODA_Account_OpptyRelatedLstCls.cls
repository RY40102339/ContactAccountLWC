public class YODA_Account_OpptyRelatedLstCls{
    
    public YODA_Account_OpptyRelatedLstCls(ApexPages.StandardController controller) {
        
    }
    
    public id AccountId{
        get{
            if(AccountId == null){
                AccountId = ApexPages.currentPage().getParameters().get('id');
            }
            return AccountId;
        }
        set{
            AccountId = value;
        }
    }
    public boolean IsAccountTeamMember{
        get{
            if(IsAccountTeamMember == null){
                list<accountteammember> atmLst = [select id from accountTeamMember where UserId =: UserInfo.getUserId() AND 
                                                  AccountId = :ApexPages.currentPage().getParameters().get('id')];

                if(atmLst != null && atmLst.size() > 0){
                    IsAccountTeamMember = true;
                }  
                else{
                    IsAccountTeamMember = false;
                } 
                
                if(IsAccountTeamMember == false){
                    list<opportunityteammember> otmLst = [select id from opportunityteammember where UserId =: UserInfo.getUserId() AND 
                                                          Opportunity.AccountId = :AccountId];
                    if(otmLst != null && otmLst.size() > 0){
                        IsAccountTeamMember = true;
                    }  
                    else{
                        IsAccountTeamMember = false;
                    } 
                }
            }
            return IsAccountTeamMember;
        }
        set{
            IsAccountTeamMember = value;
        }
    }    
    
    public integer getOpprtySize(){
        return [select id from opportunity where accountId =:AccountId].size();
    }
}