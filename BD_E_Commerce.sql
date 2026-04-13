create database if not exists DB_E_Commerce_DidiStore;
use DB_E_Commerce_DidiStore;

-- ======================================
-- TABLAS DE SEGURIDAD Y USUARIOS
-- ======================================
--  engine=InnoDB default charset=utf8mb4; Esta instrucción SQL define cómo se crea una tabla en MySQL: 
-- utiliza el motor InnoDB para gestionar datos de forma segura (con transacciones) 
-- y establece utf8mb4 como el conjunto de caracteres predeterminado, permitiendo almacenar texto multilingüe y emojis (4 bytes por carácter).

create table Perfiles (
    ID_Perfil int auto_increment primary key, -- Identificador único del perfíl
    Nombre_perfil varchar(100) not null, -- Nombre del rol (Admin, Vendedor y Cliente)
    Descripcion_perfil varchar(100) not null -- Explicación del rol
) engine=InnoDB default charset=utf8mb4;

create table Permisos (
    ID_Permiso int auto_increment primary key, -- ID único del permiso
    Nombre_permiso varchar(100) not null, -- Nombre del permiso (crear, editar y eliminar)
    Descripcion_permiso varchar(100) not null -- Descripción del permiso
) engine=InnoDB default charset=utf8mb4;

-- Tabla intermedia para establecer relación entre perfiles y permisos
create table Perfil_Permiso (
    ID_Perfil int not null, -- Relación muchos a muchos entre perfiles y permisos
    ID_Permiso int not null, -- Relación muchos a muchos entre perfiles y permisos
    primary key (ID_Perfil, ID_Permiso), -- Evita duplicado
    foreign key (ID_Perfil) references Perfiles(ID_Perfil), -- Garantiza integridad referencial
    foreign key (ID_Permiso) references Permisos(ID_Permiso) -- Garantiza integridad referencial
) engine=InnoDB default charset=utf8mb4;

create table Usuarios (
    ID_Usuario int auto_increment primary key, -- Identificador único del usuario
    Email varchar(100) unique not null, -- Correo único del usuario (login)
    Contrasena varchar(255) not null, -- Contraseña (debe almacenarse en hash)
    Nombre varchar(100) not null, -- Datos personales
    Apellido varchar(100) not null, -- Datos personales
    Documento varchar(20) unique not null, -- Identificación única del usuario
    Tipo_Documento enum('CC', 'CE', 'TI', 'Pasaporte') default 'CC', -- Tipo de documento (CC, CE, etc.)
    Perfil_ID int not null, -- Relación con roles
    Estado enum('Activo', 'Inactivo', 'Bloqueado') default 'Activo', -- Estado del usuario (activo, bloqueado)
    Email_verificado boolean default false, -- Indica si verificó el correo
    Fecha_creacion timestamp default (current_timestamp()), -- Auditoría básica
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp, -- Auditoría básica
    Fecha_ultimo_login timestamp null, -- Último acceso
    foreign key (Perfil_ID) references Perfiles(ID_Perfil) 
        on delete restrict
        on update cascade
) engine=InnoDB default charset=utf8mb4;

create table Telefonos (
    ID_Telefono int auto_increment primary key,
    Usuario_ID int not null, -- Relación con usuario
    Tipo enum('Principal', 'Secundario', 'Trabajo', 'Emergencia') default 'Principal', -- Tipo de teléfono
    Numero varchar(20) not null, -- Número telefónico
    Es_verificado boolean default false, -- Validación del número
    Fecha_agregado timestamp default (current_timestamp()), -- Auditoría básica
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete restrict
) engine=InnoDB default charset=utf8mb4;

create table Ciudades (
	ID_Ciudad int auto_increment primary key,
	Nombre_ciudad varchar(100) not null, -- Ciudad que realiza el pedido
    Departamento_ID int not null, -- Relación con departamento
    Codigo_postal varchar(10), -- Código postal opcional
    foreign key (Departamento_ID) references Departamentos(ID_Departamento)
) engine=InnoDB default charset=utf8mb4;

