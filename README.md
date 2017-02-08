# openlmis-training
Localised training environment setup for OpenLMIS 2.0

## Development

To build new image, run `docker build build-openlmis-localised/ -t lmistrainingapp/openlmis-localised --no-cache`
To publish new image, run `docker push lmistrainingapp/openlmis-localised`

## Run localised training environment

Put a dump data file 'dumpForTraining.sql' in to the project folder.
To run the localised environment, run `./run_training_app.sh`

On Windows, run double click the file run_training_app.bat.

Open browser, you can see the web portal running on http://localhost:8080