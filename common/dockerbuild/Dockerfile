FROM ubuntu:22.04
ARG userid
ARG groupid
ARG username

# If apt-get need http proxy in your host's network environment, you can refer to the line below.
# COPY apt.conf /etc/apt/apt.conf

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y uuid uuid-dev zlib1g-dev liblz-dev liblzo2-2 liblzo2-dev lzop git curl u-boot-tools mtd-utils android-sdk-libsparse-utils device-tree-compiler gdisk m4 bison flex make libssl-dev gcc-multilib libgnutls28-dev swig liblz4-tool libdw-dev dwarves bc cpio tar lz4 rsync ninja-build clang build-essential libparted-dev python3.10-dev python3-pip pkg-config libncurses5 xxd unzip \
 && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN pip install pyparted
RUN pip install six

ENV GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64 arm-gnu-toolchain-12.3.rel1-x86_64-aarch64-none-linux-gnu
RUN curl -o ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/12.3.rel1/binrel/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz \
 && tar -xvJf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz -C /opt \
 && rm -rf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz

ENV GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32 arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi
RUN curl -o ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/12.3.rel1/binrel/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz \
 && tar -xvJf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz -C /opt \
 && rm -rf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz

# imx8QM/QXP CM4 and imx95 CM7 toolchain
ENV GCC_CROSS_COMPILE_TOOL_CHAIN_CMx gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux
RUN curl -o ${GCC_CROSS_COMPILE_TOOL_CHAIN_CMx}.tar.bz2 https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/9-2020q2/${GCC_CROSS_COMPILE_TOOL_CHAIN_CMx}.tar.bz2 \
 && tar -jxvf ${GCC_CROSS_COMPILE_TOOL_CHAIN_CMx}.tar.bz2 -C /opt \
 && rm -rf ${GCC_CROSS_COMPILE_TOOL_CHAIN_CMx}.tar.bz2

ENV AARCH64_GCC_CROSS_COMPILE=/opt/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}/bin/aarch64-none-linux-gnu-
ENV AARCH32_GCC_CROSS_COMPILE=/opt/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}/bin/arm-none-eabi-
ENV ARMGCC_DIR=/opt/gcc-arm-none-eabi-9-2020-q2-update

# If failed to connect to android.googlesource.com, you can refer to the line below.
# ENV https_proxy=http://username:password@example.com:8080
RUN git clone --no-checkout --depth 1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 /opt/android-kernel-prebuilts-6.12/clang/host/linux-x86 \
  && cd /opt/android-kernel-prebuilts-6.12/clang/host/linux-x86 \
  && git fetch --depth 1 origin 66acdd82ee62e4aaa4248f03191c59dfed9db193 \
  && git checkout 66acdd82ee62e4aaa4248f03191c59dfed9db193

RUN git clone --no-checkout --depth 1 https://android.googlesource.com/kernel/prebuilts/build-tools /opt/android-kernel-prebuilts-6.12/kernel-build-tools \
  && cd /opt/android-kernel-prebuilts-6.12/kernel-build-tools \
  && git fetch --depth 1 origin 3c5e4f14b451ec85167c38b917d2459687abd7f4 \
  && git checkout 3c5e4f14b451ec85167c38b917d2459687abd7f4

RUN git clone --no-checkout --depth 1 https://android.googlesource.com/platform/prebuilts/rust /opt/android-kernel-prebuilts-6.12/rust \
  && cd /opt/android-kernel-prebuilts-6.12/rust \
  && git fetch --depth 1 origin 5156e7f81ae254c79ee736e44c960e75ad685c67 \
  && git checkout 5156e7f81ae254c79ee736e44c960e75ad685c67
RUN git clone --no-checkout --depth 1 https://android.googlesource.com/platform/prebuilts/clang-tools /opt/android-kernel-prebuilts-6.12/clang-tools \
  && cd /opt/android-kernel-prebuilts-6.12/clang-tools \
  && git fetch --depth 1 origin 17329f6590e2872dcf04a0c96a176be089470cd9 \
  && git checkout 17329f6590e2872dcf04a0c96a176be089470cd9

ENV KERNEL_PREBUILTS_PATH=/opt/android-kernel-prebuilts-6.12

RUN groupadd -g $groupid $username \
 && useradd -m -u $userid -g $groupid $username \
 && echo $username >/root/username
ENV HOME=/home/$username
ENV USER=$username

ENTRYPOINT chroot --userspec=$(cat /root/username):$(cat /root/username) / /bin/bash -i
