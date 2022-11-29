# Algoritmo_Seminario-II_Matlab-Version

Algoritmo desarrollado para la evaluacion de calidad de imagen de retina.


## Estructura de archivos:
1. getfilters.m: Archivo con la función get filter, esta funcion recibe 3 parametros getFilters(r, Nx, Ny )
    - **Parámetros de entrada:**
      - r  : Número entero que representa el **radio** del circulo a dibujar.
      - Nx : Ancho de una imagen.
      - Ny : Alto de la imagen.  
    - **Parámetros de salida:**
      - cL  : Circulo con la parte dentro de la circunferencia = 1 y la parte de afuera en = 0. 
      - cH  : Circulo con la parte exterior de la circunferencia = 1 y la parte interior en = 1.
2. test_param_gaus.m:
      - **Parámetros de entrada:**
        - img  : Matriz(M,N) que representa una imagen en algún canal de color.
       
    - **Parámetros de salida:**
      - cL  : Circulo con la parte interior de la circunferencia = 1 y la parte exterior en = 0. 
      - cH  : Circulo con la parte exterior de la circunferencia = 1 y la parte interior en = 1.
              
3. algoritmo.m: Algoritmo con las diferentes etapas de procesamiento descritas en el documento.
