#!/bin/bash
generator=https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.16/swagger-codegen-cli-3.0.16.jar
dest=API

# Prerequisites
wget $generator -O swagger-codegen-cli.jar
mkdir $dest

# Generate API
java -jar swagger-codegen-cli.jar generate -i http://147.172.178.30:3000/api-json -l java -o $dest

# Package
cd $dest
mvn clean compile assembly:single