create table Departamentos (
	ID_Departamento int auto_increment primary key, 
    Nombre_departamento varchar(100) not null unique -- Evita departamentos duplicados
) engine=InnoDB default charset=utf8mb4;

create table Direcciones (
	ID_Direccion int auto_increment primary key,
    Direccion varchar(200) not null, -- Dirección principal
    Es_principal boolean default false, -- Indica dirección principal del usuario
    Barrio varchar(100), -- Información adicional
    Referencia varchar(200), -- Información adicional
    Ciudad_ID int not null, -- Relación tabla ciudades
	Usuario_ID int not null, -- Relación tabla de usuarios
    Estado enum('Activa', 'Inactiva') default 'Activa', -- Estado (Activa, Inactiva)
    Fecha_creacion timestamp default current_timestamp(), -- Auditoría básica
    foreign key (Ciudad_ID) references Ciudades(ID_Ciudad),
	foreign key (Usuario_ID) references Usuarios(ID_Usuario)
		on delete cascade
) engine=InnoDB default charset=utf8mb4;

create table Tokens_Recuperacion (
    ID_Token int auto_increment primary key,
    Usuario_ID int not null, -- Relación tabla usuarios
    Token_hash varchar(255) unique not null, -- Token encriptado (seguridad)
    Fecha_creacion timestamp default current_timestamp(), -- Auditoría básica
    Fecha_expiracion timestamp not null, -- Control de validez
    Usado boolean default false, -- Evita reutilización
    Intentos int default 0, -- Control de seguridad
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
		on delete cascade
) engine=InnoDB default charset=utf8mb4;

create table Sesiones (
    ID_Sesion int auto_increment primary key,
    Usuario_ID int not null, -- Relación tabla usuarios
    Token_sesion varchar(255) unique not null, -- Token de autenticación
    Fecha_creacion timestamp default current_timestamp(), -- Auditoría básica
    Fecha_expiracion timestamp not null, -- Tiempo de vida
    IP varchar(45), -- Información del dispositivo
    User_agent varchar(255), -- Información del dispositivo
    Revocada boolean default false, -- Permite invalidar sesión
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
		on delete cascade
) engine=InnoDB default charset=utf8mb4;

-- ======================================
-- TABLAS DE PRODUCTOS E INVENTARIO
-- ======================================

-- Es una relación recursiva o auto-referencia que permite crear jerarquías de categorías. 
-- Por ejemplo, puedo tener 'Pijamas de mujer' como categoría raíz y dentro de ella 'Pijamas Short', 'Accesorios' y 'Aretes', 
-- Complementos y 'Bolsos' etc. 
-- Esto se logra con una FK que apunta a la misma tabla, donde Categoria_padre_ID = NULL indica categorías raíz, 
-- y valores numéricos indican subcategorías.
create table Categorias (
	ID_Categoria int auto_increment primary key, 
    Nombre_categoria varchar(100) not null unique, -- Nombre de la categoría principal
    Descripcion varchar(200), -- Descripción de la categoría principal
    Categoria_padre_ID int, -- Permite jerarquía (subcategorías)
    Fecha_creacion timestamp default (current_timestamp()), --  Auditoría básica
    foreign key (Categoria_padre_ID) references Categorias(ID_Categoria)
) engine=InnoDB default charset=utf8mb4;

create table Productos (
    ID_Producto int auto_increment primary key,
    Nombre_producto varchar(255) not null, -- Nombre del producto que se ofrece
    Descripcion_corta varchar(255) not null, -- Breve descripción del producto
    Descripcion_larga text,  -- Se detalla cuales son las características del producto
    Precio decimal(10,2) not null, -- Precio base del producto
    SKU varchar(50) unique, -- Código único del producto
    Talla enum('XS', 'S', 'M', 'L', 'XL', 'XXL'), -- Características básicas
    Color varchar(50), -- Características básicas
    Categoria_ID int not null, -- Relación con la tabla categorías
    Estado enum('Activo', 'Inactivo', 'Agotado') default 'Activo', -- Disponibilidad
    Es_destacado boolean default false, -- Producto en oferta, nuevo, etc.
    Fecha_creacion timestamp default (current_timestamp()), -- Auditroría básica
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp, -- Auditoría básica
    foreign key (Categoria_ID) references Categorias(ID_Categoria)
) engine=InnoDB default charset=utf8mb4;

