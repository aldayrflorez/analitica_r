library(ggplot2)
library(dplyr)
library(forcats)
library(nycflights13)

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
# Arrange() = Ordenas por columna

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

# Ordenar filas, por defecto ordena de mayor a menor desc() -> Ordena de mayor a menor
ordenar_origen <-
  flights |>
  arrange(desc(origin))

# distinct() -> Filas unicas del conjunto de datos

destinos_unicos <-
  flights |>
  distinct(dest)

# Total de aviones con destino a MIA entre las 8-10am
flights |>
  filter(dest == "MIA" & month == c(1, 5) & hour == c(8, 10)) |>
  summarise(vuelos = sum(flight), .by = (tailnum)) |>
  rename(placas = tailnum)
