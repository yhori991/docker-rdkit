FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
# Python3 + RDKIT
ARG RDKIT_VERSION=Release_2020_09_3
RUN apt-get update \
&& apt-get install -yq --no-install-recommends \
    ca-certificates \
    build-essential \
    git \
    cmake \
    wget \
    libboost-all-dev \
    libcairo2-dev \
    libeigen3-dev \
    python3 \
    python3-dev \
    python3-setuptools \
    python3-pip \
    python3-numpy \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
RUN wget --quiet https://github.com/rdkit/rdkit/archive/${RDKIT_VERSION}.tar.gz \
&& tar -xzf ${RDKIT_VERSION}.tar.gz \
&& mv rdkit-${RDKIT_VERSION} rdkit \
&& rm ${RDKIT_VERSION}.tar.gz
RUN mkdir /rdkit/build
WORKDIR /rdkit/build
RUN cmake -Wno-dev \
  -D RDK_INSTALL_INTREE=OFF \
  -D RDK_INSTALL_STATIC_LIBS=OFF \
  -D RDK_BUILD_INCHI_SUPPORT=ON \
  -D RDK_BUILD_AVALON_SUPPORT=ON \
  -D RDK_BUILD_PYTHON_WRAPPERS=ON \
  -D RDK_BUILD_CAIRO_SUPPORT=ON \
  -D RDK_BUILD_FREESASA_SUPPORT=ON \
  -D RDK_USE_FLEXBISON=OFF \
  -D RDK_BUILD_THREADSAFE_SSS=ON \
  -D RDK_OPTIMIZE_NATIVE=OFF \
  -D PYTHON_EXECUTABLE=/usr/bin/python3 \
  -D PYTHON_INCLUDE_DIR=/usr/include/python3.8 \
  -D PYTHON_NUMPY_INCLUDE_PATH=/usr/lib/python3/dist-packages/numpy/core/include \
  -D CMAKE_INSTALL_PREFIX=/usr \
  -D CMAKE_BUILD_TYPE=Release \
  -D Boost_NO_BOOST_CMAKE=ON \
  ..
RUN make -j $(proc) && make install
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 2
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 2
WORKDIR /
CMD /bin/bash
