FROM nvidia/cuda:8.0-devel-ubuntu16.04
MAINTAINER Allan Pinto <allansp84@gmail.com>

# -- install the required packages
RUN \
    apt-get update && \
    apt-get install -y \
        build-essential cmake unzip wget git vim htop \
        libjasper-dev libjpeg-dev libpng-dev libtiff5-dev \
        libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev \
        libopenblas-dev liblapacke-dev libtbb2 libtbb-dev libboost-all-dev libhdf5-dev && \
    apt-get install -y \
        python2.7-dev python-pip python-numpy libpython2.7-dev \
        python3.5 python3.5-dev python3-pip python3-numpy python3-urllib3 libpython3.5-dev && \
    apt-get autoclean && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# -- download the opencv-3.3.0 and opencv_contrib-3.3.0 packages
RUN \
    cd /root && \
    wget https://github.com/opencv/opencv/archive/3.3.0/opencv-3.3.0.zip && \
    unzip opencv-3.3.0.zip && \
    rm -rf /root/opencv-3.3.0.zip && \
    wget https://github.com/opencv/opencv_contrib/archive/3.3.0/opencv_contrib-3.3.0.zip && \
    unzip opencv_contrib-3.3.0.zip && \
    rm -rf /root/opencv_contrib-3.3.0.zip

# -- compile and install the opencv-3.3.0 library
RUN \
    mkdir -p /root/opencv-3.3.0/release && \
    cd /root/opencv-3.3.0/release && \
    cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_DOCS=NO -DBUILD_EXAMPLES=NO -DOPENCV_EXTRA_MODULES_PATH=/root/opencv_contrib-3.3.0/modules -DWITH_CUDA=YES -DWITH_OPENMP=YES -DWITH_CUBLAS=NO -DBUILD_PYTHON_SUPPORT=ON -DBUILD_opencv_python2=ON -DBUILD_opencv_python3=ON -DPYTHON3_EXECUTABLE=$(which python3) -DPYTHON3_INCLUDE_DIRS=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") -DPYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") -DPYTHON3_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.5m.so -DWITH_1394=OFF .. && \
    make -j"$(nproc)" && make install && \
    echo "/usr/local/include/opencv" > /etc/ld.so.conf.d/opencv.conf && ldconfig && \
    rm -rf /root/opencv-3.3.0 && rm -rf /root/opencv_contrib-3.3.0

WORKDIR /root
