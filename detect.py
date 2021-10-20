import cv2
import numpy as np

LABELS = ['Pomeranian',
'Bichon_frise',
'Maltese',
'Welsh_corgi',
'Poodle',
'Border_collie',
'Dachshund',
'Chihuahua',
'French_bulldog',
'Shih_tzu',
'Siberian_husky',
'Jindo']
CONFIDENCE = 0.3
THRESHOLD = 0.3  #NMS(Num Max Suppression)

net = cv2.dnn.readNetFromDarknet('yolov4.cfg','yolov4.weights')

def main(img_path):
    img = cv2.imread(img_path)
    H, W, _ = img.shape
    blob = cv2.dnn.blobFromImage(img, scalefactor=1/255., size=(640, 640), swapRB=True)
    net.setInput(blob)
    output = net.forward()
  
    boxes, confidences, class_ids = [], [], []
  
    for det in output: #output [:4]:x,y,w,h, [5:]:score
        box = det[:4]
        scores = det[5:]
        class_id = np.argmax(scores)
        confidence = scores[class_id]
    
        if confidence > CONFIDENCE:
            cx, cy, w, h = box * np.array([W, H, W, H])
            x = cx - (w / 2)
            y = cy - (h / 2)

            boxes.append([int(x), int(y), int(w), int(h)])
            confidences.append(float(confidence))
            class_ids.append(class_id)
    
    #Num Max Suppression
    idxs = cv2.dnn.NMSBoxes(boxes, confidences, CONFIDENCE, THRESHOLD)
    
    if len(idxs) > 0:
        for i in idxs.flatten():
            x, y, w, h = boxes[i]
            cv2.rectangle(img, pt1=(x, y), pt2=(x + w, y + h), color=(0, 0, 255), thickness=2)
            cv2.putText(img, text='%s %.2f' % (LABELS[class_ids[i]], confidences[i]), org=(x+2, y+22), fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=0.8, color=(0, 0, 255), thickness=2)

    cv2.imwrite('detection1.png', img)
