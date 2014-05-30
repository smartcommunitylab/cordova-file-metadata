package it.smartcampuslab.cordova.file;


import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class FileMetadata extends CordovaPlugin {
    private static final String LOG_TAG = "FileMetadata";

 	/* helpers to execute functions async and handle the result codes
     *
     */
   	private interface FileOp {
        void run(  ) throws Exception;
    }
    private void threadhelper(final FileOp f, final CallbackContext callbackContext){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    f.run();
                } catch ( Exception e) {
                    e.printStackTrace();
                    if( e instanceof EncodingException){
                        callbackContext.error(FileUtils.ENCODING_ERR);
                    } else if(e instanceof FileNotFoundException) {
                        callbackContext.error(FileUtils.NOT_FOUND_ERR);
                    } else if(e instanceof FileExistsException) {
                        callbackContext.error(FileUtils.PATH_EXISTS_ERR);
                    } else if(e instanceof NoModificationAllowedException ) {
                        callbackContext.error(FileUtils.NO_MODIFICATION_ALLOWED_ERR);
                    } else if(e instanceof InvalidModificationException ) {
                        callbackContext.error(FileUtils.INVALID_MODIFICATION_ERR);
                    } else if(e instanceof MalformedURLException ) {
                        callbackContext.error(FileUtils.ENCODING_ERR);
                    } else if(e instanceof IOException ) {
                        callbackContext.error(FileUtils.INVALID_MODIFICATION_ERR);
                    } else if(e instanceof EncodingException ) {
                        callbackContext.error(FileUtils.ENCODING_ERR);
                    } else if(e instanceof TypeMismatchException ) {
                        callbackContext.error(FileUtils.TYPE_MISMATCH_ERR);
                    } else {
                    	callbackContext.error(FileUtils.UNKNOWN_ERR);
                    }
                }
            }
        });
    }

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    	super.initialize(cordova, webView);
	}
	

   /**
     * Executes the request and returns whether the action was valid.
     *
     * @param action 		The action to execute.
     * @param args 		JSONArray of arguments for the plugin.
     * @param callbackContext	The callback context used when calling back into JavaScript.
     * @return 			True if the action was valid, false otherwise.
     */
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    	if (action.equals("test")) {
            final String msg=args.getString(0);
            threadhelper( new FileOp( ){
                public void run() throws JSONException {
                    JSONObject obj = doTest(msg);
                    callbackContext.success(obj);
                }
            }, callbackContext);

        } else {
            return false;

        }
        return true;
    }
    
    private JSONObject doTest(String msgStr) throws JSONException {
		Log.d(LOG_TAG, "doTest(); msg: " + msgStr);

    	JSONObject r = new JSONObject();
    	r.put("msg", msgStr);
    	r.put("done", true);
        return r;
    }
}