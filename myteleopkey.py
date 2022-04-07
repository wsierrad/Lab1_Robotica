#!/usr/bin/env python

#Se importa el cliente de Python para ROS, el mensaje twist, los servicios
#TeleportAbsolute y #TeleportRelative y lo necesario para detectar las teclas.
import rospy
from geometry_msgs.msg import Twist
from turtlesim.srv import TeleportAbsolute, TeleportRelative
import termios, os, sys
TERMIOS = termios
#Se hace uso del código brindado para la detección de las teclas oprimidas
def getkey():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    new = termios.tcgetattr(fd)
    new[3] = new[3] & ~TERMIOS.ICANON & ~TERMIOS.ECHO
    new[6][TERMIOS.VMIN] = 1
    new[6][TERMIOS.VTIME] = 0
    termios.tcsetattr(fd, TERMIOS.TCSANOW, new)
    c = None
    try:
        c = os.read(fd, 1)
    finally:
        termios.tcsetattr(fd, TERMIOS.TCSAFLUSH, old)
    return c
#Se define una función pubVel, y se publica a este un mensaje del tipo Twist
# al tópico cmd_vel, para lograr el movimiento.
#Los valores de velocidad y rotaciòn de la tortuga, le son publicados 
# mediante esta función, ademàs de un valor de tiempo que durarà la instrucción.
def pubVel(vel_x,ang_z, t):

    rospy.init_node('velPub', anonymous=True)
    pub = rospy.Publisher('/turtle1/cmd_vel', Twist, queue_size=10)
    rate = rospy.Rate(10) # 10hz
 
    vel = Twist()
    vel.linear.x = vel_x
    vel.angular.z = ang_z
    endTime = rospy.Time.now() + rospy.Duration(t)
    while rospy.Time.now() < endTime:
        pub.publish(vel)
#Se define una función pubPos, que haciendo uso del servicio TeleportAbsolute
# recibe los parámetros para transportar la tortuga a un punto indicado.
def pubPos(x,y,theta):
    rospy.wait_for_service('/turtle1/teleport_absolute')
    try:
        telA=rospy.ServiceProxy('/turtle1/teleport_absolute', TeleportAbsolute)
        resp=telA(x,y,theta)

    except rospy.ServiceException:
        pass

#Se define una función pubPosRel, que haciendo uso del servicio TeleportRelative
# recibe los parámetros para transportar la tortuga a un punto indicado, partiendo
# de su posición actual.
def pubPosRel(x,theta):
    rospy.wait_for_service('/turtle1/teleport_relative')
    try:
        telR=rospy.ServiceProxy('/turtle1/teleport_relative', TeleportRelative)
        rel=telR(x,theta)
    except rospy.ServiceException:
        pass
#en el main, se crea un bucle,en el que se detecta la tecla presionada y se compara
# con cada valor deseado. Cada tecla tiene entonces asociada su función y 
# sus valores predeterminados.
if __name__ == '__main__':
    pubVel(0,0,0.1)
    try:
        while (1):
            key = getkey()
            if key == b'w':
                pubVel(1,0,0.1)    
            if key == b's':
                pubVel(-1,0,0.1)
            if key == b'a':
                pubVel(0,1,0.1)
            if key  == b'd':
                pubVel(0,-1,0.2)   
            if key ==b'r':
                pubPos(5.54445,5.54445,0)
            if key ==b' ':
                pubPosRel(0,3.1415)
        
    except rospy.ROSInterruptException:
        pass
