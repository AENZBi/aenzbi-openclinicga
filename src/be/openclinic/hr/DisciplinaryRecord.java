package be.openclinic.hr;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;


public class DisciplinaryRecord extends OC_Object {
    public int serverId;
    public int objectId;    
    public int personId;
    
    public java.util.Date date;
    public String title;
    public String description;
    public String decision;
    public int duration;
    public String decisionBy;
    public String followUp;
    
    
    //--- CONSTRUCTOR ---
    public DisciplinaryRecord(){
        serverId = -1;
        objectId = -1;        
        personId = -1;
        
        date = null;
        title = "";
        description = "";
        decision = "";
        duration = -1;
        decisionBy = "";
        followUp = "";
    }
        
    //--- STORE -----------------------------------------------------------------------------------
    public boolean store(String userUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
                
        try{            
            if(getUid().equals("-1")){
                // insert new disciplinary record
                sSql = "INSERT INTO hr_disciplinary_records (HR_DISCREC_SERVERID,HR_DISCREC_OBJECTID,"+
                       "  HR_DISCREC_PERSONID,HR_DISCREC_DATE,HR_DISCREC_TITLE,HR_DISCREC_DESCRIPTION,"+
                       "  HR_DISCREC_DECISION,HR_DISCREC_DURATION,HR_DISCREC_DECISIONBY,"+
                       "  HR_DISCREC_FOLLOWUP,HR_DISCREC_UPDATETIME,HR_DISCREC_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"; // 12
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("HR_DISCIPLINARY_RECORD");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setInt(psIdx++,personId);
                ps.setDate(psIdx++,new java.sql.Date(date.getTime()));
                ps.setString(psIdx++,title);
                ps.setString(psIdx++,description);
                ps.setString(psIdx++,decision);
                ps.setInt(psIdx++,duration);
                ps.setString(psIdx++,decisionBy);
                ps.setString(psIdx++,followUp);                
                
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{            
                // update existing record
                sSql = "UPDATE hr_disciplinary_records SET"+
                       "  HR_DISCREC_DATE = ?, HR_DISCREC_TITLE = ?, HR_DISCREC_DESCRIPTION = ?,"+
                       "  HR_DISCREC_DECISION = ?, HR_DISCREC_DURATION = ?, HR_DISCREC_DECISIONBY = ?,"+
                       "  HR_DISCREC_FOLLOWUP = ?, HR_DISCREC_UPDATETIME = ?, HR_DISCREC_UPDATEID = ?"+ // update-info
                       " WHERE (HR_DISCREC_SERVERID = ? AND HR_DISCREC_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setDate(psIdx++,new java.sql.Date(date.getTime()));
                ps.setString(psIdx++,title);
                ps.setString(psIdx++,description);
                ps.setString(psIdx++,decision);
                ps.setInt(psIdx++,duration);
                ps.setString(psIdx++,decisionBy);
                ps.setString(psIdx++,followUp);   
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx++,userUid);
                
                ps.setInt(psIdx++,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
                ps.setInt(psIdx,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
                
                ps.executeUpdate();
            }            
        }
        catch(Exception e){
        	errorOccurred = true;
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }
    
    //--- DELETE ----------------------------------------------------------------------------------
    public static boolean delete(String sDISCRECUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM hr_disciplinary_records"+
                          " WHERE (HR_DISCREC_SERVERID = ? AND HR_DISCREC_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sDISCRECUid.substring(0,sDISCRECUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sDISCRECUid.substring(sDISCRECUid.indexOf(".")+1)));
            
            ps.executeUpdate();
        }
        catch(Exception e){
        	errorOccurred = true;
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static DisciplinaryRecord get(DisciplinaryRecord DISCREC){
    	return get(DISCREC.getUid());
    }
       
    public static DisciplinaryRecord get(String sDISCRECUid){
    	DisciplinaryRecord DISCREC = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_disciplinary_records"+
                          " WHERE (HR_DISCREC_SERVERID = ? AND HR_DISCREC_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sDISCRECUid.substring(0,sDISCRECUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sDISCRECUid.substring(sDISCRECUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
            	DISCREC = new DisciplinaryRecord();
            	DISCREC.setUid(rs.getString("HR_DISCREC_SERVERID")+"."+rs.getString("HR_DISCREC_OBJECTID"));

            	DISCREC.personId    = rs.getInt("HR_DISCREC_PERSONID");
                DISCREC.date        = rs.getDate("HR_DISCREC_DATE");
                DISCREC.title       = ScreenHelper.checkString(rs.getString("HR_DISCREC_TITLE"));
                DISCREC.description = ScreenHelper.checkString(rs.getString("HR_DISCREC_DESCRIPTION"));
                DISCREC.decision    = ScreenHelper.checkString(rs.getString("HR_DISCREC_DECISION"));
                DISCREC.duration    = rs.getInt("HR_DISCREC_DURATION");
                DISCREC.decisionBy  = ScreenHelper.checkString(rs.getString("HR_DISCREC_DECISIONBY"));
                DISCREC.followUp    = ScreenHelper.checkString(rs.getString("HR_DISCREC_FOLLOWUP")); 
               
                // parent
                DISCREC.setUpdateDateTime(rs.getTimestamp("HR_DISCREC_UPDATETIME"));
                DISCREC.setUpdateUser(rs.getString("HR_DISCREC_UPDATEID"));
            }
        }
        catch(Exception e){
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return DISCREC;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<DisciplinaryRecord> getList(){
    	return getList(new DisciplinaryRecord());     	
    }
    
    public static List<DisciplinaryRecord> getList(DisciplinaryRecord findItem){
        List<DisciplinaryRecord> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	// compose query
            String sSql = "SELECT * FROM hr_disciplinary_records WHERE 1=1"; // 'where' facilitates further composition of query 

            if(findItem.personId > -1){
                sSql+= " AND HR_DISCREC_PERSONID = "+findItem.personId;
            }
            if(ScreenHelper.checkString(findItem.title).length() > 0){
                sSql+= " AND HR_DISCREC_TITLE LIKE '%"+findItem.title+"%'";
            }
            if(ScreenHelper.checkString(findItem.description).length() > 0){
                sSql+= " AND HR_DISCREC_DESCRIPTION LIKE '%"+findItem.description+"%'";
            }
            if(ScreenHelper.checkString(findItem.decision).length() > 0){
                sSql+= " AND HR_DISCREC_DECISION = '"+findItem.decision+"'";
            }
            if(findItem.duration > -1){
                sSql+= " AND HR_DISCREC_DURATION = "+findItem.duration;
            }
            if(ScreenHelper.checkString(findItem.decisionBy).length() > 0){
                sSql+= " AND HR_DISCREC_DECISIONBY LIKE '%"+findItem.decisionBy+"%'";
            }
            if(ScreenHelper.checkString(findItem.followUp).length() > 0){
                sSql+= " AND HR_DISCREC_FOLLOWUP LIKE '%"+findItem.followUp+"%'";
            }
            sSql+= " ORDER BY HR_DISCREC_DATE ASC";

            ps = oc_conn.prepareStatement(sSql);
            System.out.println(sSql);
            
            /*
            // set question marks            
            int psIdx = 1;
            
            if(findItem.personId > -1){
            	ps.setInt(psIdx++,findItem.personId);
            }
            if(ScreenHelper.checkString(findItem.title).length() > 0){
            	ps.setString(psIdx++,findItem.title);
            }
            if(ScreenHelper.checkString(findItem.description).length() > 0){
            	ps.setString(psIdx++,findItem.description);
            }
            if(ScreenHelper.checkString(findItem.decision).length() > 0){
            	ps.setString(psIdx++,findItem.decision);
            }
            if(findItem.duration > -1){
            	ps.setInt(psIdx++,findItem.duration);
            }
            if(ScreenHelper.checkString(findItem.decisionBy).length() > 0){
            	ps.setString(psIdx++,findItem.decisionBy);
            }
            if(ScreenHelper.checkString(findItem.followUp).length() > 0){
            	ps.setString(psIdx++,findItem.followUp);
            }
            */
            
            // execute query
            rs = ps.executeQuery();
            DisciplinaryRecord item;
            
            while(rs.next()){
                item = new DisciplinaryRecord();                
                item.setUid(rs.getString("HR_DISCREC_SERVERID")+"."+rs.getString("HR_DISCREC_OBJECTID"));

                item.personId    = rs.getInt("HR_DISCREC_PERSONID");
                item.date        = rs.getDate("HR_DISCREC_DATE");
                item.title       = ScreenHelper.checkString(rs.getString("HR_DISCREC_TITLE"));
                item.description = ScreenHelper.checkString(rs.getString("HR_DISCREC_DESCRIPTION"));
                item.decision    = ScreenHelper.checkString(rs.getString("HR_DISCREC_DECISION"));
                item.duration    = rs.getInt("HR_DISCREC_DURATION");
                item.decisionBy  = ScreenHelper.checkString(rs.getString("HR_DISCREC_DECISIONBY"));
                item.followUp    = ScreenHelper.checkString(rs.getString("HR_DISCREC_FOLLOWUP")); 
                
                // parent
                item.setUpdateDateTime(rs.getTimestamp("HR_DISCREC_UPDATETIME"));
                item.setUpdateUser(rs.getString("HR_DISCREC_UPDATEID"));
                
                foundObjects.add(item);
            }
        }
        catch(Exception e){
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return foundObjects;
    }
     
}
