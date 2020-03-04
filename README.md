# 8m-7p

## Idea general

Analizar participación de mujeres en papers de computer science.

### Cosas a analizar
1. Qué participación tienen las mujeres en general?
2. En qué posiciones suelen aparecer en el orden de autores?
3. Qué tanto son referenciados los papers de autores mujeres?
4. Qué tanto se referencian las mujeres entre sí?
5. Universidades más diversas?
6. Cantidad de papers promedio publicados por mujeres vs por hombres x año/período

### Idea de proceso preliminar
#### 1. Bajar papers de computer science
  * Fuente: semantic scholar
  * **Elegir queries relevantes** -> Tarea a definir
  * **Revisar BIEN qué otros campos podemos usar**
   * citations
   * relevance
   * ratios
  * Años: 2010-2012, 2013-2015, 2016-2020
  * 6 mil por período
  * Ordenados por relevancia
  * Límite de papers por año eventualmente
  * Datos a bajar (a priori)
    * Nombre completo de todes les autores
    * Primer nombre de todes les autores
    * Título
    * Año
    * Universidad o establecimiento
    * Author ID
    
#### 2. Para cada paper, bajar las referencias
  * Cantidad de referencias
  * Nombres de les autores referenciades

#### 2.b Datos del autor
 * Cantidad de papers publicando
 * En qué años?
  * Nos explotará la cantidad de papers? 
  * Será costoso conseguir los años de cada paper para cada autor?
  
#### 3. Genderizar
  * Usando librería gender_guesser de python
  * Desambiguación con APi genderize
  * Analizar cantidad de autores que no podemos genderizar
  * Decidir
  
#### 4. Analizar
  * Usando pandas?
  * Hacer gráficos
  * Usando SQL?
