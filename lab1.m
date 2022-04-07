%% Conexión con nodo maestro
% Inicia la conexión con el nodo maestro por default en localhost por el puerto 11311. 
rosinit;
%% Configuracion de publicador
% Creación del publicador, se define el nombre del topico y el tipo de mensaje
velPub = rospublisher('/turtle1/cmd_vel','geometry_msgs/Twist');
% Creación de mensaje para su publicación
velMsg = rosmessage(velPub); 
%% Modificacion y envio del mensaje
% Se asgina el valor de 1 a la propiedad velocidad Lineal en X
velMsg.Linear.X = 1; 
% Se envia el mensaje configurado
send(velPub,velMsg);
% Pausa de 1ms
pause(1)
%% ROSsuscriber
% Creación del suscriptor, se define el nombre del topico y el tipo de mensaje
poseSub = rossubscriber("/turtle1/pose","turtlesim/Pose");
% Pausa de 1ms mientras se recibe el primer mensaje
pause(1)
% Se toma el ultimo mensaje publicado por el topico
scanMsg = poseSub.LatestMessage
%% ROS update pose
% ROS posicion y angulo
% Creación del cliente que consume el servicio
posePub = rossvcclient("/turtle1/teleport_absolute");
% Creación de mensaje
poseMsg = rosmessage(posePub);
% Espera la conexion al servicio
waitForServer(posePub,"Timeout",3)
% Define los valores de posicion de la tortuga
poseMsg.X = 4; %Valor del mensaje
poseMsg.Y = 3; %Valor del mensaje
poseMsg.Theta = pi/6; %Valor del mensaje
% Invoca al servicio y envia el mensaje
posicion = call(posePub,poseMsg,"Timeout",3);
% ROS velocidad lineal y angular
% Creación publicador para el topico /turtle1/cmd_vel
velPub = rospublisher('/turtle1/cmd_vel','geometry_msgs/Twist'); 
% Creación del mensaje
velMsg = rosmessage(velPub);
% Se asgina el valores a las propiedades velocidad lineal en X y velocidad
% angular en Z
velMsg.Linear.X = 3; %Valor del mensaje
velMsg.Angular.Z = 2; %Valor del mensaje
% Se envia el mensaje
send(velPub,velMsg); %Envio
%% Disconnet from ROS
rosshutdown