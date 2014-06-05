package it.smartcampuslab.cordova.file;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.util.Log;
import com.j256.simplemagic.*;

public class FileMetadata extends CordovaPlugin {
	private static final String LOG_TAG = "FileMetadata";

	private ContentInfoUtil contentInfoUtil;

	/*
	 * helpers to execute functions async and handle the result codes
	 */
	private interface FileOp {
		void run() throws Exception;
	}

	private void threadhelper(final FileOp f, final CallbackContext callbackContext) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
				try {
					f.run();
				} catch (Exception e) {
					e.printStackTrace();
					/*
					 * if (e instanceof EncodingException) {
					 * callbackContext.error(FileUtils.ENCODING_ERR); } else if
					 * (e instanceof FileNotFoundException) {
					 * callbackContext.error(FileUtils.NOT_FOUND_ERR); } else if
					 * (e instanceof FileExistsException) {
					 * callbackContext.error(FileUtils.PATH_EXISTS_ERR); } else
					 * if (e instanceof NoModificationAllowedException) {
					 * callbackContext
					 * .error(FileUtils.NO_MODIFICATION_ALLOWED_ERR); } else if
					 * (e instanceof InvalidModificationException) {
					 * callbackContext
					 * .error(FileUtils.INVALID_MODIFICATION_ERR); } else if (e
					 * instanceof MalformedURLException) {
					 * callbackContext.error(FileUtils.ENCODING_ERR); } else if
					 * (e instanceof IOException) {
					 * callbackContext.error(FileUtils
					 * .INVALID_MODIFICATION_ERR); } else if (e instanceof
					 * EncodingException) {
					 * callbackContext.error(FileUtils.ENCODING_ERR); } else if
					 * (e instanceof TypeMismatchException) {
					 * callbackContext.error(FileUtils.TYPE_MISMATCH_ERR); }
					 * else { callbackContext.error(FileUtils.UNKNOWN_ERR); }
					 */
					if (e instanceof FileNotFoundException) {
						Log.d(LOG_TAG, "doMetadata(); " + e.getMessage());
						callbackContext.error("");
					} else {
						Log.d(LOG_TAG, "doMetadata(); " + e.getMessage());
						callbackContext.error("");
					}
				}
			}
		});
	}

	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		contentInfoUtil = new ContentInfoUtil();
		super.initialize(cordova, webView);
	}

	/**
	 * Executes the request and returns whether the action was valid.
	 *
	 * @param action
	 *            The action to execute.
	 * @param args
	 *            JSONArray of arguments for the plugin.
	 * @param callbackContext
	 *            The callback context used when calling back into JavaScript.
	 * @return True if the action was valid, false otherwise.
	 */
	@Override
	public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
		if (action.equals("metadata")) {
			final String filename = args.getString(0);

			threadhelper(new FileOp() {
				public void run() throws JSONException, FileNotFoundException, URISyntaxException, IOException {
					JSONObject obj = doMetadata(filename);
					callbackContext.success(obj);
				}
			}, callbackContext);
		} else {
			return false;
		}

		return true;
	}

	private JSONObject doMetadata(String filename) throws JSONException, FileNotFoundException, URISyntaxException, IOException {
		URI uri = new URI(filename);
		File file = new File(uri);
		long length = 0;
		String type = null;

		if (file.exists()) {
			length = file.length();

			ContentInfo info = contentInfoUtil.findMatch(file);
			if (info != null) {
				type = info.getMimeType();
			}
		} else {
			throw new FileNotFoundException();
		}

		JSONObject r = new JSONObject();
		r.put("size", length);
		r.put("type", type);

		Log.d(LOG_TAG,
				"doMetadata(); filename: " + filename + ", size: " + r.getLong("size") + ", type: " + r.getString("type"));

		return r;
	}

}
