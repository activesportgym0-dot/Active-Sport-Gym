# 🏋️ ACTIVE SPORT GYM - SISTEMA DE GESTIÓN Y CATÁLOGO

Aplicación móvil para gestionar el catálogo de productos, membresías, rutinas, usuarios y notificaciones de Active Sport Gym, desarrollada con tecnologías modernas.

---

## 🛠️ Stack Tecnológico

El proyecto utiliza una arquitectura moderna basada en un cliente móvil, un servidor backend y una base de datos en la nube, integrando las siguientes tecnologías:

- Node.js + Express (Backend / API RESTful)
- Supabase (Base de datos PostgreSQL en la nube)
- Flutter (Frontend móvil)
- JWT para el manejo de sesiones

---

## 🚀 Características del Proyecto

### 🔒 1. Autenticación y Seguridad
- Registro e Inicio de Sesión: Autenticación segura para usuarios mediante tokens (JWT).
- Control de Acceso Basado en Roles (RBAC): Vistas y permisos diferenciados para perfiles Cliente y Administrador.
- Protección de Rutas: Middlewares en el backend para restringir el acceso a endpoints sensibles según el rol.
- Gestión de Sesión: Cierre de sesión seguro y expiración automática de credenciales.

### 🛒 2. Catálogo y Notificaciones
- Gestión de Catálogo: Consulta de suplementos, planes de gimnasio y catálogo de productos.
- Sistema de Notificaciones: Consultas y avisos en tiempo real para usuarios y panel de administración.

---

## ⚙️ Instalación y Configuración

npm install

@getbrevo/brevo

@supabase/ssr

@supabase/supabase-js

bcrypt

cloudinary

cors

dotenv

express

jsonwebtoken

multer multer-storage-cloudinary

nodemailer

nodemon


### 1. Clonar el repositorio

git clone (https://github.com/activesportgym0-dot/Active-Sport-Gym.git)

- Instalación de Node.js
- Instalar npm install
- Instalar librería de Node Express
- Instalar librería de Supabase

### 2. Ejecutar el Servidor

npm run dev

---

## 📁 Estructura del Proyecto

active-sport-gym/
├── backend/

│   ├── assets/

│   │   └── images/          # Recursos de imágenes estáticas

│   ├── config/              # Configuración de base de datos y servicios

│   ├── controllers/         # Lógica de controladores (usuarios, productos, notificaciones)

│   ├── middlewares/         # Validación de JWT y roles

│   ├── models/              # Esquemas y modelos de datos

│   ├── node_modules/        # Dependencias de Node.js

│   ├── routes/              # Definición de las rutas de la API

│   ├── uploads/             # Archivos subidos al servidor

│   ├── utils/               # Funciones auxiliares y herramientas

│   ├── .env                 # Variables de entorno

│   ├── .gitignore           # Archivos ignorados por Git

│   ├── index.js             # Punto de entrada del servidor Express

│   ├── package-lock.json    # Árbol de dependencias bloqueado

│   └── package.json         # Configuración del proyecto backend y scripts




---

## 👤 Autor

- Luisa Maria Carvajal Ospina
  - Aprendiz en Desarrollo de Software | Desarrolladora Full-Stack
  - Especialidad: Desarrollo de aplicaciones móviles y web, arquitecturas cliente-servidor e integración de APIs RESTful.
