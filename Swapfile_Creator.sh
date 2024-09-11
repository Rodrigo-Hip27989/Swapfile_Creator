#!/bin/bash
# -*- ENCODING: UTF-8 -*-

main()
{
	local titulo="CREATING - SWAPFILE"
	local swapfile_name=""
	local swapfile_path=""
	local swapfile_path_default="/mnt/Swapfiles"
	local swapfile_min_size=1
	local swapfile_max_size=$(df -m . | grep -v Filesystem | awk '{print $4}')
	local swapfile_size=$swapfile_min_size
	local opcion_valida="false"
	while [ $opcion_valida = "false" ]
	do
	    clear
        regex_swapfile_path='^(/[A-Za-z0-9.]+[-A-Za-z0-9_]*)+$'
        swapfile_path=$(input_custom_swapfile_path "$titulo" "\n\n ❯ Ruta del archivo \n\n RegEx: ^(/[A-Za-z0-9.]+[-A-Za-z0-9_]*)+$ \n " 13 48 "$swapfile_path_default")
        if [[ (-n "$swapfile_path") && ("$swapfile_path" =~ $regex_swapfile_path) ]]; then
        {
            regex_swapfile_size='^[0-9]+$'
            swapfile_size=$(input_custom_swapfile_size "$titulo" "\n\n ❯ Ingresar el tamaño (MB) \n\n RegEx: ^[0-9]+$ \n\n Espacio disponible:  $swapfile_max_size (MB) \n " 15 48 "$swapfile_size")
            if [[ (-n "$swapfile_size") && ("$swapfile_size" =~ $regex_swapfile_size) ]]; then
            {
                if [[ $swapfile_size -ge $swapfile_min_size && $swapfile_size -le $swapfile_max_size ]]; then
                {
                    regex_swapfile_name='^[A-Za-z0-9.]+[-A-Za-z0-9_]*$'
                    swapfile_name=$(input_custom_swapfile_name "$titulo" "\n\n ❯ Nombre del archivo \n\n RegEx: ^[A-Za-z0-9.]+[-A-Za-z0-9_]*$ \n " 13 48 "SP-$(date +"%y%m%d-%H%M%S")-$swapfile_size-MB")
                    if [[ (-n "$swapfile_name") && ("$swapfile_name" =~ $regex_swapfile_name) ]]; then
                    {
                        opcion_valida="true"
                        (dialog --title "$titulo" \
                            --stdout \
                            --yesno "\n [ Ruta ]\n ❯ $swapfile_path\n\n [ Nombre ]\n ❯ $swapfile_name\n\n [ Tamaño ]\n ❯ $swapfile_size MB\n\n [ Espacio restante ]\n ❯ $((swapfile_max_size-swapfile_size)) MB\n\n ¿Desea continuar?" 19 42)
                        returncode=$?
                        if [[ $returncode = 0 ]]; then
                        {
                            if [ ! -d "$swapfile_path" ]; then
                            {
                                (dialog --title "$titulo" \
                                    --stdout \
                                    --yesno "\n\n La ruta $swapfile_path no existe !!\n\n ¿Desea crearlo y continuar?" 10 48)
                                returncode=$?
                                if [[ $returncode = 0 ]]; then
                                {
                                    sudo mkdir -p "$swapfile_path"
                                    create_swapfile ${swapfile_path} ${swapfile_name} ${swapfile_size}
                                }
                                else
                                {
                                    show_custom_message "$titulo" "\n\n La creación del swapfile fue cancelada !!\n\n Codigo de error: $?" 10 48
                                    opcion_valida="false"
                                    break
                                }
                                fi
                            }
                            else
                            {
                                create_swapfile ${swapfile_path} ${swapfile_name} ${swapfile_size}
                            }
                            fi
                        }
                        else
                        {
                            show_custom_message "$titulo" "\n\n La creación del swapfile fue cancelada !!\n\n Codigo de error: $?" 10 48
                            opcion_valida="false"
                            break
                        }
                        fi
                    }
                    else
                    {
                        opcion_valida="false"
                        show_custom_message "$titulo" "\n\n El nombre del archivo no es valido!\n" 10 42
                        swapfile_name="SP-$(date +"%y%m%d-%H%M%S")-$swapfile_size-MB"
                    }
                    fi
                }
                else
                {
                    opcion_valida="false"
                    show_custom_message "$titulo" "\n\n Ingrese un valor entre $swapfile_min_size y $swapfile_max_size\n" 10 42
                    swapfile_size=$swapfile_min_size
                }
                fi
            }
            else
            {
                opcion_valida="false"
                show_custom_message "$titulo" "\n\n El valor ingresado tiene que ser numerico!\n" 10 42
                swapfile_size=$swapfile_min_size
            }
            fi
        }
        else
        {
            opcion_valida="false"
            show_custom_message "$titulo" "\n\n La ruta ingresada no es valida!\n" 10 42
            swapfile_path=$swapfile_path_default
        }
        fi
    done
    show_custom_message "$titulo" "\n\n           Hasta pronto" 8 40
}

input_custom_swapfile_name()
{
    local titulo="$1"
    local mensaje_dialog="$2"
    local width="$3"
    local height="$4"
    local default_name="$5"
    swapfile_name=$(dialog --title "$titulo" \
        --stdout \
        --inputbox "$mensaje_dialog" "$width" "$height" "$default_name")
    echo "$swapfile_name"
}

input_custom_swapfile_path()
{
    local titulo="$1"
    local mensaje_dialog="$2"
    local width="$3"
    local height="$4"
    local default_path="$5"
    swapfile_path=$(dialog --title "$titulo" \
        --stdout \
        --inputbox "$mensaje_dialog" "$width" "$height" "$default_path")
    echo "$swapfile_path"
}

input_custom_swapfile_size()
{
    local titulo="$1"
    local mensaje_dialog="$2"
    local width="$3"
    local height="$4"
    local default_size="$5"
    swapfile_size=$(dialog --title "$titulo" \
        --stdout \
        --inputbox "$mensaje_dialog" "$width" "$height" "$default_size")
    echo "$swapfile_size"
}

show_custom_message(){
    local titulo="$1"
    local mensaje_dialog="$2"
    local width="$3"
    local height="$4"
    (dialog --title "$titulo" \
         --stdout \
         --msgbox "$mensaje_dialog" "$width" "$height")
}

create_swapfile()
{
    #local created_swapfile=`sudo dd if=/dev/zero of="$swapfile_path/$swapfile_name" bs=1M count=$swapfile_size status=progress`
    sudo fallocate -l ${swapfile_size}M ${swapfile_path}/${swapfile_name}
    sudo chmod 600 "$swapfile_path/$swapfile_name"
    local formatted_swapfile=$(sudo mkswap "$swapfile_path/$swapfile_name")
    sudo swapon "$swapfile_path/$swapfile_name" --priority=100
    show_custom_message "$titulo" "\n\n ❯ Detalles:\n\n$formatted_swapfile\n\n" 12 55
    local swapon_show=$(swapon --show)
    show_custom_message "$titulo" "\n\n ❯ Dispositivos y/o archivos de swapping:\n\n $swapon_show\n\n" 18 75
}

main