/**
 * Created by Patrick O'Connor on 8/30/17.
 * https://github.com/RobertSheaO/react-native-zendesk-support
 */

package com.robertsheao.RNZenDeskSupport;

import android.content.Intent;
import android.app.Activity;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Promise;

import com.facebook.react.bridge.WritableMap;
// import zendesk.feedback.ui.ContactZendeskActivity;
 import zendesk.support.request.RequestActivity;
// import zendesk.support.SupportActivity;
// import zendesk.support.ContactUsButtonVisibility;
// import zendesk.model.access.AnonymousIdentity;
// import zendesk.sdk.model.access.Identity;
 import zendesk.support.CustomField;
// import zendesk.sdk.model.request.CreateRequest;
// import zendesk.sdk.network.impl.Zendesk;
// import zendesk.sdk.network.RequestProvider;
// import com.zendesk.service.ErrorResponse;
// import com.zendesk.service.ZendeskCallback;
import com.zendesk.*;
import zendesk.core.*;
import com.zendesk.util.*;
//import zendesk.support.*;
import com.zendesk.service.*;
import zendesk.core.Zendesk;
import zendesk.support.RequestProvider;
import zendesk.support.Support;
import zendesk.support.CreateRequest;
import zendesk.support.Request;

import com.zendesk.collection.*;
//import com.zendesk.service.
import zendesk.suas.*;
// import com.zendesk.service.ZendeskCallback;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class RNZenDeskSupportModule extends ReactContextBaseJavaModule {
  public RNZenDeskSupportModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }
  private static final String TAG = "RN Zendesk";
  private Promise innerPromise;

  @Override
  public String getName() {
    return "RNZenDeskSupport";
  }

  private static long[] toLongArray(ArrayList<?> values) {
    long[] arr = new long[values.size()];
    for (int i = 0; i < values.size(); i++)
      arr[i] = Long.parseLong((String) values.get(i));
    return arr;
  }

  @ReactMethod
  public void initialize(ReadableMap config) {
    String appId = config.getString("appId");
    String zendeskUrl = config.getString("zendeskUrl");
    String clientId = config.getString("clientId");
    Zendesk.INSTANCE.init(getReactApplicationContext(), zendeskUrl, appId, clientId);
    Support.INSTANCE.init(Zendesk.INSTANCE);
  }

  @ReactMethod
  public void setupIdentity(ReadableMap identity) {
    AnonymousIdentity.Builder builder = new AnonymousIdentity.Builder();

    if (identity != null && identity.hasKey("customerEmail")) {
      builder.withEmailIdentifier(identity.getString("customerEmail"));
    }

    if (identity != null && identity.hasKey("customerName")) {
      builder.withNameIdentifier(identity.getString("customerName"));
    }

    Zendesk.INSTANCE.setIdentity(builder.build());
  }

  @ReactMethod
  public void showHelpCenterWithOptions(ReadableMap options) {
    new HelpCenterActivityBuilder()
            .withOptions(options)
            .show(getReactApplicationContext());
  }

  @ReactMethod
  public void showCategoriesWithOptions(ReadableArray categoryIds, ReadableMap options) {
    new HelpCenterActivityBuilder()
            .withOptions(options)
            .withArticlesForCategoryIds(categoryIds)
            .show(getReactApplicationContext());
  }

  @ReactMethod
  public void showSectionsWithOptions(ReadableArray sectionIds, ReadableMap options) {
    new HelpCenterActivityBuilder()
            .withOptions(options)
            .withArticlesForSectionIds(sectionIds)
            .show(getReactApplicationContext());
  }

  @ReactMethod
  public void showLabelsWithOptions(ReadableArray labels, ReadableMap options) {
    new HelpCenterActivityBuilder()
            .withOptions(options)
            .withLabelNames(labels)
            .show(getReactApplicationContext());
  }

  @ReactMethod
  public void showHelpCenter() {
    showHelpCenterWithOptions(null);
  }

  @ReactMethod
  public void showCategories(ReadableArray categoryIds) {
    showCategoriesWithOptions(categoryIds, null);
  }

  @ReactMethod
  public void showSections(ReadableArray sectionIds) {
    showSectionsWithOptions(sectionIds, null);
  }

  @ReactMethod
  public void showLabels(ReadableArray labels) {
    showLabelsWithOptions(labels, null);
  }

  @ReactMethod
  public void callSupport(ReadableMap customFields) {

    List<CustomField> fields = new ArrayList<>();

    for (Map.Entry<String, Object> next : customFields.toHashMap().entrySet())
      fields.add(new CustomField(Long.parseLong(next.getKey()), (String) next.getValue()));

    // TODO: figure out custom fields, they currently only exist on request
//    Support.INSTANCE.setCustomFields(fields);

    Activity activity = getCurrentActivity();

    if(activity != null){
      Intent callSupportIntent = new Intent(getReactApplicationContext(), RequestActivity.class);
      callSupportIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      getReactApplicationContext().startActivity(callSupportIntent);
    }
  }

  @ReactMethod
  public void supportHistory() {

    Activity activity = getCurrentActivity();

    if(activity != null){
      Intent supportHistoryIntent = new Intent(getReactApplicationContext(), RequestActivity.class);
      supportHistoryIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      getReactApplicationContext().startActivity(supportHistoryIntent);
    }
  }

  @ReactMethod
  public void createRequest(
          ReadableMap request,
          Promise promise) {
    try {
      // Get an instance of the RequestProvider from the Zendesk
      RequestProvider provider = Support.INSTANCE.provider().requestProvider();

      // Build the request object from the javascript arguments
      CreateRequest zdRequest = new CreateRequest();

      zdRequest.setSubject(request.getString("subject"));
      zdRequest.setDescription(request.getString("requestDescription"));

      ArrayList<Object> list = request.getArray("tags").toArrayList();
      List<String> tagsList = new ArrayList<>(list.size());
      for (Object object : list) {
        tagsList.add(object != null ? object.toString() : null);
      }

      zdRequest.setTags(tagsList);

      innerPromise = promise;
      // Create thew ZendeskCallback.
      ZendeskCallback<Request> callback = new ZendeskCallback<Request>() {
        @Override
        public void onSuccess(Request createRequest) {
          Log.d(TAG, "onSuccess: Ticket created!");

          WritableMap map = Arguments.createMap();
          WritableMap request = Arguments.createMap();

          map.putString("description", createRequest.getDescription());
          map.putString("id", createRequest.getId());
          // https://zendesk.github.io/mobile_sdk_javadocs/supportv2/v211/zendesk/support/CreateRequest.html
//          map.putString("email", createRequest.getEmail());
          map.putString("subject", createRequest.getSubject());

          request.putMap("request", map);

          innerPromise.resolve(request);
        }

        @Override
        public void onError(ErrorResponse errorResponse) {
          Log.d(TAG, "onError: " + errorResponse.getReason());
          innerPromise.reject("onError", errorResponse.getReason());
        }
      } ;

      // Call the provider method
      provider.createRequest(zdRequest, callback);

    } catch (Exception e) {
      promise.reject("onException", e.getMessage());
    }
  }
}
