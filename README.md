# Lab1_Robotica
## Integrantes:

Brian Alejandro Vásquez González  
William Arturo Sierra Díaz  

## Metodología
Para el desarrollo de este laboratorio se hizo uso de Matlab 2021b en Windows, WSL version 1 para la ejeccucion de ROS y XServer para presentar la GUI de Ubuntu.
Posteriormente para el ejercicio en python se uso una instalacion nativa de Ubuntu 20.04.   

### Conexión de ROS con Matlab:

La primera parte del taller, se desarrollo en un script de MatLab clasico (.m) lo primero fue realizar la conexion con ROS por medio de `rosinit`
como no le pasamos ningun argumento a este comando, este toma por defecto los valores de localhost por el puerto 11311 para intentar conectarse a ROS  
Cuando ya estemos conectados a ROS se configura el primer publicador hacia el topico `/turtle1/cmd_vel` esto se hace por medio del comando
`rospublisher` que recibe como argumentos el nombre del topico y el tipo de mensaje. Con el publicador ya configurado se procede a crear el 
mensaje y asignar los valores deseados de la siguiente forma:
~~~
% Creacion del mensaje
velMsg = rosmessage(velPub); 
% Se asgina el valor de 1 a la propiedad velocidad Lineal en X
velMsg.Linear.X = 1; 
~~~
Para enviar el mensaje se usa el comando `send` que recibe como argumentos el publicador y el mensaje a enviar.  
Respecto al suscriptor se configura de forma similar al publicador, pero el comando para este es `rossubscriber`
el cual recibe tambien el nombre del topico que para este caso es `/turtle1/pose` y el tipo de mensaje `turtlesim/Pose`.  
Ahora se usa un servicio en este caso `/turtle1/teleport_absolute` el cual permite situar a la tortuga en una posicion 
especifica con un angulo dado, para usar este servicio se declara de la siguiente forma:
~~~
% Creación del cliente que consume el servicio
posePub = rossvcclient("/turtle1/teleport_absolute");
% Creación de mensaje
poseMsg = rosmessage(posePub);
% Espera la conexion al servicio
waitForServer(posePub,"Timeout",3)
~~~
Despues se procede a configurar los valores del la posicion X, Y y el angulo theta para luego invocar al servicio por medio del comando `call`
~~~
% Define los valores de posicion de la tortuga
poseMsg.X = 4; %Valor del mensaje
poseMsg.Y = 3; %Valor del mensaje
poseMsg.Theta = pi/6; %Valor del mensaje
% Invoca al servicio y envia el mensaje
posicion = call(posePub,poseMsg,"Timeout",3);
~~~
Por ultimo se realiza la publicacion de valores de la velocidad lineal y angular por medio del publicador de `/turtle1/cmd_vel`  
Asi se puede terminar la ejeccucion del nodo que conecta Matlab con ROS por medio de `rosshutdown`

### ROS usando scripts en python

El punto c) del laboratorio pedìa crear dentro del paquete `hello_turtle` de ROS un script de Python que permitiera operar una tortuga del paquete `turtlesim`con el teclado, siguiendo estas especificaciones:
+ Movimiento hacia delante y hacia atrás con las teclas **W** y **S**
+ Giro en sentido horario y antihorario con la teclas **D** y **A**
+ Retorno a su posición y orientación centrales con la tecla **R**
+ Debe dar un giro de 180º con la tecla **ESPACIO**

En primer lugar, se crea un script llamado `myteleopkey.pi`en el que se importa cliente de Python para ROS, el mensaje twist, los servicios `TeleportAbsolute` y `TeleportRelative`, ademàs del modulo `termios` necesario para la detección de teclas mediante la función `getkey()`.

Debido a dificultades con la líbreria `keyboard` de Python, se recomendó el uso de un código con la función `getkey()` para la detección de las teclas.

Se definió una función pubVel para realizar los movimientos hacia adelante y atrás, como las rotaciones en cada uno de los sentidos.
```python
#función pubvel
def pubVel(vel_x,ang_z, t):
    rospy.init_node('velPub', anonymous=True) #inicializa el nodo velPub
    pub = rospy.Publisher('/turtle1/cmd_vel', Twist, queue_size=10) #se le va a publicar al tópico cmd_vel un mensaje de tipo Twist
    vel = Twist() # se asigna el mensaje tipo Twist
    vel.linear.x = vel_x # se asigna velocidad en x
    vel.angular.z = ang_z #se asigna el valor a rotar alrededor de z. 
    endTime = rospy.Time.now() + rospy.Duration(t) #se establece un tiempo de finalización, con base a una variable t definida en la función
    while rospy.Time.now() < endTime: #bucle mientras el tiempo sea menor que el endTime
        pub.publish(vel) # se publica el mensaje.
```
De manera similar se definió una función `pubPos' para realizar el movimiento de la tortuga a su posición inicial, en este se hace uso del servicio 'TeleportAbsolute'

```python
#función pubPos
def pubPos(x,y,theta):
    rospy.wait_for_service('/turtle1/teleport_absolute') # se espera a que el servicio esté disponible
    try:
        telA=rospy.ServiceProxy('/turtle1/teleport_absolute', TeleportAbsolute) # se llama el servicio de tipo TeleportAbsolute
        resp=telA(x,y,theta) # se guarda el resultado.
    except rospy.ServiceException:
        pass
```

La ùltima función implementada, se utiliza para que la tortuga tenga movimiento con respecto a su posición actual, y en este caso para que gire 180º en cualquier posición.
```python
def pubPosRel(x,theta):
    rospy.wait_for_service('/turtle1/teleport_relative') # se espera a que el servicio esté disponible
    try:
        telR=rospy.ServiceProxy('/turtle1/teleport_relative', TeleportRelative) # se llama el servicio de tipo TeleportRelative
        rel=telR(x,theta) # se guarda el resultado.
    except rospy.ServiceException:
        pass
