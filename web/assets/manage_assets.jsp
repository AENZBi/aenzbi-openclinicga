<%@page import="be.openclinic.assets.Asset,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../assets/includes/commonFunctions.jsp"%>
<%=checkPermission("assets.edit","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<script src="<%=sCONTEXTPATH%>/assets/includes/commonFunctions.js"></script> 

<%
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** manage_assets.jsp ****************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////
%>            

<form name="SearchForm" id="SearchForm" method="POST">
    <%=writeTableHeader("web","assets",sWebLanguage,"")%>
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- search CODE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","code",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="searchCode" name="searchCode" size="20" maxLength="20" value="">
            </td>
        </tr>   
        
        <%-- search DESCRIPTION --%>                
        <tr>
            <td class="admin"><%=getTran("web","description",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="searchDescription" name="searchDescription" size="50" maxLength="50" value="">
            </td>
        </tr>
        
        <%-- search SERIAL NUMBER --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","serialnumber",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="searchSerialnumber" name="searchSerialnumber" size="20" maxLength="30" value="">
            </td>
        </tr>     
        
        <%-- search ASSET TYPE --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","assetType",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" id="searchAssetType" name="searchAssetType">
                    <option/>
                    <%=ScreenHelper.writeSelect("assets.type","",sWebLanguage)%>
                </select>
            </td>
        </tr>   
                
        <%-- search SUPPLIER --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","supplier",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="searchSupplierUid" id="searchSupplierUid" value="">
                <input type="text" class="text" name="searchSupplierName" id="searchSupplierName" readonly size="30" value="">
                   
                <%-- buttons --%>
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("web","select",sWebLanguage)%>" onclick="selectSupplier('searchSupplierUid','searchSupplierName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("web","clear",sWebLanguage)%>" onclick="clearSupplierSearchFields();">
            </td>
        </tr>
        
        <%-- search PURCHASE PERIOD --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","purchasePeriod",sWebLanguage)%>&nbsp;(<%=getTran("web.assets","begin",sWebLanguage)%> - <%=getTran("web.assets","end",sWebLanguage)%>)</td>
            <td class="admin2">
                <%=writeDateField("searchPurchaseBegin","SearchForm","",sWebLanguage)%>&nbsp;&nbsp;<%=getTran("web","until",sWebLanguage)%>&nbsp;&nbsp; 
                <%=writeDateField("searchPurchaseEnd","SearchForm","",sWebLanguage)%>            
            </td>                        
        </tr>
            
        <%-- search BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSearch" id="buttonSearch" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="searchAssets();">&nbsp;
                <input class="button" type="button" name="buttonClear" id="buttonClear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
            </td>
        </tr>
    </table>
</form>

<script>
  SearchForm.searchCode.focus();
  
  <%-- SEARCH ASSETS --%>
  function searchAssets(){
    var okToSubmit = true;
       
    <%-- begin can not be after end --%>
    if(document.getElementById("searchPurchaseBegin").value.length > 0 &&
       document.getElementById("searchPurchaseEnd").value.length > 0){
      var begin = makeDate(document.getElementById("searchPurchaseBegin").value),
          end   = makeDate(document.getElementById("searchPurchaseEnd").value);
      
      if(begin > end){
        okToSubmit = false;
        alertDialog("web","beginMustComeBeforeEnd");
        document.getElementById("searchPurchaseBegin").focus();
      }  
    }
    
    if(okToSubmit){
      document.getElementById("divAssets").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Searching";
  
      var url = "<c:url value='/assets/ajax/asset/getAssets.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "code="+SearchForm.searchCode.value+
                      "&description="+SearchForm.searchDescription.value+
                      "&serialnumber="+SearchForm.searchSerialnumber.value+
                      "&assetType="+SearchForm.searchAssetType.value+
                      "&supplierUid="+SearchForm.searchSupplierUid.value+
                      "&purchasePeriodBegin="+SearchForm.searchPurchaseBegin.value+
                      "&purchasePeriodEnd="+SearchForm.searchPurchaseEnd.value,
          onSuccess: function(resp){
            $("divAssets").innerHTML = resp.responseText;
            sortables_init();
            newAsset();
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'assets/ajax/asset/getAssets.jsp' : "+resp.responseText.trim();
          }
        }
      ); 
    }
  }
  
  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    document.getElementById("searchCode").value = "";
    document.getElementById("searchDescription").value = "";
    document.getElementById("searchSerialnumber").value = "";
    document.getElementById("searchAssetType").selectedIndex = 0;
    clearSupplierSearchFields();
    document.getElementById("searchPurchaseBegin").value = "";   
    document.getElementById("searchPurchaseEnd").value = "";  
  }

  <%-- CLEAR SUPPLIER SEARCH FIELDS --%>
  function clearSupplierSearchFields(){
    document.getElementById("searchSupplierUid").value = "";  
    document.getElementById("searchSupplierName").value = "";
  }
</script>

