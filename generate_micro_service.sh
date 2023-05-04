#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <module-name> <service-name>"
  exit 1
fi

ucfirst() {
    echo "$1" | awk '{print toupper(substr($0,1,1)) substr($0,2)}'
}

MODULE_NAME=$1
SERVICE_NAME=$2
CLASS_NAME=$(ucfirst $SERVICE_NAME)
CURRENT_DIR=$(pwd)

echo "Creating microservice project: $SERVICE_NAME"
mkdir -p "$CURRENT_DIR/$SERVICE_NAME"
cd "$CURRENT_DIR/$SERVICE_NAME"

echo "Creating project structure"
mkdir -p domain/model
mkdir -p domain/repository
mkdir -p domain/service
mkdir -p handler
mkdir -p proto/$SERVICE_NAME
touch Dockerfile
touch main.go
touch Makefile

echo "Initializing Go module"
go mod init "$MODULE_NAME/$SERVICE_NAME"

echo "Installing required packages"
go get github.com/micro/micro/v3/cmd/protoc-gen-micro
go get google.golang.org/grpc
go get gorm.io/gorm
go get gorm.io/driver/postgres
go get go-micro.dev/v4
go get go-micro.dev/v4/api/handler/rpc
go get go-micro.dev/v4/api/server/acme
go get go-micro.dev/v4/api/server/http
go get github.com/go-micro/plugins/v4/server/grpc

echo "Creating ${CLASS_NAME} model"
cat > domain/model/${SERVICE_NAME}.go <<EOL
package model

