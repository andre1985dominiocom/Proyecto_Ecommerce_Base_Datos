create database if not exists DB_E_Commerce_DidiStore;
use DB_E_Commerce_DidiStore;

-- ======================================
-- TABLAS DE SEGURIDAD Y USUARIOS
-- ======================================

create table Perfiles (
    ID_Perfil int auto_increment primary key,
    Nombre_perfil varchar(100) not null,
    Descripcion_perfil varchar(100) not null
);

create table Permisos (
    ID_Permiso int auto_increment primary key,
    Nombre_permiso varchar(100) not null,
    Descripcion_permiso varchar(100) not null
);

-- Tabla intermedia para establecer relación entre perfiles y permisos
create table Perfil_Permiso (
    ID_Perfil int not null,
    ID_Permiso int not null,
    primary key (ID_Perfil, ID_Permiso),
    foreign key (ID_Perfil) references Perfiles(ID_Perfil)
        on delete cascade
        on update cascade,
    foreign key (ID_Permiso) references Permisos(ID_Permiso)
        on delete cascade
        on update cascade
);

create table Usuarios (
    ID_Usuario int auto_increment primary key,
    Email varchar(100) unique not null,
    Contrasena varchar(255) not null,
    Nombre varchar(100) not null,
    Apellido varchar(100) not null,
    Documento varchar(20) unique not null,
    Tipo_Documento enum('CC', 'CE', 'TI', 'Pasaporte') default 'CC',
    Telefono varchar(20),
    Perfil_ID int not null,
    Estado enum('Activo', 'Inactivo', 'Bloqueado') default 'Activo',
    Email_verificado boolean default false,
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    Fecha_ultimo_login timestamp null,
    foreign key (Perfil_ID) references Perfiles(ID_Perfil)
        on delete restrict
        on update cascade
);

create table Telefonos (
    ID_Telefono int auto_increment primary key,
    Usuario_ID int not null,
    Tipo enum('Secundario', 'Trabajo', 'Emergencia') default 'Secundario',
    Numero varchar(20) not null,
    Extension varchar(10) not null,
    Es_verificado boolean default false,
    Fecha_agregado timestamp default (current_timestamp()),
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete cascade
);

create table Direcciones (
	ID_Direccion int auto_increment primary key,
    Direccion varchar(100) not null,
    Es_principal enum('Si', 'No') default 'Si',
    Barrio varchar(100),
    Referencia varchar(200),
    Ciudad_ID int not null,
	Usuario_ID int not null,
    foreign key (Ciudad_ID) references Ciudades(ID_Ciudad),
	foreign key (Usuario_ID) references Usuarios(ID_Usuario)
);

create table Ciudades (
	ID_Ciudad int auto_increment primary key,
	Nombre_ciudad varchar(100) not null,
    Departamento varchar(100) not null,
    Codigo_postal varchar(10)
);

create table Wishlist (
    ID_Wishlist int auto_increment primary key,
    Usuario_ID int not null,
    Producto_ID int not null,
    Fecha_agregado timestamp default current_timestamp(),
    unique key (Usuario_ID, Producto_ID),  -- Un producto por usuario
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete cascade,
    foreign key (Producto_ID) references Productos(ID_Producto)
        on delete cascade
);

create table Resenas (
    ID_Resena int auto_increment primary key,
    Usuario_ID int not null,
    Producto_ID int not null,
    Calificacion int not null check (Calificacion between 1 and 5),
    Titulo varchar(150),
    Comentario text,
    Estado enum('Pendiente', 'Aprobada', 'Rechazada') default 'Pendiente',
    Fecha_creacion timestamp default current_timestamp(),
    unique key (Usuario_ID, Producto_ID),  -- Una reseña por usuario-producto
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete cascade,
    foreign key (Producto_ID) references Productos(ID_Producto)
        on delete cascade
);

create table Tokens_Recuperacion (
    ID_Token int auto_increment primary key,
    Usuario_ID int not null,
    Token varchar(100) unique not null,
    Fecha_creacion timestamp default current_timestamp(),
    Fecha_expiracion timestamp not null,
    Usado boolean default false,
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete cascade
);

create table Sesiones (
    ID_Sesion int auto_increment primary key,
    Usuario_ID int not null,
    Token_sesion varchar(255) unique not null,
    Fecha_creacion timestamp default current_timestamp(),
    Fecha_expiracion timestamp not null,
    IP varchar(50),
    User_agent varchar(255),
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete cascade
);

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
    Nombre_categoria varchar(100) not null unique,
    Descripcion varchar(200),
    Categoria_padre_ID int,
    Fecha_creacion timestamp default (current_timestamp()),
    foreign key (Categoria_padre_ID) references Categorias(ID_Categoria)
);

