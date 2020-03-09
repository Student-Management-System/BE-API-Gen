#!/bin/bash

# Parameters
generator=https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.16/swagger-codegen-cli-3.0.16.jar
cli=swagger-codegen-cli.jar
dest=API
jarName=StudentMgmt-Backend-API
apiURL=http://147.172.178.30:3000/api-json

# Prerequisites
if [ ! -f "$cli" ]; then
    # Download Swagger Code Generator
    wget "$generator" -O "$cli"
fi
rm -r "$dest"
mkdir "$dest"

# Wait until web service is up (see https://stackoverflow.com/a/12748070)
code=0
i=0
while [ $code -ne 200 ] && [ $i -le 30 ]; do
    sleep 1
    code=$(curl -sL -w "%{http_code}\\n" "$apiURL" -o /dev/null)
    i=$((i+1))
done

# Generate API
java -jar "$cli" generate -i "$apiURL" -l java -o "$dest"

# Package
cp -f pom.xml "$dest"
cd "$dest"
mvn clean compile source:jar-no-fork package assembly:single

# Rename results
mv target/swagger-java-client-1.0.0.jar "target/${jarName}.jar"
mv target/swagger-java-client-1.0.0-jar-with-dependencies.jar "target/${jarName}-jar-with-dependencies.jar"
mv target/swagger-java-client-1.0.0-sources.jar "target/${jarName}-src.jar"

# Delete undesired results
mv -f target/swagger-java-client-1.0.0*.jar