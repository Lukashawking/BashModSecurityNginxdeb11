
# Instalando LEMP 

sudo apt update && sudo apt upgrade
sudo apt install curl -y
curl --version

#Con los siguientes comandos aseguramos de que no exista alguna instalación previa del servidor web Nginx

sudo systemctl stop nginx
sudo apt-get purge nginx -y && sudo apt autoremove nginx -y

#Este comando permite importar desde el repositorio de Nginx la versión estable más reciente.

sudo curl -sSL https://packages.sury.org/nginx-mainline/README.txt | sudo bash -x
sudo curl -sSL https://packages.sury.org/nginx/README.txt | sudo bash -x
sudo apt update

#una vez instalada y actualizada la lista de repositorios, instalamos Nginx con el siguiente comando.

sudo apt install nginx-core nginx-common nginx nginx-full
   
#Agregar el código Fuente de Nginx al repositorio editando
#Repositorio mainline

sudo nano /etc/apt/sources.list.d/nginx-mainline.list

#Agregar la siguiente línea

deb-src https://packages.sury.org/nginx-mainline/ bullseye main

#Repositorio estable

sudo nano /etc/apt/sources.list.d/nginx.list

#Agregar la siguiente línea

deb-src https://packages.sury.org/nginx-mainline/ bullseye main

#Crear la siguiente carpeta y posicionarse dentro

sudo mkdir /usr/local/src/nginx && cd /usr/local/src/nginx

#Asignar los permisos necesarios el comando whoami muestra que usurio esta logueado

sudo chown username:username /usr/local/src/ -R

sudo chown $(whoami):$(whoami) /usr/local/src/ -R

#Instalar las siguientes dependencias

sudo apt install dpkg-dev -y && sudo apt source nginx

#Actualizar lista de repositorios

sudo apt update
sudo apt source nginx

#Verificar la versión de Nginx con el siguiente comando

sudo nginx -v

#Instalar libmodsecurity3 para ModSecurity primeramente, clonar el repositorio de ModSecurity desde Github

sudo apt install git -y
sudo git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /usr/local/src/ModSecurity/

#Una vez clonado el repositorio, con el comando CD nos posicionamos en la carpeta ModSecurity:

cd /usr/local/src/ModSecurity/

#Con el siguiente comando se instalar dependencias de libmodsecurity3 para compilarlo:

sudo apt install gcc make build-essential autoconf automake libtool libcurl4-openssl-dev liblua5.3-dev libfuzzy-dev ssdeep gettext pkg-config  libpcre3 libpcre3-dev libxml2 libxml2-dev libcurl4 libgeoip-dev libyajl-dev doxygen -y

#Asegúrese de instalar los submodulos con el siguiente comando:

sudo git submodule init
sudo git submodule update

#Construyendo el entorno de ambiente para ModSecurity:

sudo ./build.sh
sudo ./configure

#Compilando el código Fuente de ModSecurity:

#sudo make -j 6

#Una vez terminada la compilación, instalar las siguientes librerías.

sudo make install
#Instalar el conector para ModSecurity-nginx:

sudo git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /usr/local/src/ModSecurity-nginx/

#Instalar las dependencias ModSecurity-nginx

cd /usr/local/src/nginx/nginx-1.21.4

#Ahora, ejecutar el comando en la terminal de Debian terminal para instalar las dependencias requerida:

sudo apt build-dep nginx && sudo apt install uuid-dev -y

#Instalar las dependencias de build:

sudo apt build-dep nginx
sudo apt install uuid-dev
sudo ./configure --with-compat --add-dynamic-module=/usr/local/src/ModSecurity-nginx


#Crear módulo dinámico con el siguiente comando:

sudo make modules

#El módulo es guardado como objs/ngx_http_modsecurity_module.so. se necesita copiar estos módulos en el siguiente path /usr/share/nginx/modules/

sudo cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules/

#Cargar y configurar el conector entre ModSecurity-nginx con el servidor web Nginx.

sudo nano /etc/nginx/nginx.conf

#Agregar las siguientes líneas cercanas al inicio del archivo:

 load_module modules/ngx_http_modsecurity_module.so;
	