create table Productos (
    ID_Producto int auto_increment primary key,
    Nombre_producto varchar(255) not null,
    Descripcion_corta varchar(255) not null,
    Descripcion_larga text,
    Precio decimal(10,2) not null,
    Precio_oferta decimal(10,2),
    SKU varchar(50) unique,
    Talla enum('XS', 'S', 'M', 'L', 'XL', 'XXL'),
    Color varchar(50),
    Categoria_ID int not null,
    Estado enum('Activo', 'Inactivo', 'Agotado') default 'Activo',
    Es_destacado boolean default false,
    Peso decimal(8,2),
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    foreign key (Categoria_ID) references Categorias(ID_Categoria)
);

create table Imagenes (
    ID_Imagen int auto_increment primary key,
    Producto_ID int not null,
    Url varchar(200),
    Formato varchar(50),
    foreign key (Producto_ID) references Productos(ID_Producto)
        on delete cascade
        on update cascade
);

create table Inventarios (
    ID_Inventario int auto_increment primary key,
    Producto_ID int not null,
    Stock_actual int not null default 0,
    Stock_minimo int not null default 5,
    Stock_reservado int not null default 0,
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    foreign key (Producto_ID) references Productos(ID_Producto)
        on delete cascade
);

-- ======================================
-- TABLAS DE CARRITO Y PEDIDOS
-- ======================================

create table Carrito_Compras (
    ID_Carrito int auto_increment primary key,
    Usuario_ID int unique,
    Sesion_ID varchar(100) unique,
    Fecha_creacion timestamp not null default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    Fecha_expiracion timestamp,
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete cascade,
	check (Usuario_ID is not null or Sesion_ID is not null)
);

create table Item_Carrito (
	ID_Item int auto_increment primary key,
	Carrito_ID int not null,
    Producto_ID int not null,
    Cantidad int not null,
    Precio_unitario decimal(10,2) not null,
    Subtotal decimal(10,2) generated always as (Cantidad * Precio_unitario) stored,
    Fecha_agregado timestamp default (current_timestamp()),
    unique key (Carrito_ID, Producto_ID),  -- No duplicar
    foreign key (Carrito_ID) references Carrito_Compras(ID_Carrito)
        on delete cascade,
    foreign key (Producto_ID) references Productos(ID_Producto)
        on delete cascade
);

create table Pedidos (
    ID_Pedido int auto_increment primary key,
    Numero_pedido varchar(20) unique,
	Usuario_ID int not null,
    Direccion_envio_ID int not null,
    Estado_pedido enum('Pendiente_Pago', 'Pagado', 'En_Preparacion', 'Despachado', 'En_Transito', 'Entregado', 'Cancelado', 'Devuelto') default 'Pendiente_Pago', -- La tabla Pedidos guarda el estado actual del pedido.
    Subtotal decimal(10,2) not null,
    Descuento decimal(10,2) default 0.00,
    IVA decimal(10,2) not null,
    Costo_envio decimal(10,2) default 0.00,
    Monto_Total decimal(10,2) not null,
    Cupon_ID int,
    Fecha_pedido timestamp default (current_timestamp()),
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete restrict,
	foreign key (Direccion_envio_ID) references Direcciones(ID_Direccion),
    foreign key (Cupon_ID) references Cupones(ID_Cupon)
);

create table Detalles_Pedidos (
    ID_Detalle int auto_increment primary key,
    Pedido_ID int not null,
    Producto_ID int not null,
    Cantidad int not null,
    Precio_unitario decimal(10,2) not null,
    Subtotal decimal(10,2) not null,
    foreign key (Pedido_ID) references Pedidos(ID_Pedido)
        on delete cascade,
    foreign key (Producto_ID) references Productos(ID_Producto)
        on delete restrict
) engine=InnoDB default charset=utf8mb4;

-- La tabla Historial_Estados_Pedido guarda el historial de cambios.
create table Historial_Estados_Pedido (
    ID_Historial int auto_increment primary key,
    Pedido_ID int not null,
    Estado_anterior enum('Pendiente_Pago', 'Pagado', 'En_Preparacion', 'Despachado', 'En_Transito', 'Entregado', 'Cancelado', 'Devuelto'),  -- 
    Estado_nuevo enum('Recibido', 'Pagado', 'En_Preparacion', 'Despachado', 'En_Transito', 'Entregado', 'Cancelado', 'Devuelto'),
    Usuario_ID int,  -- Quién cambió el estado
    Fecha_cambio timestamp default current_timestamp(),
    Notas varchar(500),
    foreign key (Pedido_ID) references Pedidos(ID_Pedido)
        on delete cascade,
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete set null
);

