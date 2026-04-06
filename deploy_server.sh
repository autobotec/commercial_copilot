#!/bin/bash

# Script de despliegue para Commercial Copilot (AlmaLinux + CyberPanel + Nginx)
# Ejecutar en el servidor después de hacer un 'git pull'

echo "================================================"
echo "  Desplegando Commercial Copilot (CyberPanel)"
echo "================================================"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Actualizar código desde GitHub
echo -e "${YELLOW}1. Actualizando código desde GitHub...${NC}"
git pull origin main

# Frontend
echo -e "${YELLOW}2. Compilando Frontend...${NC}"
cd frontend
npm install
npm run build
cd ..

# Despliegue de estáticos
echo -e "${YELLOW}3. Moviendo archivos del frontend la raíz pública...${NC}"
cp -R frontend/dist/* .

# Backend
echo -e "${YELLOW}4. Instalando dependencias del Backend...${NC}"
cd backend
npm install
cd ..

# PM2
echo -e "${YELLOW}5. Reiniciando servicio de Backend (PM2)...${NC}"
pm2 restart ecosystem.config.js || pm2 start ecosystem.config.js
pm2 save

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ✓ Despliegue completado con éxito${NC}"
echo -e "${GREEN}================================================${NC}"
