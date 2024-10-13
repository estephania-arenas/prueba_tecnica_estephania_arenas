--Prueba Ing Datos Estephania Arenas

--Transformación de  tabla clientes 
DROP TABLE IF EXISTS proceso.clientes_final_eam;
CREATE TABLE proceso.clientes_final_eam AS
SELECT 
    ABS(c.num_doc) AS num_doc, -- Transformar num_doc a su valor absoluto
    c.tipo_doc,
    CASE 
        WHEN c.tipo_persona = 'NATURAL' THEN 'PERSONA NATURAL' 
        ELSE c.tipo_persona
    END AS tipo_persona,
    c.ingresos_mensuales
FROM 
    (SELECT 
        num_doc, 
        tipo_doc, 
        tipo_persona, 
        ingresos_mensuales,
        -- Usar ROW_NUMBER para identificar duplicados
        ROW_NUMBER() OVER (PARTITION BY num_doc, tipo_doc ORDER BY num_doc) AS row_num
     FROM proceso.clientes_df_eam) AS c
WHERE 
    c.row_num = 1
    -- Eliminar registros con valores nulos
    AND c.num_doc IS NOT NULL
    AND c.tipo_doc <> '-'
    AND c.tipo_persona <> '-'
    AND c.ingresos_mensuales IS NOT NULL
    ;

--Transformación de  tabla transacciones

-- Crear tabla final de transacciones con datos limpios y transformados
DROP TABLE IF EXISTS proceso.transacciones_final_eam ;
CREATE TABLE proceso.transacciones_final_eam AS
SELECT
    --Se castean a numero y se mantienen los valores positivos 
    CAST(t.cod_canal AS BIGINT) AS cod_canal,
    ABS(CAST(t.num_doc AS BIGINT)) AS num_doc,
    ABS(CAST(t.monto AS BIGINT)) AS monto,
    t.tipo_doc,
    t.fecha_transaccion,
    t.naturaleza
    
FROM 
    proceso.transacciones_df_eam t
WHERE 
    -- Eliminar registros con valores nulos
    t.cod_canal IS NOT NULL 
    AND t.num_doc IS NOT NULL
    AND t.monto IS NOT NULL
    AND t.tipo_doc <> '-'
;


--Creación de la tabla total donde se cruzan clientes, canales y transacciones
DROP TABLE IF EXISTS proceso.tabla_total_eam ;
CREATE TABLE proceso.tabla_total_eam AS
SELECT 
    t.tipo_doc,
    t.num_doc,
    t.fecha_transaccion,
    t.naturaleza,
    t.monto, 
    c.tipo,  
    c.cod_jurisdiccion,
    cl.tipo_persona,
    cl.ingresos_mensuales
FROM proceso.transacciones_final_eam t INNER JOIN proceso.canales_df_eam c
ON t.cod_canal = CAST(c.codigo AS INT)  
INNER JOIN proceso.clientes_final_eam cl
ON t.tipo_doc = cl.tipo_doc AND t.num_doc = cl.num_doc  
;

--Tabla con las transacciones de salida efecutadas en los ultimos 6 meses desde la fecha maxima de transaccion que hay en la tabla de clientes total
DROP TABLE IF EXISTS proceso.trx_ult_6_meses_eam ;
CREATE TABLE proceso.trx_ult_6_meses_eam AS
SELECT *
FROM proceso.tabla_total_eam 
WHERE naturaleza = 'SALIDA'
  AND fecha_transaccion >= DATE_ADD(
      (SELECT MAX(fecha_transaccion) 
       FROM proceso.tabla_total_eam  
       WHERE naturaleza = 'SALIDA'), 
       INTERVAL -6 MONTH
  );

-- Clientes que superan el 200% de sus ingresos mensuales en los últimos 6 meses
DROP TABLE IF EXISTS proceso.cliente_exceden_eam ;
CREATE TABLE proceso.cliente_exceden_eam AS
SELECT 
    t.tipo_doc,
    t.num_doc,
    SUM(t.monto) AS monto_6_meses,
    c.ingresos_mensuales,
    GROUP_CONCAT(DISTINCT t.tipo) AS canales_usados  -- Obtener canales usados como lista separada por comas
FROM proceso.trx_ult_6_meses_eam t
INNER JOIN 
    (SELECT DISTINCT tipo_doc, num_doc, ingresos_mensuales FROM proceso.trx_ult_6_meses_eam) c
ON t.tipo_doc = c.tipo_doc AND t.num_doc = c.num_doc
WHERE  t.fecha_transaccion >= DATE_ADD(CURRENT_DATE(), -180)  -- Filtrar por transacciones en los últimos 6 meses
GROUP BY t.tipo_doc, t.num_doc, c.ingresos_mensuales
HAVING SUM(t.monto) >= (2 * c.ingresos_mensuales);  -- Filtrar clientes que superan el 200% de sus ingresos

;

--clientes que superan el percentil 95 por tipo de cliente de las poblacion total
DROP TABLE IF EXISTS proceso.clientes_superan_percentil_eam ;
CREATE TABLE proceso.clientes_superan_percentil_eam AS
WITH monto_total_por_cliente AS (
    SELECT 
        tipo_doc,
        num_doc,
        tipo_persona,
        SUM(monto) AS monto_total
    FROM proceso.tabla_total_eam 
    WHERE naturaleza = 'SALIDA'
    GROUP BY tipo_doc, num_doc, tipo_persona
),
total_clientes AS (
    SELECT 
        tipo_persona,
        COUNT(*) AS total
    FROM monto_total_por_cliente
    GROUP BY tipo_persona
),

percentil_95 AS (
    SELECT 
        mt.tipo_doc,
        mt.num_doc,
        mt.tipo_persona,
        mt.monto_total,
        ROW_NUMBER() OVER (PARTITION BY mt.tipo_persona ORDER BY mt.monto_total DESC) AS rn,
        tc.total
    FROM monto_total_por_cliente mt INNER JOIN total_clientes tc 
    ON mt.tipo_persona = tc.tipo_persona
)

SELECT 
    tipo_doc,
    num_doc,
    tipo_persona,
    monto_total
FROM 
    percentil_95
WHERE 
    rn <= (total * 0.05);  -- Tomar los primeros 5% de los registros que corresponde al percerntil 95
;

--tabla que reune la población solicitada, clientes que superan en un 200% sus transacciones su ingreso mensual en los ultimos 6 mese 
-- y clientes del percentil 95 del total de clientes por tipo de persona 
DROP TABLE IF EXISTS proceso.trx_porcentil_eam  ;
CREATE TABLE proceso.trx_porcentil_eam AS
SELECT 
    a.tipo_doc,
    a.num_doc,
    a.monto_6_meses,
    a.ingresos_mensuales,
    a.canales_usados,
    b.tipo_persona,
    b.monto_total
FROM proceso.cliente_exceden_eam  a INNER JOIN proceso.clientes_superan_percentil_eam b
ON a.tipo_doc = b.tipo_doc AND a.num_doc = b.num_doc;

