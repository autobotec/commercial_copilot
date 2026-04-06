# Instrucciones: Despliegue de Commercial Copilot

Esta guía asume que tienes **CyberPanel** corriendo en **AlmaLinux** sobre tu nodo Proxmox, y que configuras tus sitios usando **Nginx** (ya sea como servidor web directo o Proxy Inverso a través de CyberPanel).

## 1. Conectar con GitHub en CyberPanel (Git Manager)

Como solicitaste, la forma de descargar de Github al servidor directamente es con la herramienta Git Manager de CyberPanel.

1. Entra a tu administrador de **CyberPanel**.
2. Ve a **Websites > Create Website**. Crea el dominio de tu aplicación (por ejemplo, `misitio.com`).
3. Ve a **Websites > List Websites** y haz clic en **Manage** en tu nuevo dominio.
4. En el panel de gestión del dominio, busca la herramienta **Git Manager**.
5. Vincula el enlace del [repositorio de GitHub].
   - **Nota**: Si tu repositorio es privado, te dará una clave (Deploy Key) SSH. Cópiala y ponla en Settings > Deploy Keys del repositorio en GitHub para autorizar la conexión.
6. Adjunta el repositorio y CyberPanel clonará los archivos de tu proyecto directamente al directorio `public_html/`.

---

## 2. Configurar y Desplegar (El Script Automatizado)

Dado que subiste al repositorio los archivos `ecosystem.config.js` y `deploy_server.sh`, la compilación la podemos hacer internamente en el servidor en apenas unos pases con PM2 de Node.js:

1. Conéctate a tu servidor AlmaLinux por **SSH**:
   ```bash
   ssh root@TU_IP_SERVIDOR
   ```
2. Navega a la raíz púbica del dominio, donde CyberPanel clonó el proyecto desde Github:
   ```bash
   cd /home/misitio.com/public_html
   ```
3. Ejecuta el archivo que preparamos para ti. Éste se encarga de compilar el Frontend web, moverlo a la ruta de Nginx, e instalar e inicializar el Backend con PM2:
   ```bash
   ./deploy_server.sh
   ```
   **Tip:** En el futuro, cada vez que hagas un cambio de código y lo empujes (push) a Github, puedes entrar a CyberPanel -> Git Manager, sincronizar (pull), y luego simplemente ejecutar de nuevo `./deploy_server.sh` desde el SSH.

---

## 3. Configurar Nginx Reverse Proxy (Redirigir a API Backend)

El **Backend** está corriendo en Node.js dentro del puerto `3000`. Nuestro sitio servirá como web a los usuarios pero necesita comunicarse mediante Nginx con Node.js internamente.

Dependiendo de si instalaste **Nginx directamente como Front Proxy** en CyberPanel o mantienes LiteSpeed (vHost):

### Si usas CyberPanel configurado con Nginx en el Server:
1. En **CyberPanel**, ve a la sección **Manage** del sitio.
2. Encuentra la opción **vHost Conf** (Configuración de host) de **Nginx** o directamente busca la opción **Reverse Proxy** en la lista de opciones de configuración de CyberPanel para redirigir una ruta.
3. Lo que necesitamos es pasar las solicitudes de la ruta `/api` o general al puerto `3000`.
   - Si creaste un subdominio `api.misitio.com`, la regla Nginx a poner dentro de `location / {` es:
   ```nginx
   proxy_pass http://127.0.0.1:3000;
   proxy_http_version 1.1;
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection 'upgrade';
   proxy_set_header Host $host;
   proxy_cache_bypass $http_upgrade;
   ```

4. Recuerda dentro de CyberPanel generar un Certificado **SSL > Manage SSL** para cifrar y volver seguras tanto tu web principal como tu sistema API.
