#!/bin/bash
# -*- ENCODING: UTF-8 -*-

main()
{
	local titulo="CREATE - SWAPFILE"
	local opcion_valida="false"
	local swapfile_name="swapfile_v1"
	local swapfile_path="/mnt/swapfiles"
	local swapfile_min_size=0
	local swapfile_max_size=$(df -m . | grep -v Filesystem | awk '{print $4}')
	local swapfile_size=0
	while [ $opcion_valida = "false" ]
	do
	    clear
        input_custom_swapfile_size "$titulo" "\n\n Ruta del archivo:\n $swapfile_path\n\n Nombre del archivo:\n $swapfile_name\n\n Tamaño maximo permitido:\n $swapfile_max_size (MB)\n\n Tamaño del archivo (MB)" 22 42
        if [[ $returncode = 0 ]]; then
        {
            if [[ ($swapfile_size != *[^0-9]*) && ($swapfile_size != "") ]]; then
            {
                if [[ $swapfile_size -ge $swapfile_min_size && $swapfile_size -le $swapfile_max_size ]]; then
                {
                    opcion_valida="true"
                    if [ ! -d "$swapfile_path" ]; then
                    {
                        show_custom_message "$titulo" "\nEl directorio $swapfile_path no existe. ¿Desea proceder?..." 10 42
                        if [[ $returncode = 0 ]]; then
                        {
                            sudo mkdir -p "$swapfile_path"
                            create_swapfile ${swapfile_path} ${swapfile_name} ${swapfile_size}
                        }
                        fi
                    }
                    fi
                }
                else
                {
                    opcion_valida="false"
                    show_custom_message "$titulo" "\nIngrese un valor entre $swapfile_min_size y $swapfile_max_size\n" 10 42
                }
                fi
            }
            else
            {
                opcion_valida="false"
                show_custom_message "$titulo" "\nEl valor ingresado tiene que ser numerico\n" 10 42
            }
            fi
        }
        else
        {
            opcion_valida="true"
            show_custom_message "$titulo" "\nOperación cancelada...\n" 10 42
        }
        fi
    done
    show_custom_message "$titulo" "\nPresione una tecla para continuar...\n" 10 42
}

input_custom_swapfile_size()
{
    local titulo="$1"
    local mensaje_dialog="$2"
    local width="$3"
    local height="$4"
    swapfile_size=$(dialog --title "$titulo" \
        --stdout \
        --inputbox "$mensaje_dialog" "$width" "$height")
    returncode=$?
}

show_custom_message(){
    local titulo="$1"
    local mensaje_dialog="$2"
    local width="$3"
    local height="$4"
    clear
    (dialog --title "$titulo" \
         --stdout \
         --msgbox "$mensaje_dialog" "$width" "$height")
    returncode=$?
}

create_swapfile()
{
    #local created_swapfile=`sudo dd if=/dev/zero of="$swapfile_path/$swapfile_name" bs=1M count=$swapfile_size status=progress`
    sudo fallocate -l ${swapfile_size}M ${swapfile_path}/${swapfile_name}
    sudo chmod 600 "$swapfile_path/$swapfile_name"
    local formatted_swapfile=$(sudo mkswap "$swapfile_path/$swapfile_name")
    sudo swapon "$swapfile_path/$swapfile_name" --priority=100
    show_custom_message "$titulo" "\n\n* Detalles:\n\n$formatted_swapfile\n\n" 16 50
}

main
