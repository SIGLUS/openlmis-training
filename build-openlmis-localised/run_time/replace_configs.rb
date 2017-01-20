# add pg credentials to bashrc so the start script of CUBES will pick them up and replace them
pg_credentials=["POSTGRES_USER_NAME="+ENV["POSTGRES_USER"],
                "POSTGRES_PASSWORD="+ENV["POSTGRES_PASSWORD"],
                "POSTGRES_HOST="+ENV["POSTGRES_HOST"]]

File.open("/root/.bashrc", 'w') { |file| file.write(pg_credentials.join("\n")) }

# add pg credentials to properties file so that OPENLMIS can access db
lines=File.readlines("/usr/local/tomcat/extra_properties/default.properties")
linesWithCredentials=lines.map { |line|
  if line["openlmis.jdbc.url="]
    puts "replacing sql connection string"
    "openlmis.jdbc.url=jdbc:postgresql://"+ENV["POSTGRES_HOST"]+":5432/open_lmis"
  elsif line["openlmis.jdbc.username="]
    puts "replacing user name"
    "openlmis.jdbc.username="+ENV["POSTGRES_USER"]
  elsif line["openlmis.jdbc.password="]
    puts "replacing password"
    "openlmis.jdbc.password="+ENV["POSTGRES_PASSWORD"]
  else
    line
  end
}
File.open("/usr/local/tomcat/extra_properties/default.properties", "w+") do |f|
  linesWithCredentials.each { |element| f.puts(element) }
end

lines=File.readlines("/usr/local/tomcat/extra_properties/app.properties")
linesToReplace=lines.map { |line|
  if line["app.url"]
    "app.url=http://localhost:8080"
  else
    line
  end
}
File.open("/usr/local/tomcat/extra_properties/app.properties", "w+") do |f|
  linesToReplace.each { |element| f.puts(element) }
end