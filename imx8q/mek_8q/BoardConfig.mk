# -------@block_storage-------
TARGET_USERIMAGES_USE_EXT4 := true

# use sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

ifneq ($(TARGET_INCLUDE_DTB_TO_VENDOR_BOOT),true)
BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8qm-revd.img
ifeq ($(OTA_TARGET),8qxp)
BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8qxp.img
endif
ifeq ($(OTA_TARGET),8qxp-c0)
BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8qxp.img
endif
endif

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

# -------@block_infrastructure-------
include $(CONFIG_REPO_PATH)/imx8q/BoardConfigCommon.mk

# -------@block_security-------
BOARD_AVB_ENABLE := true

BOARD_AVB_ALGORITHM := SHA256_RSA4096
# The testkey_rsa4096.pem is copied from external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_KEY_PATH := $(CONFIG_REPO_PATH)/common/security/testkey_rsa4096.pem

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

# Enable chained vbmeta for init_boot images
BOARD_AVB_INIT_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_INIT_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX_LOCATION := 3

# Use sha256 hashtree
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256

# Build GBL image
BOARD_GBL_PARTITION_SIZE := 8388608
BOARD_GBL_KEY_PATH := device/nxp/common/security/testkey_gbl_rsa4096.pem
BOARD_GBL_ROLLBACK_INDEX_LOCATION := 15

# -------@block_treble-------
# Vendor Interface Manifest
ifeq ($(PRODUCT_IMX_CAR),true)
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest_car.xml
else
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
endif

DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(IMX_DEVICE_PATH)/device_framework_matrix.xml

# Vendor compatibility matrix
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

# -------@block_wifi-------
BOARD_WLAN_DEVICE            := nxp
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

# Enables to use two concurrent interfaces
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
# Enables following multi-interface concurrency:  STA+AP+AP, STA+AP, STA+P2P, AP+AP, STA, AP, P2P
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 1}, {{AP_BRIDGED, AP, P2P}, 1}}, {{{AP_BRIDGED}, 1}}, {{{AP}, 1}}, {{{STA}, 1},}, {{{P2P}, 1}}

#Enable hostapd 802.11ax support
WIFI_FEATURE_HOSTAPD_11AX := true

# -------@block_bluetooth-------
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

# NXP BLUETOOTH
BOARD_HAVE_BLUETOOTH_NXP := true

# -------@block_kernel_bootimg-------

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_BOOTCONFIG += androidboot.hardware=nxp

# framebuffer config
BOARD_BOOTCONFIG += androidboot.fbTileSupport=enable

# memory config
BOARD_KERNEL_CMDLINE += cma=928M@0x960M-0xfc0M transparent_hugepage=never
BOARD_KERNEL_CMDLINE += swiotlb=768

# wifi config
BOARD_BOOTCONFIG += androidboot.wificountrycode=DE
BOARD_KERNEL_CMDLINE += moal.mod_para=wifi_mod_para.conf pci=nomsi

ifeq ($(PRODUCT_IMX_CAR),true)
# automotive config
#BOARD_KERNEL_CMDLINE += video=HDMI-A-2:d
else
BOARD_BOOTCONFIG += androidboot.console=ttyLP0
endif

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_BOOTCONFIG += androidboot.vendor.sysrq=1
endif

