select p.Nombre_Categoria as "Categoría Padre",
h.Nombre_categoria as "Subcategoría"
from categorias h
left join categorias p on h.Categoria_padre_ID = p.ID_Categoria
order by p.Nombre_categoria
limit 0, 1000;

select * from categorias;

set foreign_key_checks = 0;
truncate table categorias;
set foreign_key_checks = 1;

select ID_Categoria, Nombre_categoria, categoria_padre_Id from categorias;

describe categorias;

-- 1. Desactivar revisión de llaves
SET FOREIGN_KEY_CHECKS = 0;

-- 2. Limpiar la tabla por completo
TRUNCATE TABLE categorias;

-- 3. Insertar manualmente para probar la DB
INSERT INTO categorias (Nombre_categoria, Descripcion, Categoria_padre_ID) 
VALUES ('Prueba Raiz', 'Test', NULL);

-- 4. Insertar un hijo (usa el ID 1 si es el primero que generó arriba)
INSERT INTO categorias (Nombre_categoria, Descripcion, Categoria_padre_ID) 
VALUES ('Prueba Hijo', 'Test', 1);

-- 5. Ver si el hijo realmente guardó el "1"
SELECT * FROM categorias;

-- 6. Reactivar revisión
SET FOREIGN_KEY_CHECKS = 1;

SELECT 
    hijo.ID_Categoria AS ID,
    hijo.Nombre_categoria AS Subcategoria,
    padre.Nombre_categoria AS Es_Hija_De
FROM categorias hijo
LEFT JOIN categorias padre ON hijo.Categoria_padre_ID = padre.ID_Categoria;

insert into envios (Pedido_ID, Direccion_ID, Transportadora, Numero_Guia, Estado, Observaciones)
values ("Servientrega", "SEV012", "En Preparación", "Pedido en proceso de despacho");

