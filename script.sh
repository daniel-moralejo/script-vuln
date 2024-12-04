#!/bin/bash

# Funciones de instalación
install_figlet() {
  if ! command -v figlet &> /dev/null; then
    echo "Instalando figlet..."
    sudo apt install figlet
  fi
}

install_cowsay() {
  if ! command -v cowsay &> /dev/null; then
    echo "Instalando figlet..."
    sudo apt install cowsay
  fi
}

install_fping() {
  if ! command -v fping &> /dev/null; then
    echo "Instalando figlet..."
    sudo apt install fping
  fi
}

install_wfuzz() {
  if ! command -v wfuzz &> /dev/null; then
  echo "Instalando wfuzz..."
  sudo apt install wfuzz -y
  fi
}

install_metasploit() {
  if ! command -v msfconsole &> /dev/null; then
    echo "Instalando Metasploit..."
    sudo apt install metasploit_framework
  fi
  }

install_dirbuster() {
  if ! command -v dirbuster &> /dev/null; then
    echo "Instalando DirBuster..."
    sudo apt install dirbuster
  fi
  }

# Función para el menú principal
menu() {
  clear
  toilet --gay -w 150 -f smshadow SCRIPT DE
  toilet --gay -w 150 -f shadow HERRAMIENTAS
  echo "===================================================================================="
  echo "1. Saludo"
  echo "2. Análisis de logs"
  echo "3. Ataque de diccionario"
  echo "4. Fingerprinting"
  echo "5. Footprinting"
  echo "6. Fuzzing web"
  echo "7. Usar Metaesploit"
  echo "0. Salir"
  echo "===================================================================================="
}

# Funcion de analisis de logs
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
      awk '$4 ~ /:0[0-6]:[0-5][0-9]:[0-5][0-9]/' $archivo | sort | uniq -c | sort -nr
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
      awk '$7 ~ /\/etc\/passwd|\/var\/|\/proc\//' $archivo | sort | uniq -c | sort -nr
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

#Funcion de metaesploit
metasploit() {
  read -p "Introduce la IP de la víctima (rhosts): " rhosts
  read -p "Introduce la palabra clave para buscar exploits (mysql, apache, samba...): " service
  read -p "Introduce el puerto (rport): " rport

  echo "Buscando exploits para $service..."
  msfconsole -q -x "search $service; exit" | grep exploit > exploits.txt

  echo "Exploits disponibles para $service:"
  cat exploits.txt
  read -p "Introduce el nombre del exploit a utilizar (ej: exploit/windows/smb/ms17_010_eternalblue): " exploit
  rm exploits.txt

  echo "use $exploit" > metasploit_commands.rc
  echo "set RHOSTS $rhosts" >> metasploit_commands.rc
  echo "set RPORT $rport" >> metasploit_commands.rc
  echo "run" >> metasploit_commands.rc

  echo "Ejecutando Metasploit..."
  msfconsole -r metasploit_commands.rc
  }


# Bucle principal del menú
while true; do
  menu
  read -p "Selecciona una opción: " opcion
  case $opcion in
    1)
      install_cowsay
      cowsay "HOLA QUE TAL"
      read -p "Presiona Enter para continuar..."
      ;;
    2)
      analisis_logs_nginx
      ;;
    3)
      read -p "Introduce el hash: " hash
      echo $hash > hash.txt
      hashid -m $hash
      read -p "Indica el diccionario que quieres usar (por defecto usa /usr/share/john/password.lst): " diccionario
      diccionario=${diccionario:-/usr/share/john/password.lst}

      echo "Selecciona la herramienta para romper el hash:"
      echo "1. John the Ripper"
      echo "2. Hashcat"
      read -p "Selecciona una opcion: " herramienta

      case $herramienta in
        1)
          echo "Usando John the Ripper..."
          read -p "Indica el algoritmo que se va a usar (raw-md5, raw-sha1, raw-sha256 ...): " algoritmo
          john --wordlist=$diccionario --format=$algoritmo --rules hash.txt --fork=8
          john --show hash.txt --format=$algoritmo > john.txt
          echo "-----------CONTRASEÑA------------"
          cat john.txt | grep "?" | awk -F ':' '{print $2}'
          echo "---------------------------------"
          rm john.txt
          ;;
        2)
          echo "Usando Hashcat..."
          read -p "Indica el algoritmo que se va a usar (0, 100, 900, ...): " algoritmo
          hashcat -m $algoritmo -a 0 -o hashcat.txt --remove hash.txt $diccionario
          echo "-----------CONTRASEÑA------------"
          cat hashcat.txt | grep -oP '(?<=:)[^:]*$'
          echo "---------------------------------"
          #rm hashcat.txt
          ;;
        *)
          echo "Opción inválida."
          ;;
      esac

      rm hash.txt
      read -p "Presiona Enter para continuar..."
      ;;

    4)
      read -p "Introduce la red: " redlocal
      fping -g -a $redlocal 2> /dev/null | grep -v 'Unreachable'
      read -p "Introduce una IP para escanear con Nmap: " ip
      read -p "¿Quieres usar un script de Nmap? (si/no): " usar_script

      if [ "$usar_script" == "si" ]; then
        read -p "Elige el script de Nmap a usar (default, vuln, ...): " script
        nmap --script=$script $ip > ${ip}-script.txt
        sed '1,4d' ${ip}-script.txt
      else
        nmap $ip > $ip.txt
        cat $ip.txt | grep -E '^[0-9]+/(tcp|udp).*open'
      fi
      read -p "Presiona Enter para continuar..."
      ;;
    5)
      echo "Exiftool: Ver y Editar metadatos"
      echo "1. Ver metadatos de los ficheros en la ruta del script"
      echo "2. Ver metadatos en una ruta específica"
      echo "3. Ver metadatos de un fichero específico"
      echo "4. Editar metadatos de un fichero específico"
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
        4)
          read -p "Introduce el archivo: " archivo
          echo "------------------------------"
          exiftool $archivo | awk -F ':' 'NR > 1 {print $1}'
          echo "------------------------------"
          read -p "Introduce un campo de los de arriba para editar: " campo
          read -p "Introduce el nuevo valor: " valor
          exiftool -"$campo"="$valor" "$archivo"
          echo "Metadatos actualizados para el archivo $archivo."
          ;;
        *)
          echo "Opción inválida."
          ;;
      esac
      read -p "Presiona Enter para continuar..."
      ;;

    6)
      echo "Escaneo de Directorios"
      echo "1. Utilizar Wfuzz"
      echo "2. Utilizar DirBuster(interfaz gráfica)"
      ceho "0. Volver al menú"
      read -p "Selecciona una opción: " opcion_fuzz

      case $opcion_fuzz in
      1)
      install_wfuzz
      read -p "Introduce la URL o dirección IP a escanear con Wfuzz: " url
      wfuzz -c -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt --hc 404 -u $url/FUZZ > wfuzz.txt
      cat wfuzz.txt
      ;;
      2)
      install_dirbuster
      read -p "Introduce la URL o dirección IP a escanear con DirBuster: " url
      dirbuster -u $url -l /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
      cat dirbuster.txt
      ;;
      0)
      return
      ;;
      *)
      echo "Opción inválida."
      ;;
      esac
      read -p "Presiona Enter para continuar..."
      ;;
    7)
      metasploit
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
