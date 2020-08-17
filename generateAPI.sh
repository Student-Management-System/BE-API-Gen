#!/bin/bash

# Parameters
generator=https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.21/swagger-codegen-cli-3.0.21.jar
cli=swagger-codegen-cli.jar
dest=API
destSparky=Sparky
configAPI="config-StudentManagement.json"
configSparky="config-Sparky.json"
jarName=StudentMgmt-Backend-API
jarNameSparky=Sparky-API
#apiURL=api-json.json
apiURL=http://147.172.178.30:3000/api-json
sparkyURL=http://147.172.178.30:8080/v3/api-docs

# 1: API Source (URL)
# 2: Destination Folder
# 3: POM file to use
# 4: Config to use (to specify package names)
maven() {
    # Generate API
    java -jar "$cli" generate -i "$1" -l java -o "$2" -c "$4"

    if [[ "$(ls "$2/*.jar" 2>/dev/null | wc -l)" -eq 0 ]]
    then
        echo "Failed to generate API"
        exit 1
    fi

    # Package
    cp -f "$3" "$2"/pom.xml
    cd "$2"
    mvn clean compile source:jar-no-fork package assembly:single install
    cd -
}

# Prerequisites
if [ ! -f "$cli" ]; then
    # Download Swagger Code Generator
    wget "$generator" -O "$cli"
fi
rm -r -f "$dest"
rm -r -f "$destSparky"
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
while [[ $code -ne 200 &&  $i -le 30 ]]; do
    sleep 1
    code=$(curl -sL -w "%{http_code}\\n" "$apiURL" -o /dev/null)
    i=$((i+1))
done

# Generate API
maven "$apiURL" "$dest" "pom.xml" "$configAPI"

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
maven "$sparkyURL" "$destSparky" "pom-Sparky.xml" "$configSparky"

# Rename results
mv "$destSparky"/target/sparkyservice_api-1.0.0.jar "${destSparky}/target/${jarNameSparky}.jar"
mv "$destSparky"/target/sparkyservice_api-1.0.0-jar-with-dependencies.jar "${destSparky}/target/${jarNameSparky}-jar-with-dependencies.jar"
mv "$destSparky"/target/sparkyservice_api-1.0.0-sources.jar "${destSparky}/target/${jarNameSparky}-src.jar"

# Delete undesired results
rm -f "$destSparky"/target/sparkyservice_api-1.0.0*.jar
