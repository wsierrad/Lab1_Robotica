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
~~~
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
~~~


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

## Análisis de resultados

### Conexión de ROS con Matlab:
Se evidencia que MatLab es una herramienta muy potente y puede interacturar de forma integrada con ROS extrayendo y publicando informacion
lo cual sera muy util al momento de realizar control por medio de modelos diseñados en MatLab ya que nos permite vincular directamente nuestros
diseños en Matlab con la implementacion en ROS. Ademas es importante conocer como interactua ROS con otros sistemas y software para facilitar 
su uso, por esto la conexion con MatLab por medio de suscripciones, publicadores y servicios es una herramienta util a la hora de aprender ROS.   

Adicionalmente el uso de comandos de ROS desde la interfaz de Matlab es una ventaja para tener centralizada la informacion de los modelos, los 
publicadores y suscriptores son metodos interesantes ya que con unas pocas lineas de codigo se puede controlar la pose de la simulacion

## Conclusiones
