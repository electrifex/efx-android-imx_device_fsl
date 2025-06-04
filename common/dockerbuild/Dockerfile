FROM ubuntu:22.04
ARG userid
ARG groupid
ARG username

# If apt-get need http proxy in your host's network environment, you can refer to the line below.
# COPY apt.conf /etc/apt/apt.conf

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y uuid uuid-dev zlib1g-dev liblz-dev liblzo2-2 liblzo2-dev lzop git curl u-boot-tools mtd-utils android-sdk-libsparse-utils device-tree-compiler gdisk m4 bison flex make libssl-dev gcc-multilib libgnutls28-dev swig liblz4-tool libdw-dev dwarves bc cpio tar lz4 rsync ninja-build clang build-essential libncurses5 xxd unzip \
 && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ENV GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64 arm-gnu-toolchain-12.3.rel1-x86_64-aarch64-none-linux-gnu
RUN curl -o ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/12.3.rel1/binrel/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz \
 && tar -xvJf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz -C /opt \
 && rm -rf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz

ENV GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32 arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi
RUN curl -o ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/12.3.rel1/binrel/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz \
 && tar -xvJf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz -C /opt \
 && rm -rf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz

# imx8QM/QXP CM4 and imx95 CM7 toolchain
ENV GCC_CROSS_COMPILE_TOOL_CHAIN_CM4 gcc-arm-none-eabi-7-2018-q2-update-linux
RUN curl -o ${GCC_CROSS_COMPILE_TOOL_CHAIN_CM4}.tar.xz https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/7-2018q2/${GCC_CROSS_COMPILE_TOOL_CHAIN_CM4}.tar.bz2 \
 && tar -jxvf ${GCC_CROSS_COMPILE_TOOL_CHAIN_CM4}.tar.xz -C /opt \
 && rm -rf ${GCC_CROSS_COMPILE_TOOL_CHAIN_CM4}.tar.xz

ENV AARCH64_GCC_CROSS_COMPILE=/opt/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}/bin/aarch64-none-linux-gnu-
ENV AARCH32_GCC_CROSS_COMPILE=/opt/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}/bin/arm-none-eabi-
ENV ARMGCC_DIR=/opt/gcc-arm-none-eabi-7-2018-q2-update

# If failed to connect to android.googlesource.com, you can refer to the line below.
# ENV https_proxy=http://username:password@example.com:8080

RUN git clone -b main-kernel --single-branch --depth 1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 /opt/android-kernel-prebuilts-6.12/clang/host/linux-x86
RUN git clone -b main --single-branch --depth 1 https://android.googlesource.com/kernel/prebuilts/build-tools /opt/android-kernel-prebuilts-6.12/kernel-build-tools

RUN git clone -b main --single-branch --depth 1 https://android.googlesource.com/platform/prebuilts/clang-tools /opt/android-kernel-prebuilts-6.12/clang-tools

ENV KERNEL_PREBUILTS_PATH=/opt/android-kernel-prebuilts-6.12

RUN groupadd -g $groupid $username \
 && useradd -m -u $userid -g $groupid $username \
 && echo $username >/root/username
ENV HOME=/home/$username
ENV USER=$username

ENTRYPOINT chroot --userspec=$(cat /root/username):$(cat /root/username) / /bin/bash -i
