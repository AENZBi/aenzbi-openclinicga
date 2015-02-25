<%@include file="/includes/helper.jsp"%>

<%
    String sTmpAPPDIR   = ScreenHelper.checkString(ScreenHelper.getCookie("activeProjectDir", request)),
           sTmpAPPTITLE = ScreenHelper.checkString(ScreenHelper.getCookie("activeProjectTitle", request));
    if(sTmpAPPTITLE==null) sTmpAPPTITLE = "OpenClinic";
%>
    
<html>
<head>
    <META HTTP-EQUIV="Refresh" CONTENT="3600;url=<%=sCONTEXTPATH%>/<%=sTmpAPPDIR%>">
    <%=sCSSNORMAL%>
    <%=sJSCOOKIE%>
    <%=sJSDROPDOWNMENU%>
    <%=sIcon%>
    
    <script>
      if(window.history.forward(1)!=null){
        window.history.forward(1);
      }
    
      function escBackSpace(){
        if(window.event && enterEvent(event,8)){
          window.event.keyCode = 123; // F12
        }
      }
      
      function goToLogin(){
        window.location.href = "<%=sCONTEXTPATH%>/<%=sTmpAPPDIR%>";
      }
    </script>
    
    <title><%=sWEBTITLE+" "+sTmpAPPTITLE%></title>
</head>

<body class="Geenscroll login" onkeydown="escBackSpace();if(enterEvent(event,13)){goToLogin();}">
	<%
		if(request.getRequestURL().toString().indexOf("globalhealthbarometer")>-1){
			out.print("<script>window.location.href='http://www.globalhealthbarometer.net';</script>");
		}
	
		if("openinsurance".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("edition",""))) {
			%><div id="loginopeninsurance" class="withoutfields"><%
		}
		else{
			%><div id="login" class="withoutfields"><%
		}
	%>	

    <div id="logo">
        <%
           if("datacenter".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("edition",""))){
               session.setAttribute("edition","datacenter");
               %><img src="projects/datacenter/_img/logo.jpg" border="0"><%
           }
           else if("openlab".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("edition",""))){
               session.setAttribute("edition", "openlab");
               %><img src="projects/openlab/_img/logo.jpg" border="0"><%
           }
           else if("openpharmacy".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("edition",""))){
               session.setAttribute("edition", "openlab");
               %><img src="_img/openpharmacy_logo.jpg" border="0"><%
           }
           else if("openinsurance".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("edition",""))){
               session.setAttribute("edition", "openinsurance");
               %><img src="_img/openinsurancelogo.jpg" border="0"><%
           }
           else{
               session.setAttribute("edition", "openclinic");
               %><img src="<%=sTmpAPPDIR%>_img/logo.jpg" border="0"><%
           }
        %>
    </div>
    
    <div id="version">&nbsp;</div>
    
    <div id="fields">
        <table>
            <tr>
                <td>
                    <br><br> <b>Session expired</b> <br>
                </td>
            </tr>
            <tr>
                <td>
                    <br> Your session expired.<br>Please relogin
                    <a href="<%=sCONTEXTPATH%>/<%=sTmpAPPDIR%>" onMouseOver="window.status='';return true;">here</a>.
                </td>
            </tr>
        </table>
    </div>
    <div id="messages" class="messagesnofields">
        GA Open Source Edition by:        <% if (MedwanQuery.getInstance().getConfigString("mxsref", "rw").equalsIgnoreCase("rw")) { %>
        <img src="_img/flags/rwandaflag.jpg" height="15px" width="30px" alt="Rwanda"/>
        <a href="http://mxs.rwandamed.org" target="_new"><b>MXS Central Africa SARL</b></a>
        <BR/> PO Box 3242 - Kigali Rwanda Tel +250 07884 32 435 -
        <a href="mailto:mxs@rwandamed.org">mxs@rwandamed.org</a>
        <% } else if (MedwanQuery.getInstance().getConfigString("mxsref", "rw").equalsIgnoreCase("bi")){ 
        	if(MedwanQuery.getInstance().getConfigString("projectref","").equalsIgnoreCase("paiss")){
	        %>
		        <img src="_img/flags/btc.png" height="20px" alt="CTB Burundi"/>
		        <a href="http://www.btcctb.org" target="_new"><b>CTB Burundi - PAISS</b></a>
		        <BR/> Avenue de la Croix Rouge, BP 6708 - Bujumbura +257 222 775 48<br/>
	        <% 
        	}
        	else {
    	        %>
		        <img src="_img/flags/burundiflag.jpg" height="15px" width="30px" alt="Burundi"/>
		        <a href="http://www.openit-burundi.net" target="_new"><b>Open-IT Burundi SPRL</b></a>
		        <BR/> Avenue de l'ONU 6, BP 7205 - Bujumbura +257 78 837 342<br/>
		        <a href="mailto:info@openit-burundi.net">info@openit-burundi.net</a>
	        <% 
        	}
        } else if (MedwanQuery.getInstance().getConfigString("mxsref", "rw").equalsIgnoreCase("ml")) { %>
        <img src="_img/flags/maliflag.jpg" height="15px" width="30px" alt="Mali"/>
        <a href="http://www.sante.gov.ml/" target="_new"><b>ANTIM</b></a> et <a href="http://www.mxs.be" target="_new"><b>MXS</b></a>
        <BR/> Hamdalaye ACI 2000, Rue 340, Porte 541, Bamako - Mali<br/>
        <a href="mailto:info@openit-burundi.net">ousmanely@sante.gov.ml</a>
        <% } else { %>
        <img src="_img/flags/belgiumflag.jpg" height="10px" width="20px" alt="Belgium"/>
        <a href="http://www.mxs.be" target="_new"><b>MXS SA/NV</b></a>
        <BR/> Pastoriestraat 58, 3370 Boutersem Belgium Tel: +32 16 721047 -
        <a href="mailto:mxs@rwandamed.org">info@mxs.be</a>
        <% } %>
    </div>
</div>
</body>
</html>