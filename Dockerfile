FROM golang:1.20.3

# 安裝必要套件
RUN apt-get update && \
    apt-get install -y protobuf-compiler make

# 設定工作目錄
WORKDIR /go/src/app

# 安裝 go-micro 和其他依賴
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN go install github.com/go-micro/generator/cmd/protoc-gen-micro@latest


# 複製生成 shell 腳本到容器中
COPY generate_micro_service.sh /go/src/app

# 設定環境變數
ENV PATH /go/bin:$PATH


# 預先安裝
RUN mkdir pre && \
    cd pre && \
    echo "Initializing Go module" && \
    go mod init "pre" && \
    echo "Installing required packages" && \
    go get github.com/micro/micro/v3/cmd/protoc-gen-micro && \
    go get google.golang.org/grpc && \
    go get gorm.io/gorm && \
    go get gorm.io/driver/postgres && \
    go get go-micro.dev/v4 && \
    go get go-micro.dev/v4/api/handler/rpc && \
    go get go-micro.dev/v4/api/server/acme && \
    go get go-micro.dev/v4/api/server/http && \
    go get github.com/go-micro/plugins/v4/server/grpc && \
    cd ..


# 啟動容器時執行 shell 腳本
ENTRYPOINT ["sh", "generate_micro_service.sh"]