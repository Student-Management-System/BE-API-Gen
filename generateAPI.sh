#!/bin/bash

# Parameters
generator=https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.16/swagger-codegen-cli-3.0.16.jar
cli=swagger-codegen-cli.jar
dest=API
jarName=StudentMgmt-Backend-API

# Prerequisites
if [ ! -f "$cli" ]; then
    # Download Swagger Code Generator
    wget $generator -O $cli
fi
rm -r $dest
mkdir $dest

# Generate API
java -jar $cli generate -i http://147.172.178.30:3000/api-json -l java -o $dest

# Package
cp -f pom.xml $dest
cd $dest
mvn clean compile source:jar-no-fork assembly:single

# Rename results
mv target/swagger-java-client-1.0.0-jar-with-dependencies.jar target/${jarName}.jar
mv target/swagger-java-client-1.0.0-sources.jar target/${jarName}-src.jar