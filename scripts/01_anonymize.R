library(readxl)
library(dplyr)
library(stringr)
library(writexl)

# 1. Cargar las hojas
file_path <- "../data/dataset_flota_original.xlsx"
detalle_moviles <- read_excel(file_path, sheet = "Detalle Moviles")
gasto_movil <- read_excel(file_path, sheet = "Gasto x Movil 2020-21")

# --- FUNCIONES DE APOYO ---
# Función para crear un mapeo único (ej: ID_001, ID_002)
crear_mapeo <- function(columna, prefijo) {
  unique_vals <- unique(columna)
  mapping <- setNames(paste0(prefijo, "_", str_pad(seq_along(unique_vals), 3, pad = "0")), unique_vals)
  return(mapping)
}

# --- 2. ANONIMIZACIÓN DE IDENTIFICADORES (Consistente en ambas hojas) ---
# Creamos el mapa de EQUIPO para que el cruce siga funcionando
mapa_equipo <- crear_mapeo(detalle_moviles$EQUIPO, "EQ")

detalle_moviles <- detalle_moviles %>%
  mutate(
    EQUIPO = mapa_equipo[as.character(EQUIPO)],
    PATENTE = paste0(sample(LETTERS, 3, replace=T), "-", sample(100:999, n(), replace=T)) # Patentes ficticias
  )

gasto_movil <- gasto_movil %>%
  mutate(EQUIPO = mapa_equipo[as.character(EQUIPO)])

# --- 3. ANONIMIZACIÓN DE ESTRUCTURA ORGANIZATIVA ---
mapa_gerencia <- crear_mapeo(detalle_moviles$GERENCIA, "Gerencia")
mapa_area <- crear_mapeo(detalle_moviles$`AREA O UNIDAD (Nivel 2)`, "Area")

detalle_moviles <- detalle_moviles %>%
  mutate(
    GERENCIA = mapa_gerencia[GERENCIA],
    `AREA O UNIDAD (Nivel 2)` = mapa_area[`AREA O UNIDAD (Nivel 2)`],
    `UBICACIÓN TÉCNICA` = paste0("UT_", as.numeric(as.factor(`UBICACIÓN TÉCNICA`))),
    `DENOMINACIÓN UBICACIÓN TECNICA` = paste0("Sede_", as.numeric(as.factor(`DENOMINACIÓN UBICACIÓN TECNICA`)))
  )

# --- 4. ANONIMIZACIÓN DE TIEMPO (Año y Antigüedad) ---
# Desplazamos todos los años una cantidad fija (ej: restamos 2 años)
# Esto mantiene la relación de edad pero cambia el dato real.
offset_anio <- 2
detalle_moviles <- detalle_moviles %>%
  mutate(
    AÑO = AÑO - offset_anio,
    ANTIGUEDAD = 2021 - AÑO # Recalculamos para mantener coherencia
  )

# --- 5. ANONIMIZACIÓN DE VALORES NUMÉRICOS (Sin perder relevancia) ---
# Aplicamos un "ruido" aleatorio de +/- 3% a los montos y KM.
# Esto evita que se reconozcan facturas exactas pero mantiene las medias y tendencias.
set.seed(123) # Para que sea reproducible
anom_num <- function(x) { x * runif(length(x), 0.97, 1.03) }

gasto_movil <- gasto_movil %>%
  mutate(
    `GASTO NETO DE MANTENIENTO (SIN IVA)` = anom_num(`GASTO NETO DE MANTENIENTO (SIN IVA)`),
    `GASTO COMBUSTIBLE (Incluye IVA e Imp. Internos)` = anom_num(`GASTO COMBUSTIBLE (Incluye IVA e Imp. Internos)`),
    `KM Recorridos` = anom_num(`KM Recorridos`),
    # Para cantidades discretas (conteo), podemos sumar/restar 1 aleatoriamente
    `Cantidad de Ordenes de Mantenimiento` = pmax(0, `Cantidad de Ordenes de Mantenimiento` + sample(c(-1, 0, 1), n(), replace = T)),
    `Cantidad de cargas de combustible en el periodo` = pmax(0, `Cantidad de cargas de combustible en el periodo` + sample(c(-1, 0, 1), n(), replace = T))
  )

# --- 6. EXPORTAR ---
write_xlsx(list("Detalle Moviles" = detalle_moviles, "Gasto x Movil 2020-21" = gasto_movil), 
           "../data/dataset_flota_anonimizado.xlsx")