create table Imagenes_Productos (
    ID_Imagen int auto_increment primary key, 
    Producto_ID int not null, -- Relación con la tabla de productos
    Url varchar(200) not null, -- Ruta de la imagen 
    Formato varchar(10) not null, -- Tipo de archivo (jpg, png, webp)
    foreign key (Producto_ID) references Productos(ID_Producto)
) engine=InnoDB default charset=utf8mb4;

create table Inventarios (
    ID_Inventario int auto_increment primary key,
    Producto_ID int not null unique, -- Relación con la tabla de productos
    Stock_actual int not null default 0, --  Cantidad disponible
    Stock_minimo int not null default 5, -- Nivel mínimo
    Stock_reservado int not null default 0, -- Productos apartados
    Fecha_creacion timestamp default (current_timestamp()), -- Auditoría básica
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp, -- Auditoría básica
    foreign key (Producto_ID) references Productos(ID_Producto),
    -- Los check validan coherencia del stock
    check (Stock_actual >= 0),
	check (Stock_reservado >= 0),
	check (Stock_reservado <= Stock_actual)
) engine=InnoDB default charset=utf8mb4;

create table Wishlist (
    ID_Wishlist int auto_increment primary key,
    Usuario_ID int not null, -- Realción tabla usuarios
    Producto_ID int not null, -- Relación tabla productos
    unique key (Usuario_ID, Producto_ID),  -- Un producto por usuario, evita duplicados
    foreign key (Usuario_ID) references Usuarios(ID_Usuario),
    foreign key (Producto_ID) references Productos(ID_Producto)
) engine=InnoDB default charset=utf8mb4;

create table Resenas (
    ID_Resena int auto_increment primary key,
    Usuario_ID int not null, -- Relación tabla usuarios
    Producto_ID int not null, -- Relación tabla productos
    Calificacion int not null check (Calificacion between 1 and 5), -- Valoración del producto
    Comentario text, -- Satisfacción del cliente con el producto
    Estado enum('Pendiente', 'Aprobada', 'Rechazada') default 'Pendiente', -- Moderación de reseñas
    unique key (Usuario_ID, Producto_ID),  -- Una reseña por usuario-producto
    foreign key (Usuario_ID) references Usuarios(ID_Usuario),
    foreign key (Producto_ID) references Productos(ID_Producto)
) engine=InnoDB default charset=utf8mb4;

-- ======================================
-- TABLAS DE CARRITO Y PEDIDOS
-- ======================================
-- Justificación Tablas Carrito_Compras e Item_Carrito
-- Las tablas Carrito_Compras e Item_Carrito se relacionan entre sí para gestionar
-- el proceso temporal de selección de productos por parte del usuario.

create table Carrito_Compras (
    ID_Carrito int auto_increment primary key,
    Usuario_ID int unique, -- Permite usuarios logueados y anónimos
    Sesion_ID varchar(100) unique, -- Permite usuarios logueados y anónimos
    Fecha_creacion timestamp not null default (current_timestamp()), -- Auditoría básica
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp, -- Auditoría básica
    Fecha_expiracion timestamp, -- Tiempo que pueden permanecer los productos en el carrito si realizar pedido
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
		on delete cascade,
	-- Obliga a que solo uno exista en el carrito
	check ((Usuario_ID is not null and Sesion_ID is null)
    or (Usuario_ID is null and Sesion_ID is not null))
) engine=InnoDB default charset=utf8mb4;

