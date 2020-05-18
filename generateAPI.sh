#!/bin/bash

# Parameters
generator=https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.16/swagger-codegen-cli-3.0.16.jar
cli=swagger-codegen-cli.jar
dest=API
destSparky=Sparky
jarName=StudentMgmt-Backend-API
apiURL=http://147.172.178.30:3000/api-json
sparkyURL=http://147.172.178.30:8080/v3/api-docs

# 1: API Source (URL)
# 2: Destination Folder
# 3: POM file to use
maven() {
    # Generate API
    java -jar "$cli" generate -i "$1" -l java -o "$2"

    # Package
    cp -f "$3" "$2"/pom.xml
    cd "$2"
    mvn clean compile source:jar-no-fork package assembly:single
	cd -
}

# Prerequisites
if [ ! -f "$cli" ]; then
    # Download Swagger Code Generator
    wget "$generator" -O "$cli"
fi
rm -r -f "$dest"
rm -r -f "$destSparky"
rm -r -f 'backend_api-1.0.0*.jar'
mkdir "$dest"
mkdir "$destSparky"

##########################
#                        #
# Student Management API #
#                        #
##########################

# Wait until web service is up (see https://stackoverflow.com/a/12748070)
code=0
i=0
while [ $code -ne 200 ] && [ $i -le 30 ]; do
    sleep 1
    code=$(curl -sL -w "%{http_code}\\n" "$apiURL" -o /dev/null)
    i=$((i+1))
done

# Generate API
maven "$apiURL" "$dest" "pom.xml"

# Rename results
mv "$dest"/target/backend_api-1.0.0.jar "${dest}/target/${jarName}.jar"
mv "$dest"/target/backend_api-1.0.0-jar-with-dependencies.jar "${dest}/target/${jarName}-jar-with-dependencies.jar"
mv "$dest"/target/backend_api-1.0.0-sources.jar "${dest}/target/${jarName}-src.jar"

# Delete undesired results
rm -f "$dest"/target/backend_api-1.0.0*.jar

##################
#                #
# Sparky Service #
#                #
##################

# Generate API
maven "$sparkyURL" "$destSparky" "pom-Sparky.xml"