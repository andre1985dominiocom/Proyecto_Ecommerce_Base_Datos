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
    Documento varchar(100) unique not null,
    Direccion varchar(100) not null,
    Perfil_ID int not null,
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    foreign key (Perfil_ID) references Perfiles(ID_Perfil)
        on delete cascade
        on update cascade
);

alter table Usuarios
drop column Direccion;

create table Telefonos (
    ID_Telefono int auto_increment primary key,
    Numero varchar(50) not null,
    Usuario_ID int not null,
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete cascade
        on update cascade
);

create table Emails (
	ID_Email int auto_increment primary key,
	Email varchar(100) unique not null,
    Usuario_ID int not null,
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
		on delete cascade
		on update cascade
);

create table Direcciones (
	ID_Direccion int auto_increment primary key,
	Direccion varchar(100) not null,
	Usuario_ID int not null,
	foreign key (Usuario_ID) references Usuarios(ID_Usuario)
		on delete cascade 
		on update cascade
);

alter table Direcciones
drop column Ciudad;

create table Ciudades (
	ID_Ciudad int auto_increment primary key,
	Direccion_ID int not null,
	foreign key (Direccion_ID) references Direcciones(ID_Direccion)
		on delete cascade
		on update cascade
);

alter table Ciudades
add Ciudad varchar(100) not null;

alter table Direcciones
add constraint Ciudad_ID
foreign key (Ciudad_ID) references Ciudades(ID_Ciudad);

-- ======================================
-- TABLAS DE PRODUCTOS E INVENTARIO
-- ======================================

create table Productos (
    ID_Producto int auto_increment primary key,
    Nombre_producto varchar(150) not null,
    Descripcion varchar(150) not null,
    Precio decimal(10,2) not null,
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp
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
    Stock_actual int not null,
    Stock_minimo int not null,
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    foreign key (Producto_ID) references Productos(ID_Producto)
        on delete cascade
        on update cascade
);

-- ======================================
-- TABLAS DE CARRITO Y PEDIDOS
-- ======================================

create table Carrito_Compras (
    ID_Carrito int auto_increment primary key,
    Fecha_creacion timestamp not null default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    Usuario_ID int not null,
    ID_Detalle int not null,
    foreign key (Usuario_ID) references Usuarios(ID_Usuario),
    foreign key (ID_Detalle) references Detalles_Pedidos(ID_Detalle)
        on delete cascade
        on update cascade
);

-- create table Item_Carrito (
    -- ID_Item int auto_increment primary key,
    -- Cantidad int not null,
    -- Subtotal decimal(10,2) not null,
    -- Carrito_ID int not null,
    -- Producto_ID int not null,
    -- foreign key (Carrito_ID) references Carrito_Compras(ID_Carrito)
        -- on delete cascade
        -- on update cascade,
    -- foreign key (Producto_ID) references Productos(ID_Producto)
        -- on delete cascade
        -- on update cascade
-- );

create table Pedidos (
    ID_Pedido int auto_increment primary key,
    Fecha_pedido date not null default (current_date()),
    Estado_pedido enum('Entregado', 'En Proceso', 'Pendiente') default 'Pendiente',
    Monto_Total decimal(10,2),
    Usuario_ID int not null,
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        on delete cascade
        on update cascade
);

create table Detalles_Pedidos (
    ID_Detalle int auto_increment primary key,
    Pedido_ID int not null,
    Producto_ID int not null,
    Cantidad int not null,
    Precio_unitario decimal(10,2) not null,
    Subtotal decimal(10,2) not null,
    foreign key (Pedido_ID) references Pedidos(ID_Pedido)
        on delete cascade
        on update cascade,
    foreign key (Producto_ID) references Productos(ID_Producto)
        on delete cascade
        on update cascade
);

alter table Detalles_Pedidos
drop column Subtotal;

alter table Detalles_Pedidos
add constraint ID_Carrito
foreign key (ID_Carrito) references Carrito_Compras(ID_Carrito);

alter table Detalles_Pedidos drop foreign key ID_Carrito;

-- ======================================
-- TABLAS DE ENVIOS Y PAGOS
-- ======================================

create table Envios (
    ID_Envio int auto_increment primary key,
    Direccion_destino varchar(150) not null,
    Ciudad varchar(100) not null,
    Fecha_envio timestamp default (current_timestamp()),
    Fecha_entrega datetime default (current_timestamp()),
    Estado enum('En Proceso', 'Pendiente', 'Entregado', 'Devuelto') default 'Pendiente',
    Pedido_ID int not null,
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacio timestamp default (current_timestamp()) on update current_timestamp,
    foreign key (Pedido_ID) references Pedidos(ID_Pedido)
        on delete cascade
        on update cascade
);

alter table Envios
drop column Ciudad;

alter table Envios
add Direccion_ID int not null;

alter table Envios
add constraint Direccion_ID
foreign key (Direccion_ID) references Direcciones(ID_Direccion);

create table Pagos (
    ID_Pago int auto_increment primary key,
    Estado_pago enum('En Proceso', 'Pendiente', 'Finalizado') default 'Pendiente',
    Referencia_transaccion varchar(50) not null unique,
    Referencia_pasarela varchar(100),
    Pedido_ID int not null,
    Fecha_creacion timestamp default (current_timestamp()),
    foreign key (Pedido_ID) references Pedidos(ID_Pedido)
        on delete restrict
        on update cascade
);

alter table Pagos
drop column Moneda;

alter table Pagos
add constraint Metodo_ID
foreign key (Metodo_ID) references Metodos_Pagos(ID_Metodo);

create table Metodos_Pagos (
	ID_Metodo int auto_increment primary key,
	Metodo_pago enum('Tarjeta_Credito', 'Transferencia', 'Efectivo'),
    Pago_ID int not null,
    foreign key (Pago_ID) references Pagos(ID_Pago)
		on delete restrict
        on update cascade
);

alter table Metodos_Pagos 
drop column Pago_ID;

-- create table Facturas (
    -- ID_Factura int auto_increment primary key,
    -- Pago_ID int not null,
    -- Total_factura decimal(10,2) not null,
    -- Usuario_ID int not null,
    -- foreign key (Pago_ID) references Pagos(ID_Pago)
        -- on delete restrict
        -- on update cascade,
    -- foreign key (Usuario_ID) references Usuarios(ID_Usuario)
        -- on delete restrict
        -- on update cascade
-- );

-- ======================================
-- TABLAS DE PROMOCIONES
-- ======================================

create table Promociones (
    ID_Promocion int auto_increment primary key,
    Nombre_promocion varchar(100) not null,
    Descuento int not null,
    Fecha_inicio datetime not null default current_timestamp(),
    Fecha_fin datetime not null default current_timestamp(),
    Estado enum('Activo', 'Inactivo'),
    Producto_ID int not null,
    Fecha_creacion timestamp default (current_timestamp()),
    Fecha_actualizacion timestamp default (current_timestamp()) on update current_timestamp,
    foreign key (Producto_ID) references Productos(ID_Producto)
        on delete cascade
        on update cascade
);