create table Item_Carrito (
	ID_Item int auto_increment primary key,
	Carrito_ID int not null, -- Relación con la tabla carrito de compras
    Producto_ID int not null, -- Relación tabla productos
    Cantidad int not null, -- Número de productos en el carrito de compras
    Precio_unitario decimal(10,2) not null, -- Valor del precio unitario por producto
    Subtotal decimal(10,2) generated always as (Cantidad * Precio_unitario) stored, --  GENERATED STORED que MySQL calcula automáticamente. 
																					-- Optimiza la visualización del carrito.
    Fecha_agregado timestamp default (current_timestamp()), -- Fecha en que se crea el carrito de compras
		check (Cantidad > 0), -- Validación básica
    unique key (Carrito_ID, Producto_ID),  -- No duplicar
    foreign key (Carrito_ID) references Carrito_Compras(ID_Carrito),
    foreign key (Producto_ID) references Productos(ID_Producto)
		on delete cascade
) engine=InnoDB default charset=utf8mb4;

-- Justicación Tablas Pedidos y Detalles_Pedidos
-- Las tablas Pedidos y Detalles_Pedidos se relacionan para almacenar la
-- información histórica y definitiva de una compra.

create table Pedidos (
    ID_Pedido int auto_increment primary key,
    Numero_pedido varchar(20) unique, -- Identificador visible
	Usuario_ID int not null, -- Relación tabla usuarios
    Direccion_envio_ID int not null, -- Relación tabla direcciones
    Estado_pedido enum('Pendiente_Pago', 'Pagado', 'En_Preparacion', 'Despachado', 'En_Transito', 'Entregado', 'Cancelado', 'Devuelto') default 'Pendiente_Pago', -- La tabla Pedidos guarda el estado actual del pedido.
    Subtotal decimal(10,2) not null, -- Guardo el Subtotal total del pedido para reportes rápidos. 
									 -- Calcular desde Detalles_Pedidos cada vez sería ineficiente en reportes con miles de pedidos.
    Descuento decimal(10,2) default 0.00, -- Snapshot financiero
    IVA decimal(10,2) not null, -- Snapshot financiero
    Costo_envio decimal(10,2) default 0.00, -- Snapshot financiero
    Monto_Total decimal(10,2) not null, -- Snapshot financiero
    Cupon_ID int, -- Relación tabla cupones
    Fecha_pedido timestamp default (current_timestamp()), -- Auditoría básica
		check (Monto_Total >= 0), -- Snapshot financiero.
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete restrict,
	foreign key (Direccion_envio_ID) references Direcciones(ID_Direccion),
    foreign key (Cupon_ID) references Cupones(ID_Cupon)
) engine=InnoDB default charset=utf8mb4;

create table Detalles_Pedidos (
    ID_Detalle int auto_increment primary key,
    Pedido_ID int not null, -- Relación tabla pedidos
    Producto_ID int not null, -- Relación tabla productos
    Cantidad int not null, -- Número de productos 
    Precio_unitario decimal(10,2) not null, -- Precio al momento de compra
    Subtotal decimal(10,2) not null, -- Guardo Precio_unitario y Subtotal como snapshot del momento de la compra. 
									 -- Esto garantiza que pueda regenerar facturas exactas meses después, incluso si los precios cambian.
    check (Cantidad > 0), -- Válidar coherenecia de la cantidad ingresada
	check (Precio_unitario >= 0), -- Válidar coherencia del precio unitario ingresado
    foreign key (Pedido_ID) references Pedidos(ID_Pedido),
    foreign key (Producto_ID) references Productos(ID_Producto)
		on delete cascade
) engine=InnoDB default charset=utf8mb4;

-- La conexión entre el carrito y el pedido no se realiza mediante llaves foráneas,
-- sino a través del proceso de checkout, donde los datos del carrito se copian
-- a Detalles_Pedidos, generando un “snapshot” independiente.
-- Este enfoque garantiza la integridad de los datos, permite eliminar o modificar
-- carritos sin afectar pedidos y mejora el rendimiento del sistema.