<div id="divAssets" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditAssetUid" name="EditAssetUid" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">
    
        <%-- CODE (*) --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.assets","code",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="code" name="code" size="20" maxLength="20" value="">
            </td>
        </tr>      

        <%-- PARENT --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","parent",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="parentUid" id="parentUid" value="">
                <input type="text" class="text" id="parentCode" name="parentCode" size="20" readonly value="">
                                   
                <%-- buttons --%>
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("web","select",sWebLanguage)%>" onclick="selectParent('parentUid','parentCode');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("web","clear",sWebLanguage)%>" onclick="clearParentFields();">
            </td>
        </tr>     

        <%-- DESCRIPTION (*) --%>                    
        <tr>
            <td class="admin"><%=getTran("web","description",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <textarea class="text" name="description" id="description" cols="80" rows="4" onKeyup="resizeTextarea(this,8);limitChars(this,255);"></textarea>
            </td>
        </tr>    
        
        <%-- SERIAL NUMBER --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","serialnumber",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="serialnumber" name="serialnumber" size="20" maxLength="30" value="">
            </td>
        </tr>     
        
        <%-- QUANTITY (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","quantity",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="quantity" name="quantity" size="8" maxLength="8" value="1" onKeyUp="isNumber(this);" onBlur="if(isNumber(this))setDecimalLength(this,2,true);">
            </td>
        </tr>
       
        <%-- ASSET TYPE (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","type",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <select class="text" id="assetType" name="assetType">
                    <option/>
                    <%=ScreenHelper.writeSelect("assets.type","",sWebLanguage)%>
                </select>
            </td>
        </tr>       
        
        <%-- SUPPLIER --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","supplier",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="supplierUid" id="supplierUid" value="">
                <input type="text" class="text" name="supplierName" id="supplierName" readonly size="30" value="">
                   
                <%-- buttons --%>
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("web","select",sWebLanguage)%>" onclick="selectSupplier('supplierUid','supplierName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("web","clear",sWebLanguage)%>" onclick="clearSupplierFields();">
            </td>
        </tr>
        
        <%-- PURCHASE DATE --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","purchaseDate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%=writeDateField("purchaseDate","EditForm","",sWebLanguage)%>        
            </td>                        
        </tr>        
        
        <%-- PURCHASE PRICE (+currency) --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","purchasePrice",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="purchasePrice" name="purchasePrice" size="8" maxLength="8" value="" onKeyUp="isNumber(this);" onBlur="if(isNumber(this))setDecimalLength(this,2,true);"> <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
            </td>
        </tr>        
        
        <%-- RECEIPT BY --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","receiptBy",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="receiptBy" name="receiptBy" size="50" maxLength="50" value="">
            </td>
        </tr>     
        
        <%-- PURCHASE DOCUMENTS (multi-add) --%>   
        <tr>
            <td class="admin" nowrap><%=getTran("web.assets","purchaseDocuments",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" id="purchaseDocuments" name="purchaseDocuments" value="">
                                    
                <div id="pdScroller" style="overflow:none;width:263px;height:50px;border:none;">   
	                <table width="23%" class="sortable" id="tblPD" cellspacing="1" headerRowCount="2"> 
	                    <%-- header --%>                        
	                    <tr class="admin">
	                        <%-- 0 - empty --%>
	                        <td width="40" nowrap/>
	                        <%-- 1 - type --%>
	                        <td width="10%" nowrap style="padding-left:0px;">
	                            <%=getTran("web.assets","documentId",sWebLanguage)%>&nbsp;*&nbsp;
	                        </td>    
	                        <%-- 2 - empty --%>
	                        <td width="*" nowrap>&nbsp;</td>      
	                    </tr>
	        
	                    <%-- content by ajax and javascript --%>
	                    
	                    <%-- add-row --%>                          
	                    <tr>
	                        <%-- 0 - empty --%>
	                        <td class="admin"/>
	                        <%-- 1 - documentId --%>
	                        <td class="admin"> 
	                            <input type="text" class="text" id="pdID" name="pdID" size="15" maxLength="12" value="">
	                        </td>
	                        <%-- 2 - buttons --%>
	                        <td class="admin" nowrap>
	                            <input type="button" class="button" name="ButtonAddPD" id="ButtonAddPD" value="<%=getTran("web","add",sWebLanguage)%>" onclick="if(isValidDocumentId(document.getElementById('pdID')))addPD();">
	                            <input type="button" class="button" name="ButtonUpdatePD" id="ButtonUpdatePD" value="<%=getTran("web","edit",sWebLanguage)%>" onclick="updatePD();" disabled>&nbsp;
	                        </td>    
	                    </tr>
	                </table>
	            </div>                    
            </td>
        </tr>        
        
        <%-- WRITE OFF METHOD --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","writeOffMethod",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select class="text" id="writeOffMethod" name="writeOffMethod">
                    <option/>
                    <%=ScreenHelper.writeSelect("assets.writeOffMethod","",sWebLanguage)%>
                </select>
            </td>
        </tr>

        <%-- ANNUITIY --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","annuity",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select class="text" id="annuity" name="annuity">
                    <option/>
                    <%=ScreenHelper.writeSelect("assets.annuity","",sWebLanguage)%>
                </select>
            </td>
        </tr>        
        
        <%-- CHARACTERISTICS --%>                
        <tr>
            <td class="admin"><%=getTran("web.assets","characteristics",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea class="text" name="characteristics" id="characteristics" cols="80" rows="4" onKeyup="resizeTextarea(this,8);"></textarea>
            </td>
        </tr>
        
        <%-- ACCOUNTING CODE --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","accountingCode",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="accountingCode" name="accountingCode" size="20" maxLength="20" value="">
            </td>
        </tr>     
        
        <%-- GAINS (multi-add: date, value (+currency)) --%>
        <tr>
            <td class="admin" nowrap><%=getTran("web.assets","gains",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" id="gains" name="gains" value="">
                                     
                <table width="45%" class="sortable" id="tblGA" cellspacing="1" headerRowCount="2"> 
                    <%-- header --%>                        
                    <tr class="admin">
                        <%-- 0 - empty --%>
                        <td width="40" nowrap/>
                        <%-- 1 - date --%>
                        <td width="110" nowrap style="padding-left:0px;">
                            <%=getTran("web.assets","date",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 2 - value --%>
                        <td width="100" nowrap style="padding-left:0px;">
                            <%=getTran("web.assets","value",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 3 - empty --%>
                        <td width="*" nowrap>&nbsp;</td>      
                    </tr>
        
                    <%-- content by ajax and javascript --%>
                    
                    <%-- add-row --%>                          
                    <tr>
                        <%-- 0 - empty --%>
                        <td class="admin"/>
                        <%-- 1 - gaDate --%>
                        <td class="admin"> 
                            <%=writeDateField("gaDate","EditForm","",sWebLanguage)%>&nbsp; 
                        </td>
                        <%-- 2 - gaValue --%>
                        <td class="admin"> 
                            <input type="text" class="text" id="gaValue" name="gaValue" size="8" maxLength="8" onKeyUp="isNumber(this);" onBlur="if(isNumber(this))setDecimalLength(this,2,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
                        </td>
                        <%-- 3 - buttons --%>
                        <td class="admin">
                            <input type="button" class="button" name="ButtonAddGA" id="ButtonAddGA" value="<%=getTran("web","add",sWebLanguage)%>" onclick="addGA();">
                            <input type="button" class="button" name="ButtonUpdateGA" id="ButtonUpdateGA" value="<%=getTran("web","edit",sWebLanguage)%>" onclick="updateGA();" disabled>&nbsp;
                        </td>    
                    </tr>
                </table>                    
            </td>
        </tr>        
        
        <%-- LOSSES (multi-add: date, value (+currency)) --%>  
        <tr>
            <td class="admin" nowrap><%=getTran("web.assets","losses",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" id="losses" name="losses" value="">
                                     
                <table width="45%" class="sortable" id="tblLO" cellspacing="1" headerRowCount="2"> 
                    <%-- header --%>                        
                    <tr class="admin">
                        <%-- 0 - empty --%>
                        <td width="40" nowrap/>
                        <%-- 1 - date --%>
                        <td width="110" nowrap style="padding-left:0px;">
                            <%=getTran("web.assets","date",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 2 - value --%>
                        <td width="100" nowrap style="padding-left:0px;">
                            <%=getTran("web.assets","value",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 3 - empty --%>
                        <td width="*" nowrap>&nbsp;</td>      
                    </tr>
        
                    <%-- content by ajax and javascript --%>
                    
                    <%-- add-row --%>                          
                    <tr>
                        <%-- 0 - empty --%>
                        <td class="admin"/>
                        <%-- 1 - loDate --%>
                        <td class="admin"> 
                            <%=writeDateField("loDate","EditForm","",sWebLanguage)%>&nbsp; 
                        </td>   
                        <%-- 2 - loValue --%>
                        <td class="admin"> 
                            <input type="text" class="text" id="loValue" name="loValue" size="8" maxLength="8" onKeyUp="isNumber(this)" onBlur="if(isNumber(this))setDecimalLength(this,2,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
                        </td>
                        <%-- 3 - buttons --%>
                        <td class="admin">
                            <input type="button" class="button" name="ButtonAddLO" id="ButtonAddLO" value="<%=getTran("web","add",sWebLanguage)%>" onclick="addLO();">
                            <input type="button" class="button" name="ButtonUpdateLO" id="ButtonUpdateLO" value="<%=getTran("web","edit",sWebLanguage)%>" onclick="updateLO();" disabled>&nbsp;
                        </td>    
                    </tr>
                </table>                    
            </td>
        </tr>        

        <%-- RESIDUAL VALUE HISTORY (calculated) --%>
        <tr id="residualValueHistoryDiv" style="visibility:visible;">
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.assets","residualValueHistory",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <div id="residualValueHistory" class="searchResults" style="color:black;padding:3px;width:120px;height:100px;border:1px solid #ccc;background:#f9f9f9;">
                    <%-- javascript --%>
                </div>
            </td>
        </tr>     
                    
        <%-- LOAN (own table) -------------------------------------------------------------------%>
        <tr>
            <td class="admin"><%=getTran("web.assets","loan",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" style="padding:5px;">
                <table style="border:1px solid #ddd;" cellspacing="0">
                
            <%-- subtitle : loan --%>
            <tr class="admin">
                <td colspan="2"><%=getTran("web.assets","loan",sWebLanguage)%></td>        
            </tr>
        
            <%-- LOAN DATE --%>
            <tr>
                <td class="admin" width="150"><%=getTran("web.assets","loanDate",sWebLanguage)%>&nbsp;</td>
                <td class="admin2">
                    <%=writeDateField("loanDate","EditForm","",sWebLanguage)%>            
                </td>                        
            </tr>
            
            <%-- LOAN AMOUNT --%>
            <tr>
                <td class="admin"><%=getTran("web.assets","loanAmount",sWebLanguage)%>&nbsp;</td>
                <td class="admin2">
                    <input type="text" class="text" id="loanAmount" name="loanAmount" size="8" maxLength="8" value="" onKeyUp="isNumber(this);">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
                </td>
            </tr>
                
            <%-- LOAN INTEREST RATE (text!) --%>
            <tr>
                <td class="admin"><%=getTran("web.assets","loadInterestRate",sWebLanguage)%>&nbsp;</td>
                <td class="admin2">
                    <input type="text" class="text" id="loanInterestRate" name="loanInterestRate" size="30" maxLength="30" value="">
                </td>
            </tr>     
            
            <%-- LOAN REIMBURSEMENT PLAN (multi-add: date, capital, interest, total (calculated)) --%>  
            <tr>
                <td class="admin" nowrap><%=getTran("web.assets","loadReimbursementPlan",sWebLanguage)%>&nbsp;</td>
                <td class="admin2">
                    <input type="hidden" id="loanReimbursementPlan" name="loanReimbursementPlan" value="">
                                         
                    <table width="60%" class="sortable" id="tblRP" cellspacing="1" headerRowCount="2"> 
                        <%-- header --%>                        
                        <tr class="admin">
                            <%-- 0 - empty --%>
                            <td width="40" nowrap/>
                            <%-- 1 - date --%>
                            <td width="130" nowrap style="padding-left:0px;">
                                <%=getTran("web.assets","date",sWebLanguage)%>&nbsp;*&nbsp;
                            </td>
                            <%-- 2 - capital (+currency) --%>
                            <td width="100" nowrap style="padding-left:0px;">
                                <%=getTran("web.assets","capital",sWebLanguage)%>&nbsp;*&nbsp;
                            </td>
                            <%-- 3 - interest (+currency) --%>
                            <td width="100" nowrap style="padding-left:0px;">
                                <%=getTran("web.assets","interest",sWebLanguage)%>&nbsp;*&nbsp;
                            </td>    
                            <%-- 4 - total --%>
                            <td width="100" nowrap style="padding-left:0px;">
                                <%=getTran("web.assets","total",sWebLanguage)%>&nbsp;
                            </td>   
                            <%-- 5 - empty --%>
                            <td width="*" nowrap>&nbsp;</td>      
                        </tr>
            
                        <%-- content by ajax and javascript --%>
                        
                        <%-- add-row --%>                          
                        <tr>
                            <%-- 0 - empty --%>
                            <td class="admin"/>
                            <%-- 1 - rpDate --%>
                            <td class="admin"> 
                                <%=writeDateField("rpDate","EditForm","",sWebLanguage)%>&nbsp; 
                            </td>
                            <%-- 2 - rpCapital --%>
                            <td class="admin">
                                <input type="text" class="text" id="rpCapital" name="rpCapital" size="8" maxLength="8" onKeyUp="calculateRPTotal(this,false);" onBlur="calculateRPTotal(this,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
                            </td>    
                            <%-- 3 - rpInterest --%>
                            <td class="admin">  
                                <input type="text" class="text" id="rpInterest" name="rpInterest" size="8" maxLength="8" onKeyUp="calculateRPTotal(this,false);" onBlur="calculateRPTotal(this,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
                            </td>  
                            <%-- 4 - rpTotal (calculated) --%>
                            <td style="background-color:#C3D9FF;font-weight:bold;color:#505050;">
                                <span id="rpTotal" style="searchResults" style="color:#505050;padding:3px;width:50px;height:18px;border:1px solid #ccc;background:#f0f0f0;"><%-- javascript --%></span>&nbsp;<span style="vertical-align:3px"><%=MedwanQuery.getInstance().getConfigParam("currency","�")%></span>&nbsp;
                            </td>   
                            <%-- 5 - buttons --%>
                            <td class="admin" nowrap>
                                <input type="button" class="button" name="ButtonAddRP" id="ButtonAddRP" value="<%=getTran("web","add",sWebLanguage)%>" onclick="addRP();">
                                <input type="button" class="button" name="ButtonUpdateRP" id="ButtonUpdateRP" value="<%=getTran("web","edit",sWebLanguage)%>" onclick="updateRP();" disabled>&nbsp;
                            </td>    
                        </tr>
                    </table>                    
                </td>
            </tr>        
            
            <%-- LOAN REIMBURSEMENT AMOUNT --%>
            <tr>
                <td class="admin"><%=getTran("web.assets","loanReimbursementAmount",sWebLanguage)%>&nbsp;</td>
                <td class="admin2">
                    <span id="loanReimbursementAmount" class="searchResults" style="color:black;padding:3px;width:70px;height:20px;border:1px solid #ccc;background:#f0f0f0;text-align:right;"><%-- javascript --%></span>&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
                </td>
            </tr>
            
            <%-- LOAN COMMENT --%>                
            <tr>
                <td class="admin"><%=getTran("web.assets","comment",sWebLanguage)%>&nbsp;</td>
                <td class="admin2">
                    <textarea class="text" name="loanComment" id="loanComment" cols="80" rows="4" onKeyup="resizeTextarea(this,8);"></textarea>
                </td>
            </tr>
            
            <%-- LOAN DOCUMENTS (multi-add) --%>
            <tr>
                <td class="admin" nowrap><%=getTran("web.assets","loanDocuments",sWebLanguage)%>&nbsp;</td>
                <td class="admin2">
                    <input type="hidden" id="loanDocuments" name="loanDocuments" value="">
                              
                    <div id="ldScroller" style="overflow:none;width:270px;height:50px;border:none;">           
	                    <table width="45%" class="sortable" id="tblLD" cellspacing="1" headerRowCount="2"> 
	                        <%-- header --%>                        
	                        <tr class="admin">
	                            <%-- 0 - empty --%>
	                            <td width="40" nowrap/>
	                            <%-- 1 - documentId --%>
	                            <td width="100" nowrap style="padding-left:0px;">
	                                <%=getTran("web.assets","documentId",sWebLanguage)%>&nbsp;*&nbsp;
	                            </td>    
	                            <%-- 2 - empty --%>
	                            <td width="*" nowrap>&nbsp;</td>      
	                        </tr>
	            
	                        <%-- content by ajax and javascript --%>
	                        
	                        <%-- add-row --%>                          
	                        <tr>
	                            <%-- 0 - empty --%>
	                            <td class="admin"/>
	                            <%-- 1 - documentId --%>
	                            <td class="admin"> 
	                                <input type="text" class="text" id="ldID" name="ldID" size="15" maxLength="12" value="">&nbsp;
	                            </td>
	                            <%-- 2 - buttons --%>
	                            <td class="admin" nowrap>
	                                <input type="button" class="button" name="ButtonAddLD" id="ButtonAddLD" value="<%=getTran("web","add",sWebLanguage)%>" onclick="if(isValidDocumentId(document.getElementById('ldID')))addLD();">
	                                <input type="button" class="button" name="ButtonUpdateLD" id="ButtonUpdateLD" value="<%=getTran("web","edit",sWebLanguage)%>" onclick="updateLD();" disabled>&nbsp;
	                            </td>    
	                        </tr>
	                    </table>
	                </div>                    
                </td>
            </tr>        
        
                </table>
            </td>
        </tr>
                            
        <%-- SALE DATE --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","saleDate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%=writeDateField("saleDate","EditForm","",sWebLanguage)%>&nbsp;            
            </td>                        
        </tr>
        
        <%-- SALE VALUE --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","saleValue",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="saleValue" name="saleValue" size="8" maxLength="8" value="" onKeyUp="isNumber(this);">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
            </td>
        </tr>
        
        <%-- SALE CLIENT --%>        
        <tr>
            <td class="admin"><%=getTran("web.assets","saleClient",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea class="text" name="saleClient" id="saleClient" cols="80" rows="4" onKeyup="resizeTextarea(this,8);limitChars(this,255);"></textarea>
            </td>
        </tr>        
                    
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveAsset();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteAsset();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newAsset();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>
  <%
      String sAgent = request.getHeader("User-Agent").toLowerCase();
      if(sAgent.contains("msie")){
          out.print("document.getElementById('residualValueHistoryDiv').style.display = 'none';");
      }
  %>
  
  <%-- CALCULATE RP TOTAL --%>
  function calculateRPTotal(inputField,format){
    if(isNumber(inputField)){
      if(format==true){
        setDecimalLength(inputField,2,true);
      }
       
      var capital  = document.getElementById("rpCapital").value,
          interest = document.getElementById("rpInterest").value;
    
      if(capital.length > 0 && interest.length > 0){          
        document.getElementById("rpTotal").innerHTML = formatNumber(capital*interest/100,2);      
      }
      else{
        document.getElementById("rpTotal").innerHTML = "";
      }
    }
    else{
      document.getElementById("rpTotal").innerHTML = "";
    }
  }
  
  <%-- IS VALID DOCUMENT ID --%>
  function isValidDocumentId(docIdField){
    var docId = docIdField.value;
    
    if(docId.length > 0){
      docId = replaceAll(docId,"-","");
      docId = replaceAll(docId,".","");
      
      if(docId.length==11 && !isNaN(docId)){
        var partOne = 1*docId.substr(0,9),
            partTwo = 1*docId.substr(9,2);

        if(partOne%97==97-partTwo){
          return true;
        }
      }
      
      alertDialog("web","invalidDocumentId");
      docIdField.focus();
      return false;
    }
    
    return true;
  }
  
  <%-- CLEAR ASSET FIELDS --%>
  function clearAssetFields(){
    document.getElementById("searchAsset").value = "";
    document.getElementById("searchAssetUid").value = "";  
  }

  <%-- CLEAR SUPPLIER FIELDS --%>
  function clearSupplierFields(){
    document.getElementById("supplierUid").value = ""; 
    document.getElementById("supplierName").value = ""; 
  }

  <%-- CLEAR PARENT FIELDS --%>
  function clearParentFields(){
    document.getElementById("parentUid").value = "";
    document.getElementById("parentCode").value = "";  
  }
    
  <%-- SAVE ASSET --%>
  function saveAsset(){
    var okToSubmit = true;    

    <%-- check required fields --%>
    if(requiredFieldsProvided()){    
      if(okToSubmit==true){
        document.getElementById("divMessage").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Saving";  
        var url = "<c:url value='/assets/ajax/asset/saveAsset.jsp'/>?ts="+new Date().getTime();
        disableButtons();
        
        <%-- compose string containing purchase documents --%>
        var sTmpBegin, sTmpEnd;
        
        while(sPD.indexOf("rowPD") > -1){
          sTmpBegin = sPD.substring(sPD.indexOf("rowPD"));
          sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
          sPD = sPD.substring(0,sPD.indexOf("rowPD"))+sTmpEnd;
        }
        document.getElementById("purchaseDocuments").value = sPD;
        
        <%-- compose string containing gains --%>
        while(sGA.indexOf("rowGA") > -1){
          sTmpBegin = sGA.substring(sGA.indexOf("rowGA"));
          sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
          sGA = sGA.substring(0,sGA.indexOf("rowGA"))+sTmpEnd;
        }
        document.getElementById("gains").value = sGA;
        
        <%-- compose string containing losses --%>
        while(sLO.indexOf("rowLO") > -1){
          sTmpBegin = sLO.substring(sLO.indexOf("rowLO"));
          sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
          sLO = sLO.substring(0,sLO.indexOf("rowLO"))+sTmpEnd;
        }
        document.getElementById("losses").value = sLO;
        
        <%-- compose string containing reimbursement plan --%>
        while(sRP.indexOf("rowRP") > -1){
          sTmpBegin = sRP.substring(sRP.indexOf("rowRP"));
          sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
          sRP = sRP.substring(0,sRP.indexOf("rowRP"))+sTmpEnd;
        }
        document.getElementById("loanReimbursementPlan").value = sRP;

        <%-- compose string containing loan documents --%>
        while(sLD.indexOf("rowLD") > -1){
          sTmpBegin = sLD.substring(sLD.indexOf("rowLD"));
          sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
          sLD = sLD.substring(0,sLD.indexOf("rowLD"))+sTmpEnd;
        }
        document.getElementById("loanDocuments").value = sLD;
        
        var sParams = "EditAssetUid="+EditForm.EditAssetUid.value+
                      "&code="+document.getElementById("code").value+
                      "&parentUid="+document.getElementById("parentUid").value+
                      "&description="+document.getElementById("description").value+
                      "&serialnumber="+document.getElementById("serialnumber").value+
                      "&quantity="+document.getElementById("quantity").value+
                      "&assetType="+document.getElementById("assetType").value+
                      "&supplierUid="+document.getElementById("supplierUid").value+
                      "&purchaseDate="+document.getElementById("purchaseDate").value+
                      "&purchasePrice="+document.getElementById("purchasePrice").value+
                      "&receiptBy="+document.getElementById("receiptBy").value+
                      "&purchaseDocuments="+document.getElementById("purchaseDocuments").value+
                      "&writeOffMethod="+document.getElementById("writeOffMethod").value+
                      "&annuity="+document.getElementById("annuity").value+
                      "&characteristics="+document.getElementById("characteristics").value+
                      "&accountingCode="+document.getElementById("accountingCode").value+
                      "&gains="+document.getElementById("gains").value+
                      "&losses="+document.getElementById("losses").value+
                    
                      //*** loan ***
                      "&loanDate="+document.getElementById("loanDate").value+
                      "&loanAmount="+document.getElementById("loanAmount").value+
                      "&loanInterestRate="+replaceAll(document.getElementById("loanInterestRate").value,"%","[percent]")+
                      "&loanReimbursementPlan="+document.getElementById("loanReimbursementPlan").value+
                      "&loanReimbursementAmount="+document.getElementById("loanReimbursementAmount").innerHTML+
                      "&loanComment="+document.getElementById("loanComment").value+
                      "&loanDocuments="+document.getElementById("loanDocuments").value+
                    
                      "&saleDate="+document.getElementById("saleDate").value+
                      "&saleValue="+document.getElementById("saleValue").value+
                      "&saleClient="+document.getElementById("saleClient").value;
        
        new Ajax.Request(url,
          {   
            method: "POST",
            postBody: sParams,
            onSuccess: function(resp){
              var data = eval("("+resp.responseText+")");
              $("divMessage").innerHTML = data.message;
              
              enableButtons();
              searchAssets();   
            },
            onFailure: function(resp){
              $("divMessage").innerHTML = "Error in 'assets/ajax/asset/saveAsset.jsp' : "+resp.responseText.trim();
            }
          }
        );
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
      
      <%-- focus empty field --%>
           if(document.getElementById("code").value.length==0) document.getElementById("code").focus();
      else if(document.getElementById("description").value.length==0) document.getElementById("description").focus();
      else if(document.getElementById("quantity").value.length==0) document.getElementById("quantity").focus();
      else if(document.getElementById("assetType").value.length==0) document.getElementById("assetType").focus();          
    }
  }
  
  <%-- REQUIRED FIELDS PROVIDED --%>
  function requiredFieldsProvided(){
    return document.getElementById("code").value.length > 0 &&
           document.getElementById("description").value.length > 0 &&
           document.getElementById("quantity").value.length > 0 &&
           document.getElementById("assetType").value.length > 0;           
  }
    
  <%-- LOAD (all) ASSETS --%>
  function loadAssets(){
    document.getElementById("divAssets").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Loading";
    
    var url = "<c:url value='/assets/ajax/asset/getAssets.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "",
        onSuccess: function(resp){
          $("divAssets").innerHTML = resp.responseText;
          sortables_init();
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'assets/ajax/asset/getAssets.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }

  <%-- DISPLAY ASSET --%>
  function displayAsset(assetUid){
    newAsset();
    var url = "<c:url value='/assets/ajax/asset/getAsset.jsp'/>?ts="+new Date().getTime();

    document.getElementById("pdScroller").style.height = "160px";
    document.getElementById("pdScroller").style.overflow = "auto";
    
    document.getElementById("ldScroller").style.height = "160px";
    document.getElementById("ldScroller").style.overflow = "auto";
    
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "AssetUid="+assetUid,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");

          $("EditAssetUid").value = assetUid.unhtmlEntities();
          $("code").value = data.code.unhtmlEntities();
          $("parentUid").value = data.parentUid.unhtmlEntities();
          $("parentCode").value = data.parentCode.unhtmlEntities();
          $("description").value = replaceAll(data.description.unhtmlEntities(),"<br>","\n");
          $("serialnumber").value = data.serialnumber.unhtmlEntities();
          $("quantity").value = data.quantity.unhtmlEntities();
          $("assetType").value = data.assetType.unhtmlEntities();
          $("supplierUid").value = data.supplierUid.unhtmlEntities();
          $("supplierName").value = data.supplierName.unhtmlEntities();
          $("purchaseDate").value = data.purchaseDate.unhtmlEntities();
          $("purchasePrice").value = data.purchasePrice.unhtmlEntities();
          $("receiptBy").value = data.receiptBy.unhtmlEntities();
          $("purchaseDocuments").value = data.purchaseDocuments.unhtmlEntities();
          displayPurchaseDocuments();
          $("writeOffMethod").value = data.writeOffMethod.unhtmlEntities();
          $("annuity").value = data.annuity.unhtmlEntities();
          $("characteristics").value = replaceAll(data.characteristics.unhtmlEntities(),"<br>","\n");
          $("accountingCode").value = data.accountingCode.unhtmlEntities();
          
          $("gains").value = data.gains.unhtmlEntities();
          displayGains();
          $("losses").value = data.losses.unhtmlEntities();
          displayLosses();
          
          if(data.residualValueHistory.length > 0){
	        <%
			    if(sAgent.contains("msie")){
			        %>$("residualValueHistoryDiv").style.display = "block";<%
                }
            %>
            $("residualValueHistory").innerHTML = replaceAll(data.residualValueHistory.unhtmlEntities(),"<br>","\n");
          }
          
          //*** loan ***
          $("loanDate").value = data.loanDate.unhtmlEntities();
          $("loanAmount").value = data.loanAmount.unhtmlEntities();
          $("loanInterestRate").value = data.loanInterestRate.unhtmlEntities();
          $("loanReimbursementPlan").value = data.loanReimbursementPlan.unhtmlEntities();
          displayReimbursementPlans();
          $("loanReimbursementAmount").innerHTML = data.loanReimbursementAmount.unhtmlEntities();
          //calculateTotalReimbursementAmount();
          $("loanComment").value = replaceAll(data.loanComment.unhtmlEntities(),"<br>","\n");
          $("loanDocuments").value = data.loanDocuments.unhtmlEntities();
          displayLoanDocuments();
          
          $("saleDate").value = data.saleDate.unhtmlEntities();
          $("saleValue").value = data.saleValue.unhtmlEntities();
          $("saleClient").value = replaceAll(data.saleClient.unhtmlEntities(),"<br>","\n");
          
          document.getElementById("divMessage").innerHTML = ""; 
          resizeAllTextareas(8);

          <%-- display hidden buttons --%>
          document.getElementById("buttonDelete").style.visibility = "visible";
          document.getElementById("buttonNew").style.visibility = "visible";
          
          enableButtons();
          setTimeout("sortPurchaseDocuments()",700);
          setTimeout("sortLoanDocuments()",700);
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'assets/ajax/asset/getAsset.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }

  <%-- SORT PURCHASE DOCUMENTS --%>
  function sortPurchaseDocuments(){
    var sortLink = document.getElementById("tblPD_lnk1");
    if(sortLink!=null){
      ts_resortTable(sortLink,1,false);
    }

    updateRowStylesSpecificTable("tblPD",2);
  }

  <%-- SORT LOAN DOCUMENTS --%>
  function sortLoanDocuments(){
    var sortLink = document.getElementById("tblLD_lnk1");
    if(sortLink!=null){
      ts_resortTable(sortLink,1,false);
    }

    updateRowStylesSpecificTable("tblLD",2);
  }
  
  <%-- DELETE ASSET --%>
  function deleteAsset(){ 
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){                 
      var url = "<c:url value='/assets/ajax/asset/deleteAsset.jsp'/>?ts="+new Date().getTime();
      disableButtons();
    
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "AssetUid="+document.getElementById("EditAssetUid").value,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;

            enableButtons();
            searchAssets();
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'assets/ajax/asset/deleteAsset.jsp' : "+resp.responseText.trim();
          }  
        }
      );
    }
  }
  
  <%-- NEW ASSET --%>
  function newAsset(){
    clearAllTables();
    
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("EditAssetUid").value = "-1";
    $("code").value = "";
    clearParentFields();
    $("description").value = "";
    $("serialnumber").value = "";
    $("quantity").value = "1"; // default
    $("assetType").selectedIndex = 0;
    clearSupplierFields();
    $("purchaseDate").value = "";
    $("purchasePrice").value = "";
    $("receiptBy").value = "";
    clearPDTable();
    $("writeOffMethod").value = "";
    $("annuity").value = "";
    $("characteristics").value = "";
    $("accountingCode").value = "";
    clearGATable();
    clearLOTable();

    $("residualValueHistory").innerHTML = "";
    <%
        if(sAgent.contains("msie")){
            %>$("residualValueHistoryDiv").style.display = "none";<%
        }
    %>
            
    //*** loan ***
    $("loanDate").value = "";
    $("loanAmount").value = "";
    $("loanInterestRate").value = "";
    clearRPTable();
    $("loanReimbursementAmount").innerHTML = "";
    $("loanComment").value = "";
    clearLDTable();
    
    $("saleDate").value = "";
    $("saleValue").value = "";
    $("saleClient").value = "";
    
    $("code").focus();
    resizeAllTextareas(8);
  }
  
  <%-- CLEAR ALL TABLES --%>
  function clearAllTables(){     
    clearPDTable();
    clearGATable();
    clearLOTable();
    clearRPTable();
    clearLDTable();
  }
      
  <%-- SELECT SUPPLIER --%>
  function selectSupplier(uidField,nameField){
    var url = "/_common/search/searchSupplier.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldUid="+uidField+
              "&ReturnFieldName="+nameField;
    openPopup(url);
    document.getElementById(nameField).focus();
  }

  <%-- SELECT PARENT --%>
  function selectParent(uidField,codeField){
    var url = "/_common/search/searchAsset.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldUid="+uidField+
              "&ReturnFieldCode="+codeField;
    openPopup(url);
    document.getElementById(codeField).focus();
  }
  
  <%-- DISABLE BUTTONS --%>
  function disableButtons(){
    document.getElementById("buttonSave").disabled = true;
    document.getElementById("buttonDelete").disabled = true;
    document.getElementById("buttonNew").disabled = true;
  }

  <%-- ENABLE BUTTONS --%>
  function enableButtons(){
    document.getElementById("buttonSave").disabled = false;
    document.getElementById("buttonDelete").disabled = false;
    document.getElementById("buttonNew").disabled = false;
  }
  
  <%-- CALCULATE TOTAL REIMBURSEMENT AMOUNT --%>
  function calculateTotalReimbursementAmount(){
    var sPlans = sRP;

    <%-- compose string containing reimbursement plan --%>
    while(sPlans.indexOf("rowRP") > -1){
      sTmpBegin = sPlans.substring(sPlans.indexOf("rowRP"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sPlans = sPlans.substring(0,sPlans.indexOf("rowRP"))+sTmpEnd;
    }
    
    var totalAmount = 0;
    
    if(sPlans.indexOf("$") > -1){
      var sTmpRP = sPlans;
      
      var sTmpDate, sTmpCapital, sTmpInterest;
 
      while(sTmpRP.indexOf("|") > -1){
        sTmpDate = "";
        sTmpCapital = "";
        sTmpInterest = "";

        if(sTmpRP.indexOf("|") > -1){
          sTmpDate = sTmpRP.substring(0,sTmpRP.indexOf("|"));
          sTmpRP = sTmpRP.substring(sTmpRP.indexOf("|")+1);
        }
        
        if(sTmpRP.indexOf("|") > -1){
          sTmpCapital = sTmpRP.substring(0,sTmpRP.indexOf("|"));
          sTmpRP = sTmpRP.substring(sTmpRP.indexOf("|")+1);
        }
        
        if(sTmpRP.indexOf("$") > -1){
          sTmpInterest = sTmpRP.substring(0,sTmpRP.indexOf("$"));
          sTmpRP = sTmpRP.substring(sTmpRP.indexOf("$")+1);
        }
        
        totalAmount+= parseInt(sTmpCapital)*sTmpInterest/100;
      }
      
      $("loanReimbursementAmount").innerHTML = formatNumber(totalAmount,2);
    }
    else{
      document.getElementById("loanReimbursementAmount").innerHTML = "";
    }
  }
  
  
  <%---------------------------------------------------------------------------------------------%>
  <%-- JS 1 : GAINS FUNCTIONS (GA) --------------------------------------------------------------%>
  <%---------------------------------------------------------------------------------------------%>
  var editGARowid = "", iGAIndex = 1, sGA = "";

  <%-- DISPLAY GAINS --%>
  function displayGains(){
    sGA = document.getElementById("gains").value;
        
    if(sGA.indexOf("$") > -1){
      var sTmpGA = sGA;
      sGA = "";
      
      var sTmpDate, sTmpValue;
 
      while(sTmpGA.indexOf("$") > -1){
        sTmpDate = "";
        sTmpValue = "";

        if(sTmpGA.indexOf("|") > -1){
          sTmpDate = sTmpGA.substring(0,sTmpGA.indexOf("|"));
          sTmpGA = sTmpGA.substring(sTmpGA.indexOf("|")+1);
        }
        
        if(sTmpGA.indexOf("$") > -1){
          sTmpValue = sTmpGA.substring(0,sTmpGA.indexOf("$"));
          sTmpGA = sTmpGA.substring(sTmpGA.indexOf("$")+1);
        }            

        sGA+= "rowGA"+iGAIndex+"="+sTmpDate+"|"+
                                   sTmpValue+"$";
        displayGain(iGAIndex++,sTmpDate,sTmpValue);
      }
    }
  }
  
  <%-- DISPLAY GAIN --%>
  function displayGain(iGAIndex,sDate,sValue){
    var tr = tblGA.insertRow(tblGA.rows.length);
    tr.id = "rowGA"+iGAIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteGA(rowGA"+iGAIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editGA(rowGA"+iGAIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+sDate;
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.align = "right";
    td.innerHTML = "&nbsp;"+sValue+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
    tr.appendChild(td);
               
    <%-- empty cell --%>
    td = tr.insertCell(3);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iGAIndex-1);
  }
  
  <%-- ADD GAIN --%>
  function addGA(){
    if(countSelectedGains() <= 20){
      if(areRequiredGAFieldsFilled()){
        var okToAdd = true;
          
        if(okToAdd==true){
          iGAIndex++;

          <%-- update arrayString --%>
          sGA+="rowGA"+iGAIndex+"="+EditForm.gaDate.value+"|"+
                                    EditForm.gaValue.value+"$";
        
          var tr = tblGA.insertRow(tblGA.rows.length);
          tr.id = "rowGA"+iGAIndex;

          var td = tr.insertCell(0);
          td.innerHTML = "<a href='javascript:deleteGA(rowGA"+iGAIndex+")'>"+
                          "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                         "</a> "+
                         "<a href='javascript:editGA(rowGA"+iGAIndex+")'>"+
                          "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                         "</a>";
          tr.appendChild(td);

          td = tr.insertCell(1);
          td.innerHTML = "&nbsp;"+EditForm.gaDate.value;
          tr.appendChild(td);

          td = tr.insertCell(2);
          td.align = "right";
          td.innerHTML = "&nbsp;"+EditForm.gaValue.value+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
          tr.appendChild(td);
                  
          <%-- empty cell --%>
          td = tr.insertCell(3);
          td.innerHTML = "&nbsp;";
          tr.appendChild(td);

          setRowStyle(tr,iGAIndex);
      
          <%-- reset --%>
          clearGAFields()
          EditForm.ButtonUpdateGA.disabled = true;
        }
      }
      else{
        alertDialog("web.manage","dataMissing");
    
        <%-- focus empty field --%>
             if(EditForm.gaDate.value.length==0) EditForm.gaDate.focus();
        else if(EditForm.gaValue.value==0) EditForm.gaValue.focus();
      }
    
      return true;
    }
    else{
      //alertDialog("web.assets","reachedMaximumGains");
      
      if(window.showModalDialog){
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=ScreenHelper.getTs()%>&labelValue=<%=getTranNoLink("web.assets","reachedMaximumGains",sWebLanguage).replaceAll("#maxGains#","20")%>";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        window.showModalDialog(popupUrl,"",modalities);
      }
      else{
        alert(labelId);          
      }
      
      return false;
    }
  }
  
  <%-- COUNT SELECTED GAINS --%>
  function countSelectedGains(){
    var table = document.getElementById("tblGA");
    return table.rows.length-1; // exclude add-row
  }

  <%-- UPDATE GAIN --%>
  function updateGA(){
    if(areRequiredGAFieldsFilled()){
      var okToAdd = true;
    
      if(okToAdd==true){        
        <%-- update arrayString --%>
        var newRow = editGARowid.id+"="+EditForm.gaDate.value+"|"+
                                        EditForm.gaValue.value;

        sGA = replaceRowInArrayString(sGA,newRow,editGARowid.id);

        <%-- update table object --%>
        var row = tblGA.rows[editGARowid.rowIndex];
        row.cells[0].innerHTML = "<a href='javascript:deleteGA("+editGARowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                                 "</a> "+
                                 "<a href='javascript:editGA("+editGARowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                                 "</a>";

        row.cells[1].innerHTML = "&nbsp;"+EditForm.gaDate.value;
        row.cells[2].innerHTML = "&nbsp;"+EditForm.gaValue.value+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
                        
        <%-- empty cell --%>
        row.cells[3].innerHTML = "&nbsp;";

        <%-- reset --%>
        clearGAFields();
        EditForm.ButtonUpdateGA.disabled = true;
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
    
      <%-- focus empty field --%>
           if(EditForm.gaDate.value.length==0) EditForm.gaDate.focus();
      else if(EditForm.gaValue.value==0) EditForm.gaValue.focus();
    }
  }
  
  <%-- ARE REQUIRED GA FIELDS FILLED --%>
  function areRequiredGAFieldsFilled(){
    return (EditForm.gaDate.value.length > 0 &&
            EditForm.gaValue.value.length > 0);
  }

  <%-- CLEAR GAIN FIELDS --%>
  function clearGAFields(){
    EditForm.gaDate.value = "";
    EditForm.gaValue.value = "";   
  }

  <%-- CLEAR GAIN TABLE --%>
  function clearGATable(){
    $("gains").value = "";
    var table = document.getElementById("tblGA");
    
    for(var i=table.rows.length; i>2; i--){
      table.deleteRow(i-1);
    }
  }
  
  <%-- DELETE GAIN --%>
  function deleteGA(rowid){
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){
      sGA = deleteRowFromArrayString(sGA,rowid.id);
      tblGA.deleteRow(rowid.rowIndex);
      
      updateRowStylesSpecificTable("tblGA",2);
      clearGAFields();
    }
  }

  <%-- EDIT GAIN --%>
  function editGA(rowid){
    var row = getRowFromArrayString(sGA,rowid.id);

    EditForm.gaDate.value  = getCelFromRowString(row,0);
    EditForm.gaValue.value = getCelFromRowString(row,1);

    editGARowid = rowid;
    EditForm.ButtonUpdateGA.disabled = false;
  }

  
  <%---------------------------------------------------------------------------------------------%>
  <%-- JS 2 : LOSSES FUNCTIONS (LO) -------------------------------------------------------------%>
  <%---------------------------------------------------------------------------------------------%>
  var editLORowid = "", iLOIndex = 1, sLO = "";

  <%-- DISPLAY LOSSES --%>
  function displayLosses(){
    sLO = document.getElementById("losses").value;
        
    if(sLO.indexOf("$") > -1){
      var sTmpLO = sLO;
      sLO = "";
      
      var sTmpDate, sTmpValue;
 
      while(sTmpLO.indexOf("$") > -1){
        sTmpDate = "";
        sTmpValue = "";

        if(sTmpLO.indexOf("|") > -1){
          sTmpDate = sTmpLO.substring(0,sTmpLO.indexOf("|"));
          sTmpLO = sTmpLO.substring(sTmpLO.indexOf("|")+1);
        }
        
        if(sTmpLO.indexOf("$") > -1){
          sTmpValue = sTmpLO.substring(0,sTmpLO.indexOf("$"));
          sTmpLO = sTmpLO.substring(sTmpLO.indexOf("$")+1);
        }

        sLO+= "rowLO"+iLOIndex+"="+sTmpDate+"|"+
                                   sTmpValue+"$";
        displayLoss(iLOIndex++,sTmpDate,sTmpValue);
      }
    }
  }
  
  <%-- DISPLAY LOSS --%>
  function displayLoss(iLOIndex,sDate,sValue){
    var tr = tblLO.insertRow(tblLO.rows.length);
    tr.id = "rowLO"+iLOIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteLO(rowLO"+iLOIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editLO(rowLO"+iLOIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+sDate;
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.align = "right";
    td.innerHTML = "&nbsp;"+sValue+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
    tr.appendChild(td);
               
    <%-- empty cell --%>
    td = tr.insertCell(3);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iLOIndex-1);
  }
  
  <%-- ADD LOSS --%>
  function addLO(){
    if(countSelectedLosses() <= 20){
      if(areRequiredLOFieldsFilled()){
        var okToAdd = true;
          
        if(okToAdd==true){
          iLOIndex++;

          <%-- update arrayString --%>
          sLO+="rowLO"+iLOIndex+"="+EditForm.loDate.value+"|"+
                                    EditForm.loValue.value+"$";
        
          var tr = tblLO.insertRow(tblLO.rows.length);
          tr.id = "rowLO"+iLOIndex;

          var td = tr.insertCell(0);
          td.innerHTML = "<a href='javascript:deleteLO(rowLO"+iLOIndex+")'>"+
                          "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                         "</a> "+
                         "<a href='javascript:editLO(rowLO"+iLOIndex+")'>"+
                          "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                         "</a>";
          tr.appendChild(td);

          td = tr.insertCell(1);
          td.innerHTML = "&nbsp;"+EditForm.loDate.value;
          tr.appendChild(td);

          td = tr.insertCell(2);
          td.align = "right";
          td.innerHTML = "&nbsp;"+EditForm.loValue.value+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
          tr.appendChild(td);
                  
          <%-- empty cell --%>
          td = tr.insertCell(3);
          td.innerHTML = "&nbsp;";
          tr.appendChild(td);

          setRowStyle(tr,iLOIndex);
      
          <%-- reset --%>
          clearLOFields()
          EditForm.ButtonUpdateLO.disabled = true;
        }
      }
      else{
        alertDialog("web.manage","dataMissing");
    
        <%-- focus empty field --%>
             if(EditForm.loDate.value.length==0) EditForm.loDate.focus();
        else if(EditForm.loValue.value==0) EditForm.loValue.focus();
      }
     
      return true;
    }
    else{
      //alertDialog("web.assets","reachedMaximumLosses");

      if(window.showModalDialog){
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=ScreenHelper.getTs()%>&labelValue=<%=getTranNoLink("web.assets","reachedMaximumLosses",sWebLanguage).replaceAll("#maxLosses#","20")%>";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        window.showModalDialog(popupUrl,"",modalities);
      }
      else{
        alert(labelId);          
      }
      
      return false;
    }
  }
  
  <%-- COUNT SELECTED LOSSES --%>
  function countSelectedLosses(){
    var table = document.getElementById("tblLO");
    return table.rows.length-1; // exclude add-row
  }

  <%-- UPDATE LOSS --%>
  function updateLO(){
    if(areRequiredLOFieldsFilled()){
      var okToAdd = true;
    
      if(okToAdd==true){        
        <%-- update arrayString --%>
        var newRow = editLORowid.id+"="+EditForm.loDate.value+"|"+
                                        EditForm.loValue.value;

        sLO = replaceRowInArrayString(sLO,newRow,editLORowid.id);

        <%-- update table object --%>
        var row = tblLO.rows[editLORowid.rowIndex];
        row.cells[0].innerHTML = "<a href='javascript:deleteLO("+editLORowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                                 "</a> "+
                                 "<a href='javascript:editLO("+editLORowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                                 "</a>";

        row.cells[1].innerHTML = "&nbsp;"+EditForm.loDate.value;
        row.cells[2].innerHTML = "&nbsp;"+EditForm.loValue.value+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
                        
        <%-- empty cell --%>
        row.cells[3].innerHTML = "&nbsp;";

        <%-- reset --%>
        clearLOFields();
        EditForm.ButtonUpdateLO.disabled = true;
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
    
      <%-- focus empty field --%>
           if(EditForm.loDate.value.length==0) EditForm.loDate.focus();
      else if(EditForm.loValue.value==0) EditForm.loValue.focus();
    }
  }
  
  <%-- ARE REQUIRED LO FIELDS FILLED --%>
  function areRequiredLOFieldsFilled(){
    return (EditForm.loDate.value.length > 0 &&
            EditForm.loValue.value.length > 0);
  }

  <%-- CLEAR LOSS FIELDS --%>
  function clearLOFields(){
    EditForm.loDate.value = "";
    EditForm.loValue.value = "";   
  }

  <%-- CLEAR LOSS TABLE --%>
  function clearLOTable(){
    $("losses").value = "";
    var table = document.getElementById("tblLO");
    
    for(var i=table.rows.length; i>2; i--){
      table.deleteRow(i-1);
    }
  }
  
  <%-- DELETE LOSS --%>
  function deleteLO(rowid){
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){
      sLO = deleteRowFromArrayString(sLO,rowid.id);
      tblLO.deleteRow(rowid.rowIndex);

      updateRowStylesSpecificTable("tblLO",2);
      clearLOFields();
    }
  }

  <%-- EDIT LOSS --%>
  function editLO(rowid){
    var row = getRowFromArrayString(sLO,rowid.id);

    EditForm.loDate.value  = getCelFromRowString(row,0);
    EditForm.loValue.value = getCelFromRowString(row,1);

    editLORowid = rowid;
    EditForm.ButtonUpdateLO.disabled = false;
  }
  

  <%---------------------------------------------------------------------------------------------%>
  <%-- JS 3 : PURCHASE DOCUMENTS FUNCTIONS (PD) -------------------------------------------------%>
  <%---------------------------------------------------------------------------------------------%>
  var editPDRowid = "", iPDIndex = 1, sPD = "";
  
  <%-- DISPLAY PURCHASE DOCUMENTS --%>
  function displayPurchaseDocuments(){
    sPD = document.getElementById("purchaseDocuments").value;
        
    if(sPD.indexOf("$") > -1){
      var sTmpPD = sPD;
      sPD = "";
      
      var sTmpID;
 
      while(sTmpPD.indexOf("$") > -1){
        sTmpID = "";

        if(sTmpPD.indexOf("$") > -1){
          sTmpID = sTmpPD.substring(0,sTmpPD.indexOf("$"));
          sTmpPD = sTmpPD.substring(sTmpPD.indexOf("$")+1);
        }
        
        sPD+= "rowPD"+iPDIndex+"="+sTmpID+"$";
        displayPurchaseDocument(iPDIndex++,sTmpID);
      }
    }
  }
  
  <%-- DISPLAY PURCHASE DOCUMENT --%>
  function displayPurchaseDocument(iPDIndex,sID){
    var tr = tblPD.insertRow(tblPD.rows.length);
    tr.id = "rowPD"+iPDIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deletePD(rowPD"+iPDIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editPD(rowPD"+iPDIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+sID;
    tr.appendChild(td);
               
    <%-- empty cell --%>
    td = tr.insertCell(2);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iPDIndex-1);
  }
  
  <%-- ADD PURCHASE DOCUMENT --%>
  function addPD(){
  	EditForm.pdID.value = formatDocumentID(EditForm.pdID.value); 
  	
    if(sPD.indexOf(EditForm.pdID.value) > -1){
      alertDialog("web.assets","documentAlreadySelected");
      //EditForm.pdID.focus();
      return false;        
    }
    
    if(countSelectedPDs() <= 20){
      if(areRequiredPDFieldsFilled()){
        iPDIndex++;

        <%-- update arrayString --%>
        sPD+="rowPD"+iPDIndex+"="+EditForm.pdID.value+"$";
        
        var tr = tblPD.insertRow(tblPD.rows.length);
        tr.id = "rowPD"+iPDIndex;

        var td = tr.insertCell(0);
        td.innerHTML = "<a href='javascript:deletePD(rowPD"+iPDIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                       "</a> "+
                       "<a href='javascript:editPD(rowPD"+iPDIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                       "</a>";
        tr.appendChild(td);

        td = tr.insertCell(1);
        td.innerHTML = "&nbsp;"+EditForm.pdID.value;
        tr.appendChild(td);
                  
        <%-- empty cell --%>
        td = tr.insertCell(2);
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        setRowStyle(tr,iPDIndex-1);
      
        <%-- reset --%>
        clearPDFields()
        EditForm.ButtonUpdatePD.disabled = true;
      }
      else{
        alertDialog("web.manage","dataMissing");
      
        <%-- focus empty field --%>
        if(EditForm.pdID.value.length==0) EditForm.pdID.focus();
      }
      
      return true; 
    }
    else{
      //alertDialog("web.assets","reachedMaximumDocuments");

      if(window.showModalDialog){
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=ScreenHelper.getTs()%>&labelValue=<%=getTranNoLink("web.assets","reachedMaximumDocuments",sWebLanguage).replaceAll("#maxDocuments#","20")%>";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        window.showModalDialog(popupUrl,"",modalities);
      }
      else{
        alert(labelId);          
      }
      
      return false;
    }
  }
  
  <%-- COUNT SELECTED PDS --%>
  function countSelectedPDs(){
    var table = document.getElementById("tblPD");
    return table.rows.length-1; // exclude add-row
  }

  <%-- UPDATE PURCHASE DOCUMENT --%>
  function updatePD(){
    if(areRequiredPDFieldsFilled()){
      <%-- update arrayString --%>
      var newRow = editPDRowid.id+"="+EditForm.pdID.value;

      sPD = replaceRowInArrayString(sPD,newRow,editPDRowid.id);

      <%-- update table object --%>
      var row = tblPD.rows[editPDRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deletePD("+editPDRowid.id+")'>"+
                                "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                               "</a> "+
                               "<a href='javascript:editPD("+editPDRowid.id+")'>"+
                                "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                               "</a>";

      row.cells[1].innerHTML = "&nbsp;"+EditForm.pdID.value;
                        
      <%-- empty cell --%>
      row.cells[2].innerHTML = "&nbsp;";

      <%-- reset --%>
      clearPDFields();
      EditForm.ButtonUpdatePD.disabled = true;
    }
    else{
      alertDialog("web.manage","dataMissing");
    
      <%-- focus empty field --%>
      if(EditForm.pdID.value.length==0) EditForm.pdID.focus();
    }
  }
  
  <%-- ARE REQUIRED PD FIELDS FILLED --%>
  function areRequiredPDFieldsFilled(){
    return (EditForm.pdID.value.length > 0);
  }

  <%-- CLEAR PURCHASE DOCUMENT FIELDS --%>
  function clearPDFields(){
    EditForm.pdID.value = "";
  }

  <%-- CLEAR PURCHASE DOCUMENT TABLE --%>
  function clearPDTable(){
    $("purchaseDocuments").value = "";
    var table = document.getElementById("tblPD");
    
    for(var i=table.rows.length; i>2; i--){
      table.deleteRow(i-1);
    }
  }
  
  <%-- DELETE PURCHASE DOCUMENT --%>
  function deletePD(rowid){
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){
      sPD = deleteRowFromArrayString(sPD,rowid.id);
      tblPD.deleteRow(rowid.rowIndex);

      updateRowStylesSpecificTable("tblPD",2);
      clearPDFields();
    }
  }

  <%-- EDIT PURCHASE DOCUMENT --%>
  function editPD(rowid){
    var row = getRowFromArrayString(sPD,rowid.id);

    EditForm.pdID.value = getCelFromRowString(row,0);

    editPDRowid = rowid;
    EditForm.ButtonUpdatePD.disabled = false;
  }

  
  <%---------------------------------------------------------------------------------------------%>
  <%-- JS 4 : LOAN REIMBURSEMENT PLAN FUNCTIONS (RP) --------------------------------------------%>
  <%---------------------------------------------------------------------------------------------%>
  var editRPRowid = "", iRPIndex = 1, sRP = "";

  <%-- DISPLAY REIMBURSEMENT PLANS --%>
  function displayReimbursementPlans(){
    sRP = document.getElementById("loanReimbursementPlan").value;
        
    if(sRP.indexOf("|") > -1){
      var sTmpRP = sRP;
      sRP = "";
      
      var sTmpDate, sTmpCapital, sTmpInterest;
 
      while(sTmpRP.indexOf("|") > -1){
        sTmpDate = "";
        sTmpCapital = "";
        sTmpInterest = "";
        
        if(sTmpRP.indexOf("|") > -1){
          sTmpDate = sTmpRP.substring(0,sTmpRP.indexOf("|"));
          sTmpRP = sTmpRP.substring(sTmpRP.indexOf("|")+1);
        }
        
        if(sTmpRP.indexOf("|") > -1){
          sTmpCapital = sTmpRP.substring(0,sTmpRP.indexOf("|"));
          sTmpRP = sTmpRP.substring(sTmpRP.indexOf("|")+1);
        }
        
        if(sTmpRP.indexOf("$") > -1){
          sTmpInterest = sTmpRP.substring(0,sTmpRP.indexOf("$"));
          sTmpRP = sTmpRP.substring(sTmpRP.indexOf("$")+1);
        }
        
        var sTotal = formatNumber(sTmpCapital*sTmpInterest/100,2);
        
        sRP+= "rowRP"+iRPIndex+"="+sTmpDate+"|"+sTmpCapital+"|"+sTmpInterest+"$";
        displayReimbursementPlan(iRPIndex++,sTmpDate,sTmpCapital,sTmpInterest,sTotal);
      }
    }
  }
  
  <%-- DISPLAY REIMBURSEMENT PLAN --%>
  function displayReimbursementPlan(iRPIndex,sDate,sCapital,sInterest,sTotal){
    var tr = tblRP.insertRow(tblRP.rows.length);
    tr.id = "rowRP"+iRPIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteRP(rowRP"+iRPIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editRP(rowRP"+iRPIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+sDate;
    tr.appendChild(td);
    
    td = tr.insertCell(2);
    td.align = "right";
    td.innerHTML = "&nbsp;"+sCapital+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
    tr.appendChild(td);

    td = tr.insertCell(3);
    td.align = "right";
    td.innerHTML = "&nbsp;"+sInterest+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
    tr.appendChild(td);
    
    td = tr.insertCell(4);
    td.align = "right";
    td.innerHTML = "&nbsp;"+sTotal+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
    tr.appendChild(td);
               
    <%-- empty cell --%>
    td = tr.insertCell(5);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iRPIndex-1);
  }
  
  <%-- ADD REIMBURSEMENT PLAN --%>
  function addRP(){
    if(countSelectedRPs() <= 20){
      if(areRequiredRPFieldsFilled()){
        iRPIndex++;

        <%-- update arrayString --%>
        sRP+="rowRP"+iRPIndex+"="+EditForm.rpDate.value+"|"+EditForm.rpCapital.value+"|"+EditForm.rpInterest.value+"$";
        
        var tr = tblRP.insertRow(tblRP.rows.length);
        tr.id = "rowRP"+iRPIndex;

        var td = tr.insertCell(0);
        td.innerHTML = "<a href='javascript:deleteRP(rowRP"+iRPIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                       "</a> "+
                       "<a href='javascript:editRP(rowRP"+iRPIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                       "</a>";
        tr.appendChild(td);

        td = tr.insertCell(1);
        td.innerHTML = "&nbsp;"+EditForm.rpDate.value;
        tr.appendChild(td);
      
        td = tr.insertCell(2);
        td.align = "right";
        td.innerHTML = "&nbsp;"+EditForm.rpCapital.value+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
        tr.appendChild(td);

        td = tr.insertCell(3);
        td.align = "right";
        td.innerHTML = "&nbsp;"+EditForm.rpInterest.value+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
        tr.appendChild(td);
      
        td = tr.insertCell(4);
        td.align = "right";
        td.innerHTML = "&nbsp;"+document.getElementById("rpTotal").innerHTML+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
        tr.appendChild(td);
                  
        <%-- empty cell --%>
        td = tr.insertCell(5);
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        setRowStyle(tr,iRPIndex);
      
        <%-- reset --%>
        clearRPFields()
        EditForm.ButtonUpdateRP.disabled = true;
      
        calculateTotalReimbursementAmount();
      }
      else{
        alertDialog("web.manage","dataMissing");
    
        <%-- focus empty field --%>
             if(EditForm.rpDate.value.length==0) EditForm.rpDate.focus();
        else if(EditForm.rpCapital.value.length==0) EditForm.rpCapital.focus();
        else if(EditForm.rpInterest.value.length==0) EditForm.rpInterest.focus();
      }
    
      return true;
    }
    else{
      //alertDialog("web.assets","reachedMaximumReimbursementPlans");

      if(window.showModalDialog){
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=ScreenHelper.getTs()%>&labelValue=<%=getTranNoLink("web.assets","reachedMaximumReimbursementPlans",sWebLanguage).replaceAll("#maxReimbursements#","20")%>";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        window.showModalDialog(popupUrl,"",modalities);
      }
      else{
        alert(labelId);          
      }
      
      return false;
    }
  }
  
  <%-- COUNT SELECTED RPS --%>
  function countSelectedRPs(){
    var table = document.getElementById("tblRP");
    return table.rows.length-1; // exclude add-row
  }

  <%-- UPDATE REIMBURSEMENT PLAN --%>
  function updateRP(){
    if(areRequiredRPFieldsFilled()){        
      <%-- update arrayString --%>
      var newRow = editRPRowid.id+"="+EditForm.rpDate.value+"|"+EditForm.rpCapital.value+"|"+EditForm.rpInterest.value;
 
      sRP = replaceRowInArrayString(sRP,newRow,editRPRowid.id);

      <%-- update table object --%>
      var row = tblRP.rows[editRPRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deleteRP("+editRPRowid.id+")'>"+
                                "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                               "</a> "+
                               "<a href='javascript:editRP("+editRPRowid.id+")'>"+
                                "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                               "</a>";

      row.cells[1].innerHTML = "&nbsp;"+EditForm.rpDate.value;
      row.cells[2].innerHTML = "&nbsp;"+EditForm.rpCapital.value+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
      row.cells[3].innerHTML = "&nbsp;"+EditForm.rpInterest.value+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
      row.cells[4].innerHTML = "&nbsp;"+document.getElementById("rpTotal").innerHTML+" <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;";
                        
      <%-- empty cell --%>
      row.cells[5].innerHTML = "&nbsp;";

      <%-- reset --%>
      clearRPFields();
      EditForm.ButtonUpdateRP.disabled = true;
      
      calculateTotalReimbursementAmount();
    }
    else{
      alertDialog("web.manage","dataMissing");
    
      <%-- focus empty field --%>
           if(EditForm.rpDate.value.length==0) EditForm.rpDate.focus();
      else if(EditForm.rpCapital.value.length==0) EditForm.rpCapital.focus();
      else if(EditForm.rpInterest.value.length==0) EditForm.rpInterest.focus();
    }
  }
  
  <%-- ARE REQUIRED RP FIELDS FILLED --%>
  function areRequiredRPFieldsFilled(){
    return (EditForm.rpDate.value.length > 0 &&
            EditForm.rpCapital.value.length > 0 &&
            EditForm.rpInterest.value.length > 0);
  }

  <%-- CLEAR REIMBURSEMENT PLAN FIELDS --%>
  function clearRPFields(){
    EditForm.rpDate.value = "";
    EditForm.rpCapital.value = "";
    EditForm.rpInterest.value = "";  
    document.getElementById("rpTotal").innerHTML = "";
  }

  <%-- CLEAR REIMBURSEMENT PLAN TABLE --%>
  function clearRPTable(){
    $("loanReimbursementPlan").value = "";
    var table = document.getElementById("tblRP");
    
    for(var i=table.rows.length; i>2; i--){
      table.deleteRow(i-1);
    }

    document.getElementById("loanReimbursementAmount").innerHTML = "";
  }
  
  <%-- DELETE REIMBURSEMENT PLAN --%>
  function deleteRP(rowid){
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){
      sRP = deleteRowFromArrayString(sRP,rowid.id);
      tblRP.deleteRow(rowid.rowIndex);

      updateRowStylesSpecificTable("tblRP",2);
      clearRPFields();
      calculateTotalReimbursementAmount();
    }
  }

  <%-- EDIT REIMBURSEMENT PLAN --%>
  function editRP(rowid){
    var row = getRowFromArrayString(sRP,rowid.id);

    EditForm.rpDate.value = getCelFromRowString(row,0);
    EditForm.rpCapital.value = getCelFromRowString(row,1);
    EditForm.rpInterest.value = getCelFromRowString(row,2);

    <%-- calculate total --%>
    document.getElementById("rpTotal").innerHTML = formatNumber(EditForm.rpCapital.value*EditForm.rpInterest.value/100,2); 
        
    editRPRowid = rowid;
    EditForm.ButtonUpdateRP.disabled = false;
  }
  

  <%---------------------------------------------------------------------------------------------%>
  <%-- JS 5 : LOAN DOCUMENTS FUNCTIONS (LD) -----------------------------------------------------%>
  <%---------------------------------------------------------------------------------------------%>
  var editLDRowid = "", iLDIndex = 1, sLD = "";

  <%-- DISPLAY LOAN DOCUMENTS --%>
  function displayLoanDocuments(){
    sLD = document.getElementById("loanDocuments").value;
        
    if(sLD.indexOf("$") > -1){
      var sTmpLD = sLD;
      sLD = "";
      
      var sTmpID;
 
      while(sTmpLD.indexOf("$") > -1){
        sTmpID = "";

        if(sTmpLD.indexOf("$") > -1){
          sTmpID = sTmpLD.substring(0,sTmpLD.indexOf("$"));
          sTmpLD = sTmpLD.substring(sTmpLD.indexOf("$")+1);
        }
        
        sLD+= "rowLD"+iLDIndex+"="+sTmpID+"$";
        displayLoanDocument(iLDIndex++,sTmpID);
      }
    }
  }
  
  <%-- DISPLAY LOAN DOCUMENT --%>
  function displayLoanDocument(iLDIndex,sID){
    var tr = tblLD.insertRow(tblLD.rows.length);
    tr.id = "rowLD"+iLDIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteLD(rowLD"+iLDIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editLD(rowLD"+iLDIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+sID;
    tr.appendChild(td);
               
    <%-- empty cell --%>
    td = tr.insertCell(2);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iLDIndex-1);
  }
  
  <%-- ADD LOAN DOCUMENT --%>
  function addLD(){
    EditForm.ldID.value = formatDocumentID(EditForm.ldID.value);
      
    if(sLD.indexOf(EditForm.ldID.value) > -1){
      alertDialog("web.assets","documentAlreadySelected");
      //EditForm.ldID.focus();
      return false;        
    }
    
    if(countSelectedLDs() <= 20){
      if(areRequiredLDFieldsFilled()){
        iLDIndex++;

        <%-- update arrayString --%>
        sLD+="rowLD"+iLDIndex+"="+EditForm.ldID.value+"$";
        
        var tr = tblLD.insertRow(tblLD.rows.length);
        tr.id = "rowLD"+iLDIndex;

        var td = tr.insertCell(0);
        td.innerHTML = "<a href='javascript:deleteLD(rowLD"+iLDIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                       "</a> "+
                       "<a href='javascript:editLD(rowLD"+iLDIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                       "</a>";
        tr.appendChild(td);

        td = tr.insertCell(1);
        td.innerHTML = "&nbsp;"+EditForm.ldID.value;
        tr.appendChild(td);
                  
        <%-- empty cell --%>
        td = tr.insertCell(2);
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        setRowStyle(tr,iLDIndex-1);
      
        <%-- reset --%>
        clearLDFields()
        EditForm.ButtonUpdateLD.disabled = true;
      }
      else{
        alertDialog("web.manage","dataMissing");
    
        <%-- focus empty field --%>
        if(EditForm.ldID.value.length==0) EditForm.ldID.focus();
      }
    
      return true;
    }
    else{
      //alertDialog("web.assets","reachedMaximumDocuments");

      if(window.showModalDialog){
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=ScreenHelper.getTs()%>&labelValue=<%=getTranNoLink("web.assets","reachedMaximumDocuments",sWebLanguage).replaceAll("#maxDocuments#","20")%>";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        window.showModalDialog(popupUrl,"",modalities);
      }
      else{
        alert(labelId);          
      }
      
      return false;
    }
  }  
  
  <%-- FORMAT DOCUMENT ID --%>
  function formatDocumentID(docID){
    docID = replaceAll(docID,"-","");
    docID = replaceAll(docID,".","");

    if(docID.length==11){
      var part1 = docID.substr(0,9),
	      part2 = docID.substr(9,2);
	
      return part1+"-"+part2;
	}
	else{
      return docID;
	}
  }
  
  <%-- COUNT SELECTED LDS --%>
  function countSelectedLDs(){
    var table = document.getElementById("tblLD");
    return table.rows.length-1; // exclude add-row
  }
  
  <%-- UPDATE LOAN DOCUMENT --%>
  function updateLD(){
    if(areRequiredLDFieldsFilled()){        
      <%-- update arrayString --%>
      var newRow = editLDRowid.id+"="+EditForm.ldID.value;
 
      sLD = replaceRowInArrayString(sLD,newRow,editLDRowid.id);

      <%-- update table object --%>
      var row = tblLD.rows[editLDRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deleteLD("+editLDRowid.id+")'>"+
                                "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                               "</a> "+
                               "<a href='javascript:editLD("+editLDRowid.id+")'>"+
                                "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                               "</a>";

      row.cells[1].innerHTML = "&nbsp;"+EditForm.ldID.value;
                        
      <%-- empty cell --%>
      row.cells[2].innerHTML = "&nbsp;";

      <%-- reset --%>
      clearLDFields();
      EditForm.ButtonUpdateLD.disabled = true;
    }
    else{
      alertDialog("web.manage","dataMissing");
    
      <%-- focus empty field --%>
      if(EditForm.ldID.value.length==0) EditForm.ldID.focus();
    }
  }
  
  <%-- ARE REQUIRED LD FIELDS FILLED --%>
  function areRequiredLDFieldsFilled(){
    return (EditForm.ldID.value.length > 0);
  }

  <%-- CLEAR LOAN DOCUMENT FIELDS --%>
  function clearLDFields(){
    EditForm.ldID.value = "";  
  }

  <%-- CLEAR LOAN DOCUMENT TABLE --%>
  function clearLDTable(){
    $("loanDocuments").value = "";
    var table = document.getElementById("tblLD");
    
    for(var i=table.rows.length; i>2; i--){
      table.deleteRow(i-1);
    }
  }
  
  <%-- DELETE LOAN DOCUMENT --%>
  function deleteLD(rowid){
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){
      sLD = deleteRowFromArrayString(sLD,rowid.id);
      tblLD.deleteRow(rowid.rowIndex);

      updateRowStylesSpecificTable("tblLD",2);
      clearLDFields();
    }
  }

  <%-- EDIT LOAN DOCUMENT --%>
  function editLD(rowid){
    var row = getRowFromArrayString(sLD,rowid.id);

    EditForm.ldID.value = getCelFromRowString(row,0);

    editLDRowid = rowid;
    EditForm.ButtonUpdateLD.disabled = false;
  }
  
  resizeAllTextareas(8);
</script>