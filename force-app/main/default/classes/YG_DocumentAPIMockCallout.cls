/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 23/08/2020
* @description 
* This class is used to write the Apex test class coverage for Document API Mock Callout.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/
@isTest
public class YG_DocumentAPIMockCallout implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest request) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-CLA-Code', YG_Constants.CL_CODE_SUCCESS);
        res.setHeader('X-CLA-Message', YG_Constants.X_CLA_Message);
        System.debug('request.getEndpoint() ::: '+request.getEndpoint());
        res.setBody('[ { '+
                '"Model": "EJA110J",'+
                '"DocType": "GS",'+
                '"LanguageID": "JA",'+
                '"DownloadURL": "library.yokogawa.com/document/download/AxkHnJ89/0000082643/0/JA/",'+
                '"DocName": "EJX/EJA-Jシリーズ　船級型式認証品",'+
                '"DocNo": "GS 01C26A20-01JA",'+
                '"DocRevNo": "1",'+
                '"ProdCareer": "",'+
                '"ProdTrade": "DPharpEJX, DPharpEJA",'+
                '"FileSize": 243,'+
                '"DocPriority": "500",'+
                '"PageNo": 1,'+
                '"ViewCount": 5,'+
                '"StartLine": 1,'+
                '"EndLine": 5,'+
                '"Count": 5,'+
                '"OldVersionFlag": "0",'+
                '"OrderStopFlag": "0",'+
                '"AreaOpenDate": "20160318",'+
                '"EntryNo": "0000082643",'+
                '"FileRevNo": "0"'+
            '},{'+
 				'"Model": "EJA110J",'+
          		'"DocType": "IM",'+
              	'"LanguageID": "JA",'+
              	'"DownloadURL": "library.yokogawa.com/document/download/AxkHnJ89/0000053397/23/JA/",'+
             	'"DocName": "EJX/EJA-Jシリーズ　スタートアップマニュアル",'+
              	'"DocNo": "IM 01C26A01-01",'+
              	'"DocRevNo": "6",'+
              	'"ProdCareer": "",'+
              	'"ProdTrade": "DPharpEJX, DPharpEJA",'+
              	'"FileSize": 9250,'+
              	'"DocPriority": "500",'+
              	'"PageNo": 1,'+
              	'"ViewCount": 11,'+
              	'"StartLine": 1,'+
              	'"EndLine": 11,'+
              	'"Count": 11,'+
              	'"OldVersionFlag": "0",'+
              	'"OrderStopFlag": "0",'+
              	'"AreaOpenDate": "20160229",'+
              	'"EntryNo": "0000053397",'+
              	'"FileRevNo": "23"'+
            '},{'+
              	'"Model": "EJA110J",'+
              	'"DocType": "SD",'+
              	'"LanguageID": "JA",'+
              	'"DownloadURL": "library.yokogawa.com/document/download/AxkHnJ89/0000066066/18/JA/",'+
              	'"DocName": "差圧伝送器　接液部材質コード: H,M,T,A,B,W, 測定スパンコードFまたは付加仕様コード/HD",'+
              	'"DocNo": "SD 01C32B01-06JA",'+
              	'"DocRevNo": "5",'+
              	'"ProdCareer": "",'+
              	'"ProdTrade": "DPharpEJA",'+
              	'"FileSize": 380,'+
              	'"DocPriority": "500",'+
              	'"PageNo": 1,'+
              	'"ViewCount": 11,'+
              	'"StartLine": 1,'+
              	'"EndLine": 11,'+
              	'"Count": 11,'+
              	'"OldVersionFlag": "0",'+
              	'"OrderStopFlag": "0",'+
              	'"AreaOpenDate": "20160520",'+
              	'"EntryNo": "0000066066",'+
             	'"FileRevNo": "18"'+
            '},{'+
 				'"Model": "EJA110J",'+
          		'"DocType": "IM",'+
              	'"LanguageID": "JA",'+
              	'"DownloadURL": "library.yokogawa.com/document/download/AxkHnJ89/0000053397/23/JA/",'+
             	'"DocName": "EJX/EJA-Jシリーズ　スタートアップマニュアル",'+
              	'"DocNo": "IM 01C26A01-01",'+
              	'"DocRevNo": "6",'+
              	'"ProdCareer": "",'+
              	'"ProdTrade": "DPharpEJX, DPharpEJA",'+
              	'"FileSize": 9250,'+
              	'"DocPriority": "500",'+
              	'"PageNo": 1,'+
              	'"ViewCount": 11,'+
              	'"StartLine": 1,'+
              	'"EndLine": 11,'+
              	'"Count": 11,'+
              	'"OldVersionFlag": "0",'+
              	'"OrderStopFlag": "0",'+
              	'"AreaOpenDate": "20160229",'+
              	'"EntryNo": "0000053397",'+
              	'"FileRevNo": "23"'+
            '},{'+
              	'"Model": "EJA110J",'+
              	'"DocType": "TI",'+
              	'"LanguageID": "JA",'+
              	'"DownloadURL": "library.yokogawa.com/document/download/AxkHnJ89/0000066066/18/JA/",'+
              	'"DocName": "差圧伝送器　接液部材質コード: H,M,T,A,B,W, 測定スパンコードFまたは付加仕様コード/HD_差圧伝送器　接液部材質コード: H,M,T,A,B,W, 測定スパンコードFまたは付加仕様コード/HD",'+
              	'"DocNo": "SD 01C32B01-06JA",'+
              	'"DocRevNo": "5",'+
              	'"ProdCareer": "",'+
              	'"ProdTrade": "DPharpEJA",'+
              	'"FileSize": 380,'+
              	'"DocPriority": "500",'+
              	'"PageNo": 1,'+
              	'"ViewCount": 11,'+
              	'"StartLine": 1,'+
              	'"EndLine": 11,'+
              	'"Count": 11,'+
              	'"OldVersionFlag": "0",'+
              	'"OrderStopFlag": "0",'+
              	'"AreaOpenDate": "20160520",'+
              	'"EntryNo": "0000066066",'+
             	'"FileRevNo": "18"'+
            '},{'+
              	'"LinkageNo10": "2004880151",'+
                    '"LinkageNo6": "000300",'+
                    '"ComponentNo": "0001",'+
                    '"LESSystemId": "001",'+
                    '"DocumentId": "1000001",'+
                    '"SerialNo": "91U601404",'+
                    '"Model": "EJXC40A",'+
                    '"MSCode": "EJXC40A-D55RWTWTB-11/EC5/Z",'+
                    '"YPDSSearchKey": "",'+
                    '"CreateFileDate": "20180628",'+
                    '"UploadDate": "20180628",'+
                    '"ProjectNo": null,'+
                    '"ProjectItemNo": null,'+
                    '"FileSize": 125945,'+
                    '"DocumentName": "Test Certificate",'+
                    '"DownloadURL": "library.yokogawa.com/contents/download/F5cJnZkn/2004880151/000300/0001/0011000001/91U601404/",'+
                    '"PageNo": 1,'+
                    '"ViewCount": 1,'+
                    '"StartLine": 1,'+
                    '"EndLine": 1,'+
                    '"Count": 1'+   
            '}]');
        res.setStatusCode(200);
        return res;
    }
}