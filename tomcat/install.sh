#!/bin/bash
#set -x

#Versions
VSN_ACTIVEMQ="5.16.3"
VSN_JDK="8.58.0.13-ca-jdk8.0.312"
VSN_TOMCAT="9.0.56"

#Names
NAME_ACTIVEMQ="activemq"
NAME_NOVLUA="novlua"
NAME_TOMCAT="tomcat"

#Directories
DIR_ACTIVEMQ="${NAME_ACTIVEMQ}"
DIR_BACKUP="backup"
DIR_BASE="/opt/netiq/idm/apps"
DIR_COMPRESSED="./compressed"
DIR_JDK="jdk"
DIR_LOG="./logs"
DIR_PRISTINE="./untouched"
DIR_TOMCAT="${NAME_TOMCAT}"

#Files
FILE_ACTIVEMQ="${DIR_COMPRESSED}/apache-activemq-${VSN_ACTIVEMQ}-bin.tar.gz"
FILE_JDK="${DIR_COMPRESSED}/zulu${VSN_JDK}-linux_x64.tar.gz"
FILE_LOG="${DIR_LOG}/IDGov-Core-Helper.log"
FILE_TOMCAT="${DIR_COMPRESSED}/apache-tomcat-${VSN_TOMCAT}.tar.gz"

#Services
SERV_ACTIVEMQ_SERVICE="identity_activemq"
SERV_TOMCAT_SERVICE="identity_tomcat"

#Tee
TEE="tee -a"

#Which Linux
LINUX_VARIETY="$( cat /etc/os-release | grep "^ID=" | sed "s|ID=\"||g" | sed "s|\"||g" )"

# Determine installed features
USAGE_THIS="Usage: ${0##*/} -all|-gov|-base|-tomcat|-activemq|-novlua|-java"


INSTALL_AMQ=""
INSTALL_JDK=""
INSTALL_LOG="true"
INSTALL_WEB=""
INSTALL_WEB_USER=""

while [ $# -gt 0 ]
do
  case $1 in
    '-h'|'-help')
      echo "${USAGE_THIS}"; exit
    ;;
    '-all'|'-gov'|'-idgov')
      INSTALL_AMQ="true"
      INSTALL_JDK="true"
      INSTALL_WEB="true"
      INSTALL_WEB_USER="true"
    ;;
    '-base'|'-tomcat'|'-web')
      INSTALL_JDK="true"
      INSTALL_WEB="true"
      INSTALL_WEB_USER="true"
    ;;
    '-activemq'|'-mail')
      INSTALL_AMQ="true"
      INSTALL_JDK="true"
      INSTALL_WEB_USER="true"
    ;;
    '-java'|'-jdk'|'-jre')
      INSTALL_JDK="true"
      INSTALL_WEB_USER="true"
    ;;
    '-novlua'|'-ua'|'-user')
      INSTALL_WEB_USER="true"
    ;;
    '-useLog')
      INSTALL_LOG=""
      if [ ${2} ]; then
        FILE_LOG=${2}
        shift
      else
        echo -e "Missing log file!\n Using \"${FILE_LOG}\" instead"
      fi
    ;;
    *)
      echo -e "Unrecognized arg \"${1}\"\n${USAGE_THIS}"; exit
    ;;
  esac
  shift
done

if [ -z "${INSTALL_AMQ}" ] && [ -z "${INSTALL_JDK}" ] && [ -z "${INSTALL_WEB}" ] && [ -z "${INSTALL_WEB_USER}" ]; then
  echo -e "Nothing specified for installation!\n${USAGE_THIS}"; exit
fi


activemq_install() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Extracting ActiveMQ to ${DIR_BASE}/${DIR_ACTIVEMQ}:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  mkdir -p "${DIR_BASE}/${DIR_ACTIVEMQ}" 2>&1 | ${TEE} ${FILE_LOG}
  tar -xvf "${FILE_ACTIVEMQ}" -C "${DIR_BASE}/${DIR_ACTIVEMQ}" --strip-components=1 2>&1 | ${TEE} ${FILE_LOG}
  sed -i "s|#JAVA_HOME=\"\"|JAVA_HOME=\"${DIR_BASE}/jre\"|g" "${DIR_BASE}/${DIR_ACTIVEMQ}/bin/env" 2>&1 | ${TEE} ${FILE_LOG}
}

activemq_own() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Recursively assign directory ownerships ${NAME_NOVLUA}.users ${DIR_BASE}/${DIR_ACTIVEMQ}:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  /bin/chown -R ${NAME_NOVLUA}.users "${DIR_BASE}/${DIR_ACTIVEMQ}" 2>&1 | ${TEE} ${FILE_LOG}
}

