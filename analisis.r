"""
# Crear un dataset simple
datos <- data.frame(
  nombre = c("Ana", "Luis", "Carlos", "Marta"),
  edad = c(23, 30, 28, 35),
  salario = c(1200, 1500, 1400, 2500)
)

# Ver los datos
print(datos)

# Resumen estadístico
summary(datos)

# Promedio de salarios
promedio_salario <- mean(datos$salario)
print(paste("Promedio salario:", promedio_salario))

# Gráfico sencillo
plot(
  datos$edad,
  datos$salario,
  main = "Edad vs Salario",
  xlab = "Edad",
  ylab = "Salario",
  col = "blue",
  pch = 19
)
"""
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

# Visualizar distribuciones
ggplot(
  datos_pinguinos, 
  aes(x = fct_infreq(species))
) +
  geom_bar() +
  labs(
    title = "Distribucion de especies",
    x = "Especies"
  )



