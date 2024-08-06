package com.pinmi.react.printer.adapter;

import android.hardware.usb.UsbDevice;

/**
 * Created by xiesubin on 2017/9/21.
 */
public class USBPrinterDeviceId extends PrinterDeviceId {

    private Integer vendorId;
    private Integer productId;
    private String deviceName;

    public Integer getVendorId() {
        return vendorId;
    }

    public Integer getProductId() {
        return productId;
    }

    public String getDeviceName() { return deviceName; }

    public static USBPrinterDeviceId valueOf(Integer vendorId, Integer productId, String deviceName) {
        return new USBPrinterDeviceId(vendorId, productId, deviceName);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        if (!super.equals(o))
            return false;

        USBPrinterDeviceId that = (USBPrinterDeviceId) o;

        if (!vendorId.equals(that.vendorId)) {
          return false;
        }
        if (!deviceName.equals(that.deviceName)) {
          return false;
        }
        return productId.equals(that.productId);
    }

    @Override
    public int hashCode() {
        int result = vendorId.hashCode();
        result = 31 * result + productId.hashCode();
        return result;
    }

    public boolean matchesDevice(UsbDevice device) {
      return device.getVendorId() == this.getVendorId()
        && device.getProductId() == this.getProductId()
        && device.getDeviceName() == this.getDeviceName();
    }

    private USBPrinterDeviceId(Integer vendorId, Integer productId, String deviceName) {
        this.vendorId = vendorId;
        this.productId = productId;
        this.deviceName = deviceName;
    }
}