#Agregar las siguientes líneas de código por debajo HTTP {}

 modsecurity on;
 modsecurity_rules_file /etc/nginx/modsec/main.conf;

#Crear y configurar los archivos y carpetas para ModSecurity

sudo mkdir /etc/nginx/modsec/

#Copiar el archivo de configuración de ModSecurity desde el repositorio clonado desde GIT

sudo cp /usr/local/src/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf


#Editar el siguiente archivo.
#Localizar la línea 7 y editar de esta manera:

SecRuleEngine DetectionOnly

sudo nano /etc/nginx/modsec/modsecurity.conf

 SecRuleEngine DetectionOnly
 SecRuleEngine On


#Localizar la línea 224 y editar de esta manera:

# Log everything we know about a transaction.
SecAuditLogParts ABIJDEFHZ

SecAuditLogParts ABCEFHJKZ




*/ 
    Section	Description
    A	Audit log header (mandatory)
    ---
    B	Request headers
    ----
    C	Request body
    ----
    D	Reserved
    ----
    E	Response body
    ----
    F	Response headers
    ----
    G	Reserved
    ----
    H	Audit log trailer, which contains additional data
    ----
    I	Compact request body alternative (to part C), which excludes files
    ----
    J	Information on uploaded files
    ----
    K	Contains a list of all rules that matched for the transaction
    ----
    Z	Final boundary (mandatory)
    ----
/*

#Crear el siguiente archive el este path /etc/nginx/modsec/main.conf

sudo nano /etc/nginx/modsec/main.conf

#Una vez dentro agregar la siguiente línea

Include /etc/nginx/modsec/modsecurity.conf

#Copiar unicode.mapping a la dirección /etc/nginx/modsec/

sudo cp /usr/local/src/ModSecurity/unicode.mapping /etc/nginx/modsec/


#Realizar un testing de la configuración de Nginx

sudo nginx -t

#Si la configuración es correcta, deberíamos tener la siguiente salida.

nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

#Finalmente reiniciar Nginx para aplicar los cambios realizados.

sudo systemctl restart nginx
sudo systemctl enable nginx
sudo systemctl status nginx

#Instalar OWASP Core Rule Set para ModSecurity

sudo wget https://github.com/coreruleset/coreruleset/archive/v3.3.0.tar.gz 
sudo tar xvf v3.3.0.tar.gz

#Mover y descomprimir las carpetas en la siguiente dirección /etc/nginx/modsec/ path.

sudo mv coreruleset-3.3.0/ /etc/nginx/modsec/

#Renombrar el archivo crs-setup.conf.example como crs-setup.conf

sudo mv /etc/nginx/modsec/coreruleset-3.3.0/crs-setup.conf.example /etc/nginx/modsec/coreruleset-3.3.0/crs-setup.conf

#Habilitar las reglas (rules), abrir el archivo /etc/nginx/modsec/main.conf

sudo nano /etc/nginx/modsec/main.conf

#Una vez dentro agregar las siguiente líneas

Include /etc/nginx/modsec/coreruleset-3.3.0/crs-setup.conf
Include /etc/nginx/modsec/coreruleset-3.3.0/rules/*.conf

#Reiniciar Nginx para aplicar los cambios

sudo systemctl restart nginx

#Abrir el archivo modsecurity.conf

sudo nano /etc/nginx/modsec/modsecurity.conf

#Agregar la siguiente linea justo debajo de SecRuleEngine On

SecRule ARGS:testparam "@contains test" "id:254,deny,status:403,msg:'Test Successful'"

#Puedes configurar tu propia ‘id’ y ‘msg’ tags con tus valores preferidos.

#Guardar y reiniciar Nginx.

sudo systemctl restart nginx

#Con los siguientes Link se puede realizar un Test al servidor modsecurity.

*/
    http://server-ip/?testparam=test
    http://www.yourdomain.com/index.html?exec=/bin/bash
/*

#Con esto puedes comprobar en el logs de Nginx errores para confirmar que el cliente ha sido bloqueado

cat /var/log/nginx/error.log | grep "Test Successful"
