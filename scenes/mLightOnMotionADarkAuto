/** 
* @name Свет по датчику движения АВТО с учетом аналоговой освещенности  
* @desc Включает светильник по датчику движения, отключает при отсутствии движения в течение заданного времени  
*   Учитывает аналоговый датчик освещенности при включении (опционально)
*/


const lamp = Device("ActorD", "Светильник", [
  {"name":"timeOff", "note":"Светильник горит без движения, сек", "type":"number", "val":300},
  {"name":"takeDarkness", "note":"Учитывать освещенность", "type":"cb", "val":0},
  {"name":"levelDarkness", "note":"Порог освещенности", "type":"number", "val":5}
]); 
  
const motion = Device("SensorD", "Датчик движения");  
const lightSensor = Device("SensorA", "Датчик аналоговой освещенности");  

const script = {
  
    // Запустим сценарий, ЕСЛИ
    // флаг светильника Авто установлен 
    // и светильник не горит 
    // и есть движение - тогда включим лампу 
    // или светильник горит (чтобы выключить, так как режим Авто)
    //
  
    check() {
      return ((lamp.auto==1) && ((lamp.dval==0) && (motion.dval==1) && (!lamp.takeDarkness || (lightSensor.aval < lamp.levelDarkness)) || (lamp.dval==1)));  
    },
    
    start() {
         this.addTimer("T1"); // Таймер нужно объявить, т к он участвует в функции onMotion
        
        if ((lamp.dval==0) && (motion.dval>0)) {
          // Cветильник не горит, движение есть  
          this.do(lamp, "aon");
        } else {
          // движения нет - взводим таймер, чтобы отключить 
          this.startTimer("T1", lamp.timeOff, "turnOff");       
        }
        // В любом случае следим за датчиком движения и светильником
        this.addListener(motion, "onMotion");
        this.addListener(lamp, "onLamp");
    },
  
  
    onMotion() {
       // Если движение прекратилось - взводим таймер
      if (motion.dval==0 && this.timer.T1 == "off")  {
        this.startTimer("T1", lamp.timeOff, "turnOff");
      }  
        
       // Если движение возобновилось - сбрасываем таймер
      if (motion.dval==1 && this.timer.T1 == 'on')  {
        this.stopTimer('T1');
      }  
    },
    
     onLamp() {
      // Светильник выключили другим способом или сбросили флаг Авто - выходим
       if (lamp.dval==0 || lamp.auto==0) this.exit();
     },
     
    // Функция, которая сработает, когда таймер досчитает (нет движения в течение заданного времени) - отключаем и выходим
    turnOff() {
      this.do(lamp, "aoff");
      this.exit();
    }
};
