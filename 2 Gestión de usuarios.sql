CREATE ROLE rol_operaciones_lectura;

GRANT USAGE ON SCHEMA operaciones TO rol_operaciones_lectura;

GRANT
SELECT
    ON ALL TABLES IN SCHEMA operaciones TO rol_operaciones_lectura;

ALTER DEFAULT PRIVILEGES IN SCHEMA operaciones
GRANT
SELECT
    ON TABLES TO rol_operaciones_lectura;

COMMENT ON ROLE rol_operaciones_lectura IS 'Rol con permisos de solo lectura en el esquema operaciones';

CREATE ROLE rol_operaciones_gestion_completa;

GRANT USAGE ON SCHEMA operaciones TO rol_operaciones_gestion_completa;

GRANT
SELECT,
INSERT
,
UPDATE,
DELETE ON ALL TABLES IN SCHEMA operaciones TO rol_operaciones_gestion_completa;

GRANT USAGE,
SELECT
    ON ALL SEQUENCES IN SCHEMA operaciones TO rol_operaciones_gestion_completa;

ALTER DEFAULT PRIVILEGES IN SCHEMA operaciones
GRANT
SELECT,
INSERT
,
UPDATE,
DELETE ON TABLES TO rol_operaciones_gestion_completa;

ALTER DEFAULT PRIVILEGES IN SCHEMA operaciones
GRANT USAGE,
SELECT
    ON SEQUENCES TO rol_operaciones_gestion_completa;

COMMENT ON ROLE rol_operaciones_gestion_completa IS 'Rol con permisos completos de gestión en el esquema operaciones';

-- ============================================================================
-- 2. CREACIÓN DE ROLES PARA EL ESQUEMA ADMINISTRACIÓN
-- ============================================================================

CREATE ROLE rol_administracion_lectura;

GRANT USAGE ON SCHEMA administracion TO rol_administracion_lectura;

GRANT
SELECT
    ON ALL TABLES IN SCHEMA administracion TO rol_administracion_lectura;

ALTER DEFAULT PRIVILEGES IN SCHEMA administracion
GRANT
SELECT
    ON TABLES TO rol_administracion_lectura;

COMMENT ON ROLE rol_administracion_lectura IS 'Rol con permisos de solo lectura en el esquema administracion';

CREATE ROLE rol_administracion_gestion_completa;

GRANT USAGE ON SCHEMA administracion TO rol_administracion_gestion_completa;

GRANT
SELECT,
INSERT
,
UPDATE,
DELETE ON ALL TABLES IN SCHEMA administracion TO rol_administracion_gestion_completa;

GRANT USAGE,
SELECT
    ON ALL SEQUENCES IN SCHEMA administracion TO rol_administracion_gestion_completa;

ALTER DEFAULT PRIVILEGES IN SCHEMA administracion
GRANT
SELECT,
INSERT
,
UPDATE,
DELETE ON TABLES TO rol_administracion_gestion_completa;

ALTER DEFAULT PRIVILEGES IN SCHEMA administracion
GRANT USAGE,
SELECT
    ON SEQUENCES TO rol_administracion_gestion_completa;

COMMENT ON ROLE rol_administracion_gestion_completa IS 'Rol con permisos completos de gestión en el esquema administracion';

-- ============================================================================
-- 3. CREACIÓN DE USUARIOS ESPECÍFICOS
-- ============================================================================

CREATE USER usuario_consultor_operaciones
WITH
    PASSWORD 'ConsultOp2024!';

GRANT rol_operaciones_lectura TO usuario_consultor_operaciones;

COMMENT ON ROLE usuario_consultor_operaciones IS 'Usuario con permisos de consulta en operaciones';

CREATE USER usuario_gestor_operaciones WITH PASSWORD 'GestorOp2024!';

GRANT rol_operaciones_gestion_completa TO usuario_gestor_operaciones;

COMMENT ON ROLE usuario_gestor_operaciones IS 'Usuario con permisos completos en operaciones';

CREATE USER usuario_consultor_admin
WITH
    PASSWORD 'ConsultAdmin2024!';

GRANT rol_administracion_lectura TO usuario_consultor_admin;

COMMENT ON ROLE usuario_consultor_admin IS 'Usuario con permisos de consulta en administracion';

CREATE USER usuario_gestor_admin WITH PASSWORD 'GestorAdmin2024!';

GRANT rol_administracion_gestion_completa TO usuario_gestor_admin;