# For Android Auto with M4 EVS, fstab entries in dtb are in the form of non-dynamic partition by default
# For Android Auto without M4 EVS, fstab entries in dtb are in the form of dynamic partition by default
# For standard Android, the form of fstab entries in dtb depend on the value of "TARGET_USE_DYNAMIC_PARTITIONS"
#
ifeq ($(PRODUCT_IMX_CAR),true)
  ifeq ($(PRODUCT_IMX_CAR_M4),true)
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-car-no-product-max9286-csi0.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-car-no-product-max9286.dtb
    else
      ifeq ($(IMX8QM_A72_BOOT),true)
        # imx8qm auto android, A72 boot
        TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-car-a72-max9286-csi0.dtb
        # imx8qm auto with SOF
        TARGET_BOARD_DTS_CONFIG += imx8qm-sof:imx8qm-mek-car-a72-sof-max9286-csi0.dtb
        # imx8qm auto android, A72 boot on revd
        TARGET_BOARD_DTS_CONFIG += imx8qm-revd:imx8qm-mek-revd-car-a72-max9286-csi0.dtb
        # imx8qm auto with SOF on revd
        TARGET_BOARD_DTS_CONFIG += imx8qm-sof-revd:imx8qm-mek-revd-car-a72-sof-max9286-csi0.dtb
      else
        # imx8qm auto android
        TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-car-max9286-csi0.dtb
        # imx8qm auto android with multi-display
        TARGET_BOARD_DTS_CONFIG += imx8qm-md:imx8qm-mek-car-md-max9286-csi0.dtb
      endif
      # imx8qxp auto android
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-car-max9286.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp-sof:imx8qxp-mek-car-sof-max9286.dtb
    endif # IMX_NO_PRODUCT_PARTITION
  else #PRODUCT_IMX_CAR_M4
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-car2-no-product-max9286-csi0.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-car2-no-product-max9286.dtb
    else
      ifeq ($(IMX8QM_A72_BOOT),true)
        # imx8qm auto android without m4 image, A72 boot
        TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-car2-a72-max9286-csi0.dtb
        # imx8qm auto android without m4 image for multi-display, A72 boot
        TARGET_BOARD_DTS_CONFIG += imx8qm-md:imx8qm-mek-car2-md-a72-max9286-csi0.dtb
        # imx8qm auto with SOF
        TARGET_BOARD_DTS_CONFIG += imx8qm-sof:imx8qm-mek-car2-a72-sof-max9286-csi0.dtb
        # imx8qm auto android without m4 image, A72 boot on revd
        TARGET_BOARD_DTS_CONFIG += imx8qm-revd:imx8qm-mek-revd-car2-a72-max9286-csi0.dtb
        # imx8qm auto android without m4 image for multi-display, A72 boot on revd
        TARGET_BOARD_DTS_CONFIG += imx8qm-md-revd:imx8qm-mek-revd-car2-md-a72-max9286-csi0.dtb
        # imx8qm auto with SOF on revd
        TARGET_BOARD_DTS_CONFIG += imx8qm-sof-revd:imx8qm-mek-revd-car2-a72-sof-max9286-csi0.dtb
      else
        # imx8qm auto android without m4 image
        TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-car2-max9286-csi0.dtb
        # imx8qm auto android without m4 image for multi-display
        TARGET_BOARD_DTS_CONFIG += imx8qm-md:imx8qm-mek-car2-md-max9286-csi0.dtb
      endif
      # imx8qxp auto android without m4 image
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-car2-max9286.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp-sof:imx8qxp-mek-car2-sof-max9286.dtb
    endif #IMX_NO_PRODUCT_PARTITION
  endif #PRODUCT_IMX_CAR_M4
