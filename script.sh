#!/bin/bash

# Función para instalar figlet si no está instalado
install_figlet() {
  if ! command -v figlet &> /dev/null; then
    echo "Instalando figlet..."
    sudo apt install figlet
  fi
}

# Función para el menú principal
menu() {
  clear
  echo "===== Menú de Herramientas ======"
  echo "1. Saludo con figlet"
  echo "2. Análisis de logs de Nginx"
  echo "3. Ataque de diccionario con John the Ripper"
  echo "4. Ping y escaneo Nmap"
  echo "5. Exiftool: Ver metadatos"
  echo "6. Wfuzz: Fuzzing web"
  echo "7. Otro saludo con figlet"
  echo "0. Salir"
}

# Análisis avanzado de logs de NGINX
analisis_logs_nginx() {
  echo "===== Análisis avanzado de logs de Nginx ====="
  echo "1. Direcciones IP que han intentado realizar solicitudes a horas poco habituales"
  echo "2. Direcciones IP que han realizado intentos de acceso repetido a recursos inexistentes"
  echo "3. Direcciones IP que realizan un número elevado de solicitudes en un periodo corto"
  echo "4. Accesos a directorios restringidos o sensibles"
  echo "0. Volver al menú principal"
  read -p "Selecciona una opción: " opcion_logs
  case $opcion_logs in
    1)
      read -p "Indica el archivo de logs: " archivo
      awk '$4 !~ /:[0-9]{2}:[0-9]{2}/' $archivo | sort | uniq -c | sort -nr
      read -p "Presiona Enter para continuar..."
      ;;
    2)
      read -p "Indica el archivo de logs: " archivo
      awk '$9 ~ /404/' $archivo | awk '{print $1}' | sort | uniq -c | sort -nr
      read -p "Presiona Enter para continuar..."
      ;;
    3)
      read -p "Indica el archivo de logs: " archivo
      awk '{count[$1]++} END {for (ip in count) if (count[ip] > 100) print ip, count[ip]}' $archivo
      read -p "Presiona Enter para continuar..."
      ;;
    4)
      read -p "Indica el archivo de logs: " archivo
      awk '$7 ~ /\/etc\/passwd|\/var\/|\/proc\//' $archivo | awk '{print $1}' | sort | uniq -c | sort -nr
      read -p "Presiona Enter para continuar..."
      ;;
    0)
      return
      ;;
    *)
      echo "Opción inválida."
      read -p "Presiona Enter para continuar..."
      ;;
  esac
}

# Bucle principal del menú
while true; do
  menu
  read -p "Selecciona una opción: " opcion
  case $opcion in
    1)
      install_figlet
      read -p "Introduce un mensaje: " mensaje
      figlet "$mensaje"
      read -p "Presiona Enter para continuar..."
      ;;
    2)
      analisis_logs_nginx
      ;;
    3)
      read -p "Introduce el hash: " hash
      echo $hash > hash.txt
      hashid -m $hash
      read -p "Indica el algoritmo que se va a usar(raw-md5, raw-sha1, raw-sha256 ...): " algoritmo
      john --wordlist=/usr/share/john/password.lst --format=$algoritmo --rules hash.txt > john.log
      grep "Found" john.log | awk '{print "la contraseña es: "$2}'
      john --show hash.txt --format=$algoritmo | grep -oE '^[^:]*'
      rm hash.txt
      rm john.log
      read -p "Presiona Enter para continuar..."
      ;;
    4)
      read -p "Introduce la red: " redlocal
      fping -g $redlocal | grep -v 'Unreachable'
      read -p "Introduce una IP para escanear con Nmap: " ip
      nmap $ip
      read -p "Presiona Enter para continuar..."
      ;;
    5)
      echo "Exiftool: Ver metadatos"
      echo "1. Metadatos de los ficheros en la ruta del script"
      echo "2. Metadatos en una ruta específica"
      echo "3. Metadatos de un fichero específico"
      read -p "Selecciona una opción: " opcion_exif
      case $opcion_exif in
        1)
          exiftool .
          ;;
        2)
          read -p "Introduce la ruta: " ruta
          exiftool "$ruta"
          ;;
        3)
          read -p "Introduce el archivo: " archivo
          exiftool "$archivo"
          ;;
      esac
      read -p "Presiona Enter para continuar..."
      ;;
    6)
      echo "Wfuzz: Fuzzing web (implementación pendiente)"
      read -p "Presiona Enter para continuar..."
      ;;
    7)
      install_figlet
      figlet "Hasta luego!"
      read -p "Presiona Enter para continuar..."
      ;;
    0)
      echo "Saliendo..."
      exit 0
      ;;
    *)
      echo "Opción inválida."
      read -p "Presiona Enter para continuar..."
      ;;
  esac
done