```
Finalmente, en el `main` del programa se le asigna a cada tecla su funciòn, con sus respectivos valores.
```python
if __name__ == '__main__':
    pubVel(0,0,0.1)
    try:
        while (1):
            key = getkey() #se llama la función getkey() y se obtiene la tecla pulsada
            if key == b'w': 
                pubVel(1,0,0.1) #si se pulsa w, se avanza    
            if key == b's':
                pubVel(-1,0,0.1) #si se pulsa s, se retrocede
            if key == b'a':
                pubVel(0,1,0.1) # si se pulsa a, se gira en sentido antihorario
            if key  == b'd':
                pubVel(0,-1,0.1) # si se pulsa d, se gira ne sentido horario   
            if key ==b'r':
                pubPos(5.54445,5.54445,0) #si se pulsa r, se vuelve al punto de inicio
            if key ==b' ':
                pubPosRel(0,3.1415) #si se pulsa ESPACIO, se gira 180º
        
    except rospy.ROSInterruptException:
        pass
```
Así, queda el script finalizado

## Resultados

### Conexión de ROS con Matlab:

Por medio de la conexion a ROS y el primer publicador a `/turtle1/cmd_vel` se obtiene el siguiente resultado, en el cual la 
tortuga avanza en direccion X positiva pese a que la velocidad asignada es positiva y solo tiene componente en X    
[![ROS-MATLAB.png](https://i.postimg.cc/c48pQqLD/ROS-MATLAB.png)](https://postimg.cc/cr0kSbYY)  
Posteriormente se tiene que por medio del comando rossubscriber se obtiene todos los datos de la pose de la 
tortuga teniendo asi su posicion completa en X, Y, theta y su velocidad lineal y angular, como se ve en la imagen
[![ROS-MATLAB1.png](https://i.postimg.cc/5tbdnhd1/ROS-MATLAB1.png)](https://postimg.cc/yDQbNr8r)
Por utlimo podemos modificar en su totalidad la pose de la torturga usando el servicio `/turtle1/teleport_absolute` y el topico
`/turtle1/cmd_vel` obteniendo el resultado que se ve en la siguiente imagen
[![ROS-MATLAB2.png](https://i.postimg.cc/3rp1xd0S/ROS-MATLAB2.png)](https://postimg.cc/xqfMsjRM)

### ROS usando scripts en python
Para probar el script, se seguirán los siguientes pasos.
+ Lo primero es incluir el script dentro del archivo `CMakeLists.txt`, siguiendo la misma estructura de los otros scripts, como sigue:
~~~
catkin_install_python(PROGRAMS
  scripts/turtlePos.py
  scripts/turtleSpawn.py
  scripts/turtleSub.py
  scripts/turtleVel.py
  scripts/myteleopkey.py #se añade el script diseñado.
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
~~~
Tras esto se lanza una terminal, y se inicializa el nodo maestro.
~~~
roscore
~~~
En una segunda terminal, se inicía una tortuga.
~~~
rosrun turtlesim turtlesim_node
~~~
Finalmente en una tercera terminal.
~~~
cd catkin_ws/
source devel/setup.bash
rosrun hello_turtle myteleopkey.py
~~~
Asì, obtenemos una instancia de la tortuga, en la que por ejemplo, podemos dibujar una linea recta, y volver a la posición inicial.

[![ROS-Python.png](https://i.postimg.cc/85FT4dYg/ROS-Python.png)](https://postimg.cc/Vr8yLt1K)

Para mostrar el uso de todo el teclado, se dibujará una figura con avances y rotaciones, se girarà en 180º y se volverá a la posición inicial.

[![Ros-Python2.png](https://i.postimg.cc/Xv1V91Qg/Ros-Python2.png)](https://postimg.cc/sBSdrmFB)

## Análisis de resultados

### Conexión de ROS con Matlab:
Se evidencia que MatLab es una herramienta muy potente y puede interacturar de forma integrada con ROS extrayendo y publicando informacion
lo cual sera muy util al momento de realizar control por medio de modelos diseñados en MatLab ya que nos permite vincular directamente nuestros
diseños en Matlab con la implementacion en ROS. Ademas es importante conocer como interactua ROS con otros sistemas y software para facilitar 
su uso, por esto la conexion con MatLab por medio de suscripciones, publicadores y servicios es una herramienta util a la hora de aprender ROS.   

Adicionalmente el uso de comandos de ROS desde la interfaz de Matlab es una ventaja para tener centralizada la informacion de los modelos, los 
publicadores y suscriptores son metodos interesantes ya que con unas pocas lineas de codigo se puede controlar la pose de la simulacion

### ROS usando scripts en python
Podemos obser var que utilizando Pytho, se logra una excelente ingraciòn con ros, y ademàs sin ncesidad de instalar ningún software adicional, siendo que Python ya viene con nuestra instalación de Linux.

Se pueden utilizar distintos scripts con distintas funcionalidad, y asì poder manejar la tortuga casi que al antojo del usuario. Ademàs, gracias a la cantidad de lirerias de Python, y a su sintaxis, es amigable para el usuario.

Desde el script diseñado, se puede cambiar la configuraciòn para mover la tortuga con las teclas que desee el usuario, de la misma manera, se pueden realizar giros relativos en cualquier número de grados que se desee, e igualmente ir a cualquier posición absoluta predeterminada.

En este ejercicio tambien se puede modificar la velocidad con la que se realiza cada instrucción, utilizando el parámetro de tiempo de las funcion `PubVel`, así, como decidir cuanto avanza y rota la tortuga, cada vez que se presiona una tecla.

## Conclusiones