else
  ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-ov5640-no-product.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-ov5640-rpmsg-no-product.dtb
    else
      # imx8qm standard android; MIPI-HDMI display
      TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-ov5640-dual-rpmsg.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qm-ov5640-csi0:imx8qm-mek-ov5640-csi0-rpmsg.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qm-ov5640-csi1:imx8qm-mek-ov5640-csi1-rpmsg.dtb
      # imx8qm standard android; MIPI panel display
      TARGET_BOARD_DTS_CONFIG += imx8qm-mipi-panel:imx8qm-mek-dsi-rm67199.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qm-mipi-panel-rm67191:imx8qm-mek-dsi-rm67191.dtb
      # imx8qm standard android; HDMI display
      TARGET_BOARD_DTS_CONFIG += imx8qm-hdmi:imx8qm-mek-hdmi.dtb
      # imx8qm standard android; HDMI and HDMI RX
      TARGET_BOARD_DTS_CONFIG += imx8qm-hdmi-rx:imx8qm-mek-hdmi.dtb
      # imx8qm standard android; LVDS1 panel display
      TARGET_BOARD_DTS_CONFIG += imx8qm-lvds1-panel:imx8qm-mek-jdi-wuxga-lvds1-panel.dtb
      # imx8qxp standard android; MIPI-HDMI display
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-ov5640-dual-rpmsg.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp-ov5640-csi:imx8qxp-mek-ov5640-csi-rpmsg.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp-ov5640-parallel:imx8qxp-mek-ov5640-parallel-rpmsg.dtb
      TARGET_BOARD_DTS_CONFIG += imx8dx:imx8dx-mek.dtb
      # imx8qxp standard android; MIPI panel display
      TARGET_BOARD_DTS_CONFIG += imx8qxp-mipi-panel:imx8qxp-mek-dsi-rm67199-rpmsg.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp-mipi-panel-rm67191:imx8qxp-mek-dsi-rm67191-rpmsg.dtb
      # imx8qxp standard android; LVDS panel display
      TARGET_BOARD_DTS_CONFIG += imx8qxp-lvds0-panel:imx8qxp-mek-jdi-wuxga-lvds0-panel-rpmsg.dtb
      # imx8qm support SOF
      TARGET_BOARD_DTS_CONFIG += imx8qm-sof:imx8qm-mek-sof-wm8960.dtb
      # imx8qxp support SOF
      TARGET_BOARD_DTS_CONFIG += imx8qxp-sof:imx8qxp-mek-sof-wm8960.dtb
      # imx8qm standard android; MIPI-HDMI display on revd
      TARGET_BOARD_DTS_CONFIG += imx8qm-revd:imx8qm-mek-revd-ov5640-dual-rpmsg.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qm-ov5640-csi0-revd:imx8qm-mek-revd-ov5640-csi0-rpmsg.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qm-ov5640-csi1-revd:imx8qm-mek-revd-ov5640-csi1-rpmsg.dtb
      # imx8qm standard android; MIPI panel display on revd
      TARGET_BOARD_DTS_CONFIG += imx8qm-mipi-panel-revd:imx8qm-mek-revd-dsi-rm67199.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qm-mipi-panel-rm67191-revd:imx8qm-mek-revd-dsi-rm67191.dtb
      # imx8qm standard android; HDMI display on revd
      TARGET_BOARD_DTS_CONFIG += imx8qm-hdmi-revd:imx8qm-mek-revd-hdmi.dtb
      # imx8qm standard android; HDMI and HDMI RX on revd
      TARGET_BOARD_DTS_CONFIG += imx8qm-hdmi-rx-revd:imx8qm-mek-revd-hdmi.dtb
      # imx8qm standard android; LVDS1 panel display on revd
      TARGET_BOARD_DTS_CONFIG += imx8qm-lvds1-panel-revd:imx8qm-mek-revd-jdi-wuxga-lvds1-panel.dtb
      # imx8qm support SOF on revd
      TARGET_BOARD_DTS_CONFIG += imx8qm-sof-revd:imx8qm-mek-revd-sof-wm8962.dtb
    endif #IMX_NO_PRODUCT_PARTITION
  else
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-ov5640-no-product-no-dynamic_partition.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-ov5640-rpmsg-no-product-no-dynamic_partition.dtb
    else
      TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-ov5640-no-dynamic_partition.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-ov5640-rpmsg-no-dynamic_partition.dtb
    endif
  endif
endif #PRODUCT_IMX_CAR

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

# -------@block_sepolicy-------
BOARD_SEPOLICY_DIRS := \
       $(CONFIG_REPO_PATH)/imx8q/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

HAS_SYSTEM_EXT_SEPOLICY := true

ifeq ($(PRODUCT_IMX_CAR),true)
BOARD_SEPOLICY_DIRS += \
     $(CONFIG_REPO_PATH)/imx8q/sepolicy_car \
     $(IMX_DEVICE_PATH)/sepolicy_car \
     device/generic/car/common/sepolicy \
     vendor/nxp-opensource/imx/evs/sepolicy \
     vendor/nxp-opensource/imx/vehicle/sepolicy
endif

# -------@block_camera-------
ifeq ($(PRODUCT_IMX_CAR),true)
BOARD_HAVE_IMX_EVS := true
endif
