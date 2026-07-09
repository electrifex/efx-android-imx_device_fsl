# Copyright (C) 2026 Electrifex
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# FRDM-iMX95 automotive (AAOS) product.
#
# Reuses the evk_95_car2 configuration (Android Automotive OS, no M7/M4 EVS,
# rpmsg/dummy vehicle HAL) but targets the NXP FRDM-iMX95 (15x15) board
# hardware instead of the 19x19 EVK / Verdin.
#
# The board (TARGET_DEVICE) is still evk_95, so the shared BoardConfig.mk /
# UbootKernelBoardConfig.mk are reused; FRDM selection is driven by the
# PRODUCT_IMX_FRDM flag set in SharedBoardConfig.mk for this product.

# -------@block_infrastructure-------
CONFIG_REPO_PATH := device/nxp
CURRENT_FILE_PATH := $(lastword $(MAKEFILE_LIST))
IMX_DEVICE_PATH := $(strip $(patsubst %/, %, $(dir $(CURRENT_FILE_PATH))))

# Inherit the full Android Automotive (car2 / no-M7) product configuration.
include $(IMX_DEVICE_PATH)/evk_95_car2.mk

# -------@block_common_config-------
# Overrides: this is a distinct product targeting the FRDM-iMX95 board.
PRODUCT_NAME := frdm_imx95
PRODUCT_MODEL := FRDM_IMX95
TARGET_BOOTLOADER_BOARD_NAME := FRDM_IMX95