-- La tabla Historial_Estados_Pedido guarda el historial de cambios.
create table Historial_Estados_Pedido (
    ID_Historial int auto_increment primary key,
    Pedido_ID int not null, -- Relación tabla pedidos
    Estado_anterior enum('Pendiente_Pago', 'Pagado', 'En_Preparacion', 'Despachado', 'En_Transito', 'Entregado', 'Cancelado', 'Devuelto'),  -- Lo que era antes, control de cambios
    Estado_nuevo enum('Pendiente_Pago', 'Pagado', 'En_Preparacion', 'Despachado', 'En_Transito', 'Entregado', 'Cancelado', 'Devuelto'), -- Lo que es ahora, control de cambios
    Usuario_ID int,  -- Quién cambió el estado 
    Fecha_cambio timestamp default current_timestamp(), -- Auditoría básica
    Notas varchar(500), -- Descripción del pedido
    foreign key (Pedido_ID) references Pedidos(ID_Pedido)
        on delete cascade,
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete set null
) engine=InnoDB default charset=utf8mb4;

-- ======================================
-- TABLAS DE ENVIOS Y PAGOS
-- ======================================

create table Envios (
    ID_Envio int auto_increment primary key,
    Pedido_ID int not null unique, -- Relación tabla pedidos
    Direccion_ID int not null, -- Relación tabla direcciones
    Transportadora enum('Servientrega', 'Coordinadora', 'Deprisa', 'Otro'), -- Empresa de envío
    Numero_guia varchar(100) unique, -- Seguimiento
    Estado enum('Pendiente', 'En Preparación', 'Despachado', 'En Transito', 'En Reparto', 'Entregado', 'Devuelto', 'Rechazado') default 'Pendiente', -- Verificación del estado en que se encuentra el envió
    Fecha_despacho timestamp null, -- Auditoría básica
    Fecha_entrega_estimada timestamp null, -- Auditoría básica
    Fecha_entrega_real timestamp null, -- Auditoría básica
    Observaciones text, -- Descripción de la no entrega del envió
    Fecha_creacion timestamp default (current_timestamp()), -- Auditoría básica
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp, -- Auditoría básica
    foreign key (Pedido_ID) references Pedidos(ID_Pedido),
	foreign key (Direccion_ID) references Direcciones(ID_Direccion)
) engine=InnoDB default charset=utf8mb4;

create table Pagos (
    ID_Pago int auto_increment primary key,
    Pedido_ID int not null unique, -- Relación tabla pedidos
    Metodo_pago enum('Tarjeta Credito', 'Tarjeta Debito', 'PSE', 'Efectivo', 'Transferencia') not null, -- Tipo de pago
    Estado_pago enum('Pendiente', 'En Proceso', 'Aprobado', 'Rechazado', 'Reembolsado', 'Expirado') default 'Pendiente', -- Estado de la transacción
    Monto decimal(10,2) not null, -- Total del pago realizado
    Referencia_transacción varchar(100) unique, -- Número de la transacción realizada por el cliente en la pasarela de pagos
    Referencia_interna varchar(50) unique, -- Número interno de la transacción realizada por el cliente
    Datos_pasarela text, -- Referencia de la pasarela de pagos con la que se realiza el pago
    Fecha_pago timestamp null, -- Auditoría básica
    Fecha_creacion timestamp default (current_timestamp()), -- Auditoría básica
    foreign key (Pedido_ID) references Pedidos(ID_Pedido)
) engine=InnoDB default charset=utf8mb4;

-- ======================================
-- TABLAS DE PROMOCIONES
-- ======================================
-- Son descuentos automáticos que el sistema aplica sin intervención del cliente. 
-- Por ejemplo: 'Todos los pijamas de mujer tienen 20% de descuento esta semana'. 
-- El cliente simplemente navega y ve el precio rebajado.

-- -- Justicación Producto_ID Categoria_ID
-- La tabla Promociones se relaciona con Productos y Categorías para permitir
-- aplicar descuentos de forma flexible, ya sea a un producto específico o a
-- todos los productos de una categoría.
-- Esto mejora la escalabilidad, evita duplicar promociones y facilita la
-- gestión de campañas, alineándose con prácticas reales en sistemas e-commerce.

