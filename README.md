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
7. Cantidad de autores cuando hay mujeres entre les autores
8. Qué autores influencian/son influenciades por hombres vs mujeres? https://www.semanticscholar.org/author/Oren-Etzioni/1741101
9. Uso de palabras clave en el título por género
10. Quedan clusterizadas las palabras clave x género? 
11. Tiempo de actividad, año de primera publicación? -> Puede no ser tan preciso
12. Cruzar datos con egresos/padrón de universidades para ver si la academia es mas dispar todavía
    * http://www.fi.uba.ar/sites/default/files/Padr%C3%B3n%20Graduados%202019%20%28DEFINITIVO%29.pdf (graduades fiuba)
    * http://www.fi.uba.ar/sites/default/files/PADRON%20COMPLETO%20-%20EXTERIOR%20%281%29_0.pdf (padrón fiuba)
    * Buscar números en Argentina 
    * https://www.argentina.gob.ar/sites/default/files/presentacion_diagnostico_mujeres_en_ciencia_y_tecnologia_14-9-2018_meccyt.pdf
13. Participación x género en papers que unen computer science con otro campo de estudio

### Idea de proceso preliminar
#### 1. Bajar papers de computer science
  * Fuente: semantic scholar
  * **Elegir queries relevantes**
            **Lista KWs 2010-2020:**
            computer 1,890,000
            algorithm : 2,500,000 results
            model: 3,270,000
            cpu: 382,000
            architecture: 1,100,000
            performance: 2,560,000
            machine learning: 716,000
            blockchain: 18,400 (había mil papers de esto antes del 2010 :o)
            Technology: 2,160,000
            systems: 3,730,000
            network: 2,190,000
            novel: 1,090,000
            approach: 2,900,000
            IOT: 134,000
  * **Revisar BIEN qué otros campos podemos usar**
    * citation velocity: cantidad de veces promedio que fue citado x año
    * referencias: cuántas referencias hizo ese paper
    * "numCitations": 794,
    * "estNumCitations": 429.72803282114995,
    * "numReferences": 4,
    * "numKeyCitations": 119,
    * "numKeyReferences": 0,
    * "numViewableReferences": 4,
    * "keyCitationRate": 0.14987405541561713,
    * "citationVelocity": 80.33333333333333,
    * "citationAcceleration": -0.31521739130434784, -> cambio en las veces de citación
    * "fieldsOfStudy" -> Lista de campos de estudio
  * Años: 2010-2012, 2013-2015, 2016-2020
  * 6 mil por período
  * Ordenados por relevancia
  * Datos a bajar (a priori)
    * Nombre completo de todes les autores
    * Primer nombre de todes les autores
    * Título
    * Año
    * Universidad o establecimiento
    * Author ID
    * Paper ID
    
#### 2.a Datos del autor
 * Cantidad de papers publicando
 * En qué años?
  * Nos explotará la cantidad de papers? 
  * Será costoso conseguir los años de cada paper para cada autor?
  * Influencias del autor -> Propuesta preliminar
    * Agarrar a todas las autoras y ver sus influencias
    * Agarrar subset de autores hombres y ver sus influencias
    * **Es scrapeable?**
    * Hace falta entonces ver las referencas de cada paper teniendo esto?

#### 2.b Para cada paper, bajar las referencias
  * Cantidad de referencias
  * Nombres de les autores referenciades
  
#### 3. Genderizar
  * Usando librería gender_guesser de python
  * Desambiguación con APi genderize
  * Analizar cantidad de autores que no podemos genderizar
  * Decidir

#### 4. Analizar
  * Usando pandas?
  * Hacer gráficos
  * Usando SQL?
  * Clusterización: Eli tiene cosas hechas con tf-idf y clustering
