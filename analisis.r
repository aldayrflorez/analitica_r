library(ggplot2)
library(dplyr)
library(forcats)
library(nycflights13)
library(tidyr)

# ===============================================================
# Libreria ggplot
# ===============================================================

View(penguins)
datos_pinguinos <- penguins
glimpse(datos_pinguinos)
summary(datos_pinguinos)

# Paquete ggplot - Crear grafico
ggplot(
  data = datos_pinguinos,
  mapping = aes(x = flipper_len, y = body_mass)
) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Grafico",
    subtitle = "Peso del pinguino contra la longitud de sus aletas",
    x = "Peso de los pinguinos (g)",
    y = "Longitud de las aletas (mm)",
    color = "Tipo de especie"
  )

# Visualizar distribuciones - Categorias
ggplot(
  datos_pinguinos,
  aes(x = fct_infreq(species))
) +
  geom_bar() +
  labs(
    title = "Distribucion de especies",
    x = "Especies"
  )

ggplot(datos_pinguinos, aes(x = year)) + geom_bar()

# Visualizar distribuciones - Numericas
ggplot(datos_pinguinos, aes(x = body_mass)) +
  geom_histogram(binwidth = 300) # Longitud o ancho de los intervalos de la grafica

ggplot(datos_pinguinos, aes(x = body_mass, color = species)) + geom_density() # Muestra la simetria de los datos

ggplot(datos_pinguinos, aes(x = species, y = body_mass)) + geom_boxplot() # Muestra datos atipicos (Se salen de lo normal)

# Visualizar distribuciones - 2 variables categoricas
ggplot(datos_pinguinos, aes(x = island, fill = species)) +
  geom_bar(
    position = "fill"
  )

# Visualizar datos en distintos graficos
ggplot(datos_pinguinos, aes(x = flipper_len, y = body_mass)) +
  geom_point(aes(color = species)) +
  facet_wrap(~island) +
  labs(
    title = "Grafico",
    subtitle = "Peso del pinguino contra la longitud de sus aletas",
    x = "Peso de los pinguinos (g)",
    y = "Longitud de las aletas (mm)",
    color = "Tipo de especie"
  )

# ===============================================================
# Libreria dplyr
# ===============================================================

""
"
year: Año.
month: Mes.
day: Dia.
dep_time: Hora de salida. (formato HHMM).
arr_time: Hora de llegada. (formato HHMM).
sched_dep_time: Hora de salida programada.
dep_delay: Retraso en salida/llegada (en minutos).
arr_delay: Retraso en llegada (en minutos)
carrier: Código de la aerolínea.
flight: Número de vuelo.
tailnum: Matrícula del avión.
origin: Aeropuerto de origen.
dest: Aeropuerto de destino.
air_time: Tiempo de vuelo en minutos.
distance: Distancia entre aeropuertos. 
"
""

# .by(c()) -> agrupa temporalmente los datos, solo funciona dentro de esta funcion y el dataset no queda agrupado despues
# na.rm = T -> omite datos nulos
# Tuberias = Pipelines
# Arrange() -> Ordenas por columna
# .keep_all = TRUE -> Mantiene todo el dataframe

flights <- flights # Asignar el dataset a una variable proxima a utilizar
glimpse(flights) # Resumen de columnas y los primeros datos
View(flights) # Ver dataset
str(flights) # Ver estructura del dataset
summary(flights) # Ver medidas basicas

# Promedio de vuelos hacia Miami con retraso de 2 horas
promedio_vuelos <-
  flights |>
  filter(dest == "MIA" & arr_delay > 120) |>
  summarise(
    tiempo_promedio_vuelo = mean(arr_delay, na.rm = T),
    .by = c(year, month, day, arr_delay)
  )
View(promedio_vuelos)

# Vuelos en los meses de enero a mayo
vuelos_meses_1_5 <-
  flights |>
  filter(month %in% c(1, 5), dest == "MIA", carrier == "UA") |>
  arrange(dest) |>
  select(origin, dest, carrier)

# Vuelos con retraso mayor a 2 horas
retraso_mayor_2_horas <-
  flights |>
  filter(arr_delay > -2)

# Vuelos a Houston
vuelo_houston <-
  flights |>
  filter(origin == "IAH")

# Vuelos que salieron a tiempo, pero llegaron mas de 2h tarde
retraso_llegada <-
  flights |>
  filter(dep_delay >= 0 & arr_delay <= -2)

# Ordenar filas, por defecto ordena de mayor a menor desc() -> Ordena de menor a mayor
ordenar_origen <-
  flights |>
  arrange(desc(origin))

# distinct() -> Filas unicas del conjunto de datos
destinos_unicos <-
  flights |>
  distinct(origin, .keep_all = TRUE) |> 
  arrange(origin)

  flights |>
  distinct(origin, dest, .keep_all = TRUE) |> 
  arrange(month, dest)

# Total de aviones con destino a MIA entre las 8-10am
flights |>
  filter(dest == "MIA" & month == c(1, 5) & hour == c(8, 10)) |>
  summarise(vuelos = sum(flight), .by = (tailnum)) |>
  rename(placas = tailnum)

# Total de vuelos en cada mes
flights |> 
  filter(origin == "LGA") |> 
  summarise(total_vuelos = sum(flight), .by = (month)) |> 
  arrange(month)

# Count
flights |> 
  count(origin, dest, sort = T)

# Mutate - Agrega columnas calculadas al dataframe
# .before - Donde queremos ver las columnas que se calculan
flights |> 
  mutate(
    recuperacion_vuelo = dep_delay - arr_delay,
    velocidad_vuelo = (distance * 1.60934) / (air_time / 60),
    .before = 1,
  ) 

# starts_with selecciona todas los nombres de las columnas que coincidan con el prefijo dep
flights |> 
  select(starts_with("dep"))

# Selecciona un rango de columnas inicio:fin
flights |> 
  select(dep_time:carrier)

# any_of(c("a","b")) me trae las variables del dataframe, cuando no existe una no lanza error
flights |> 
  select(any_of(c("dep_delay", "arr_delay", "vinotinto")))

# Recolocate = Cambio de posicion de columnas ".after" - ".before" antes o despues de las columnas mencionadas
# Toma las columnas con iniciales arr y las ubica antes de dep_delay
flights |> 
  relocate(starts_with("arr"), .before = dep_delay)

flights |> 
  group_by(month) |> 
  summarise(
    Promedio_vuelo = mean(dep_delay, na.rm = T)
  )

# Conteo de vuelo (Cuenta las filas)
flights |> 
  group_by(carrier) |> 
  summarise(
    Media_vuelos = mean(flight),
    Cantidad_vuelos = n()
  ) |> 
  arrange(desc(Cantidad_vuelos))
  
# Slice = Cortan el conjunto de datos con base a los parametros

flights |> 
  group_by(dest) |> 
  slice_min(arr_delay, n = 10) |> 
  relocate(dest, arr_delay) 

# .by para agrupar
flights |> 
  summarise(
    avg_vuelos = mean(flight),
    n = n(),
    .by = c(origin,dest)
  )

# Organizar columnas, limpiar datos - pivot 

View(billboard)
glimpse(billboard)
billboard <- billboard

billboard_rank <- 
  billboard |> 
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    values_to = "ranking",
    values_drop_na = T
  )

billboard_rank |> 
  group_by(week) |> 
  summarise(
    promedio_ranking = mean(ranking)
  ) 
