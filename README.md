# go-micro-service-template

[![Build Status](https://travis-ci.com/example/go-micro-service-template.svg?branch=main)](https://travis-ci.com/example/go-micro-service-template)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A go-micro service template with pre-configured tools and dependencies for quick development.

## Features

- Pre-installed packages and dependencies for building microservices with go-micro.
- A simple shell script to generate new microservices based on the template.
- Support for data access and manipulation with GORM.
- Support for PostgreSQL database.
- RESTful API endpoint with HTTP server and gRPC endpoint with a pluggable gRPC server.
- A Makefile with predefined tasks for building, testing, and deploying microservices.
- A Dockerfile for building and deploying the microservice with Docker.

## Getting Started

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/tc3oliver/go-micro-service-template.git
    ```

2. Run the following command to generate a new microservice:

    ```bash
    docker build -t new-template .
    docker run --rm -v $(pwd):$(pwd) -w $(pwd) new-template github.com/myusername <service-name>
    ```

    Note: When using this command, please replace github.com/myusername with the URL or path of your own version control system.

3. Follow the instructions in the generated README.md file to start developing your microservice.

## Documentation

For more information about go-micro and how to use this template, please refer to the following resources:

- [go-micro Documentation](https://go-micro.dev/docs/)
- [go-micro GitHub Repository](https://github.com/asim/go-micro)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## Contributing

Contributions are always welcome! If you find any issues or bugs in this template, please feel free to open an issue or submit a pull request.

## License

This project is licensed under the terms of the [MIT license](LICENSE).