activemq_service() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Prepare ActiveMQ service, ${SERV_ACTIVEMQ_SERVICE}.service:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  cp "${DIR_PRISTINE}/activemq.service" "./${SERV_ACTIVEMQ_SERVICE}.service"
  sed -i "s|REPLACE_INSTALL_BASE|${DIR_BASE}|g" "${SERV_ACTIVEMQ_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  sed -i "s|REPLACE_INSTALL_JAVA|${DIR_BASE}/${DIR_JDK}|g" "${SERV_ACTIVEMQ_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  sed -i "s|REPLACE_TOMCAT_USER|${NAME_NOVLUA}|g" "${SERV_ACTIVEMQ_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  sed -i "s|REPLACE_VERSION_ACTIVEMQ|${VSN_ACTIVEMQ}|g" "${SERV_ACTIVEMQ_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  mv ${SERV_ACTIVEMQ_SERVICE}.service "/usr/lib/systemd/system/${SERV_ACTIVEMQ_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  if [ "${LINUX_VARIETY}" == "rhel" ]; then
    semanage fcontext --add --type systemd_unit_file_t --seuser system_u "/usr/lib/systemd/system/${SERV_ACTIVEMQ_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
    restorecon -vF "/usr/lib/systemd/system/${SERV_ACTIVEMQ_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  fi
  systemctl enable "${SERV_ACTIVEMQ_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
}

create_base () {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Setting Base Directory of ${DIR_BASE}:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  mkdir -p "${DIR_BASE}" 2>&1 | ${TEE} ${FILE_LOG}
}

jdk_install() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Extracting JDK to ${DIR_BASE}/${DIR_JDK}:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  mkdir -p "${DIR_BASE}/${DIR_JDK}" 2>&1 | ${TEE} ${FILE_LOG}
  tar -xvf ${FILE_JDK} -C "${DIR_BASE}/${DIR_JDK}" --strip-components=1 2>&1 | ${TEE} ${FILE_LOG}

  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Creating symbolic link to ${DIR_BASE}/jre:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  ln -s "${DIR_BASE}/${DIR_JDK}/jre" "${DIR_BASE}/jre" 2>&1 | ${TEE} ${FILE_LOG}
}

jdk_own() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Recursively assign directory ownerships ${NAME_NOVLUA}.users ${DIR_BASE}/${DIR_JDK}:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  /bin/chown -R ${NAME_NOVLUA}.users "${DIR_BASE}/${DIR_JDK}" 2>&1 | ${TEE} ${FILE_LOG}
  /bin/chown -R ${NAME_NOVLUA}.users "${DIR_BASE}/jre" 2>&1 | ${TEE} ${FILE_LOG}
}

log_end () {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "Completed" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "Review the log file at ${FILE_LOG}:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
}

log_start () {
  mkdir -p ${DIR_LOG} >> /dev/null 2>&1
  >${FILE_LOG}
}

owner_definition() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Create Tomcat user and group ${NAME_NOVLUA}:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  groupadd ${NAME_NOVLUA} -r 2>&1 | ${TEE} ${FILE_LOG}
  useradd ${NAME_NOVLUA} -r -m -c "User created by helper script" -s /bin/bash -d ${DIR_BASE}/${NAME_NOVLUA} -g ${NAME_NOVLUA} 2>&1 | ${TEE} ${FILE_LOG}
}

tomcat_activemq_dependency() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Copying the ActiveMQ Jar to ${DIR_BASE}/${DIR_TOMCAT}/lib:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  cp "${DIR_BASE}/${DIR_ACTIVEMQ}/"activemq-all*.jar "${DIR_BASE}/${DIR_TOMCAT}/lib" 2>&1 | ${TEE} ${FILE_LOG}
}

tomcat_disable_ajp_connector() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Disable Tomcat AJP connector within \"${DIR_BASE}/${DIR_TOMCAT}/conf/server.xml\"" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}

  rex_line_01="\(\\s\+<\!-- Define an AJP 1\\.3 Connector on port [0-9]\+ -->\)\(\\s*\)"
  rex_line_02="\(\\s\+\)\(<Connector port=\"[0-9]\+\" protocol=\"AJP/1\\.3\" redirectPort=\"[0-9]\+\"\\s*/>\)\(\\s*\)"
  regex_replace="\\1\\2\\n\\3<!--\\n\\3\\4\\5\\n\\3-->"
  sed -i "\|^${rex_line_01}\$|{
    $!{ N # Append the next line if not the last
      \|^${rex_line_01}\n${rex_line_02}\$|{
        s|^${rex_line_01}\n${rex_line_02}\$|${regex_replace}|g
      }
    }
  }" "${DIR_BASE}/${DIR_TOMCAT}/conf/server.xml" 2>&1 | ${TEE} ${FILE_LOG}
}

