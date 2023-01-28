#!/bin/bash
#
# Install and configure Tomcaa, Java, and its dependencies

#######################################
# print error message to STDERR
# Globals:
#   None
# Arguments:
#   ErrorMessage
# Examples:
#   if ! do_something; then
#     err "Unable to do_something"
#     exit 1
#   fi
# Author: Google
#######################################
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

# fail early
if [[ -z "${0%/*}/Zollinstall.properties" ]]; then
  source "${0%/*}/Zollinstall.properties"
else
  err "no ${0%/*}/Zollinstall.properties file found."
  exit 1
fi 

if [[ -n ${PKG_DEPS} ]]
  yum install -y ${PKG_DEPS} && yum update -y
else
  err "no value given for PKG_DEPS"
  exit 1
fi


#######################################
# extracts tomcat tarball
# Globals:
#   None
# Arguments:
#   tarball location
#   root directory for tomcat, jdk, jre
# Examples:
#   None
# Author: Jonathan Zollinger
#######################################
install_tomcat() {

  if [[! -e "${0%/*}/apache-tomcat-${TOMCAT_VERSION}.tar.gz" ]]; then
    if [[ -n "${TOMCAT_TARBALL_URI}" ]]; then
      wget $TOMCAT_TARBALL_URI
    else 
      err "The \$TOMCAT_TARBALL_URI variable is an empty string and no tarball is locally available."
      exit 1
    done
  done

  mkdir -p $TOMCAT_ROOT_DIRECTORY
  tar xfz "${0%/*}/apache-tomcat-${TOMCAT_VERSION}.tar.gz" -C $TOMCAT_ROOT_DIRECTORY --strip-components=1


}