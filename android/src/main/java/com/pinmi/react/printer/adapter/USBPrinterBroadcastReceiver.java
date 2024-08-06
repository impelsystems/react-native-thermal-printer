package com.pinmi.react.printer.adapter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.util.Log;
import android.widget.Toast;

/**
 * Created by sadpaulafterdaysofandroidintent on 2024/7/20.
 */
public class USBPrinterBroadcastReceiver extends BroadcastReceiver {
    private String LOG_TAG = "USBPrinterBroadcastReceiver";
    private Context mContext;
    private IUSBPrinterDeviceCallback mCallback;
    private static final String ACTION_USB_PERMISSION = "com.pinmi.react.USBPrinter.USB_PERMISSION";

    public USBPrinterBroadcastReceiver() { }
    public USBPrinterBroadcastReceiver(Context context, IUSBPrinterDeviceCallback callback) {
        mContext = context;
        mCallback = callback;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (ACTION_USB_PERMISSION.equals(action)) {
            var testOut = intent.getStringExtra("tester");
            Log.d(LOG_TAG, "Test out was: " + testOut);

            synchronized (this) {
                var testIn = intent.getStringExtra("tester");
                Log.d(LOG_TAG, "Test in was: " + testOut);

                UsbDevice usbDevice = null;
                if (android.os.Build.VERSION.SDK_INT > android.os.Build.VERSION_CODES.TIRAMISU) {
                    usbDevice = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice.class);
                } else {
                    usbDevice = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
                }
                if (usbDevice == null) {
                    Log.i(LOG_TAG,
                            "Unable to retrieve device to check if permission was granted.");
                    Toast.makeText(context,
                            "Failed determining result.",
                            Toast.LENGTH_LONG).show();
                    return;
                }
                if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                    Log.i(LOG_TAG,
                            "Success to grant permission for device " + usbDevice.getDeviceId() + ", vendorId: "
                                    + usbDevice.getVendorId() + " productId: " + usbDevice.getProductId() + " deviceName: " + usbDevice.getDeviceName());
                    mCallback.onUsbDeviceSelected(usbDevice);
                    return;
                }
                Toast.makeText(context,
                        "User refuses to obtain USB device permissions" + usbDevice.getDeviceName(),
                        Toast.LENGTH_LONG).show();
            }
        } else if (UsbManager.ACTION_USB_DEVICE_DETACHED.equals(action)) {
            mCallback.onUsbDeviceDetached();
        } else if (UsbManager.ACTION_USB_ACCESSORY_ATTACHED.equals(action)
                || UsbManager.ACTION_USB_DEVICE_ATTACHED.equals(action)) {
            mCallback.onUsbDeviceAttached();
        }
    }

    public IntentFilter createIntentFilter() {
        var filter = new IntentFilter();
        filter.addAction(ACTION_USB_PERMISSION);
        filter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
        filter.addAction(UsbManager.ACTION_USB_ACCESSORY_ATTACHED);
        filter.addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED);
        return filter;
    }
};
