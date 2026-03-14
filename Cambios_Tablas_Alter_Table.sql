-- Eliminar campo redundante en Pagos
alter table Pagos drop column Direccion_destino;
-- Hacer Extension opcional en Telefonos
alter table Telefonos modify Extension varchar(10);
-- Hacer Producto_ID y Categoria_ID opcionales en Promociones
alter table Promociones modify Producto_ID int;
alter table Promociones modify Categoria_ID int;
alter table Promociones add constraint chk_promocion_target 
    check (Producto_ID is not null or Categoria_ID is not null);
-- Cambiar Es_principal a boolean en Direcciones
alter table Direcciones drop column Es_principal;
alter table Direcciones add column Es_principal boolean default false;
alter table Direcciones drop column Es_principal;
alter table Direcciones add column Es_principal boolean default false;
-- Agregar unique a Pedido_ID en Pagos y Envios
alter table Pagos drop foreign key Pagos_ibfk_1;
alter table Pagos add unique key (Pedido_ID);
alter table Pagos add foreign key (Pedido_ID) references Pedidos(ID_Pedido) on delete restrict;
alter table Envios drop foreign key Envios_ibfk_1;
alter table Envios add unique key (Pedido_ID);
alter table Envios add foreign key (Pedido_ID) references Pedidos(ID_Pedido) on delete restrict;

-- Mejorar la redacción del campo Estado_pedido
alter table Pedidos drop column Estado_pedido;
alter table Pedidos 
add column Estado_pedido
enum('Pendiente_Pago', 'Pagado', 'En_Preparacion', 'Despachado', 'En_Transito', 'Entregado', 'Cancelado', 'Devuelto') default 'Pendiente_Pago';

-- Modificar campo Estado_anterior
alter table Historial_Estados_pedido 
modify column Estado_anterior
enum('Pendiente_Pago', 'Pagado', 'En_Preparacion', 'Despachado', 'En_Transito', 'Entregado', 'Cancelado', 'Devuelto');
