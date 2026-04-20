-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 17-04-2026 a las 05:54:12
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `netshield`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `piezas_venta`
--

CREATE TABLE `piezas_venta` (
  `id` int(11) NOT NULL,
  `sku` varchar(40) NOT NULL,
  `nombre_pieza` varchar(180) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `marca` varchar(80) DEFAULT NULL,
  `modelo_compatible` varchar(120) DEFAULT NULL,
  `categoria_id` int(11) DEFAULT NULL,
  `categoria_nombre` varchar(80) DEFAULT NULL,
  `proveedor_id` int(11) DEFAULT NULL,
  `proveedor_nombre` varchar(120) DEFAULT NULL,
  `stock_actual` int(11) NOT NULL DEFAULT 0,
  `stock_minimo` int(11) NOT NULL DEFAULT 0,
  `lote` varchar(40) DEFAULT NULL,
  `ubicacion_id` int(11) DEFAULT NULL,
  `ubicacion_nombre` varchar(120) DEFAULT NULL,
  `costo` decimal(12,2) NOT NULL DEFAULT 0.00,
  `precio_venta` decimal(12,2) NOT NULL DEFAULT 0.00,
  `moneda` enum('COP','USD') NOT NULL DEFAULT 'COP',
  `precio_usd` decimal(12,2) DEFAULT NULL,
  `impuesto_porcentaje` decimal(5,2) NOT NULL DEFAULT 19.00,
  `descuento_porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `codigo_barras` varchar(60) DEFAULT NULL,
  `unidad_medida` enum('unidad','par','caja','metro','litro') NOT NULL DEFAULT 'unidad',
  `estado` enum('activo','descontinuado','sin_stock') NOT NULL DEFAULT 'activo',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `piezas_venta`
--

INSERT INTO `piezas_venta` (`id`, `sku`, `nombre_pieza`, `descripcion`, `marca`, `modelo_compatible`, `categoria_id`, `categoria_nombre`, `proveedor_id`, `proveedor_nombre`, `stock_actual`, `stock_minimo`, `lote`, `ubicacion_id`, `ubicacion_nombre`, `costo`, `precio_venta`, `moneda`, `precio_usd`, `impuesto_porcentaje`, `descuento_porcentaje`, `codigo_barras`, `unidad_medida`, `estado`, `creado_en`, `actualizado_en`) VALUES
(1, 'SKU-0001', 'Filtro de aire', 'Filtro de aire para mantenimiento general', 'Bosch', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 120, 20, 'L-2026-01', 1, 'Bodega Central - A1', 12.50, 25.00, 'USD', 25.00, 19.00, 0.00, '770123450001', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(2, 'SKU-0002', 'Bujía estándar', 'Bujía para motor gasolina', 'NGK', 'Motores 1.6-2.0', 11, 'Encendido', 501, 'Distribuidora Andina', 300, 50, 'L-2026-01', 1, 'Bodega Central - A1', 2.10, 4.80, 'USD', 4.80, 19.00, 5.00, '770123450002', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(3, 'SKU-0003', 'Aceite 10W-40', 'Aceite sintético 1L', 'Mobil', 'Universal', 12, 'Lubricantes', 502, 'Suministros Motor', 80, 15, 'L-2026-02', 2, 'Bodega Central - B2', 6.20, 11.90, 'USD', 11.90, 19.00, 0.00, '770123450003', 'litro', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(4, 'SKU-0004', 'Pastillas de freno delanteras', 'Juego de pastillas delanteras', 'Brembo', 'Sedán compacto', 13, 'Frenos', 503, 'Frenos Premium', 45, 10, 'L-2026-02', 3, 'Bodega Central - C3', 18.00, 35.00, 'USD', 35.00, 19.00, 0.00, '770123450004', 'par', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(5, 'SKU-0005', 'Disco de freno', 'Disco ventilado', 'Brembo', 'Sedán compacto', 13, 'Frenos', 503, 'Frenos Premium', 20, 5, 'L-2026-02', 3, 'Bodega Central - C3', 22.00, 48.00, 'USD', 48.00, 19.00, 0.00, '770123450005', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(6, 'SKU-0006', 'Correa de distribución', 'Kit de correa + tensores', 'Gates', 'Motores 1.6', 14, 'Transmisión', 504, 'Partes y Correas', 18, 5, 'L-2026-03', 4, 'Bodega Central - D1', 45.00, 89.00, 'USD', 89.00, 19.00, 0.00, '770123450006', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(7, 'SKU-0007', 'Batería 12V 60Ah', 'Batería libre de mantenimiento', 'Varta', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 22, 5, 'L-2026-03', 5, 'Bodega Central - E2', 72.00, 120.00, 'USD', 120.00, 19.00, 8.00, '770123450007', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(8, 'SKU-0008', 'Alternador 90A', 'Alternador para sedán', 'Valeo', 'Sedán compacto', 15, 'Eléctrico', 505, 'ElectroPartes', 7, 2, 'L-2026-03', 5, 'Bodega Central - E2', 115.00, 210.00, 'USD', 210.00, 19.00, 0.00, '770123450008', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(9, 'SKU-0008', 'Alternador 90A', 'Alternador para sedán (registro duplicado)', 'Valeo', 'Sedán compacto', 15, 'Eléctrico', 505, 'ElectroPartes', 7, 2, 'L-2026-03', 5, 'Bodega Central - E2', 115.00, 210.00, 'USD', 210.00, 19.00, 0.00, '770123450008', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(10, 'SKU-0009', 'Motor de arranque', 'Arranque reforzado', 'Denso', 'Sedán compacto', 15, 'Eléctrico', 505, 'ElectroPartes', 5, 2, 'L-2026-04', 5, 'Bodega Central - E2', 98.00, 175.00, 'USD', 175.00, 19.00, 0.00, '770123450009', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(11, 'SKU-0010', 'Amortiguador delantero', 'Amortiguador gas', 'Monroe', 'Sedán compacto', 16, 'Suspensión', 506, 'Suspensión Total', 16, 4, 'L-2026-04', 6, 'Bodega Central - F1', 38.00, 75.00, 'USD', 75.00, 19.00, 0.00, '770123450010', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(12, 'SKU-0011', 'Amortiguador trasero', 'Amortiguador gas', 'Monroe', 'Sedán compacto', 16, 'Suspensión', 506, 'Suspensión Total', 14, 4, 'L-2026-04', 6, 'Bodega Central - F1', 36.00, 72.00, 'USD', 72.00, 19.00, 0.00, '770123450011', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(13, 'SKU-0012', 'Rótula de dirección', 'Rótula reforzada', 'TRW', 'Sedán compacto', 16, 'Suspensión', 506, 'Suspensión Total', 40, 10, 'L-2026-04', 6, 'Bodega Central - F1', 7.20, 15.50, 'USD', 15.50, 19.00, 0.00, '770123450012', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(14, 'SKU-0013', 'Kit de clutch', 'Disco + plato + balinera', 'LUK', 'Motores 1.6', 14, 'Transmisión', 504, 'Partes y Correas', 9, 3, 'L-2026-05', 4, 'Bodega Central - D1', 95.00, 165.00, 'USD', 165.00, 19.00, 0.00, '770123450013', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(15, 'SKU-0014', 'Radiador', 'Radiador aluminio', 'Nissens', 'Sedán compacto', 17, 'Refrigeración', 507, 'CoolingPro', 6, 2, 'L-2026-05', 7, 'Bodega Central - G2', 68.00, 129.00, 'USD', 129.00, 19.00, 0.00, '770123450014', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(16, 'SKU-0015', 'Bomba de agua', 'Bomba para motor', 'Gates', 'Motores 1.6', 17, 'Refrigeración', 507, 'CoolingPro', 12, 3, 'L-2026-05', 7, 'Bodega Central - G2', 22.50, 45.00, 'USD', 45.00, 19.00, 0.00, '770123450015', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(17, 'SKU-0016', 'Termostato', 'Termostato 82°C', 'Mahle', 'Motores 1.6', 17, 'Refrigeración', 507, 'CoolingPro', 25, 6, 'L-2026-05', 7, 'Bodega Central - G2', 8.00, 16.50, 'USD', 16.50, 19.00, 0.00, '770123450016', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(18, 'SKU-0017', 'Filtro de aceite', 'Filtro rosca', 'Mann', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 200, 30, 'L-2026-06', 1, 'Bodega Central - A1', 4.10, 8.90, 'USD', 8.90, 19.00, 0.00, '770123450017', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(19, 'SKU-0018', 'Sensor O2', 'Sensor oxígeno', 'Bosch', 'Motores 1.6-2.0', 18, 'Sensores', 508, 'Sensores Express', 8, 2, 'L-2026-06', 8, 'Bodega Central - H1', 32.00, 65.00, 'USD', 65.00, 19.00, 0.00, '770123450018', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(20, 'SKU-0019', 'Sensor MAP', 'Sensor presión', 'Bosch', 'Motores 1.6-2.0', 18, 'Sensores', 508, 'Sensores Express', 10, 2, 'L-2026-06', 8, 'Bodega Central - H1', 28.00, 58.00, 'USD', 58.00, 19.00, 0.00, '770123450019', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(21, 'SKU-0020', 'Bobina de encendido', 'Bobina individual', 'Delphi', 'Motores 1.6-2.0', 11, 'Encendido', 501, 'Distribuidora Andina', 18, 5, 'L-2026-06', 1, 'Bodega Central - A1', 19.00, 39.00, 'USD', 39.00, 19.00, 0.00, '770123450020', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(22, 'SKU-0021', 'Kit de mantenimiento', 'Filtro + aceite', 'Bosch', 'Universal', 10, 'Lubricantes', 501, 'Distribuidora Andina', 60, 10, 'L-2026-06', 1, 'Bodega Central - A1', 9.90, 19.90, 'USD', 19.90, 19.00, 0.00, '770123450021', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(23, 'SKU-0022', 'Kit de frenos', 'Pastillas + discos', 'Brembo', 'Sedán compacto', 13, 'Frenos', 503, 'Frenos Premium', 8, 2, 'L-2026-07', 3, 'Bodega Central - C3', 58.00, 115.00, 'USD', 115.00, 19.00, 0.00, '770123450022', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(24, 'SKU-0023', 'Filtro de cabina', 'Filtro anti-polvo', 'Mahle', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 140, 20, 'L-2026-07', 1, 'Bodega Central - A1', 6.20, 12.50, 'USD', 12.50, 19.00, 0.00, '770123450023', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(25, 'SKU-0024', 'Liquido de frenos DOT4', 'Fluido 500ml', 'Bosch', 'Universal', 12, 'Lubricantes', 502, 'Suministros Motor', 55, 10, 'L-2026-07', 2, 'Bodega Central - B2', 3.50, 7.50, 'USD', 7.50, 19.00, 0.00, '770123450024', 'litro', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(26, 'SKU-0025', 'Juego de limpias', 'Plumillas 22\"', 'Bosch', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 90, 15, 'L-2026-07', 1, 'Bodega Central - A1', 5.00, 10.90, 'USD', 10.90, 19.00, 0.00, '770123450025', 'par', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(27, 'SKU-0026', 'Fusibles surtidos', 'Caja de fusibles', 'Generic', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 75, 15, 'L-2026-08', 5, 'Bodega Central - E2', 6.50, 14.00, 'USD', 14.00, 19.00, 0.00, '770123450026', 'caja', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(28, 'SKU-0027', 'Bombillo H4', 'Bombillo halógeno', 'Philips', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 160, 30, 'L-2026-08', 5, 'Bodega Central - E2', 3.00, 7.00, 'USD', 7.00, 19.00, 0.00, '770123450027', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(29, 'SKU-0028', 'Bombillo H7', 'Bombillo halógeno', 'Philips', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 140, 30, 'L-2026-08', 5, 'Bodega Central - E2', 3.20, 7.50, 'USD', 7.50, 19.00, 0.00, '770123450028', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(30, 'SKU-0029', 'Relevador 12V', 'Relevador universal', 'Bosch', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 95, 20, 'L-2026-08', 5, 'Bodega Central - E2', 2.40, 5.90, 'USD', 5.90, 19.00, 0.00, '770123450029', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(31, 'SKU-0030', 'Faja auxiliar', 'Correa auxiliar', 'Gates', 'Motores 1.6', 14, 'Transmisión', 504, 'Partes y Correas', 30, 8, 'L-2026-08', 4, 'Bodega Central - D1', 9.80, 19.50, 'USD', 19.50, 19.00, 0.00, '770123450030', 'unidad', 'activo', '2026-04-17 03:44:24', '2026-04-17 03:44:24'),
(32, 'SKU-0031', 'Filtro de combustible', 'Filtro para línea de combustible', 'Mann', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 110, 20, 'L-2026-09', 1, 'Bodega Central - A1', 5.10, 10.90, 'USD', 10.90, 19.00, 0.00, '770123450031', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(33, 'SKU-0032', 'Aceite 5W-30', 'Aceite sintético 1L', 'Mobil', 'Universal', 12, 'Lubricantes', 502, 'Suministros Motor', 70, 15, 'L-2026-09', 2, 'Bodega Central - B2', 6.80, 12.90, 'USD', 12.90, 19.00, 0.00, '770123450032', 'litro', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(34, 'SKU-0033', 'Refrigerante 1L', 'Refrigerante orgánico', 'Prestone', 'Universal', 17, 'Refrigeración', 507, 'CoolingPro', 85, 15, 'L-2026-09', 7, 'Bodega Central - G2', 4.60, 9.90, 'USD', 9.90, 19.00, 0.00, '770123450033', 'litro', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(35, 'SKU-0034', 'Liquido dirección hidráulica', 'Fluido 1L', 'Castrol', 'Universal', 12, 'Lubricantes', 502, 'Suministros Motor', 40, 10, 'L-2026-09', 2, 'Bodega Central - B2', 5.20, 11.00, 'USD', 11.00, 19.00, 0.00, '770123450034', 'litro', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(36, 'SKU-0035', 'Kit limpieza inyectores', 'Aditivo limpiador', 'STP', 'Motores 1.6-2.0', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 55, 10, 'L-2026-09', 1, 'Bodega Central - A1', 3.40, 7.50, 'USD', 7.50, 19.00, 0.00, '770123450035', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(37, 'SKU-0036', 'Pastillas de freno traseras', 'Juego de pastillas traseras', 'Brembo', 'Sedán compacto', 13, 'Frenos', 503, 'Frenos Premium', 38, 10, 'L-2026-10', 3, 'Bodega Central - C3', 16.00, 31.00, 'USD', 31.00, 19.00, 0.00, '770123450036', 'par', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(38, 'SKU-0037', 'Disco de freno trasero', 'Disco sólido', 'Brembo', 'Sedán compacto', 13, 'Frenos', 503, 'Frenos Premium', 15, 5, 'L-2026-10', 3, 'Bodega Central - C3', 19.00, 41.00, 'USD', 41.00, 19.00, 0.00, '770123450037', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(39, 'SKU-0038', 'Kit bandas de freno', 'Bandas + resortes', 'TRW', 'Sedán compacto', 13, 'Frenos', 503, 'Frenos Premium', 10, 3, 'L-2026-10', 3, 'Bodega Central - C3', 22.00, 49.00, 'USD', 49.00, 19.00, 0.00, '770123450038', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(40, 'SKU-0039', 'Balinera delantera', 'Rodamiento delantero', 'SKF', 'Sedán compacto', 16, 'Suspensión', 506, 'Suspensión Total', 25, 6, 'L-2026-10', 6, 'Bodega Central - F1', 12.00, 26.00, 'USD', 26.00, 19.00, 0.00, '770123450039', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(41, 'SKU-0040', 'Bomba de gasolina', 'Bomba eléctrica', 'Bosch', 'Motores 1.6', 18, 'Sensores', 508, 'Sensores Express', 7, 2, 'L-2026-10', 8, 'Bodega Central - H1', 45.00, 89.00, 'USD', 89.00, 19.00, 0.00, '770123450040', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(42, 'SKU-0041', 'Bomba de gasolina', 'Bomba eléctrica (registro duplicado)', 'Bosch', 'Motores 1.6', 18, 'Sensores', 508, 'Sensores Express', 7, 2, 'L-2026-10', 8, 'Bodega Central - H1', 45.00, 89.00, 'USD', 89.00, 19.00, 0.00, '770123450040', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(43, 'SKU-0042', 'Sensor TPS', 'Sensor posición acelerador', 'Bosch', 'Motores 1.6-2.0', 18, 'Sensores', 508, 'Sensores Express', 9, 2, 'L-2026-10', 8, 'Bodega Central - H1', 18.00, 38.00, 'USD', 38.00, 19.00, 0.00, '770123450042', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(44, 'SKU-0043', 'Sensor ABS', 'Sensor rueda', 'Bosch', 'Sedán compacto', 18, 'Sensores', 508, 'Sensores Express', 11, 3, 'L-2026-10', 8, 'Bodega Central - H1', 21.00, 44.00, 'USD', 44.00, 19.00, 0.00, '770123450043', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(45, 'SKU-0044', 'Batería 12V 45Ah', 'Batería compacta', 'Varta', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 18, 5, 'L-2026-11', 5, 'Bodega Central - E2', 58.00, 99.00, 'USD', 99.00, 19.00, 0.00, '770123450044', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(46, 'SKU-0044', 'Batería 12V 45Ah', 'Batería compacta (registro duplicado)', 'Varta', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 18, 5, 'L-2026-11', 5, 'Bodega Central - E2', 58.00, 99.00, 'USD', 99.00, 19.00, 0.00, '770123450044', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(47, 'SKU-0045', 'Alternador 120A', 'Alternador alto desempeño', 'Valeo', 'SUV', 15, 'Eléctrico', 505, 'ElectroPartes', 4, 2, 'L-2026-11', 5, 'Bodega Central - E2', 145.00, 255.00, 'USD', 255.00, 19.00, 0.00, '770123450045', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(48, 'SKU-0046', 'Motor de arranque', 'Arranque reforzado', 'Denso', 'SUV', 15, 'Eléctrico', 505, 'ElectroPartes', 3, 2, 'L-2026-11', 5, 'Bodega Central - E2', 110.00, 195.00, 'USD', 195.00, 19.00, 0.00, '770123450046', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(49, 'SKU-0047', 'Fusibles mini', 'Caja de fusibles mini', 'Generic', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 90, 20, 'L-2026-11', 5, 'Bodega Central - E2', 7.20, 15.50, 'USD', 15.50, 19.00, 0.00, '770123450047', 'caja', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(50, 'SKU-0048', 'Relé 12V 40A', 'Relé automotriz', 'Bosch', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 70, 15, 'L-2026-11', 5, 'Bodega Central - E2', 2.90, 6.50, 'USD', 6.50, 19.00, 0.00, '770123450048', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(51, 'SKU-0049', 'Kit amortiguadores', 'Par delantero', 'Monroe', 'Sedán compacto', 16, 'Suspensión', 506, 'Suspensión Total', 6, 2, 'L-2026-11', 6, 'Bodega Central - F1', 72.00, 135.00, 'USD', 135.00, 19.00, 0.00, '770123450049', 'par', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(52, 'SKU-0050', 'Resorte suspensión', 'Resorte delantero', 'Monroe', 'Sedán compacto', 16, 'Suspensión', 506, 'Suspensión Total', 12, 4, 'L-2026-11', 6, 'Bodega Central - F1', 18.00, 37.00, 'USD', 37.00, 19.00, 0.00, '770123450050', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(53, 'SKU-0051', 'Terminal dirección', 'Terminal externo', 'TRW', 'Sedán compacto', 16, 'Suspensión', 506, 'Suspensión Total', 28, 8, 'L-2026-11', 6, 'Bodega Central - F1', 6.50, 14.90, 'USD', 14.90, 19.00, 0.00, '770123450051', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(54, 'SKU-0052', 'Barra estabilizadora (buje)', 'Buje estabilizadora', 'TRW', 'Sedán compacto', 16, 'Suspensión', 506, 'Suspensión Total', 60, 15, 'L-2026-12', 6, 'Bodega Central - F1', 1.90, 4.80, 'USD', 4.80, 19.00, 0.00, '770123450052', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(55, 'SKU-0053', 'Manguera radiador superior', 'Manguera superior', 'Gates', 'Sedán compacto', 17, 'Refrigeración', 507, 'CoolingPro', 18, 6, 'L-2026-12', 7, 'Bodega Central - G2', 7.80, 16.50, 'USD', 16.50, 19.00, 0.00, '770123450053', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(56, 'SKU-0054', 'Manguera radiador inferior', 'Manguera inferior', 'Gates', 'Sedán compacto', 17, 'Refrigeración', 507, 'CoolingPro', 18, 6, 'L-2026-12', 7, 'Bodega Central - G2', 7.60, 16.00, 'USD', 16.00, 19.00, 0.00, '770123450054', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(57, 'SKU-0055', 'Tapa radiador', 'Tapa presión', 'Mahle', 'Universal', 17, 'Refrigeración', 507, 'CoolingPro', 35, 10, 'L-2026-12', 7, 'Bodega Central - G2', 2.30, 5.90, 'USD', 5.90, 19.00, 0.00, '770123450055', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(58, 'SKU-0056', 'Ventilador radiador', 'Ventilador eléctrico', 'Denso', 'Sedán compacto', 17, 'Refrigeración', 507, 'CoolingPro', 5, 2, 'L-2026-12', 7, 'Bodega Central - G2', 58.00, 110.00, 'USD', 110.00, 19.00, 0.00, '770123450056', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(59, 'SKU-0057', 'Bomba de agua', 'Bomba para motor', 'Gates', 'Motores 2.0', 17, 'Refrigeración', 507, 'CoolingPro', 9, 3, 'L-2026-12', 7, 'Bodega Central - G2', 24.00, 49.00, 'USD', 49.00, 19.00, 0.00, '770123450057', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(60, 'SKU-0058', 'Termostato', 'Termostato 82°C', 'Mahle', 'Motores 2.0', 17, 'Refrigeración', 507, 'CoolingPro', 20, 6, 'L-2026-12', 7, 'Bodega Central - G2', 8.50, 17.50, 'USD', 17.50, 19.00, 0.00, '770123450058', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(61, 'SKU-0059', 'Kit correa auxiliar', 'Correa + rodillos', 'Gates', 'Motores 2.0', 14, 'Transmisión', 504, 'Partes y Correas', 14, 4, 'L-2026-12', 4, 'Bodega Central - D1', 22.00, 44.00, 'USD', 44.00, 19.00, 0.00, '770123450059', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(62, 'SKU-0060', 'Kit distribución', 'Correa + tensores', 'Gates', 'Motores 2.0', 14, 'Transmisión', 504, 'Partes y Correas', 10, 3, 'L-2026-12', 4, 'Bodega Central - D1', 52.00, 99.00, 'USD', 99.00, 19.00, 0.00, '770123450060', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(63, 'SKU-0061', 'Kit clutch', 'Disco + plato + balinera', 'LUK', 'Motores 2.0', 14, 'Transmisión', 504, 'Partes y Correas', 6, 2, 'L-2026-12', 4, 'Bodega Central - D1', 110.00, 189.00, 'USD', 189.00, 19.00, 0.00, '770123450061', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(64, 'SKU-0062', 'Bombillo H11', 'Bombillo halógeno', 'Philips', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 80, 20, 'L-2026-12', 5, 'Bodega Central - E2', 3.40, 7.90, 'USD', 7.90, 19.00, 0.00, '770123450062', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(65, 'SKU-0063', 'Juego de limpias premium', 'Plumillas 24\"', 'Bosch', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 40, 10, 'L-2026-12', 1, 'Bodega Central - A1', 7.10, 14.90, 'USD', 14.90, 19.00, 0.00, '770123450063', 'par', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(66, 'SKU-0064', 'Aceite de caja', 'Fluido transmisión 1L', 'Castrol', 'Universal', 12, 'Mantenimiento', 502, 'Suministros Motor', 22, 6, 'L-2026-12', 2, 'Bodega Central - B2', 7.60, 14.50, 'USD', 14.50, 19.00, 0.00, '770123450064', 'litro', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(67, 'SKU-0065', 'Aditivo octanaje', 'Mejorador de octanaje', 'STP', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 28, 8, 'L-2026-12', 1, 'Bodega Central - A1', 3.10, 7.20, 'USD', 7.20, 19.00, 0.00, '770123450065', 'unidad', 'activo', '2026-04-17 03:49:19', '2026-04-17 03:49:19'),
(68, 'SKU-0066', 'Filtro de aire premium', 'Filtro alto flujo', 'Bosch', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 60, 15, 'L-2026-13', 1, 'Bodega Central - A1', 8.20, 16.90, 'USD', 16.90, 19.00, 0.00, '770123450066', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(69, 'SKU-0067', 'Bujía Iridium', 'Bujía alto desempeño', 'NGK', 'Motores 1.6-2.0', 11, 'Encendido', 501, 'Distribuidora Andina', 90, 20, 'L-2026-13', 1, 'Bodega Central - A1', 6.80, 14.90, 'USD', 14.90, 19.00, 0.00, '770123450067', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(70, 'SKU-0068', 'Bobina de encendido', 'Bobina individual', 'Delphi', 'Motores 2.0', 11, 'Encendido', 501, 'Distribuidora Andina', 12, 4, 'L-2026-13', 1, 'Bodega Central - A1', 21.00, 43.00, 'USD', 43.00, 19.00, 0.00, '770123450068', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(71, 'SKU-0069', 'Sensor MAF', 'Sensor flujo de aire', 'Bosch', 'Motores 1.6-2.0', 18, 'Sensores', 508, 'Sensores Express', 6, 2, 'L-2026-13', 8, 'Bodega Central - H1', 35.00, 72.00, 'USD', 72.00, 19.00, 0.00, '770123450069', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(72, 'SKU-0070', 'Bomba de agua', 'Bomba para motor', 'Gates', 'Motores 1.6', 17, 'Refrigeración', 507, 'CoolingPro', 14, 4, 'L-2026-13', 7, 'Bodega Central - G2', 22.50, 45.00, 'USD', 45.00, 19.00, 0.00, '770123450070', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(73, 'SKU-0071', 'Bomba de agua', 'Bomba para motor (duplicado barras)', 'Gates', 'Motores 1.6', 17, 'Refrigeración', 507, 'CoolingPro', 14, 4, 'L-2026-13', 7, 'Bodega Central - G2', 22.50, 45.00, 'USD', 45.00, 19.00, 0.00, '770123450070', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(74, 'SKU-0072', 'Radiador', 'Radiador aluminio', 'Nissens', 'SUV', 17, 'Refrigeración', 507, 'CoolingPro', 4, 2, 'L-2026-13', 7, 'Bodega Central - G2', 92.00, 169.00, 'USD', 169.00, 19.00, 0.00, '770123450072', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(75, 'SKU-0073', 'Kit frenos delanteros', 'Pastillas + discos', 'Brembo', 'SUV', 13, 'Frenos', 503, 'Frenos Premium', 5, 2, 'L-2026-13', 3, 'Bodega Central - C3', 75.00, 149.00, 'USD', 149.00, 19.00, 0.00, '770123450073', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(76, 'SKU-0074', 'Pastillas cerámicas', 'Pastillas cerámicas', 'Brembo', 'SUV', 13, 'Frenos', 503, 'Frenos Premium', 22, 6, 'L-2026-13', 3, 'Bodega Central - C3', 24.00, 49.00, 'USD', 49.00, 19.00, 0.00, '770123450074', 'par', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(77, 'SKU-0075', 'Disco ventilado', 'Disco ventilado', 'Brembo', 'SUV', 13, 'Frenos', 503, 'Frenos Premium', 10, 4, 'L-2026-13', 3, 'Bodega Central - C3', 28.00, 59.00, 'USD', 59.00, 19.00, 0.00, '770123450075', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(78, 'SKU-0076', 'Amortiguador delantero', 'Amortiguador gas', 'Monroe', 'SUV', 16, 'Suspensión', 506, 'Suspensión Total', 10, 4, 'L-2026-14', 6, 'Bodega Central - F1', 44.00, 89.00, 'USD', 89.00, 19.00, 0.00, '770123450076', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(79, 'SKU-0077', 'Bieleta estabilizadora', 'Bieleta delantera', 'TRW', 'SUV', 16, 'Suspensión', 506, 'Suspensión Total', 35, 10, 'L-2026-14', 6, 'Bodega Central - F1', 4.20, 9.90, 'USD', 9.90, 19.00, 0.00, '770123450077', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(80, 'SKU-0078', 'Buje bandeja', 'Buje suspensión', 'TRW', 'SUV', 16, 'Suspensión', 506, 'Suspensión Total', 50, 15, 'L-2026-14', 6, 'Bodega Central - F1', 3.10, 7.20, 'USD', 7.20, 19.00, 0.00, '770123450078', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(81, 'SKU-0079', 'Rótula inferior', 'Rótula suspensión', 'TRW', 'SUV', 16, 'Suspensión', 506, 'Suspensión Total', 18, 6, 'L-2026-14', 6, 'Bodega Central - F1', 8.30, 18.00, 'USD', 18.00, 19.00, 0.00, '770123450079', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(82, 'SKU-0080', 'Terminal dirección', 'Terminal externo', 'TRW', 'SUV', 16, 'Suspensión', 506, 'Suspensión Total', 20, 6, 'L-2026-14', 6, 'Bodega Central - F1', 6.80, 15.50, 'USD', 15.50, 19.00, 0.00, '770123450080', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(83, 'SKU-0081', 'Correa de accesorios', 'Correa auxiliar', 'Gates', 'SUV', 14, 'Transmisión', 504, 'Partes y Correas', 24, 8, 'L-2026-14', 4, 'Bodega Central - D1', 10.20, 21.50, 'USD', 21.50, 19.00, 0.00, '770123450081', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(84, 'SKU-0082', 'Tensor correa', 'Tensor automático', 'Gates', 'SUV', 14, 'Transmisión', 504, 'Partes y Correas', 9, 3, 'L-2026-14', 4, 'Bodega Central - D1', 22.00, 45.00, 'USD', 45.00, 19.00, 0.00, '770123450082', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(85, 'SKU-0083', 'Rodillo guía', 'Rodillo auxiliar', 'Gates', 'SUV', 14, 'Transmisión', 504, 'Partes y Correas', 14, 4, 'L-2026-14', 4, 'Bodega Central - D1', 9.10, 19.00, 'USD', 19.00, 19.00, 0.00, '770123450083', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(86, 'SKU-0084', 'Kit clutch', 'Disco + plato + balinera', 'LUK', 'SUV', 14, 'Transmisión', 504, 'Partes y Correas', 4, 2, 'L-2026-14', 4, 'Bodega Central - D1', 130.00, 220.00, 'USD', 220.00, 19.00, 0.00, '770123450084', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(87, 'SKU-0085', 'Aceite 0W-20', 'Aceite sintético 1L', 'Mobil', 'Universal', 12, 'Lubricantes', 502, 'Suministros Motor', 55, 12, 'L-2026-14', 2, 'Bodega Central - B2', 7.10, 13.50, 'USD', 13.50, 19.00, 0.00, '770123450085', 'litro', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(88, 'SKU-0086', 'Bombillo LED H4', 'Bombillo LED', 'Generic', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 40, 10, 'L-2026-15', 5, 'Bodega Central - E2', 9.90, 19.90, 'USD', 19.90, 19.00, 0.00, '770123450086', 'par', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(89, 'SKU-0087', 'Cargador USB 12V', 'Cargador doble', 'Generic', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 35, 10, 'L-2026-15', 5, 'Bodega Central - E2', 4.50, 9.90, 'USD', 9.90, 19.00, 0.00, '770123450087', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(90, 'SKU-0088', 'Batería 12V 60Ah', 'Batería libre mantenimiento', 'Varta', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 12, 4, 'L-2026-15', 5, 'Bodega Central - E2', 72.00, 120.00, 'USD', 120.00, 19.00, 0.00, '770123450088', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(91, 'SKU-0088', 'Batería 12V 60Ah', 'Batería libre mantenimiento (duplicado)', 'Varta', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 12, 4, 'L-2026-15', 5, 'Bodega Central - E2', 72.00, 120.00, 'USD', 120.00, 19.00, 0.00, '770123450088', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(92, 'SKU-0089', 'Alternador 90A', 'Alternador sedán', 'Valeo', 'Sedán compacto', 15, 'Eléctrico', 505, 'ElectroPartes', 6, 2, 'L-2026-15', 5, 'Bodega Central - E2', 115.00, 210.00, 'USD', 210.00, 19.00, 0.00, '770123450089', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(93, 'SKU-0090', 'Motor de arranque', 'Arranque sedán', 'Denso', 'Sedán compacto', 15, 'Eléctrico', 505, 'ElectroPartes', 4, 2, 'L-2026-15', 5, 'Bodega Central - E2', 98.00, 175.00, 'USD', 175.00, 19.00, 0.00, '770123450090', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(94, 'SKU-0091', 'Sensor temperatura', 'Sensor refrigerante', 'Bosch', 'Universal', 18, 'Sensores', 508, 'CoolingPro', 20, 6, 'L-2026-15', 8, 'Bodega Central - H1', 6.50, 14.50, 'USD', 14.50, 19.00, 0.00, '770123450091', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(95, 'SKU-0092', 'Filtro de aceite', 'Filtro rosca', 'Mann', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 120, 25, 'L-2026-15', 1, 'Bodega Central - H1', 4.10, 8.90, 'USD', 8.90, 19.00, 0.00, '770123450092', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(96, 'SKU-0093', 'Kit bujías', 'Juego 4 bujías', 'NGK', 'Motores 1.6', 11, 'Encendido', 501, 'Distribuidora Andina', 35, 10, 'L-2026-15', 1, 'Bodega Central - A1', 7.80, 16.00, 'USD', 16.00, 19.00, 0.00, '770123450093', 'caja', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(97, 'SKU-0094', 'Liquido de frenos DOT4', 'Fluido 500ml', 'Bosch', 'Universal', 12, 'Lubricantes', 502, 'Suministros Motor', 30, 10, 'L-2026-15', 2, 'Bodega Central - B2', 3.50, 7.50, 'USD', 7.50, 19.00, 0.00, '770123450094', 'litro', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(98, 'SKU-0095', 'Líquido limpiaparabrisas', 'Fluido 1L', 'Generic', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 45, 12, 'L-2026-15', 1, 'Bodega Central - A1', 1.20, 3.50, 'USD', 3.50, 19.00, 0.00, '770123450095', 'litro', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(99, 'SKU-0096', 'Juego de limpias 26\"', 'Plumillas 26\"', 'Bosch', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 25, 8, 'L-2026-15', 1, 'Bodega Central - A1', 7.60, 15.90, 'USD', 15.90, 19.00, 0.00, '770123450096', 'par', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(100, 'SKU-0097', 'Bombillo H7', 'Bombillo halógeno', 'Philips', 'Universal', 15, 'Eléctrico', 505, 'ElectroPartes', 100, 25, 'L-2026-15', 5, 'Bodega Central - E2', 3.20, 7.50, 'USD', 7.50, 19.00, 0.00, '770123450097', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(101, 'SKU-0098', 'Faja auxiliar', 'Correa auxiliar', 'Gates', 'Motores 2.0', 14, 'Transmisión', 504, 'Partes y Correas', 18, 6, 'L-2026-15', 4, 'Bodega Central - D1', 10.40, 20.50, 'USD', 20.50, 19.00, 0.00, '770123450098', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(102, 'SKU-0099', 'Balinera trasera', 'Rodamiento trasero', 'SKF', 'Sedán compacto', 16, 'Suspensión', 506, 'Suspensión Total', 20, 6, 'L-2026-15', 6, 'Bodega Central - F1', 11.50, 24.50, 'USD', 24.50, 19.00, 0.00, '770123450099', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58'),
(103, 'SKU-0100', 'Kit mantenimiento premium', 'Filtro + aceite + aditivo', 'Bosch', 'Universal', 10, 'Mantenimiento', 501, 'Distribuidora Andina', 12, 3, 'L-2026-15', 1, 'Bodega Central - A1', 14.50, 29.90, 'USD', 29.90, 19.00, 0.00, '770123450100', 'unidad', 'activo', '2026-04-17 03:53:58', '2026-04-17 03:53:58');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `piezas_venta`
--
ALTER TABLE `piezas_venta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sku` (`sku`),
  ADD KEY `idx_categoria` (`categoria_id`),
  ADD KEY `idx_proveedor` (`proveedor_id`),
  ADD KEY `idx_estado` (`estado`),
  ADD KEY `idx_barras` (`codigo_barras`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `piezas_venta`
--
ALTER TABLE `piezas_venta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
