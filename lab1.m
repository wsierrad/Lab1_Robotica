%%
rosinit;
%Conexión con nodo maestro
%%
velPub = rospublisher('/turtle1/cmd_vel','geometry_msgs/Twist'); %Creación publicador
velMsg = rosmessage(velPub); %Creación de mensaje
%%
velMsg.Linear.X = 1; %Valor del mensaje
send(velPub,velMsg); %Envio
pause(1)
%% rossuscriber
poseSub = rossubscriber("/turtle1/pose","turtlesim/Pose");
scanMsg = poseSub.LatestMessage
%% ros update pose
% Ros position and angle
posePub = rossvcclient("/turtle1/teleport_absolute"); %rospublisher('/turtle1/pose','turtlesim/Pose'); %Creación publicador
poseMsg = rosmessage(posePub); %Creación de mensaje
waitForServer(posePub,"Timeout",3)
poseMsg.X = 2; %Valor del mensaje
poseMsg.Y = 2; %Valor del mensaje
poseMsg.Theta = 1.57; %Valor del mensaje
testresp = call(posePub,poseMsg,"Timeout",3);
% ros linear and angular vel
velPub = rospublisher('/turtle1/cmd_vel','geometry_msgs/Twist'); %Creación publicador
velMsg = rosmessage(velPub);
velMsg.Linear.X = 1; %Valor del mensaje
velMsg.Angular.Z = 1; %Valor del mensaje
send(velPub,velMsg); %Envio