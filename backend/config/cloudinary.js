import { v2 as cloudinary } from 'cloudinary';
import { CloudinaryStorage } from 'multer-storage-cloudinary';
import multer from 'multer';
import dotenv from 'dotenv';

dotenv.config();

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

// Storage para Fotos de Perfil
const storagePerfil = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'active_sport_gym/perfiles',
        resource_type: 'auto',
        allowed_formats: ['jpg', 'png', 'jpeg', 'webp']
    }
});

// Storage Dinámico para Ejercicios (Separa automáticamente en carpetas)
const storageEjercicios = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: async (req, file) => {
        if (file.fieldname === 'gif_url') {
            return {
                folder: 'active_sport_gym/ejercicios/videos',
                resource_type: 'auto',
                allowed_formats: ['gif', 'mp4', 'avi', 'webm']
            };
        }

        return {
            folder: 'active_sport_gym/ejercicios/imagenes',
            resource_type: 'image',
            allowed_formats: ['jpg', 'png', 'jpeg', 'webp']
        };
    }
});

// Storage Dinámico para Notificaciones (Eventos, Banners y Promociones)
const storageNotificaciones = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: async (req, file) => {
        return {
            folder: 'active_sport_gym/notificaciones/imagenes',
            resource_type: 'image',
            allowed_formats: ['jpg', 'png', 'jpeg', 'webp']
        };
    }
});

const storageProductos = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: async (req, file) => {
        return {
            folder: 'active_sport_gym/productos',
            resource_type: 'image',
            allowed_formats: ['jpg', 'png', 'jpeg', 'webp']
        };
    }
});

const storageHistorias = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: async (req, file) => {
        return {
            folder: 'active_sport_gym/historias',
            resource_type: 'image',
            allowed_formats: ['jpg', 'png', 'jpeg', 'webp']
        };
    }
});

export const uploadHistoria = multer({
    storage: storageHistorias,
    limits: { fileSize: 10 * 1024 * 1024 } // 10 MB
});

export const uploadPerfil = multer({
    storage: storagePerfil,
    limits: { fileSize: 10 * 1024 * 1024 } // 10 MB
});

export const uploadEjercicio = multer({
    storage: storageEjercicios,
    limits: { fileSize: 50 * 1024 * 1024 } // 50 MB
});

export const uploadProducto = multer({
    storage: storageProductos,
    limits: { fileSize: 10 * 1024 * 1024 } // 10 MB
});

export const uploadNotificacion = multer({
    storage: storageNotificaciones,
    limits: { fileSize: 15 * 1024 * 1024 } // 15 MB
});

export { cloudinary };