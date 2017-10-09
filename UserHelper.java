package com.onjyb.beans;

import android.app.Activity;
import android.content.Context;
import android.os.Build.VERSION;
import android.provider.Settings.Secure;
import android.util.Log;

import com.onjyb.C0531R;
import com.onjyb.app.Constants;
import com.onjyb.app.OnjybApp;
import com.onjyb.db.AssociateService;
import com.onjyb.db.Branch;
import com.onjyb.db.DatabaseHelper;
import com.onjyb.db.Employee;
import com.onjyb.db.LeaveType;
import com.onjyb.db.OvertimeRule;
import com.onjyb.db.Project;
import com.onjyb.db.Service;
import com.onjyb.db.WorkSheet;
import com.onjyb.reqreshelper.ActionCallback;
import com.onjyb.reqreshelper.AsyncTaskCompleteListener;
import com.onjyb.reqreshelper.ETechAsyncTask;
import com.onjyb.reqreshelper.FileObject;
import com.onjyb.util.AppUtils;
import com.onjyb.util.Preference;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;

import org.codehaus.jackson.map.DeserializationConfig.Feature;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class UserHelper implements AsyncTaskCompleteListener<String> {
    String TAG = UserHelper.class.getName();
    ActionCallback actionCallback;
    Context context;
    DatabaseHelper dbHelper;

    class C05341 extends TypeReference<ArrayList<Project>> {
        C05341() {
        }
    }

    class C05352 extends TypeReference<ArrayList<Service>> {
        C05352() {
        }
    }

    class C05363 extends TypeReference<ArrayList<Branch>> {
        C05363() {
        }
    }

    class C05374 extends TypeReference<ArrayList<LeaveType>> {
        C05374() {
        }
    }

    class C05385 extends TypeReference<ArrayList<AssociateService>> {
        C05385() {
        }
    }

    class C05396 extends TypeReference<ArrayList<Employee>> {
        C05396() {
        }
    }

    class C05407 extends TypeReference<ArrayList<OvertimeRule>> {
        C05407() {
        }
    }

    class C05418 extends TypeReference<ArrayList<LeaveType>> {
        C05418() {
        }
    }

    public UserHelper(Context context) {
        this.context = context;
    }

    public void apiregisterDeviceForNotification(ActionCallback actionCallback, String regId) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            String appVersionName = "";
            appVersionName = this.context.getPackageManager().getPackageInfo(this.context.getPackageName(), 0).versionName;
            map.put("appname", Constants.APP_NAME);
            map.put("appversion", appVersionName);
            map.put("deviceuid", Secure.getString(this.context.getContentResolver(), "android_id"));
            map.put("devicetoken", regId);
            map.put("devicename", "android");
            map.put("devicemodel", "android");
            map.put("deviceversion", VERSION.RELEASE);
            map.put("pushbadge", "enabled");
            map.put("pushalert", "enabled");
            map.put("pushsound", "enabled");
            map.put("clientid", "onjyb");
            map.put("memberid", Preference.getSharedPref(Constants.PREF_USER_ID, ""));
            map.put("environment", "production");
            map.put("task", "register");
            map.put("os", "android");
            ETechAsyncTask task = new ETechAsyncTask(this.context, this, Constants.URL_REGISTER_DEVICE, map, 2, false, true);
            task.hideProgressDialog();
            task.execute(new String[]{Constants.URL_REGISTER_DEVICE});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiGetUnReadCount(ActionCallback actionCallback) {
        try {
            String usrId = Preference.getSharedPref(Constants.PREF_USER_ID, "");
            String roleId = Preference.getSharedPref(Constants.PREF_KEY_USER_USER_ROLE_ID, "");
            String compId = Preference.getSharedPref(Constants.PREF_COMPANY_ID, "");
            String last_date = Preference.getSharedPref(Constants.PREF_GET_LASTDATE_UNREAD_COUNT, "");
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            if (!(usrId == null || usrId.equalsIgnoreCase(""))) {
                map.put("user_id", usrId);
            }
            if (!(roleId == null || roleId.equalsIgnoreCase(""))) {
                map.put("role_id", roleId);
            }
            if (!(compId == null || compId.equalsIgnoreCase(""))) {
                map.put("company_id", compId);
            }
            if (!(last_date == null || last_date.equalsIgnoreCase(""))) {
                map.put("last_date", last_date);
            }
            ETechAsyncTask task = new ETechAsyncTask(this.context, this, Constants.URL_GET_UNREAD_COUNT, map, 2, false, false);
            task.hideProgressDialog();
            task.execute(new String[]{Constants.URL_GET_UNREAD_COUNT});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiLogOut(ActionCallback actionCallback) {
        try {
            String usrId = Preference.getSharedPref(Constants.PREF_USER_ID, "");
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            if (!(usrId == null || usrId.equalsIgnoreCase(""))) {
                map.put("user_id", usrId);
            }
            map.put("client_id", "onjyb");
            map.put("device_id", Secure.getString(this.context.getContentResolver(), "android_id"));
            ETechAsyncTask task = new ETechAsyncTask(this.context, this, Constants.URL_LOGOUT_USER, map, 2, false, true);
            task.hideProgressDialog();
            task.execute(new String[]{Constants.URL_LOGOUT_USER});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiUserLogin(User userdata, ActionCallback actionCallback) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            map.put("txtEmail", userdata.getEmail());
            map.put("txtPassword", userdata.getPassword());
            ETechAsyncTask task = new ETechAsyncTask(this.context, this, Constants.URL_LOGIN, map, 2, false, true);
            task.hideProgressDialog();
            task.execute(new String[]{Constants.URL_LOGIN});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apigetMessages(String compId, int pageNo, ActionCallback actionCallback) {
        try {
            String user_id = Preference.getSharedPref(Constants.PREF_USER_ID, "");
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            if (user_id != null) {
                map.put("user_id", user_id);
            }
            if (compId != null) {
                map.put("company_id", compId);
            }
            if (pageNo != 0) {
                map.put("page_number", Integer.valueOf(pageNo));
            }
            ETechAsyncTask task = new ETechAsyncTask(this.context, this, Constants.URL_GET_MESSAGES, map, 2, false, true);
            task.hideProgressDialog();
            task.execute(new String[]{Constants.URL_GET_MESSAGES});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apigetLatestMessages(String compId, int pageNo, String Last_id, ActionCallback actionCallback) {
        try {
            String user_id = Preference.getSharedPref(Constants.PREF_USER_ID, Constants.USER_ROLE_EMPLOYEE);
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            if (user_id != null) {
                map.put("user_id", user_id);
            }
            if (compId != null) {
                map.put("company_id", compId);
            }
            if (pageNo != 0) {
                map.put("page_number", Integer.valueOf(pageNo));
            }
            if (Last_id != null) {
                map.put("last_id", Last_id);
            }
            ETechAsyncTask task = new ETechAsyncTask(this.context, this, Constants.URL_GET_MESSAGES, map, 2, false, true);
            task.hideProgressDialog();
            task.execute(new String[]{Constants.URL_GET_MESSAGES});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiSendGroupMessage(String userId, String compId, String Msg, ActionCallback actionCallback) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            if (userId != null) {
                map.put("user_id", userId);
            }
            if (compId != null) {
                map.put("company_id", compId);
            }
            if (Msg != null) {
                map.put("message", Msg);
            }
            ETechAsyncTask task = new ETechAsyncTask(this.context, this, Constants.URL_GROUP_CHAT, map, 2, false, true);
            task.hideProgressDialog();
            task.execute(new String[]{Constants.URL_GROUP_CHAT});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiProfiledisplay(String userId, ActionCallback actionCallback) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            if (userId != null) {
                map.put("user_id", userId);
            }
            ETechAsyncTask task = new ETechAsyncTask(this.context, this, Constants.URL_PROFILE_DISPLAY, map, 2, false, true);
            task.hideProgressDialog();
            task.execute(new String[]{Constants.URL_PROFILE_DISPLAY});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiEditProfile(User user, ActionCallback actionCallback) {
        Exception e;
        try {
            ETechAsyncTask task;
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            if (user != null) {
                map.put("user_id", user.getUserId());
            }
            if (!(user.getMobile() == null || user.getFirstName() == null)) {
                String[] strs = user.getFirstName().split(" ");
                map.put("mobile_number", user.getMobile());
                map.put("first_name", strs[0]);
                map.put("last_name", strs[1]);
                if (!user.getAddress().equalsIgnoreCase("")) {
                    map.put("address", user.getAddress());
                }
            }
            if (user.getProfile_image() != null) {
                File file = new File(user.getProfile_image());
                try {
                    if (file.exists()) {
                        FileObject fObj = new FileObject();
                        FileObject fileObject;
                        try {
                            fObj.setContentType("image/*");
                            fObj.setByteData(AppUtils.readFile(file));
                            fObj.setFileName(file.getName());
                            map.put("user_photo", fObj);
                            fileObject = fObj;
                        } catch (Exception e2) {
                            e = e2;
                            fileObject = fObj;
                            e.printStackTrace();
                            task = new ETechAsyncTask(this.context, this, Constants.URL_PROFILE_EDIT, map, 2, true, true);
                            task.hideProgressDialog();
                            task.execute(new String[]{Constants.URL_PROFILE_EDIT});
                        }
                    }
                } catch (Exception e3) {
                    e = e3;
                    e.printStackTrace();
                    task = new ETechAsyncTask(this.context, this, Constants.URL_PROFILE_EDIT, map, 2, true, true);
                    task.hideProgressDialog();
                    task.execute(new String[]{Constants.URL_PROFILE_EDIT});
                }
            }
            task = new ETechAsyncTask(this.context, this, Constants.URL_PROFILE_EDIT, map, 2, true, true);
            task.hideProgressDialog();
            task.execute(new String[]{Constants.URL_PROFILE_EDIT});
        } catch (Exception e4) {
            e4.printStackTrace();
        }
    }

    public void apiChangePassword(String userId, String oldPsw, String newPsw, String resetPsw, ActionCallback actionCallback) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            if (!(oldPsw == null || newPsw == null || resetPsw == null)) {
                map.put("user_id", userId);
                map.put("old_password", oldPsw);
                map.put("new_password", newPsw);
                map.put("confirm_password", resetPsw);
            }
            ETechAsyncTask task = new ETechAsyncTask(this.context, this, Constants.URL_CHANGE_PASSWORD, map, 2, false, true);
            task.hideProgressDialog();
            task.execute(new String[]{Constants.URL_CHANGE_PASSWORD});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiForgotPassword(User userdata, ActionCallback actionCallback) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            map.put("txtEmail", userdata.getEmail());
            new ETechAsyncTask(this.context, this, Constants.URL_FORGOT_PASSWORD, map, 2, false, true).execute(new String[]{Constants.URL_FORGOT_PASSWORD});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiGetMasterTablesDetail(ActionCallback actionCallback) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            map.put("user_id", Preference.getSharedPref(Constants.PREF_USER_ID, ""));
            new ETechAsyncTask(this.context, this, Constants.URL_MASTER_LIST, map, 2, false, false).execute(new String[]{Constants.URL_MASTER_LIST});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiGetWorksheetDetails(WorkSheet workSheet, ActionCallback myTaskDetailCallback) {
        try {
            this.actionCallback = myTaskDetailCallback;
            HashMap<String, Object> map = new HashMap();
            map.put("work_id", workSheet.getServerWorkSheetId());
            new ETechAsyncTask(this.context, this, Constants.URL_MYTASK_WORKSHEET_DETAIL, map, 2, false, true).execute(new String[]{Constants.URL_MYTASK_WORKSHEET_DETAIL});
            Log.i("URL--?>>>", Constants.URL_MYTASK_WORKSHEET_DETAIL);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiCallRejectTask(ActionCallback actionCallback, WorkSheet workSheet) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            String userId = Preference.getSharedPref(Constants.PREF_USER_ID, "");
            String roleId = Preference.getSharedPref(Constants.PREF_KEY_USER_USER_ROLE_ID, "");
            map.put("user_id", userId);
            map.put("work_id", workSheet.getServerWorkSheetId());
            map.put("approve_status", "reject");
            map.put("reason", workSheet.getRejectComments());
            new ETechAsyncTask(this.context, this, Constants.URL_REJECT_TASK, map, 2, false, true).execute(new String[]{Constants.URL_REJECT_TASK});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apigetGraphDetails(String projectId, ActionCallback actionCallback) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            map.put("project_id", projectId);
            new ETechAsyncTask(this.context, this, Constants.URL_GRAPH_DETAIL, map, 2, false, true).execute(new String[]{Constants.URL_GRAPH_DETAIL});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiGetTaskListWithTotal(ActionCallback actionCallback, String status, int pageNo, String pro_id, String Ser_id, String Branch_id, String employeeId, String startDate, String enddate, boolean issummary, boolean is_mng_jobber) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            String userId = Preference.getSharedPref(Constants.PREF_USER_ID, "");
            String roleId = Preference.getSharedPref(Constants.PREF_KEY_USER_USER_ROLE_ID, "");
            String compId = Preference.getSharedPref(Constants.PREF_COMPANY_ID, "");
            map.put("user_id", userId);
            map.put("company_id", compId);
            if (issummary) {
                map.put("is_summary", "yes");
            } else {
                map.put("is_summary", "");
            }
            if (is_mng_jobber) {
                map.put("is_mng_jobber", "yes");
            } else {
                map.put("is_mng_jobber", "");
            }
            map.put("role_id", roleId);
            map.put("approve_status", status);
            if (pageNo != 0) {
                map.put("page_number", Integer.valueOf(pageNo));
            }
            if (pro_id != null) {
                map.put("project_id", pro_id);
            }
            if (Ser_id != null) {
                map.put("service_id", Ser_id);
            }
            if (Branch_id != null) {
                map.put("branch_id", Branch_id);
            }
            if (startDate != null) {
                String strDate1 = AppUtils.getFormattedDate(startDate, "dd MMM yy", "dd/MM/yyyy");
                if (!(strDate1 == null || "".equalsIgnoreCase(strDate1))) {
                    map.put("start_date", strDate1);
                }
            }
            if (enddate != null) {
                String endDate1 = AppUtils.getFormattedDate(enddate, "dd MMM yy", "dd/MM/yyyy");
                if (!(endDate1 == null || "".equalsIgnoreCase(endDate1))) {
                    map.put("end_date", endDate1);
                }
            }
            if (employeeId != null) {
                map.put("employee_id", employeeId);
            }
            new ETechAsyncTask(this.context, this, Constants.URL_MYTASK_WORKSHEET_LIST, map, 2, false, true).execute(new String[]{Constants.URL_MYTASK_WORKSHEET_LIST});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiGetTaskList(ActionCallback actionCallback, boolean is_from_manager_jobber, String status, int pageNo) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            String userId = Preference.getSharedPref(Constants.PREF_USER_ID, "");
            String roleId = Preference.getSharedPref(Constants.PREF_KEY_USER_USER_ROLE_ID, "");
            String compId = Preference.getSharedPref(Constants.PREF_COMPANY_ID, "");
            if (is_from_manager_jobber) {
                map.put("is_mng_jobber", "yes");
            } else {
                map.put("is_mng_jobber", "");
            }
            map.put("user_id", userId);
            map.put("company_id", compId);
            map.put("is_summary", "");
            map.put("role_id", roleId);
            map.put("approve_status", status);
            if (pageNo != 0) {
                map.put("page_number", Integer.valueOf(pageNo));
            }
            new ETechAsyncTask(this.context, this, Constants.URL_MYTASK_WORKSHEET_LIST, map, 2, false, true).execute(new String[]{Constants.URL_MYTASK_WORKSHEET_LIST});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void apiGetTaskList(ActionCallback actionCallback, String status, int pageNo, String pro_id, String Ser_id, String Branch_id, String employeeId, String startDate, String enddate, boolean is_from_manager_jobber) {
        try {
            this.actionCallback = actionCallback;
            HashMap<String, Object> map = new HashMap();
            String userId = Preference.getSharedPref(Constants.PREF_USER_ID, "");
            String roleId = Preference.getSharedPref(Constants.PREF_KEY_USER_USER_ROLE_ID, "");
            String compId = Preference.getSharedPref(Constants.PREF_COMPANY_ID, "");
            if (is_from_manager_jobber) {
                map.put("is_mng_jobber", "yes");
            } else {
                map.put("is_mng_jobber", "");
            }
            map.put("user_id", userId);
            map.put("company_id", compId);
            map.put("is_summary", "");
            map.put("role_id", roleId);
            map.put("approve_status", status);
            map.put("page_number", Integer.valueOf(pageNo));
            if (pro_id != null) {
                map.put("project_id", pro_id);
            }
            if (Ser_id != null) {
                map.put("service_id", Ser_id);
            }
            if (Branch_id != null) {
                map.put("branch_id", Branch_id);
            }
            if (startDate != null) {
                map.put("start_date", startDate);
            }
            if (enddate != null) {
                map.put("end_date", enddate);
            }
            if (employeeId != null) {
                map.put("employee_id", employeeId);
            }
            new ETechAsyncTask(this.context, this, Constants.URL_MYTASK_WORKSHEET_LIST, map, 2, false, true).execute(new String[]{Constants.URL_MYTASK_WORKSHEET_LIST});
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void onTaskComplete(int statusCode, String result, String webserviceCb, Object tag) {
        try {
            Log.d(this.TAG, "onTaskComplete()statusCode : " + statusCode);
            if (statusCode == 104 || statusCode == 101) {
                this.actionCallback.onActionComplete(statusCode, webserviceCb, result);
            } else if (statusCode != 102 || result == null) {
                this.actionCallback.onActionComplete(statusCode, webserviceCb, this.context.getString(C0531R.string.response_error_msg));
            } else if (statusCode == 102) {
                JSONObject jObj = new JSONObject(result);
                if (((Integer) jObj.get(Constants.RESPONSE_KEY_CODE)).intValue() != 1) {
                    this.actionCallback.onActionComplete(0, webserviceCb, jObj.get(Constants.RESPONSE_KEY_MSG).toString());
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_FORGOT_PASSWORD)) {
                    this.actionCallback.onActionComplete(1, webserviceCb, jObj);
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_MASTER_LIST)) {
                    try {
                        resobj = jObj.getJSONObject(Constants.RESPONSE_KEY_OBJ);
                        Preference.setSharedPref(Constants.PREF_MASTERLIST_LAST_UPDATE, resobj.getString("last_update"));
                        JSONArray proj_detail = resobj.getJSONArray("project_details");
                        ArrayList<Project> proDetailList = (ArrayList) new ObjectMapper().configure(Feature.FAIL_ON_UNKNOWN_PROPERTIES, false).readValue(proj_detail.toString(), new C05341());
                        this.dbHelper = new DatabaseHelper(this.context);
                        this.dbHelper = DatabaseHelper.getDBAdapterInstance(this.context);
                        if (proDetailList != null && proDetailList.size() > 0) {
                            this.dbHelper.inserOrReplaceProjectDetail(proDetailList);
                        }
                        JSONArray service = resobj.getJSONArray("service_details");
                        ArrayList<Service> services = (ArrayList) new ObjectMapper().configure(Feature.FAIL_ON_UNKNOWN_PROPERTIES, false).readValue(service.toString(), new C05352());
                        this.dbHelper = new DatabaseHelper(this.context);
                        this.dbHelper = DatabaseHelper.getDBAdapterInstance(this.context);
                        if (services != null && services.size() > 0) {
                            this.dbHelper.inserOrReplaceService(services);
                        }
                        JSONArray branch = resobj.getJSONArray("branch_details");
                        ArrayList<Branch> branches = (ArrayList) new ObjectMapper().configure(Feature.FAIL_ON_UNKNOWN_PROPERTIES, false).readValue(branch.toString(), new C05363());
                        this.dbHelper = new DatabaseHelper(this.context);
                        this.dbHelper = DatabaseHelper.getDBAdapterInstance(this.context);
                        if (branches != null && branches.size() > 0) {
                            this.dbHelper.insertOrReplaceBranch(branches);
                        }
                        JSONArray leaveType = resobj.getJSONArray("leavetype_details");
                        ArrayList<LeaveType> leaveTypes = (ArrayList) new ObjectMapper().configure(Feature.FAIL_ON_UNKNOWN_PROPERTIES, false).readValue(leaveType.toString(), new C05374());
                        this.dbHelper = new DatabaseHelper(this.context);
                        this.dbHelper = DatabaseHelper.getDBAdapterInstance(this.context);
                        if (leaveTypes != null && leaveTypes.size() > 0) {
                            this.dbHelper.inserOrReplaceLeaveType(leaveTypes);
                        }
                        JSONArray AssociateServiceArray = resobj.getJSONArray("associate_service_details");
                        ArrayList<AssociateService> arrAssociateService = (ArrayList) new ObjectMapper().configure(Feature.FAIL_ON_UNKNOWN_PROPERTIES, false).readValue(AssociateServiceArray.toString(), new C05385());
                        this.dbHelper = new DatabaseHelper(this.context);
                        this.dbHelper = DatabaseHelper.getDBAdapterInstance(this.context);
                        if (arrAssociateService != null && arrAssociateService.size() > 0) {
                            this.dbHelper.insertOrReplaceWorkService(arrAssociateService);
                        }
                        JSONArray employeeDetailArray = resobj.getJSONArray("employee_details");
                        ArrayList<Employee> employee = (ArrayList) new ObjectMapper().configure(Feature.FAIL_ON_UNKNOWN_PROPERTIES, false).readValue(employeeDetailArray.toString(), new C05396());
                        this.dbHelper = new DatabaseHelper(this.context);
                        this.dbHelper = DatabaseHelper.getDBAdapterInstance(this.context);
                        if (employee != null && employee.size() > 0) {
                            this.dbHelper.inserOrReplaceEmployeeDetail(employee);
                        }
                        JSONArray overtimerule_detailsArray = resobj.getJSONArray("rules_list");
                        ArrayList<OvertimeRule> OvertimeRulelist = (ArrayList) new ObjectMapper().configure(Feature.FAIL_ON_UNKNOWN_PROPERTIES, false).readValue(overtimerule_detailsArray.toString(), new C05407());
                        if (OvertimeRulelist != null && OvertimeRulelist.size() > 0) {
                            Constants.UserDependsOvertimeRulesList.clear();
                            Constants.UserDependsOvertimeRulesList.addAll(OvertimeRulelist);
                        }
                        String workovertimeautomatic = resobj.getString("isworkovertimeautomatic");
                        Preference.setSharedPref(Constants.PREF_WORK_OVERTIME_AUTOMATIC, workovertimeautomatic);
                        String defaultHrs = resobj.getString("default_working_hours");
                        Preference.setSharedPref(Constants.PREF_DEFAULT_WORKHRS, defaultHrs);
                        Log.d(this.TAG, "Task-Mode:MasterList API:isworkovertimeautomatic" + workovertimeautomatic.toString());
                        Log.d(this.TAG, "Task-Mode:MasterList API:default_working_hours" + defaultHrs.toString());
                        this.actionCallback.onActionComplete(1, webserviceCb, jObj);
                    } catch (Exception e) {
                        e.printStackTrace();
                        this.actionCallback.onActionComplete(0, webserviceCb, "ERROR");
                    }
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_MYTASK_WORKSHEET_LIST)) {
                    resobj = jObj.getJSONObject(Constants.RESPONSE_KEY_OBJ);
                    Preference.setSharedPref(Constants.PREF_HASE_RECORDS_AVAILABLE_APPROVE, String.valueOf(resobj.getBoolean("has_more_records")));
                    this.actionCallback.onActionComplete(1, webserviceCb, resobj);
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_GRAPH_DETAIL)) {
                    this.actionCallback.onActionComplete(1, webserviceCb, jObj.getJSONObject(Constants.RESPONSE_KEY_OBJ));
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_REJECT_TASK)) {
                    jobject = jObj;
                    this.actionCallback.onActionComplete(1, webserviceCb, jObj);
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_UPLOAD__WORKSHEET_TO_SERVER)) {
                    jobject = jObj;
                    this.actionCallback.onActionComplete(1, webserviceCb, jObj.getJSONObject(Constants.RESPONSE_KEY_OBJ));
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_MYTASK_WORKSHEET_DETAIL)) {
                    jobject = jObj;
                    this.actionCallback.onActionComplete(1, webserviceCb, jObj.getJSONObject(Constants.RESPONSE_KEY_OBJ));
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_PROFILE_DISPLAY)) {
                    jobject = jObj;
                    try {
                        this.actionCallback.onActionComplete(1, webserviceCb, jObj.getJSONObject(Constants.RESPONSE_KEY_OBJ));
                    } catch (Exception e2) {
                        e2.printStackTrace();
                    }
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_GET_MESSAGES)) {
                    resobj = jObj.getJSONObject(Constants.RESPONSE_KEY_OBJ);
                    Preference.setSharedPref(Constants.PREF_HASE_RECORDS_AVAILABLE_MESSAGES, String.valueOf(resobj.getBoolean("has_more_records")));
                    this.actionCallback.onActionComplete(1, webserviceCb, resobj);
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_GET_UNREAD_COUNT)) {
                    resobj = jObj.getJSONObject(Constants.RESPONSE_KEY_OBJ);
                    try {
                        if (resobj.has("left_leave")) {
                            Preference.setSharedPref(Constants.PREF_LEFT_LEAVE, resobj.getString("left_leave"));
                        }
                        if (resobj.has("left_count_details")) {
                            JSONArray leavescountArray = resobj.getJSONArray("left_count_details");
                            OnjybApp.leaveTypesArray = (ArrayList) new ObjectMapper().configure(Feature.FAIL_ON_UNKNOWN_PROPERTIES, false).readValue(leavescountArray.toString(), new C05418());
                        }
                    } catch (Exception e22) {
                        e22.getMessage();
                    }
                    Preference.setSharedPref(Constants.PREF_UNREAD_WORK_COUNT, resobj.getString("work_unread"));
                    Preference.setSharedPref(Constants.PREF_UNREAD_LEAVE_COUNT, resobj.getString("leave_unread"));
                    Preference.setSharedPref(Constants.PREF_UNREAD_MESSAGE_COUNT, resobj.getString("message_unread"));
                    Preference.setSharedPref(Constants.PREF_UNREAD_MANAGER_APPROVE_TASK, resobj.getString("work_manager_unread"));
                    Preference.setSharedPref(Constants.PREF_UNREAD_MANAGER_APPROVE_leave, resobj.getString("leave_manager_unread"));
                    this.actionCallback.onActionComplete(1, webserviceCb, resobj);
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_LOGOUT_USER)) {
                    this.actionCallback.onActionComplete(1, webserviceCb, jObj.getString(Constants.RESPONSE_KEY_MSG));
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_CHANGE_PASSWORD)) {
                    try {
                        this.actionCallback.onActionComplete(1, webserviceCb, jObj);
                    } catch (Exception e222) {
                        e222.printStackTrace();
                    }
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_PROFILE_EDIT)) {
                    jobject = jObj;
                    try {
                        JSONObject object = (JSONObject) jObj.getJSONArray(Constants.RESPONSE_KEY_OBJ).get(0);
                        String userfname = object.getString("first_name");
                        String userlname = object.getString("last_name");
                        String usermobileno = object.getString("mobile");
                        String email = object.getString("email");
                        String profile = object.getString("profile_image");
                        Preference.setSharedPref(Constants.PREF_USER_FNAME, userfname);
                        Preference.setSharedPref(Constants.PREF_USER_LNAME, userlname);
                        Preference.setSharedPref(Constants.PREF_MOBILE, usermobileno + "");
                        Preference.setSharedPref(Constants.PREF_USER_EMAIL, email);
                        Preference.setSharedPref(Constants.PREF_USER_PROFILE_PIC, profile);
                        this.actionCallback.onActionComplete(1, webserviceCb, jObj);
                    } catch (Exception e2222) {
                        e2222.printStackTrace();
                    }
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_GROUP_CHAT)) {
                    jobject = jObj;
                    String resobj = jObj.getString(Constants.RESPONSE_KEY_MSG);
                    try {
                        this.actionCallback.onActionComplete(1, webserviceCb, jObj);
                    } catch (Exception e22222) {
                        e22222.printStackTrace();
                    }
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_REGISTER_DEVICE)) {
                    jobject = jObj;
                    try {
                        this.actionCallback.onActionComplete(1, webserviceCb, jObj.getString(Constants.RESPONSE_KEY_MSG));
                    } catch (Exception e222222) {
                        e222222.printStackTrace();
                    }
                } else if (webserviceCb.equalsIgnoreCase(Constants.URL_LOGIN)) {
                    jobject = jObj;
                    final String str = webserviceCb;
                    new Thread(new Runnable() {

                        class C05421 implements Runnable {
                            C05421() {
                            }

                            public void run() {
                                try {
                                    UserHelper.this.actionCallback.onActionComplete(1, str, jobject.get(Constants.RESPONSE_KEY_MSG).toString());
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        }

                        public void run() {
                            try {
                                JSONObject object = jobject.getJSONObject(Constants.RESPONSE_KEY_OBJ).getJSONObject(Constants.RESPONSE_KEY_USER_DETAIL);
                                int userRoleId = object.getInt(Constants.RESPONSE_ROLE_ID);
                                String userfname = object.getString("first_name");
                                String userlname = object.getString("last_name");
                                String usermobileno = object.getString("mobile");
                                String comp_id = object.getString("company_id");
                                String userid = object.getString("id");
                                String email = object.getString("email");
                                String profile = object.getString("profile_image");
                                String compLogo = object.getString("company_logo");
                                Preference.setSharedPref(Constants.PREF_KEY_USER_USER_ROLE_ID, userRoleId + "");
                                Preference.setSharedPref(Constants.PREF_USER_FNAME, userfname);
                                Preference.setSharedPref(Constants.PREF_USER_LNAME, userlname);
                                Preference.setSharedPref(Constants.PREF_MOBILE, usermobileno + "");
                                Preference.setSharedPref(Constants.PREF_COMPANY_ID, comp_id);
                                Preference.setSharedPref(Constants.PREF_USER_ID, userid);
                                Preference.setSharedPref(Constants.PREF_USER_EMAIL, email);
                                Preference.setSharedPref(Constants.PREF_USER_PROFILE_PIC, profile);
                                Preference.setSharedPref(Constants.PREF_COMPANY_LOGO, compLogo);
                                ((Activity) UserHelper.this.context).runOnUiThread(new C05421());
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }).start();
                }
            }
        } catch (Exception e2222222) {
            e2222222.printStackTrace();
            this.actionCallback.onActionComplete(0, webserviceCb, e2222222.getMessage().toString() + "");
        }
    }
}
