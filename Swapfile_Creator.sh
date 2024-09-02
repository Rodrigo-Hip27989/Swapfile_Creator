#!/bin/sh
# -*- ENCODING: UTF-8 -*-

create_swapfile()
{
	local titulo="CREATE - SWAPFILE"
	local opcion_valida="false"
	local swapfile_name="swapfile_v1"
	local swapfile_path="/mnt/swapfiles"
	local swapfile_min_size=0
	local swapfile_max_size=5120
	local swapfile_size=0
	while [ $opcion_valida = "false" ]
	do
	  clear
	  swapfile_size=$(dialog --title "$titulo" \
            --stdout \
				--inputbox "\n\n Ruta del archivo:\n $swapfile_path\n\n Nombre del archivo:\n $swapfile_name\n\n Tamaño maximo permitido:\n $swapfile_max_size (MB)\n\n Tamaño del archivo (MB)" 22 42)
      returncode=$?
      if [[ $returncode = 0 ]]; then
        if [[ ($swapfile_size != *[^0-9]*) && ($swapfile_size != "") ]]; then
          if [[ $swapfile_size -ge $swapfile_min_size && $swapfile_size -le $swapfile_max_size ]]; then
            opcion_valida="true"
				#local created_swapfile=`sudo dd if=/dev/zero of="$swapfile_path/$swapfile_name" bs=1M count=$swapfile_size status=progress`
				local created_swapfile=`sudo fallocate -l ${swapfile_size}M ${swapfile_path}/${swapfile_name}`
				local changed_permissions=`sudo chmod 600 "$swapfile_path/$swapfile_name"`
				local formatted_swapfile=`sudo mkswap "$swapfile_path/$swapfile_name"`
				local activated_swapfile=`sudo swapon "$swapfile_path/$swapfile_name"`
				mensaje=$(dialog --title "$titulo" \
					--stdout \
					--msgbox "\n\n* Detalles:\n\n$formatted_swapfile\n\n" 16 50)
		      returncode=$?
          else
            opcion_valida="false"
				mensaje=$(dialog --title "$titulo" \
					--stdout \
					--msgbox "\nIngrese un valor entre $swapfile_min_size y $swapfile_max_size\n" 10 42)
		      returncode=$?
          fi
        else
          opcion_valida="false"
			 mensaje=$(dialog --title "$titulo" \
					--stdout \
					--msgbox "\nEl valor ingresado tiene que ser numerico\n" 10 42)
		    returncode=$?
        fi
      else
        opcion_valida="true"
		  mensaje=$(dialog --title "$titulo" \
			  --stdout \
		     --msgbox "\nOperación cancelada\n" 10 42)
		  returncode=$?
      fi
    done
	 mensaje=$(dialog --title "$titulo" \
		--stdout \
	   --msgbox "\nPresione una tecla para continuar...\n" 10 42)
	 returncode=$?
}

create_swapfile_notes()
{
  # Comados usados para crear el archivo swapfile	
  #sudo fallocate -l ${swapfile_size}M ${swapfile_path}/${swapfile_name}
  sudo dd if=/dev/zero of=/mnt/swapfiles/swapfile_v1 bs=1M count=3072 status=progress
  sudo chmod 600 /mnt/swapfiles/swapfile_v1
  sudo mkswap /mnt/swapfiles/swapfile_v1
  sudo swapon /mnt/swapfiles/swapfile_v1
}

create_swapfile
