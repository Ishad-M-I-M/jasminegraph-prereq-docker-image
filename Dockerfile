#installing ubuntu:focal
FROM ubuntu:focal
WORKDIR /home/ubuntu
RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN apt-get -y install software-properties-common gpgv curl git cmake wget build-essential

#installing docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN apt-get update
RUN apt-get -y install docker-ce

#installing python
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install -y python3.8 python3.8-dev
RUN alias python=python3.8
RUN apt-get install -y python3-pip
RUN alias pip=pip3
RUN apt-get install -y libtool

#creating and moving to /home/ubuntu/software directory. All the essential libraries will be clone to this directory
RUN mkdir software
WORKDIR /home/ubuntu/software

#installing flatbuffers
RUN git clone https://github.com/google/flatbuffers.git
WORKDIR /home/ubuntu/software/flatbuffers
RUN git checkout tags/v2.0.8
RUN cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
RUN make

#installing metis
WORKDIR /home/ubuntu/software
RUN git clone https://github.com/KarypisLab/METIS.git
WORKDIR /home/ubuntu/software/METIS
RUN git switch -c build tags/v5.1.1-DistDGL-v0.5
RUN git submodule update --init
RUN make config shared=1 cc=gcc prefix=/home/ubuntu/local
RUN make install

#installing spdlog
WORKDIR /home/ubuntu/software
RUN git clone https://github.com/gabime/spdlog.git
WORKDIR /home/ubuntu/software/spdlog
RUN mkdir build
WORKDIR /home/ubuntu/software/spdlog/build
RUN cmake .. && make -j

#installing sqlite3, ...
RUN apt-get install -y sqlite3
RUN apt-get install -y libsqlite3-dev
RUN apt install -y librdkafka-dev
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y libssl-dev

#installing cppkafka
WORKDIR /home/ubuntu/software
RUN git clone https://github.com/mfontanini/cppkafka.git
WORKDIR /home/ubuntu/software/cppkafka
RUN mkdir build
WORKDIR /home/ubuntu/software/cppkafka/build
RUN cmake .. && make && make install

#installing xerces
WORKDIR /home/ubuntu/software
RUN wget https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.2.2.tar.gz
RUN tar -xvf xerces-c-3.2.2.tar.gz
WORKDIR /home/ubuntu/software/xerces-c-3.2.2
RUN sh configure --disable-transcoder-icu
RUN make install

#installing jsoncpp
WORKDIR /home/ubuntu/software
RUN git clone https://github.com/open-source-parsers/jsoncpp.git
WORKDIR /home/ubuntu/software/jsoncpp
RUN git checkout tags/1.8.4
RUN mkdir -p build/debug
WORKDIR /home/ubuntu/software/jsoncpp/build/debug
RUN cmake -DCMAKE_BUILD_TYPE=debug -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DARCHIVE_INSTALL_DIR=. -G "Unix Makefiles" ../..
RUN make

#installing pigz
WORKDIR /home/ubuntu/software
RUN wget http://zlib.net/pigz/pigz-2.7.tar.gz
RUN tar -xvf pigz-2.7.tar.gz
WORKDIR /home/ubuntu/software/pigz-2.7
RUN make
ENV PATH="/home/ubuntu/software/pigz-2.7/pigz:${PATH}"

#installing nlohmann_json
WORKDIR /home/ubuntu/software
RUN git clone https://github.com/nlohmann/json.git nlohmann_json
WORKDIR /home/ubuntu/software/nlohmann_json
RUN git checkout tags/v3.9.1
RUN cmake .
RUN make && make install

#installing required python packages for graphsage
WORKDIR /home/ubuntu/software
RUN apt-get -y install gfortran libopenblas-dev liblapack-dev
RUN apt-get update
RUN wget -o requirements.txt https://raw.githubusercontent.com/FYP-Auto-Scale-JasmineGraph/jasminegraph/main/GraphSAGE/requirements
RUN pip install -r ./GraphSAGE/requirements

CMD ["bash"]