create table Promociones (
    ID_Promocion int auto_increment primary key,
    Nombre_promocion varchar(100) not null, -- Nombre de la promoción que se realiza en la tienda
    Descripcion varchar(255), -- Breve descripción de la promoción anunciada
    Tipo_descuento enum('Porcentaje', 'Monto Fijo') default 'Porcentaje', -- Porcentaje o valor fijo
    Valor_descuento decimal(10,2) not null, -- Descuento de la rebaja del precio antes y después 
    Producto_ID int null, -- Relación tabla productos alcance del descuento
    Categoria_ID int null, -- Relación tabla categorías alcance del descuento
    Fecha_inicio datetime not null, -- Fecha inicio de la promoción
    Fecha_fin datetime not null, -- Fecha fin de la promoción
    Estado enum('Activo', 'Inactivo', 'Expirado') default 'Activo', -- Vigencia de la promoción
    Aplica_con_otros boolean default false, -- Verificar si la promoción aplica con otras promociones
    Fecha_creacion timestamp default (current_timestamp()), -- Auditoría básica
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp, -- Auditoría básica
    foreign key (Producto_ID) references Productos(ID_Producto),
	foreign key (Categoria_ID) references Categorias(ID_Categoria)
) engine=InnoDB default charset=utf8mb4;

-- Son descuentos que requieren un código que el cliente debe ingresar manualmente en el checkout. 
-- Por ejemplo: 'Usa el código BIENVENIDO10 para obtener 10% de descuento en tu primera compra'.
create table Cupones (
    ID_Cupon int auto_increment primary key,
    Codigo varchar(50) unique not null, -- Código ingresado por usuario
    Tipo_descuento enum('Porcentaje', 'Monto_Fijo'), -- Porcentahe o valor fijo
    Valor_descuento decimal(10,2) not null, -- Descuento después de ingresar el cupón
    Monto_minimo decimal(10,2),  -- Compra mínima requerida
    Cantidad_maxima_usos int, -- Límite de uso
    Cantidad_usos_actuales int default 0, -- Verificar el número de usos del cupón
    Fecha_inicio datetime not null, -- Fecha de inicio del cupón 
    Fecha_fin datetime not null, -- Fecha fin del cupón
    Estado enum('Activo', 'Inactivo') default 'Activo', -- Vigencia del cupón 
    Fecha_creacion timestamp default current_timestamp() -- Auditoría básica
) engine=InnoDB default charset=utf8mb4;

-- ======================================
-- TABLAS DE DEVOLUCIONES
-- ======================================

create table Devoluciones (
    ID_Devolucion int auto_increment primary key,
    Pedido_ID int not null, -- Relación tabla pedidos
    Usuario_ID int not null, -- Relación tabla usuarios
    Motivo enum('Defectuoso', 'Talla_Incorrecta', 'No_Me_Gusto', 'Otro') not null, -- Razón de devolución
    Descripcion text, -- Justificación del motivó de la devolución
    Estado enum('Solicitada', 'Aprobada', 'Rechazada', 'Recolectada', 'Reembolsada') default 'Solicitada', -- Proceso de devolución
    Fecha_solicitud timestamp default current_timestamp(), -- Fecha que el cliente solicita la devolución
    Fecha_resolucion timestamp null, -- Fecha en que se acepta la devolución
    Monto_reembolso decimal(10,2), -- Valor de la devolución 
    foreign key (Pedido_ID) references Pedidos(ID_Pedido),
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
) engine=InnoDB default charset=utf8mb4;

create table Imagenes_Devolucion (
    ID_Imagen int auto_increment primary key,
    Devolucion_ID int not null, -- Relación tabla devoluciones
    Url varchar(200) not null, -- Evidencia visual
    foreign key (Devolucion_ID) references Devoluciones(ID_Devolucion)
) engine=InnoDB default charset=utf8mb4;