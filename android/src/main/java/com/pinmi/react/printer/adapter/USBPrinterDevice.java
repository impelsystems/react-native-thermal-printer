package com.pinmi.react.printer.adapter;

import android.hardware.usb.UsbDevice;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;

/**
 * Created by xiesubin on 2017/9/21.
 */
public class USBPrinterDevice implements PrinterDevice {
    private UsbDevice mDevice;
    private USBPrinterDeviceId usbPrinterDeviceId;

    public USBPrinterDevice(UsbDevice device) {
        this.usbPrinterDeviceId = USBPrinterDeviceId.valueOf(
          device.getVendorId(),
          device.getProductId(),
          device.getDeviceName(),
          this.tryGetDeviceSerialNumber(device)
        );
        this.mDevice = device;
    }

    @Override
    public PrinterDeviceId getPrinterDeviceId() {
        return this.usbPrinterDeviceId;
    }

    public UsbDevice getUsbDevice() {
        return this.mDevice;
    }

    @Override
    public WritableMap toRNWritableMap() {
        WritableMap deviceMap = Arguments.createMap();
        deviceMap.putString("deviceName", this.mDevice.getDeviceName());
        deviceMap.putInt("device_id", this.mDevice.getDeviceId());
        deviceMap.putInt("vendorId", this.mDevice.getVendorId());
        deviceMap.putInt("productId", this.mDevice.getProductId());
        deviceMap.putString("serialNumber", this.tryGetDeviceSerialNumber(this.mDevice));
        return deviceMap;
    }

  private String tryGetDeviceSerialNumber(UsbDevice device) {
    try {
      return device.getSerialNumber();
    } catch (Exception error) {
      // you'll do nothing
    }
    return null;
  }
}
