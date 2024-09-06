package com.pinmi.react.printer;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.pinmi.react.printer.adapter.NetPrinterAdapter;
import com.pinmi.react.printer.adapter.NetPrinterDeviceId;
import com.pinmi.react.printer.adapter.PrinterAdapter;
import com.pinmi.react.printer.adapter.PrinterDevice;

import java.util.List;

/**
 * Created by xiesubin on 2017/9/22.
 */
public class RNNetPrinterModule extends ReactContextBaseJavaModule implements RNPrinterModule {

    private PrinterAdapter adapter;
    private ReactApplicationContext reactContext;

    public RNNetPrinterModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @ReactMethod
    @Override
    public void init(Callback successCallback, Callback errorCallback) {
        this.adapter = NetPrinterAdapter.getInstance();
        this.adapter.init(reactContext, successCallback, errorCallback);
    }

    @ReactMethod
    @Override
    public void closeConn() {
        this.adapter = NetPrinterAdapter.getInstance();
        this.adapter.closeConnectionIfExists();
    }

    @ReactMethod
    @Override
    public void getDeviceList(Callback successCallback, Callback errorCallback) {
        try {
            List< PrinterDevice> printerDevices = this.adapter.getDeviceList(errorCallback);
            WritableArray pairedDeviceList = Arguments.createArray();
            if (printerDevices.size() > 0) {
              for (PrinterDevice printerDevice : printerDevices) {
                pairedDeviceList.pushMap(printerDevice.toRNWritableMap());
              }
              successCallback.invoke(pairedDeviceList);
            } else {
              errorCallback.invoke("No Device Found");
            }
        } catch (Exception ex) {
            errorCallback.invoke(ex.getMessage());
        }
    }

    @ReactMethod
    public void connectPrinter(String host, Integer port, Callback successCallback, Callback errorCallback) {
        adapter.selectDevice(NetPrinterDeviceId.valueOf(host, port), successCallback, errorCallback);
    }

    @ReactMethod
    @Override
    public void printRawData(String base64Data, Callback errorCallback) {
        adapter.printRawData(base64Data, errorCallback);
    }

    @Override
    public String getName() {
        return "RNNetPrinter";
    }
}
