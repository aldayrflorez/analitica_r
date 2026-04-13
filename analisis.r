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
