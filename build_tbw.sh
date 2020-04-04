#! /bin/bash

id -a
pwd


cd /home/pi/
rm -Rf ToxBlinkenwall/.git # remove previous install
rm -Rf tmp/

echo "using local build from zoff99 repo"
git clone https://github.com/zoff99/toxic tmp
cd tmp
git checkout "master"

cd ..
mkdir -p ToxBlinkenwall/
cp -a tmp/*  ToxBlinkenwall/
cp -a tmp/.gitignore ToxBlinkenwall/
cp -a tmp/.git ToxBlinkenwall/
rm -Rf tmp/

cd
export _HOME_="/home/pi/"
echo $_HOME_
cd $_HOME_/ToxBlinkenwall/


export _SRC_=$_HOME_/src/
export _INST_=$_HOME_/inst/

export CF2=" -O3 -ggdb3 "
export CF3="" # " -funsafe-math-optimizations "
export VV1=" VERBOSE=1 V=1 "

sudo rm -Rfv $_SRC_
sudo rm -Rfv $_INST_

mkdir -p $_SRC_
mkdir -p $_INST_
sudo chown -R pi:pi $_SRC_
sudo chown -R pi:pi $_INST_

export LD_LIBRARY_PATH=$_INST_/lib/
export PKG_CONFIG_PATH=$_INST_/lib/pkgconfig:/usr/local/lib/pkgconfig


cd $_SRC_
rm -Rf nasm
# git clone http://repo.or.cz/nasm.git # site is down
git clone https://github.com/unofficial-mirror/nasm
cd nasm
git checkout nasm-2.14.02
./autogen.sh
./configure --prefix=$_INST_
make -j $(nproc) || exit 1
# # seems man pages are not always built. but who needs those
touch nasm.1
touch ndisasm.1
make install

id -a
sudo cp -av $_INST_/bin/nasm /usr/bin/
sudo chmod a+rx /usr/bin/nasm
nasm -v


cd $_SRC_
# rm -Rf x264
git clone https://code.videolan.org/videolan/x264.git
cd x264
git checkout 34c06d1c17ad968fbdda153cb772f77ee31b3095 # stable
./configure --prefix=$_INST_ --disable-opencl --enable-static \
--disable-avs --disable-cli --enable-pic
make clean
make -j $(nproc) || exit 1
make install



cd $_SRC_
git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
cd nv-codec-headers
git checkout n8.1.24.10 # n9.1.23.0
make -j $(nproc) || exit 1
sudo make install

#ls -al /usr/local/include/ffnvcodec
#mkdir -p $_INST_/include/ffnvcodec
#sudo mkdir -p /usr/include/ffnvcodec
#sudo cp -av /usr/local/include/ffnvcodec/* /usr/include/ffnvcodec/
#cp -av /usr/local/include/ffnvcodec/* $_INST_/include/ffnvcodec/

#ls -al /usr/local/lib/pkgconfig
#mkdir -p $_INST_/lib/pkgconfig
#sudo mkdir -p /usr/lib/pkgconfig
#sudo cp -av /usr/local/lib/pkgconfig/* /usr/lib/pkgconfig/
#cp -av /usr/local/lib/pkgconfig/* $_INST_/lib/pkgconfig/

pkg-config --cflags ffnvcodec
pkg-config --libs ffnvcodec



# for ffmpeg --------
export CFLAGS="$CF2 $CF3 -I/usr/local/include"

cd $_SRC_
# rm -Rf libav
git clone --depth=1 --branch=n4.2.1 https://github.com/FFmpeg/FFmpeg libav
cd libav
./configure --prefix=$_INST_ --disable-devices \
--enable-pthreads \
--disable-shared --enable-static \
--disable-doc --disable-avdevice \
\
--disable-network \
--enable-ffmpeg --enable-ffprobe \
--disable-network --disable-everything \
--disable-bzlib \
--disable-libxcb-shm \
--disable-libxcb-xfixes \
--enable-parser=h264 \
--enable-nvenc --enable-encoder=h264_nvenc \
--enable-nvdec --enable-decoder=h264_cuvid \
--enable-protocol=file --enable-protocol=data \
--enable-demuxer=h264 \
--enable-indev=lavfi --enable-filter=testsrc \
--enable-filter=scale \
--enable-muxer=h264 --enable-muxer=matroska \
--enable-runtime-cpudetect \
--enable-libx264 \
--enable-encoder=libx264 \
--enable-decoder=rawvideo \
--enable-hwaccel=h264_nvdec --enable-hwaccel=h264_vaapi --enable-hwaccel=h264_vdpau \
--enable-gpl --enable-decoder=h264 || exit 1

# --disable-swscale \
# ./ffmpeg -y -f lavfi -i testsrc=duration=10:size=1280x720:rate=30 -vcodec h264_nvenc test.mkv -v 56

make clean
make -j $(nproc) || exit 1
make install

unset CFLAGS

cd $_SRC_
git clone --depth=1 --branch=1.0.18 https://github.com/jedisct1/libsodium.git
cd libsodium
./autogen.sh
res1=$?
if [ $res1 -ne 0 ]; then
    echo "retrying to autoconf libsodium"
    sleep 61
    ./autogen.sh || exit 1
fi
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "
./configure --prefix=$_INST_ --disable-shared --disable-soname-versions
res=$?
if [ $res -ne 0 ]; then
    echo "retrying to configure libsodium"
    sleep 61
    ./autogen.sh
    ./configure --prefix=$_INST_ --disable-shared --disable-soname-versions || exit 1
fi
make -j $(nproc) || exit 1
make install

cd $_SRC_
git clone --depth=1 --branch=v1.8.1 https://github.com/webmproject/libvpx.git
cd libvpx
make clean
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "
./configure --prefix=$_INST_ --disable-examples \
  --disable-unit-tests --enable-shared \
  --size-limit=16384x16384 \
  --enable-onthefly-bitpacking \
  --enable-error-concealment \
  --enable-runtime-cpu-detect \
  --enable-multi-res-encoding \
  --enable-postproc \
  --enable-vp9-postproc \
  --enable-temporal-denoising \
  --enable-vp9-temporal-denoising

#  --enable-better-hw-compatibility \

make -j $(nproc) || exit 1
make install

cd $_SRC_
git clone --depth=1 --branch=v1.3.1 https://github.com/xiph/opus.git
cd opus
./autogen.sh
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "
./configure --prefix=$_INST_ --disable-shared
make -j $(nproc) || exit 1
make install


## --------- build without HW Accceleration ---------

cd $_SRC_

echo "using build from zoff99 repo"
git clone https://github.com/zoff99/c-toxcore
cd c-toxcore
git checkout "zoff99/zoxcore_local_fork"

./autogen.sh
make clean
export CFLAGS=" $CF2 -D_GNU_SOURCE -I$_INST_/include/ -O3 \
                --param=ssp-buffer-size=1 -ggdb3 -fstack-protector-all "
export LDFLAGS=-L$_INST_/lib

./configure \
--prefix=$_INST_ \
--disable-soname-versions --disable-testing --disable-shared
make -j $(nproc) || exit 1
make install


cd $_HOME_/ToxBlinkenwall/

make -j $(nproc)
res2=$?

ldd build/toxic
ls -hal build/toxic
file build/toxic

mkdir -p $_HOME_/ToxBlinkenwall/toxblinkenwall/
chown pi:pi $_HOME_/ToxBlinkenwall/toxblinkenwall/

cp -av build/toxic $_HOME_/ToxBlinkenwall/toxblinkenwall/
chown pi:pi $_HOME_/ToxBlinkenwall/toxblinkenwall/toxic
chmod a+rx $_HOME_/ToxBlinkenwall/toxblinkenwall/toxic

echo '#! /bin/bash
export LD_LIBRARY_PATH="/home/pi/inst/lib/"
cd /home/pi/ToxBlinkenwall/toxblinkenwall/
mkdir -p ./db/
while [ 1 == 1 ]; do
    su -p --session-command ./toxic -- pi
    sleep 4
done
' > $_HOME_/ToxBlinkenwall/toxblinkenwall/start_toxic.sh


chmod a+rx $_HOME_/ToxBlinkenwall/toxblinkenwall/start_toxic.sh
chown pi:pi $_HOME_/ToxBlinkenwall/toxblinkenwall/start_toxic.sh

## --------- build without HW Accceleration ---------



cd $_HOME_


if [ $res2 -eq 0 ]; then
 echo "compile: OK"

 # echo "clean up of compile files ..."
 rm -Rf $_SRC_
 ## do not cleanup install dir ## rm -Rf $_INST_
 echo "... ready"

else
 echo "compile: ** ERROR **"
 exit 2
fi

echo '
IS_ON=RASPI
HD=RASPIHD
export IS_ON
export HD

PULSE_PROP=filter.want=echo-cancel
export PULSE_PROP

TBW_KILLSWITCH_ENGAGE=1
export TBW_KILLSWITCH_ENGAGE

' >> ~/.profile

echo "build ready"