tomcat_install() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Extracting Tomcat to ${DIR_BASE}/${DIR_TOMCAT}:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  mkdir -p "${DIR_BASE}/${DIR_TOMCAT}" 2>&1 | ${TEE} ${FILE_LOG}
  tar -xvf "${FILE_TOMCAT}" -C "${DIR_BASE}/${DIR_TOMCAT}" --strip-components=1 2>&1 | ${TEE} ${FILE_LOG}

  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Moving the default Tomcat wars to ${DIR_BASE}/${DIR_BACKUP}:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  mkdir -p "${DIR_BASE}/${DIR_BACKUP}" 2>&1 | ${TEE} ${FILE_LOG}
  mv "${DIR_BASE}/${DIR_TOMCAT}/"webapps/* "${DIR_BASE}/${DIR_BACKUP}" 2>&1 | ${TEE} ${FILE_LOG}

  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Creating new default Tomcat index.html file in ${DIR_BASE}/${DIR_TOMCAT}/webapps/ROOT/index.html:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  mkdir -p "${DIR_BASE}/${DIR_TOMCAT}/webapps/ROOT" 2>&1 | ${TEE} ${FILE_LOG}
  cp "${DIR_PRISTINE}/index.html" "${DIR_BASE}/${DIR_TOMCAT}/webapps/ROOT/index.html" 2>&1 | ${TEE} ${FILE_LOG}

  tomcat_disable_ajp_connector
}

tomcat_own() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Recursively assign directory ownerships ${NAME_NOVLUA}.${NAME_NOVLUA} ${DIR_BASE}/${DIR_TOMCAT}:" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  /bin/chown -R ${NAME_NOVLUA}.${NAME_NOVLUA} "${DIR_BASE}/${DIR_TOMCAT}" 2>&1 | ${TEE} ${FILE_LOG}
}

tomcat_service() {
  echo -e "\n" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e " Prepare Tomcat service, ${SERV_TOMCAT_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  echo -e "######################################################################################" 2>&1 | ${TEE} ${FILE_LOG}
  cp "${DIR_PRISTINE}/tomcat.service" "./${SERV_TOMCAT_SERVICE}.service"
  sed -i "s|REPLACE_INSTALL_TOMCAT|${DIR_BASE}/${DIR_TOMCAT}|g" "${SERV_TOMCAT_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  sed -i "s|REPLACE_INSTALL_JAVA|${DIR_BASE}/${DIR_JDK}|g" "${SERV_TOMCAT_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  sed -i "s|REPLACE_VERSION_TOMCAT|${VSN_TOMCAT}|g" "${SERV_TOMCAT_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  sed -i "s|REPLACE_TOMCAT_USER|${NAME_NOVLUA}|g" "${SERV_TOMCAT_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  sed -i "s|REPLACE_SERVICE_ACTIVEMQ|${SERV_ACTIVEMQ_SERVICE}|g" "${SERV_TOMCAT_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  mv "./${SERV_TOMCAT_SERVICE}.service" "/usr/lib/systemd/system/${SERV_TOMCAT_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  if [ "${LINUX_VARIETY}" == "rhel" ]; then
    semanage fcontext --add --type systemd_unit_file_t --seuser system_u "/usr/lib/systemd/system/${SERV_TOMCAT_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
    restorecon -vF "/usr/lib/systemd/system/${SERV_TOMCAT_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
  fi
  systemctl enable "${SERV_TOMCAT_SERVICE}.service" 2>&1 | ${TEE} ${FILE_LOG}
}

# owner_definition()
#   jdk_install()
#     jdk_own()
#     activemq_install()
#       activemq_own()
#       activemq_service()
#     tomcat_install()
#       tomcat_activemq_dependency() # only when necessary
#       tomcat_own()
#       tomcat_service()

if [ -n "${INSTALL_LOG}" ]; then 
  log_start
fi

create_base

if [ -n "${INSTALL_WEB_USER}" ]; then 
  owner_definition
fi

if [ -n "${INSTALL_JDK}" ]; then
  jdk_install
  jdk_own
fi

if [ -n "${INSTALL_AMQ}" ]; then
  activemq_install
  activemq_own
  activemq_service
fi

if [ -n "${INSTALL_WEB}" ]; then
  tomcat_install
  if [ -n "${INSTALL_AMQ}" ]; then 
    tomcat_activemq_dependency
  fi
  tomcat_own
  tomcat_service
fi

if [ -n "${INSTALL_LOG}" ]; then 
  log_end
fi
