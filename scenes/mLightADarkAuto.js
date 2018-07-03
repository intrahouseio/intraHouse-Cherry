/** 
* @name Свет АВТО по освещенности (аналоговый датчик) 
* @desc Включает и выключает светильник по датчику аналоговой освещенности 
*/

const lamp = Device("ActorD", "Светильник", [
  {"name":"levelDarkOn", "note":"Порог освещенности для вкл", "type":"number", "val":5},
  {"name":"levelDarkOff", "note":"Порог освещенности для выкл", "type":"number", "val":10}
]); 
  

const lightSensor = Device("SensorA", "Датчик освещенности аналоговый");  

const script = {
  
    check() {
      return ((lamp.auto==1) && ((lamp.dval==0) && (lightSensor.aval <= lamp.levelDarkOn) || (lamp.dval==1) && (lightSensor.aval >= lamp.levelDarkOff)));  
    },
    
    start() {
        
        if (lamp.dval==0) {
          this.do(lamp, "aon");
        } else {
          this.do(lamp, "aoff");  
        }
    }
};
