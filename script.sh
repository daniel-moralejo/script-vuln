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
  read -p "Selecciona una opción: " opcion
}

# Bucle principal del menú
while true; do
  menu
  case $opcion in
    1)
      install_figlet
      read -p "Introduce un mensaje: " mensaje
      figlet "$mensaje"
      ;;
    2)
      echo "Análisis de logs de Nginx (implementación pendiente)"
      # Aquí deberías implementar la lógica para analizar los logs de Nginx
      ;;
    3)
      read -p "Introduce el hash: " hash
      # Aquí deberías implementar la lógica para identificar el algoritmo y usar John the Ripper
      echo "Ataque de diccionario con John the Ripper (implementación pendiente)"
      ;;
    4)
      fping -g 192.168.1.0/24  # Ajusta la red según tus necesidades
      read -p "Introduce una IP para escanear con Nmap: " ip
      nmap $ip
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
      ;;
    6)
      echo "Wfuzz: Fuzzing web (implementación pendiente)"
      # Aquí deberías implementar la lógica para usar wfuzz
      ;;
    7)
      install_figlet
      figlet "Hasta luego!"
      ;;
    0)
      echo "Saliendo..."
      exit 0
      ;;
    *)
      echo "Opción inválida."
      ;;
  esac
done