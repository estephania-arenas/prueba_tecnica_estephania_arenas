Tabla 1: tabla_total, tabla con el cruce de CLIENTES, CANALES, TRANSACCIONES

|      Columna       |                  Descripción                          | Tipo de Dato |
------------------------------------------------------------------------------------------------
| fecha_transaccion  | Fecha de la transacción                               |datetime6
| cod_canal          | Código del canal usado para la transacción            |bigint       
| tipo_doc           | Tipo de documento del cliente                         |String       
| num_doc            | Numero de documento del cliente                       |bigint        
| naturaleza         | Tipo de transacción Entrada o Salida                  |String       
| monto              | Monto de la transacción                               |bigint         
| nombre_canal       | Nombre del canal usado                                |String       
| tipo               | Tipo de canal                                         |String       
| cod_jurisdiccion   | Código DANE del municipio donde se encuentra el canal |bigint         
| nombre_persona     | Nombre de la persona                                  |String       
| tipo_persona       | Tipo de persona                                       |String       
| ingresos_mensuales | Ingresos mensuales                                    |float

Tabla 2: trx_ult_6_meses, tabla que contiene las transacciones de salida de los ultimos 6 meses 

|      Columna       |                  Descripción                          | Tipo de Dato |
------------------------------------------------------------------------------------------------
| fecha_transaccion  | Fecha de la transacción                               |datetime6
| cod_canal          | Código del canal usado para la transacción            |bigint       
| tipo_doc           | Tipo de documento del cliente                         |String       
| num_doc            | Numero de documento del cliente                       |bigint        
| naturaleza         | Tipo de transacción, solo de salida                   |String       
| monto              | Monto de la transacción                               |bigint         
| nombre_canal       | Nombre del canal usado                                |String       
| tipo               | Tipo de canal                                         |String       
| cod_jurisdiccion   | Código DANE del municipio donde se encuentra el canal |bigint         
| nombre_persona     | Nombre de la persona                                  |String       
| tipo_persona       | Tipo de persona                                       |String       
| ingresos_mensuales | Ingresos mensuales                                    |float

Tabla 3: cliente_exceden, Contiene clientes que exceden por 200% o mas sus ingresos mensuales en el total de transacciones durante los últimos 6 meses 

|      Columna       |                  Descripción                          | Tipo de Dato |
------------------------------------------------------------------------------------------------     
| tipo_doc           | Tipo de documento del cliente                         |String       
| num_doc            | Numero de documento del cliente                       |bigint             
| monto_6_meses      | Monto transaccionado en los ultimos 6 meses           |bigint               
| ingresos_mensuales | Ingresos mensuales                                    |float
| excede_200_ingresos| Marca True o False para indicar si exceden ingresos   |boolean

Tabla 4: clientes_superan_percentil, Contiene clientes que superan el percentil 95 de las transacciones realizadas del total de la población por tipo de persona

|      Columna       |                  Descripción                          | Tipo de Dato |
------------------------------------------------------------------------------------------------     
| tipo_doc           | Tipo de documento del cliente                         |String       
| num_doc            | Numero de documento del cliente                       |bigint             
| tipo_persona       | Tipo de persona                                       |String                 
| monto              | Monto total transaccionado                            |bigint
| percentil_95       | Percentil 95 de transacciones por tipo de persona     |float

Tabla 5: trx_porcentil, Contiene clientes que superan el percentil 95 y los clientes que superan por el 200% sus ingresos en transacciones de salida. Esta es la audiencia solicitada

|      Columna       |                  Descripción                          | Tipo de Dato |
------------------------------------------------------------------------------------------------     
| tipo_doc           | Tipo de documento del cliente                         |String       
| num_doc            | Numero de documento del cliente                       |bigint             
| monto_6_meses      | Monto transaccionado en los ultimos 6 meses           |bigint               
| ingresos_mensuales | Ingresos mensuales                                    |float
| excede_200_ingresos| Marca True o False para indicar si exceden ingresos   |boolean
| canales            | Canales usados para realizar las transacciones        |String
| tipo_persona       | Tipo de persona                                       |String  
| monto              | Monto total transaccionado                            |bigint
| percentil_95       | Valor del percentil 95 del total de transacciones tipo|float



