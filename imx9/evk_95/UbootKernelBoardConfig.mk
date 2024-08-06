# from BoardConfig.mk
TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

ifeq ($(PRODUCT_IMX_CAR),true)
  ifeq ($(PRODUCT_IMX_CAR_M7),true)
    TARGET_BOOTLOADER_CONFIG := imx95:imx95_19x19_evk_androidauto_trusty_defconfig
  else
    TARGET_BOOTLOADER_CONFIG := imx95:imx95_19x19_evk_androidauto2_trusty_defconfig
    TARGET_BOOTLOADER_CONFIG += imx95-verdin:imx95_19x19_verdin_androidauto2_trusty_defconfig
  endif #PRODUCT_IMX_CAR_M7
else
  # u-boot target
  TARGET_BOOTLOADER_CONFIG := imx95:imx95_19x19_evk_android_defconfig
  TARGET_BOOTLOADER_CONFIG += imx95-verdin:imx95_19x19_verdin_android_defconfig
  TARGET_BOOTLOADER_CONFIG += imx95-15x15:imx95_15x15_evk_android_defconfig
  TARGET_BOOTLOADER_CONFIG += imx95-dual:imx95_19x19_evk_android_dual_defconfig
  TARGET_BOOTLOADER_CONFIG += imx95-15x15-dual:imx95_15x15_evk_android_dual_defconfig
  TARGET_BOOTLOADER_CONFIG += imx95-trusty-dual:imx95_19x19_evk_android_trusty_dual_defconfig
  TARGET_BOOTLOADER_CONFIG += imx95-trusty-secure-unlock-dual:imx95_19x19_evk_android_trusty_secure_unlock_dual_defconfig
  TARGET_BOOTLOADER_CONFIG += imx95-trusty-verdin-dual:imx95_19x19_verdin_android_trusty_dual_defconfig
  TARGET_BOOTLOADER_CONFIG += imx95-trusty-15x15-dual:imx95_15x15_evk_android_trusty_dual_defconfig
  TARGET_BOOTLOADER_CONFIG += imx95-rpmsg:imx95_19x19_evk_android_rpmsg_defconfig
endif #PRODUCT_IMX_CAR

TARGET_BOOTLOADER_CONFIG += imx95-evk-uuu:imx95_19x19_evk_android_uuu_defconfig
TARGET_BOOTLOADER_CONFIG += imx95-verdin-uuu:imx95_19x19_verdin_android_uuu_defconfig
ifneq ($(PRODUCT_IMX_CAR),true)
  TARGET_BOOTLOADER_CONFIG += imx95-15x15-evk-uuu:imx95_15x15_evk_android_uuu_defconfig
endif

ifeq ($(PRODUCT_IMX_CAR),true)
  ifeq ($(PRODUCT_IMX_CAR_M7),true)
    TARGET_KERNEL_ADDITION_DEFCONF := automotive_addition_car_defconfig
  else
    TARGET_KERNEL_ADDITION_DEFCONF := automotive_addition_car2_defconfig
  endif # PRODUCT_IMX_CAR_M7
  TARGET_KERNEL_DEFCONFIG := gki_defconfig
  ifeq ($(LOADABLE_KERNEL_MODULE),true)
    TARGET_KERNEL_GKI_DEFCONF:= imx95_car_gki.fragment
  else
    TARGET_KERNEL_GKI_DEFCONF:= imx_v8_android_defconfig
  endif
else
  TARGET_KERNEL_DEFCONFIG := gki_defconfig
  ifeq ($(LOADABLE_KERNEL_MODULE),true)
    TARGET_KERNEL_GKI_DEFCONF:= imx95_gki.fragment
  else
    TARGET_KERNEL_GKI_DEFCONF:= imx_v8_android_defconfig
  endif # LOADABLE_KERNEL_MODULE
  ifeq ($(POWERSAVE),true)
    TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig
  endif
endif # PRODUCT_IMX_CAR


# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

ifeq ($(PRODUCT_IMX_DUAL_BOOTLOADER),true)
  export PRODUCT_IMX_DUAL_BOOTLOADER
endif

export PRODUCT_IMX_CAR
export PRODUCT_IMX_CAR_M7