-- ======================================
-- TABLAS DE ENVIOS Y PAGOS
-- ======================================

create table Envios (
    ID_Envio int auto_increment primary key,
    Pedido_ID int not null,
    Direccion_ID int not null,
    Transportadora enum('Servientrega', 'Coordinadora', 'Deprisa', 'Otro'),
    Numero_guia varchar(100) unique,
    Estado enum('Pendiente', 'En Preparación', 'Despachado', 'En Transito', 'En Reparto', 'Entregado', 'Devuelto', 'Rechazado') default 'Pendiente',
    Fecha_despacho timestamp null,
    Fecha_entrega_estimada timestamp null,
    Fecha_entrega_real timestamp null,
    Observaciones text,
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    foreign key (Pedido_ID) references Pedidos(ID_Pedido)
		on delete restrict,
	foreign key (Direccion_ID) references Direcciones(ID_Direccion)
);

create table Pagos (
    ID_Pago int auto_increment primary key,
    Pedido_ID int not null,
    Metodo_pago enum('Tarjeta Credito', 'Tarjeta Debito', 'PSE', 'Efectivo', 'Transferencia') not null,
    Estado_pago enum('Pendiente', 'En Proceso', 'Aprobado', 'Rechazado', 'Reembolsado', 'Expirado') default 'Pendiente',
    Monto decimal(10,2) not null,
    Direccion_destino varchar(150) not null,
    Referencia_transacción varchar(100) unique,
    Referencia_interna varchar(50) unique,
    Datos_pasarela text,
    Fecha_pago timestamp null,
    Fecha_creacion timestamp default (current_timestamp()),
    foreign key (Pedido_ID) references Pedidos(ID_Pedido)
        on delete restrict
);

-- ======================================
-- TABLAS DE PROMOCIONES
-- ======================================

create table Promociones (
    ID_Promocion int auto_increment primary key,
    Nombre_promocion varchar(100) not null,
    Descripcion varchar(255),
    Tipo_descuento enum('Porcentaje', 'Monto Fijo') default 'Porcentaje',
    Valor_descuento decimal(10,2) not null,
    Producto_ID int not null,
    Categoria_ID int not null,
    Fecha_inicio datetime not null,
    Fecha_fin datetime not null,
    Estado enum('Activo', 'Inactivo', 'Expirado') default 'Activo',
    Aplica_con_otros boolean default false,
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    foreign key (Producto_ID) references Productos(ID_Producto)
        on delete cascade,
	foreign key (Categoria_ID) references Categorias(ID_Categoria)
);

create table Cupones (
    ID_Cupon int auto_increment primary key,
    Codigo varchar(50) unique not null,
    Tipo_descuento enum('Porcentaje', 'Monto_Fijo'),
    Valor_descuento decimal(10,2) not null,
    Monto_minimo decimal(10,2),  -- Compra mínima requerida
    Cantidad_maxima_usos int,
    Cantidad_usos_actuales int default 0,
    Fecha_inicio datetime not null,
    Fecha_fin datetime not null,
    Estado enum('Activo', 'Inactivo') default 'Activo',
    Fecha_creacion timestamp default current_timestamp()
);

-- ======================================
-- TABLAS DE DEVOLUCIONES
-- ======================================

create table Devoluciones (
    ID_Devolucion int auto_increment primary key,
    Pedido_ID int not null,
    Usuario_ID int not null,
    Motivo enum('Defectuoso', 'Talla_Incorrecta', 'No_Me_Gusto', 'Otro') not null,
    Descripcion text,
    Estado enum('Solicitada', 'Aprobada', 'Rechazada', 'Recolectada', 'Reembolsada') default 'Solicitada',
    Fecha_solicitud timestamp default current_timestamp(),
    Fecha_resolucion timestamp null,
    Monto_reembolso decimal(10,2),
    foreign key (Pedido_ID) references Pedidos(ID_Pedido),
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
);

create table Imagenes_Devolucion (
    ID_Imagen int auto_increment primary key,
    Devolucion_ID int not null,
    Url varchar(200) not null,
    foreign key (Devolucion_ID) references Devoluciones(ID_Devolucion)
        on delete cascade
);