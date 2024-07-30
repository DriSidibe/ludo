import math
from pynput import mouse

# Variable globale pour stocker les positions des points A et B
pointA = None
pointB = None

# Fonction pour calculer la distance euclidienne entre deux points
def distance(pointA, pointB):
    return math.sqrt((pointA[0] - pointB[0]) ** 2 + (pointA[1] - pointB[1]) ** 2)

def on_clickA(x, y, button, pressed):
    global pointA
    if pressed:
        pointA = (x, y)
        print(f"Point A: {pointA}")
        # Arrêter l'écoute après le premier clic
        return False

def on_clickB(x, y, button, pressed):
    global pointB
    if pressed:
        pointB = (x, y)
        print(f"Point B: {pointB}")
        print(f"La distance entre le point A et le point B est de {distance(pointA, pointB):.2f} pixels.")
        # Arrêter l'écoute après le deuxième clic
        return False

print("Cliquez sur le point A")

# Écouter le premier clic
with mouse.Listener(on_click=on_clickA) as listener:
    listener.join()

print("Cliquez sur le point B")

# Écouter le deuxième clic
with mouse.Listener(on_click=on_clickB) as listener:
    listener.join()
