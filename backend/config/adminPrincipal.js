// ADMINISTRADOR PRINCIPAL
// Es la cuenta que manda sobre todas: soporte del gimnasio. Solo ella puede cambiar roles
// (volver administrador a alguien o quitárselo), y nadie más puede quitarle el rol,
// desactivarla ni eliminarla.
// Se identifica por su correo. Si algún día cambia, se puede definir ADMIN_PRINCIPAL_CORREO en el .env.
export const CORREO_ADMIN_PRINCIPAL = (
    process.env.ADMIN_PRINCIPAL_CORREO || "activesportgym0@gmail.com"
).trim().toLowerCase();

export const esAdminPrincipal = (correo) =>
    String(correo || "").trim().toLowerCase() === CORREO_ADMIN_PRINCIPAL;
