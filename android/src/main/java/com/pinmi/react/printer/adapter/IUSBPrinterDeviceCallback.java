package com.pinmi.react.printer.adapter;

import android.hardware.usb.UsbDevice;

public interface IUSBPrinterDeviceCallback {
    void onUsbDeviceAttached();
    void onUsbDeviceDetached();
    void onUsbDeviceSelected(UsbDevice device);
}