type ${CLASS_NAME} struct {
    ID uint \`gorm:"primary_key;not_null;auto_increment"\`
}
EOL

cat > proto/${SERVICE_NAME}/${SERVICE_NAME}.proto <<EOL
syntax = "proto3";

package ${SERVICE_NAME};

option go_package = "proto/${SERVICE_NAME}";

service ${CLASS_NAME}Service {
  rpc Get(${CLASS_NAME}Request) returns (${CLASS_NAME}Response) {}
}

message ${CLASS_NAME}Request {
}

message ${CLASS_NAME}Response {
}
EOL

echo "Creating ${CLASS_NAME} repository"
cat > domain/repository/${SERVICE_NAME}_repository.go <<EOL
package repository

import (
    "gorm.io/gorm"

    "$MODULE_NAME/$SERVICE_NAME/domain/model"
)

type I${CLASS_NAME}Repository interface {
    Find${CLASS_NAME}ByID(uint) (*model.${CLASS_NAME}, error)
    Create${CLASS_NAME}(*model.${CLASS_NAME}) (uint, error)
    Delete${CLASS_NAME}ByID(uint) error
    Update${CLASS_NAME}(*model.${CLASS_NAME}) error
    FindAll() ([]model.${CLASS_NAME}, error)
}

type ${CLASS_NAME}Repository struct {
    db *gorm.DB
}

// create ${CLASS_NAME}Repository
func New${CLASS_NAME}Repository(db *gorm.DB) I${CLASS_NAME}Repository {
    return &${CLASS_NAME}Repository{db}
}

// TODO: implement data access interface
// find ${SERVICE_NAME} by ID
func (r *${CLASS_NAME}Repository) Find${CLASS_NAME}ByID(${SERVICE_NAME}ID uint) (*model.${CLASS_NAME}, error) {
    ${SERVICE_NAME} := &model.${CLASS_NAME}{}
    return ${SERVICE_NAME}, r.db.First(${SERVICE_NAME}, ${SERVICE_NAME}ID).Error
}

// create ${SERVICE_NAME}
func (r *${CLASS_NAME}Repository) Create${CLASS_NAME}(${SERVICE_NAME} *model.${CLASS_NAME}) (uint, error) {
    return ${SERVICE_NAME}.ID, r.db.Create(${SERVICE_NAME}).Error
}

// delete ${SERVICE_NAME} by ID
func (r *${CLASS_NAME}Repository) Delete${CLASS_NAME}ByID(${SERVICE_NAME}ID uint) error {
    return r.db.Where("id = ?", ${SERVICE_NAME}ID).Delete(&model.${CLASS_NAME}{}).Error
}

// update ${SERVICE_NAME}
func (r *${CLASS_NAME}Repository) Update${CLASS_NAME}(${SERVICE_NAME} *model.${CLASS_NAME}) error {
    return r.db.Model(&model.${CLASS_NAME}{}).Where("id = ?", ${SERVICE_NAME}.ID).Updates(${SERVICE_NAME}).Error
}

// get result set
func (r *${CLASS_NAME}Repository) FindAll() ([]model.${CLASS_NAME}, error) {
    ${SERVICE_NAME}All := []model.${CLASS_NAME}{}
    return ${SERVICE_NAME}All, r.db.Find(&${SERVICE_NAME}All).Error
}
EOL

echo "Creating ${CLASS_NAME} data service"
cat > domain/service/${SERVICE_NAME}_data_service.go <<EOL
package service

import (
    "$MODULE_NAME/$SERVICE_NAME/domain/model"
    "$MODULE_NAME/$SERVICE_NAME/domain/repository"
)

type I${CLASS_NAME}DataService interface {
    Add${CLASS_NAME}(data *model.${CLASS_NAME}) (uint, error)
    Delete${CLASS_NAME}(id uint) error
    Update${CLASS_NAME}(data *model.${CLASS_NAME}) error
    Find${CLASS_NAME}ByID(id uint) (*model.${CLASS_NAME}, error)
    FindAll${CLASS_NAME}() ([]model.${CLASS_NAME}, error)
}

type ${CLASS_NAME}DataService struct {
    ${SERVICE_NAME}Repo repository.I${CLASS_NAME}Repository
}

func New${CLASS_NAME}DataService(${SERVICE_NAME}Repo repository.I${CLASS_NAME}Repository) I${CLASS_NAME}DataService {
    return &${CLASS_NAME}DataService{
        ${SERVICE_NAME}Repo: ${SERVICE_NAME}Repo,
    }
}

func (s *${CLASS_NAME}DataService) Add${CLASS_NAME}(data *model.${CLASS_NAME}) (uint, error) {
    return s.${SERVICE_NAME}Repo.Create${CLASS_NAME}(data)
}

func (s *${CLASS_NAME}DataService) Delete${CLASS_NAME}(id uint) error {
    return s.${SERVICE_NAME}Repo.Delete${CLASS_NAME}ByID(id)
}

func (s *${CLASS_NAME}DataService) Update${CLASS_NAME}(data *model.${CLASS_NAME}) error {
    return s.${SERVICE_NAME}Repo.Update${CLASS_NAME}(data)
}

func (s *${CLASS_NAME}DataService) Find${CLASS_NAME}ByID(id uint) (*model.${CLASS_NAME}, error) {
    return s.${SERVICE_NAME}Repo.Find${CLASS_NAME}ByID(id)
}

func (s *${CLASS_NAME}DataService) FindAll${CLASS_NAME}() ([]model.${CLASS_NAME}, error) {
    return s.${SERVICE_NAME}Repo.FindAll()
}
EOL

echo "Creating ${CLASS_NAME} handler"
cat > handler/${SERVICE_NAME}_handler.go <<EOL
package handler

import (
	"context"

	"github.com/tc3oliver/${SERVICE_NAME}/domain/service"
	"github.com/tc3oliver/${SERVICE_NAME}/proto/${SERVICE_NAME}"
)

type ${CLASS_NAME} struct {
	service service.I${CLASS_NAME}DataService
}

func New${CLASS_NAME}(srv service.I${CLASS_NAME}DataService) *${CLASS_NAME} {
	return &${CLASS_NAME}{
		service: srv,
	}
}

func (s *${CLASS_NAME}) Get(ctx context.Context, req *${SERVICE_NAME}.${CLASS_NAME}Request, rsp *${SERVICE_NAME}.${CLASS_NAME}Response) error {
	// TODO: 實現方法邏輯
	return nil
}
EOL

echo "Creating main.go"
cat > main.go <<EOL
package main

import (
    "log"

    "$MODULE_NAME/$SERVICE_NAME/handler"
    "$MODULE_NAME/$SERVICE_NAME/proto/$SERVICE_NAME"
    "$MODULE_NAME/$SERVICE_NAME/domain/model"
    "$MODULE_NAME/$SERVICE_NAME/domain/repository"
    "$MODULE_NAME/$SERVICE_NAME/domain/service"
    "go-micro.dev/v4"
    "go-micro.dev/v4/server"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
    grpcsvr "github.com/go-micro/plugins/v4/server/grpc"
)

func main() {
    // 連接資料庫
    dsn := "host=localhost user=postgres password=mysecretpassword dbname=${SERVICE_NAME} port=5432 sslmode=disable TimeZone=Asia/Taipei"
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if err != nil {
        panic(err)
    }

    // 建立資料表
    err = db.AutoMigrate(&model.${CLASS_NAME}{})
    if err != nil {
        panic(err)
    }

    // 創建資料庫操作對象
    ${SERVICE_NAME}Repo := repository.New${CLASS_NAME}Repository(db)
    ${SERVICE_NAME}Service := service.New${CLASS_NAME}DataService(${SERVICE_NAME}Repo)

    // 創建服務
    service := micro.NewService(
        micro.Name("go.micro.service.${SERVICE_NAME}"),
        micro.Address(":8081"),
        micro.Version("latest"),
        micro.Server(grpcsvr.NewServer(
            server.Address(":8081"),
        )),
    )

    // 初始化服務
    service.Init()

    // 註冊 handler
    ${SERVICE_NAME}.Register${CLASS_NAME}ServiceHandler(service.Server(), handler.New${CLASS_NAME}(${SERVICE_NAME}Service))

    // 啟動服務
    if err := service.Run(); err != nil {
        log.Fatal(err)
    }
}
EOL

echo "Creating proto "
protoc --proto_path=. --micro_out=. --go_out=. ./proto/$SERVICE_NAME/*.proto

echo "Creating Makefile"
cat > Makefile <<EOL
GOPATH:=\$(go env GOPATH)
.PHONY: proto
proto:
	protoc --proto_path=. --micro_out=. --go_out=. ./proto/$SERVICE_NAME/*.proto

.PHONY: build
build: 
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $SERVICE_NAME-service *.go

.PHONY: test
test:
	go test -v ./... -cover

.PHONY: docker
docker:
	docker build . -t $SERVICE_NAME-service:latest

EOL

echo "Creating README.md"
cat > README.md <<EOL
# $SERVICE_NAME

## Overview

$SERVICE_NAME is a microservice developed using go-micro.

## Prerequisites

- Go 1.16 or later
- Protocol Buffers v3
- make

## API

The service provides the following API:

- TODO: 定義 API
EOL

echo "Creating Dockerfile"
cat > Dockerfile <<EOL
FROM alpine
ADD $SERVICE_NAME-service /$SERVICE_NAME-service
ENTRYPOINT [ "/$SERVICE_NAME-service" ]
EOL

echo "Container exiting..."
exit 0