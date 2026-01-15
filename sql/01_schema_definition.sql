USE master; 

CREATE DATABASE Gestion_Flota_Vehiculos;

GO

USE Gestion_Flota_Vehiculos;
GO

--1) Tablas Maestras (sin dependencias)
CREATE TABLE Marcas (
    ID_Marca INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(40) UNIQUE NOT NULL
);

CREATE TABLE Tipo_Mantenimiento (
    ID_Tipo_Mantenimiento INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) UNIQUE
);

CREATE TABLE Motivo_Mantenimiento (
    ID_Motivo_Mantenimiento INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) UNIQUE 
);

CREATE TABLE Tipo_Combustible (
    ID_Tipo_Combustible INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Tipo_Vehiculo (
    ID_Tipo_Vehiculo INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Gerencia (
    ID_Gerencia INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) UNIQUE NOT NULL
   );


-- 2) Nivel 1: Dependencias Simples
CREATE TABLE Categoria_Vehiculo (
    ID_Categoria_Vehiculo INT PRIMARY KEY IDENTITY(1,1),
    ID_Tipo_Vehiculo INT,
    Nombre VARCHAR(50) UNIQUE NOT NULL,
    FOREIGN KEY (ID_Tipo_Vehiculo) REFERENCES Tipo_Vehiculo(ID_Tipo_Vehiculo)
);

CREATE TABLE Modelos (
    ID_Modelo INT PRIMARY KEY IDENTITY(1,1),
    ID_Marca INT NOT NULL,
    ID_Tipo_Vehiculo INT NOT NULL,
    Nombre VARCHAR(40) UNIQUE NOT NULL,
    KM_litro_min DECIMAL(10,2),
    KM_litro_max DECIMAL(10,2),
    FOREIGN KEY (ID_Marca) REFERENCES Marcas(ID_Marca),
    FOREIGN KEY (ID_Tipo_Vehiculo) REFERENCES Tipo_Vehiculo(ID_Tipo_Vehiculo)
);

CREATE TABLE Area (
    ID_Area INT PRIMARY KEY IDENTITY(1,1),
    ID_Gerencia INT,
    Nombre VARCHAR(100),
    FOREIGN KEY (ID_Gerencia) REFERENCES Gerencia(ID_Gerencia)
);

CREATE TABLE Ubicacion_Tecnica (
    ID_Ubicacion_Tecnica INT PRIMARY KEY IDENTITY(1,1),
    ID_Area INT,
    Nombre VARCHAR(100),
    FOREIGN KEY (ID_Area) REFERENCES Area(ID_Area)
);

-- 3) Nivel 2: Entidad Principal


CREATE TABLE Vehiculos (
    ID_Vehiculo INT PRIMARY KEY IDENTITY(1,1),
    EQUIPO INT,
    ID_Modelo INT,
    ID_Ubicacion_Tecnica INT,
    ID_Categoria_Vehiculo INT,
    ID_Tipo_Combustible_1 INT,
    ID_Tipo_Combustible_2 INT,
    Patente VARCHAR(12) NOT NULL,
    Ano INT,
    FOREIGN KEY (ID_Modelo) REFERENCES Modelos(ID_Modelo),
    FOREIGN KEY (ID_Ubicacion_Tecnica) REFERENCES Ubicacion_Tecnica(ID_Ubicacion_Tecnica),
    FOREIGN KEY (ID_Categoria_Vehiculo) REFERENCES Categoria_Vehiculo(ID_Categoria_Vehiculo),
    FOREIGN KEY (ID_Tipo_Combustible_1) REFERENCES Tipo_Combustible(ID_Tipo_Combustible),
    FOREIGN KEY (ID_Tipo_Combustible_2) REFERENCES Tipo_Combustible(ID_Tipo_Combustible)

);

