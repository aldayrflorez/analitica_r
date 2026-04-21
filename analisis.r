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

# Tuberias = Pipelines

View(flights) # Ver dataset
str(flights) # Ver estructura

"""
year, month, day: Año, mes, día.
dep_time, arr_time: Hora de salida y llegada (formato HHMM).
sched_dep_time: Hora de salida programada.
dep_delay, arr_delay: Retraso en salida/llegada (en minutos).
carrier: Código de la aerolínea.
flight: Número de vuelo.
tailnum: Matrícula del avión.
origin, dest: Aeropuerto de origen y destino.
air_time: Tiempo de vuelo en minutos.
distance: Distancia entre aeropuertos. 
"""

flights <- flights
glimpse(flights)
summary(flights)

promedio_vuelos <- 
  flights |> 
  filter(dest == "MIA" & arr_delay > 120) |> 
  summarise(tiempo_promedio_vuelo = mean(arr_delay, na.rm = T), .by = c(year,month,day, arr_delay))
View(promedio_vuelos)

vuelos_meses_1_5 <-
  flights |> 
  filter(month %in% c(1,5), dest == "MIA", carrier =="UA") |> 
  arrange(dest) |> 
  select(origin, dest, carrier)

# .by agrupa temporalmente los datos, solo funciona dentro de esta funcion y el dataset no queda agrupado despues
# na.rm = omite datos nulos

