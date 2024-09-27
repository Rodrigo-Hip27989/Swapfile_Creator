# Swapfile_Creator

Script de bash para crear un achivo swap.

Se pueden configurar los siguientes valores:

- Ruta
- Nombre
- Tamaño

**Requerimientos:**

Instalación de `dialog` para la interfaz grafica del programa

**Notas:**

- Ejemplo para desactivar el archivo swapfile creado:

> sudo swapoff /mnt/Swapfiles/My_Swapfile

- Ejemplo para volver a activar el archivo swapfile con la prioridad más alta:

> sudo swapon /mnt/Swapfiles/My_Swapfile --pri=100

- Ejemplo para eliminar el archivo swapfile:

> sudo rm /mnt/Swapfiles/My_Swapfile