-- 4) Nivel 3: Transaccionales
CREATE TABLE Ordenes_Mantenimiento (
    ID_Orden INT PRIMARY KEY IDENTITY(1,1),
    ID_Vehiculo INT,
    ID_Tipo_Mantenimiento INT,
    ID_Motivo_Mantenimiento INT,
    FECHA DATETIME,
    Lectura_KM DECIMAL(12,2),
    Nivel_Tanque_Porcentaje DECIMAL (5,2),
    Importe DECIMAL(18,2), 
    Detalle VARCHAR(500),
    FOREIGN KEY (ID_Vehiculo) REFERENCES Vehiculos(ID_Vehiculo),
    FOREIGN KEY (ID_Tipo_Mantenimiento) REFERENCES Tipo_Mantenimiento(ID_Tipo_Mantenimiento),
    FOREIGN KEY (ID_Motivo_Mantenimiento) REFERENCES Motivo_Mantenimiento(ID_Motivo_Mantenimiento)

);

CREATE TABLE Cargas_Combustible (
    ID_Carga INT PRIMARY KEY IDENTITY(1,1),
    ID_Vehiculo INT NOT NULL,
    ID_Tipo_Combustible INT,
    Fecha DATETIME NOT NULL,
    Lectura_KM DECIMAL(12,2),
    Nivel_Tanque_Porcentaje DECIMAL (5,2),
    Litros_Cargados DECIMAL(18,2),
    Importe DECIMAL(18,2),
    FOREIGN KEY (ID_Vehiculo) REFERENCES Vehiculos(ID_Vehiculo),
    FOREIGN KEY (ID_Tipo_Combustible) REFERENCES Tipo_Combustible(ID_Tipo_Combustible)
);

CREATE TABLE Auditoria(
    ID_Auditoria INT PRIMARY KEY IDENTITY(1,1),
    ID_Vehiculo INT NOT NULL,
    Fecha DATETIME NOT NULL,
    Lectura_KM DECIMAL(12,2) NOT NULL,
    Nivel_Tanque_Porcentaje DECIMAL (5,2),
    Observaciones VARCHAR(255),
    FOREIGN KEY (ID_Vehiculo) REFERENCES Vehiculos(ID_Vehiculo)
    );

  CREATE TABLE Detalle_Gastos_Anual(
    ID_Detalle_Gastos_Anual INT PRIMARY KEY IDENTITY(1,1),
    ID_Vehiculo INT NOT NULL,
    ANO DATE NOT NULL,
    Gasto_Neto_Mantenimiento MONEY,
    Cantidad_Ordenes_Mantenimiento INT,
    Gasto_Combustible MONEY,
    Cantidad_Cargas_Combustible INT,
    KM_Recorridos DECIMAL(12,2),
    FOREIGN KEY (ID_Vehiculo) REFERENCES Vehiculos(ID_Vehiculo)
    );

--5) Vistas
CREATE VIEW Vista_Detalle_Vehiculos AS

SELECT 
	v.ID_Vehiculo,
	v.Patente,
	v.Ano AS Año,
	mo.Nombre AS Modelo,
	mo.KM_litro_min,
	mo.KM_litro_max,
	ma.Nombre AS Marca,
	cv.Nombre AS Categoria_Vehiculo,
	tv.Nombre AS Tipo_Vehiculo,
	ut.Nombre AS Ubicacion_Tecnica,
	ar.Nombre AS Area,
	ge.Nombre AS Gerencia,
	tc1.Nombre AS Combustible1,
	tc2.Nombre AS Combustible2


FROM Vehiculos v
JOIN Modelos mo ON v.ID_Modelo = mo.ID_Modelo
JOIN Marcas ma ON mo.ID_Marca = ma.ID_Marca
JOIN Categoria_Vehiculo cv ON v.ID_Categoria_Vehiculo = cv.ID_Categoria_Vehiculo
JOIN Tipo_Vehiculo tv ON cv.ID_Tipo_Vehiculo = tv.ID_Tipo_Vehiculo
JOIN Ubicacion_Tecnica ut ON v.ID_Ubicacion_Tecnica = ut.ID_Ubicacion_Tecnica
JOIN Area ar ON ut.ID_Area = ar.ID_Area
JOIN Gerencia ge ON ar.ID_Gerencia = ge.ID_Gerencia
JOIN Tipo_Combustible tc1 ON v.ID_Tipo_Combustible_1 = tc1.ID_Tipo_Combustible
LEFT JOIN Tipo_Combustible tc2 ON v.ID_Tipo_Combustible_2 = tc2.ID_Tipo_Combustible
;

