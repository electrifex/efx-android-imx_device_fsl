# -------@block_infrastructure-------
CONFIG_REPO_PATH := device/nxp
CURRENT_FILE_PATH :=  $(lastword $(MAKEFILE_LIST))
IMX_DEVICE_PATH := $(strip $(patsubst %/, %, $(dir $(CURRENT_FILE_PATH))))

# -------@block_kernel_bootimg-------
# Don't enable vendor boot for Android Auto with M4 EVS for now
TARGET_USE_VENDOR_BOOT ?= true

# -------@block_storage-------
# Android Auto with M4 EVS does not use dynamic partition
TARGET_USE_DYNAMIC_PARTITIONS ?= true

# -------@block_infrastructure-------
include $(IMX_DEVICE_PATH)/evk_95.mk

# -------@block_common_config-------
# Overrides
PRODUCT_NAME := evk_95_car
PRODUCT_PACKAGE_OVERLAYS := $(IMX_DEVICE_PATH)/overlay_car $(PRODUCT_PACKAGE_OVERLAYS)

# -------@block_app-------
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/privapp-permissions-imx.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-imx.xml \
    $(CONFIG_REPO_PATH)/imx9/default-permissions/default-permissions-com.android.car.dialer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default-permissions/prebuilt_default-permissions-com.android.car.dialer.xml

# -------@block_camera-------
# Android Auto with Camera2 enablement
ENABLE_CAMERA_SERVICE ?= true
# Add Car related HAL
PRODUCT_PACKAGES += \
    android.hardware.broadcastradio-service.default \
    android.hardware.gnss-service.example \
    android.hardware.automotive.vehicle@V1-imx-service


# broadcast radio feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.broadcastradio.xml:system/etc/permissions/android.hardware.broadcastradio.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml

# -------@block_miscellaneous-------
PRODUCT_COPY_FILES += \
    packages/services/Car/car_product/init/init.bootstat.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.bootstat.rc \
    packages/services/Car/car_product/init/init.car.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.car.rc \

# ONLY devices that meet the CDD's requirements may declare these features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.hardware.type.automotive.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.type.automotive.xml

ifeq ($(PRODUCT_IMX_CAR_M7),false)
# Simulate the vehical rpmsg register event for non M7 car image
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.vehicle.register=1 \
    vendor.evs.video.ready=1
else
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/display.init.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/display.init.cfg
endif # PRODUCT_IMX_CAR_M7