COMMENT ON ROLE usuario_gestor_admin IS 'Usuario con permisos completos en administracion';

CREATE USER usuario_supervisor WITH PASSWORD 'Supervisor2024!';

GRANT rol_operaciones_gestion_completa TO usuario_supervisor;

GRANT rol_administracion_gestion_completa TO usuario_supervisor;

COMMENT ON ROLE usuario_supervisor IS 'Usuario supervisor con permisos completos en ambos esquemas';

CREATE USER usuario_auditor WITH PASSWORD 'Auditor2024!';

GRANT rol_operaciones_lectura TO usuario_auditor;

GRANT rol_administracion_lectura TO usuario_auditor;

COMMENT ON ROLE usuario_auditor IS 'Usuario auditor con permisos de consulta en ambos esquemas';

-- ============================================================================
-- 4. CONSULTAS DE VERIFICACIÓN
-- ============================================================================

-- Verificar roles creados
SELECT rolname, rolcanlogin
FROM pg_roles
WHERE
    rolname LIKE 'rol_%'
    OR rolname LIKE 'usuario_%'
ORDER BY rolname;

-- Verificar permisos de un usuario específico sobre las tablas
-- Ejemplo: Ver permisos del usuario_gestor_operaciones
SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE
    grantee IN (
        'rol_operaciones_gestion_completa',
        'usuario_gestor_operaciones'
    )
ORDER BY
    table_schema,
    table_name,
    privilege_type;

-- Ver qué roles tiene asignado cada usuario
SELECT r.rolname AS usuario, m.rolname AS rol_asignado
FROM
    pg_roles r
    JOIN pg_auth_members ON r.oid = pg_auth_members.member
    JOIN pg_roles m ON pg_auth_members.roleid = m.oid
WHERE
    r.rolname LIKE 'usuario_%'
ORDER BY r.rolname;

-- ============================================================================
-- 5. COMANDOS DE ADMINISTRACIÓN (Para referencia)
-- ============================================================================

-- Para REVOCAR permisos de un usuario:
-- REVOKE rol_operaciones_lectura FROM usuario_consultor_operaciones;

-- Para ELIMINAR un usuario (primero revocar roles):
-- REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA operaciones FROM usuario_consultor_operaciones;
-- DROP USER usuario_consultor_operaciones;

-- Para MODIFICAR la contraseña de un usuario:
-- ALTER USER usuario_consultor_operaciones WITH PASSWORD 'NuevaContraseña2024!';

-- Para ver todos los permisos de un esquema:
-- SELECT * FROM information_schema.role_table_grants WHERE table_schema = 'operaciones';

-- Para listar todos los usuarios de la base de datos:
-- SELECT usename, usesuper, usecreatedb FROM pg_user;

-- ============================================================================
-- RESUMEN DE LA ESTRUCTURA DE PERMISOS
-- ============================================================================

/*
ROLES CREADOS:
1. rol_operaciones_lectura - Solo SELECT en esquema operaciones
2. rol_operaciones_gestion_completa - SELECT, INSERT, UPDATE, DELETE en esquema operaciones
3. rol_administracion_lectura - Solo SELECT en esquema administracion
4. rol_administracion_gestion_completa - SELECT, INSERT, UPDATE, DELETE en esquema administracion

USUARIOS CREADOS:
1. usuario_consultor_operaciones - Lectura en operaciones
2. usuario_gestor_operaciones - Gestión completa en operaciones
3. usuario_consultor_admin - Lectura en administración
4. usuario_gestor_admin - Gestión completa en administración
5. usuario_supervisor - Gestión completa en ambos esquemas
6. usuario_auditor - Lectura en ambos esquemas

MATRIZ DE PERMISOS:
┌─────────────────────────────┬──────────────┬──────────────────┐
│ Usuario                     │ Operaciones  │ Administración   │
├─────────────────────────────┼──────────────┼──────────────────┤
│ usuario_consultor_operac... │ Lectura      │ Sin acceso       │
│ usuario_gestor_operaciones  │ Completa     │ Sin acceso       │
│ usuario_consultor_admin     │ Sin acceso   │ Lectura          │
│ usuario_gestor_admin        │ Sin acceso   │ Completa         │
│ usuario_supervisor          │ Completa     │ Completa         │
│ usuario_auditor             │ Lectura      │ Lectura          │
└─────────────────────────────┴──────────────┴──────────────────┘
*/