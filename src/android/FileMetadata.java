package it.smartcampuslab.cordova.file;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URL;
import java.net.HttpURLConnection;
import java.net.URISyntaxException;
import java.net.MalformedURLException;
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
				    Log.d(LOG_TAG, e.getMessage());
					callbackContext.error("");
				}
			}
		});
	}

	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		contentInfoUtil = new ContentInfoUtil();
		super.initialize(cordova, webView);
	}

	@Override
	public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
		if (action.equals("getMetadataForFileURI")) {
			final String filename = args.getString(0);

			threadhelper(new FileOp() {
				public void run() throws JSONException, URISyntaxException, IOException {
					JSONObject obj = getMetadataForFileURI(filename);
					callbackContext.success(obj);
				}
			}, callbackContext);
		} else if (action.equals("getMetadataForURL")) {
			final String url = args.getString(0);

			threadhelper(new FileOp() {
				public void run() throws JSONException, IOException, MalformedURLException {
					JSONObject obj = getMetadataForURL(url);
					callbackContext.success(obj);
				}
			}, callbackContext);
		} else if (action.equals("setModifiedForFileURI")) {
            final long modified = args.getLong(0);
			final String uri = args.getString(1);

			threadhelper(new FileOp() {
				public void run() throws JSONException, IOException, MalformedURLException {
					JSONObject obj = setModifiedForFileURI(modified, uri);
					callbackContext.success(obj);
				}
			}, callbackContext);
		} else {
            return false;
        }

		return true;
	}

    private JSONObject setModifiedForFileURI(long modified, String uri) throws JSONException, URISyntaxException, IOException {
      URI fileUri = new URI(uri);
      File file = new File(fileUri);
      long modified = -1;

      if (file.exists()) {
        file.setLastModified(modified);
      }

      JSONObject r = new JSONObject();
      r.put("uri", uri);
      r.put("modified", modified);

      Log.d(LOG_TAG, r.toString());

      return r;
    }

    private JSONObject getMetadataForURL(String url) throws JSONException, IOException, MalformedURLException {
      long modified = -1;
      long length = -1;

      HttpURLConnection.setFollowRedirects(true);
      HttpURLConnection con = (HttpURLConnection) new URL(url).openConnection();
      length = con.getContentLength();
      long date = con.getLastModified();

      if (date != 0) {
        modified = date;
      }

      JSONObject r = new JSONObject();
      r.put("url", url);
      r.put("length", length);
      r.put("modified", modified);

      return r;
    }

	private JSONObject getMetadataForFileURI(String uri) throws JSONException, URISyntaxException, IOException {
		URI fileUri = new URI(uri);
		File file = new File(fileUri);
		long length = -1;
		String type = null;
        long modified = -1;

		if (file.exists()) {
			length = file.length();

			ContentInfo info = contentInfoUtil.findMatch(file);
			if (info != null) {
				type = info.getMimeType();
			}
		}

		JSONObject r = new JSONObject();
        r.put("uri", uri);
		r.put("size", length);
		r.put("type", type);
        r.put("modified", modified);

		Log.d(LOG_TAG, r.toString());

		return r;
	}

}
