FROM tomcat:7.0.72-jre7
MAINTAINER CPF

#add the build time scripts, and run them
ADD build_time /build_time
RUN chmod -R +x /build_time
RUN /build_time/install_packages.sh

#break cache to force docker build to redownload apps every time
#but keep the packages if cached
#ARG CACHE_DATE=not_a_date

RUN /build_time/download_apps.sh
RUN rm -rf /build_time #remove after built, they are not needed for run time

#add the run time scripts, they will run by default when you do 'docker run'
ADD run_time /run_time
RUN chmod -R +x /run_time
CMD ["/run_time/start.sh"]
